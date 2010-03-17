#!/usr/bin/perl -w
#!/usr/bin/perl -d:ptkdb -w
#


use strict;


package GENESIS3::Documentation;


package GENESIS3::Documentation::Document;


sub build
{
    my $self = shift;

    my $options = shift;

    my $directory = $self->{directory};

    if ($options->{verbose})
    {
	print "$0: entering $directory\n";
    }

    if (!chdir $directory)
    {
	die "$0: *** Error: cannot change to directory $directory";
    }


    # Load the descriptor for special parameters if present.

    my $descriptor = YAML::LoadFile('descriptor.yml');



    #
    # check for the obsolete tag first so we don't end up doing
    # any extra work.
    #
    if (tag_defined($descriptor,'obsolete'))
    {
      print "This document is obsolete, skipping.\n";

      if ($options->{verbose})
      {
	print "$0: leaving $directory\n";
      }

      chdir '..';
      return;
    }



    #
    # Here we check for the redirect attribute and perform actions as 
    # necessary.
    #
    if (defined $descriptor->{redirect})
    {
      create_http_redirect($directory, $descriptor->{redirect});
      chdir '..';
      return;
    }

    # Note: This tag handles special cases for pdf.
    # Should expand it to allow maybe a "filetype" attribute
    # to check for so that it can copy over other file types.
    if (tag_defined($descriptor,'pdf'))
    {
	file_copy($descriptor->{'document name'},'pdf');
#       print "\n\nThe document ";
#       print $descriptor->{'document name'};
#       print " is a pdf file, copying it over to the output directory\n\n";

#       system "mkdir -p output/ps";
#       system "mkdir -p output/pdf";
#       system "mkdir -p output/html";
#       system "cp *.pdf output/html";
#       system "cp *.pdf output/ps";
#       system "cp *.pdf output/pdf";

	chdir '..';
	return;
    }
    elsif (tag_defined($descriptor,'mp3'))
    {
	file_copy($descriptor->{'document name'},'mp3');
	chdir '..';
	return;
    }
    elsif (tag_defined($descriptor,'wav'))
    {
	file_copy($descriptor->{'document name'},'wav');
	chdir '..';
	return;
    }
    elsif (tag_defined($descriptor,'html'))
    {
	file_copy($descriptor->{'document name'},'html');
	chdir '..';
	return;
    }
    elsif (tag_defined($descriptor,'png'))
    {
	file_copy($descriptor->{'document name'},'png');
	chdir '..';
	return;
    }
    elsif (tag_defined($descriptor,'ps'))
    {
	file_copy($descriptor->{'document name'},'ps');
	chdir '..';
	return;
    }


    # if we find a makefile

    if (-f 'Makefile')
    {
	# that is what we use

	system "make build_document";
    }
    else
    {
	# find relevant source files

	my $filenames = $self->filenames();

	# loop over source files

	foreach my $filename (@$filenames)
	{
	    # for latex sources

	    if ($filename =~ /\.tex$/)
	    {
		chdir "output";

		# prepare output: general latex processing

		$filename =~ m((.*)\.tex$);

		# Remove references to self, as well as any empty itemize blocks
		# since the itemize blocks kill the cron job. After we remove
		# the references and resave the file.

		if ($filename =~ m/contents-level[1234567]/)
		{
		    # read latex source

		    use IO::File;

		    my $source_file = IO::File->new("<../$filename");

		    my $source_text = join "", <$source_file>;

		    $source_file->close();

		    my @name = split(/\./,$filename);

		    $source_text =~ s(\\item \\href\{\.\.\/$name[0]\/$name[0]\.\w+\}\{\\bf \\underline\{.*\}\})( )g;

		    # If we have nothing but whitespace in between the itemize tags, remove
		    # the whole line.
		    $source_text =~ s(\\begin\{itemize\}\s+\\end\{itemize\})( )g;


		    open(OUTPUT,">$filename");
		
		    print OUTPUT $source_text;
		    close(OUTPUT);
		}

		my $filename_base = get_relative_path($directory);

		if ($options->{parse_only} == 0)
		{
		    system "latex -halt-on-error '$filename'";

		    system "makeindex -c '$filename_base'";

		    system "bibtex '$filename_base'";

		    system "latex '$filename'";
		    system "latex '$filename'";
		}

		# generate ps output

		{
		    mkdir "ps";

		    if ($options->{verbose})
		    {
			print "$0: entering ps\n";
		    }

		    chdir "ps";

		    if ($options->{parse_only} == 0)
		    {
			system "dvips '../$filename_base.dvi' -o '$filename_base.ps'";
		    }

		    if ($options->{verbose})
		    {
			print "$0: leaving ps\n";
		    }

		    chdir "..";
		}

		# generate pdf output

		{
		    mkdir "pdf";

		    if ($options->{verbose})
		    {
			print "$0: entering pdf\n";
		    }

		    chdir "pdf";

		    if ($options->{parse_only} == 0)
		    {
			system "ps2pdf '../ps/$filename_base.ps' '$filename_base.pdf'";
		    }

		    if ($options->{verbose})
		    {
			print "$0: leaving pdf\n";
		    }

		    chdir "..";
		}

		# generate html output

		{
		    mkdir 'html';
		    mkdir 'html/figures';

		    if ($options->{verbose})
		    {
			print "$0: entering html\n";
		    }

		    chdir "html";

		    # read latex source

		    use IO::File;

		    my $source_file = IO::File->new("<../$filename");

		    my $source_text = join "", <$source_file>;

		    $source_file->close();

		    # update the bibliographic reference

		    $source_text =~ s(\\bibliography{\.\./tex/bib/)(\\bibliography{\.\./\.\./\.\./tex/bib/)g;

		    # update html links to their proper file types.

		    my $source_html = update_html($descriptor,$source_text);

		    # write converted source

		    $source_file = IO::File->new(">$filename");

		    print $source_file $source_html;

		    $source_file->close();

		    # copy figures

		    system "cp -rp ../figures/* figures/";

		    # generate html output

		    if ($options->{parse_only} == 0)
		    {
			system "latex '$filename'";
			system "makeindex -c '$filename_base'";
			system "bibtex '$filename_base'";
			system "htlatex '$filename'";
		    }

		    if ($options->{verbose})
		    {
			print "$0: leaving html\n";
		    }

		    chdir "..";
		}

		chdir "..";
	    }

	    # else unknown source file type

	    else
	    {
		print "$0: unknown file type for $filename";
	    }
	}
    }

    if ($options->{verbose})
    {
	print "$0: leaving $directory\n";
    }

    chdir '..';
}


sub copy
{
    my $self = shift;

    my $options = shift;

    my $directory = $self->{directory};

    if ($options->{verbose})
    {
	print "$0: entering $directory\n";
    }

    chdir $directory;

    # if we find a makefile

    if (-f 'Makefile')
    {
	# that is what we use

	system "make copy_document";
    }
    else
    {
	# find relevant source files

	my $filenames = $self->filenames();

	# loop over source files

	foreach my $filename (@$filenames)
	{
	    # for latex sources

	    if ($filename =~ /\.tex$/)
	    {
		# create workspace directories for generating output

		mkdir "output";
		#mkdir 'output/figures';

		# copy source files

		system "cp $filename output/";

		if (-d "figures")
		{

		    system "cp -rfp figures output/";

		}
	    }

	    # else unknown source file type

	    else
	    {
		print "$0: unknown file type for $filename";
	    }
	}
    }

    if ($options->{verbose})
    {
	print "$0: leaving $directory\n";
    }

    chdir '..';
}


# ($directory, $filetype)
#
# Takes a particular file type to use an as extension for copying
# data to an output folder.

sub file_copy
{
    my $documentname = shift;

    my $filetype = shift;

    print "\n\nThe document ";
    print $documentname;
    print " is a $filetype file, copying it over to the output directory\n\n";

    system "mkdir -p output/ps";
    system "mkdir -p output/pdf";
    system "mkdir -p output/html";
    system "cp *.$filetype output/html";
    system "cp *.$filetype output/ps";
    system "cp *.$filetype output/pdf";

    return;
}


sub filenames
{
    my $self = shift;

    my $result
	= [
	   map
	   {
	       chomp; $_
	   }
	   `ls *.tex`,
	  ];

    return $result;
}



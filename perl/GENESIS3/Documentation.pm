#!/usr/bin/perl -w
#!/usr/bin/perl -d:ptkdb -w
#


use strict;


package GENESIS3::Documentation;


package GENESIS3::Documentation::Descriptor;


sub has_tag
{
    my $self = shift;

    my $tag = shift;

    my $tags = $self->{tags};

    foreach (@$tags)
    {
	if ( $tag eq $_ )
	{
	    return 1;
	}
    }

    return 0;
}


package GENESIS3::Documentation::Document;


sub build
{
    my $self = shift;

    my $options = shift;

    my $directory = $self->{name};

    if ($options->{verbose})
    {
	print "$0: entering $directory\n";
    }

    if (!chdir $directory)
    {
	die "$0: *** Error: cannot change to directory $directory";
    }

    # read the descriptor

    if ($self->read_descriptor())
    {
	return "cannot read descriptor for $self->{name}";
    }

    # check for the obsolete tag first so we don't end up doing
    # any extra work.

    if ($self->is_obsolete())
    {
	print "This document is obsolete, skipping.\n";
    }

    # if we find a makefile

    elsif (-f 'Makefile')
    {
	# that is what we use

	system "make build_document";
    }

    # Here we check for the redirect attribute and perform actions as
    # necessary.

    elsif ($self->is_redirect())
    {
	$self->build_redirect();
    }
    elsif ($self->is_pdf())
    {
	$self->build_pdf();
    }
    elsif ($self->is_mp3())
    {
	$self->build_mp3();
    }
    elsif ($self->is_wav())
    {
	$self->build_wav();
    }
    elsif ($self->is_html())
    {
	$self->build_html();
    }
    elsif ($self->is_png())
    {
	$self->build_png();
    }
    elsif ($self->is_ps())
    {
	$self->build_ps();
    }
    else
    {
	$self->build_latex();
    }

    if ($options->{verbose})
    {
	print "$0: leaving $directory\n";
    }

    chdir '..';
}


sub build_redirect
{
    my $self = shift;

    my $directory = $self->{name};

    create_http_redirect($directory, $self->{descriptor}->{redirect});
}


sub build_html
{
    my $self = shift;

    my $directory = $self->{name};

    build_file_copy($self->{descriptor}->{'document name'}, 'html');
}


sub build_latex
{
    my $self = shift;

    my $options = shift;

    my $directory = $self->{name};

    # find relevant source files

    my $filenames = $self->source_filenames();

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
		# generate ps output

		$self->build_2_ps($filename, $filename_base);

		# generate pdf output

		$self->build_2_pdf($filename, $filename_base);

		# generate html output

		$self->build_2_html($filename, $filename_base);
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


sub build_pdf
{
    my $self = shift;

    my $directory = $self->{name};

    build_file_copy($self->{descriptor}->{'document name'}, 'pdf');
}


sub build_png
{
    my $self = shift;

    my $directory = $self->{name};

    build_file_copy($self->{descriptor}->{'document name'}, 'png');
}


sub build_ps
{
    my $self = shift;

    my $directory = $self->{name};

    build_file_copy($self->{descriptor}->{'document name'}, 'ps');
}


sub build_mp3
{
    my $self = shift;

    my $directory = $self->{name};

    build_file_copy($self->{descriptor}->{'document name'}, 'mp3');
}


sub build_wav
{
    my $self = shift;

    my $directory = $self->{name};

    build_file_copy($self->{descriptor}->{'document name'}, 'wav');
}


sub build_2_dvi
{
    my $self = shift;

    my $filename = shift;

    my $filename_base = shift;

    system "latex -halt-on-error '$filename'";

    system "makeindex -c '$filename_base'";

    system "bibtex '$filename_base'";

    system "latex '$filename'";
    system "latex '$filename'";

    $self->{build_2_dvi} = 1;
}


sub build_2_html
{
    my $self = shift;

    my $filename = shift;

    my $filename_base = shift;

    my $options = shift;

    if (!$self->{build_2_dvi})
    {
	$self->build_2_dvi($filename, $filename_base, $options);
    }

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

    my $source_html = update_html($self->{descriptor}, $source_text);

    # write converted source

    $source_file = IO::File->new(">$filename");

    print $source_file $source_html;

    $source_file->close();

    # copy figures

    system "cp -rp ../figures/* figures/";

    # generate html output

    if ($options->{parse_only} == 0)
    {
	#t some of these were already done by ->build_2_dvi()

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


sub build_2_pdf
{
    my $self = shift;

    my $filename = shift;

    my $filename_base = shift;

    my $options = shift;

    if (!$self->{build_2_dvi})
    {
	$self->build_2_dvi($filename, $filename_base, $options);
    }

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


sub build_2_ps
{
    my $self = shift;

    my $filename = shift;

    my $filename_base = shift;

    my $options = shift;

    if (!$self->{build_2_dvi})
    {
	$self->build_2_dvi($filename, $filename_base, $options);
    }

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


sub copy
{
    my $self = shift;

    my $options = shift;

    my $directory = $self->{name};

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

	my $filenames = $self->source_filenames();

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

sub build_file_copy
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


sub has_tag
{
    my $self = shift;

    my $tag = shift;

    if ($self->read_descriptor())
    {
	return "cannot read descriptor for $self->{name}";
    }

    return $self->{descriptor}->has_tag($tag);
}


sub is_html
{
    my $self = shift;

    return $self->has_tag('html');
}


sub is_mp3
{
    my $self = shift;

    return $self->has_tag('mp3');
}


sub is_pdf
{
    my $self = shift;

    return $self->has_tag('pdf');
}


sub is_png
{
    my $self = shift;

    return $self->has_tag('png');
}


sub is_obsolete
{
    my $self = shift;

    return $self->has_tag('obsolete');
}


sub is_ps
{
    my $self = shift;

    return $self->has_tag('ps');
}


sub is_redirect
{
    my $self = shift;

    if ($self->read_descriptor())
    {
	return "cannot read descriptor for $self->{name}";
    }

    return defined $self->{descriptor}->{redirect};
}


sub is_wav
{
    my $self = shift;

    return $self->has_tag('wav');
}


sub read_descriptor
{
    my $self = shift;

    my $filename = $self->{name} . "/descriptor.yml";

    if ($self->{descriptor})
    {
	return '';
    }

    eval
    {
	$self->{descriptor} = YAML::LoadFile($filename);
    };

    if ($@)
    {
	return $@;
    }
    else
    {
	bless $self->{descriptor}, "GENESIS3::Documentation::Descriptor";

	return '';
    }
}


sub source_filenames
{
    my $self = shift;

    my $result
	= [
	   sort
	   map
	   {
	       chomp; $_
	   }
	   `ls *.tex`,
	  ];

    return $result;
}


1;



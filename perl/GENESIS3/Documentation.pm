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

    my $result;

    my $directory = $self->{name};

    # read the descriptor

    if ($self->read_descriptor())
    {
	$result = "cannot read descriptor for $self->{name}";
    }

    if ($options->{verbose})
    {
	print "$0: entering $directory\n";
    }

    if (!chdir $directory)
    {
	$result = "cannot change to directory $directory";
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

	if ($?)
	{
	    $result = 'make build_document failed';
	}
    }

    # Here we check for the redirect attribute and perform actions as
    # necessary.

    elsif ($self->is_redirect())
    {
	$result = $self->build_redirect();
    }
    elsif ($self->is_pdf())
    {
	$result = $self->build_pdf();
    }
    elsif ($self->is_mp3())
    {
	$result = $self->build_mp3();
    }
    elsif ($self->is_wav())
    {
	$result = $self->build_wav();
    }
    elsif ($self->is_html())
    {
	$result = $self->build_html();
    }
    elsif ($self->is_png())
    {
	$result = $self->build_png();
    }
    elsif ($self->is_ps())
    {
	$result = $self->build_ps();
    }
    else
    {
	$result = $self->build_latex();
    }

    if ($options->{verbose})
    {
	print "$0: leaving $directory\n";
    }

    chdir '..';

    return $result;
}


sub build_2_dvi
{
    my $self = shift;

    my $filename = shift;

    my $filename_base = shift;

    system "latex -halt-on-error '$filename'";

    if ($?)
    {
	print "------------------ Error: latex -halt-on-error '$filename' failed\n";

	return "latex -halt-on-error '$filename' failed";
    }

    #! note: both makeindex and bibtex produce error returns when
    #! there is no correct configuration for them in the latex file, we
    #! ignore these error returns

    system "makeindex -c '$filename_base'";

#     if ($?)
#     {
# 	print "------------------ Error: makeindex -c '$filename_base'\n";

# 	return "makeindex -c '$filename_base'";
#     }

    system "bibtex '$filename_base'";

#     if ($?)
#     {
# 	print "------------------ Error: bibtex '$filename_base'\n";

# 	return "bibtex '$filename_base'";
#     }

    system "latex '$filename'";

    if ($?)
    {
	print "------------------ Error: latex '$filename'\n";

	return "latex '$filename'";
    }

   system "latex '$filename'";

    if ($?)
    {
	print "------------------ Error: latex '$filename'\n";

	return "latex '$filename'";
    }

    $self->{build_2_dvi} = 1;

    return undef;
}


sub build_2_html
{
    my $self = shift;

    my $filename = shift;

    my $filename_base = shift;

    my $options = shift;

    my $result;

    if (!$self->{build_2_dvi})
    {
	my $build_error = $self->build_2_dvi($filename, $filename_base, $options);

	if ($build_error)
	{
	    return $build_error;
	}
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

#     if ($?)
#     {
# 	return "cp -rp ../figures/* figures/";
#     }

    # generate html output

    if (!$options->{parse_only})
    {
	#t some of these were already done by ->build_2_dvi()

	system "latex '$filename'";

	if ($?)
	{
	    $result = "latex '$filename'";
	}

	#! note: both makeindex and bibtex produce error returns when
	#! there is no correct configuration for them in the latex file, we
	#! ignore these error returns

	system "makeindex -c '$filename_base'";

# 	if ($?)
# 	{
# 	    $result = "makeindex -c '$filename_base'";
# 	}

	system "bibtex '$filename_base'";

# 	if ($?)
# 	{
# 	    $result = "bibtex '$filename_base'";
# 	}

	system "htlatex '$filename'";

	if ($?)
	{
	    $result = "htlatex '$filename'";
	}

   }

    if ($options->{verbose})
    {
	print "$0: leaving html\n";
    }

    chdir "..";

    return $result;
}


sub build_2_pdf
{
    my $self = shift;

    my $filename = shift;

    my $filename_base = shift;

    my $options = shift;

    my $result;

    if (!$self->{build_2_dvi})
    {
	my $build_error = $self->build_2_dvi($filename, $filename_base, $options);

	if ($build_error)
	{
	    return $build_error;
	}
    }

    mkdir "pdf";

    if ($options->{verbose})
    {
	print "$0: entering pdf\n";
    }

    chdir "pdf";

    if (!$options->{parse_only})
    {
	system "ps2pdf '../ps/$filename_base.ps' '$filename_base.pdf'";

	if ($?)
	{
	    $result = "ps2pdf '../ps/$filename_base.ps' '$filename_base.pdf'";
	}

    }

    if ($options->{verbose})
    {
	print "$0: leaving pdf\n";
    }

    chdir "..";

    return $result;
}


sub build_2_ps
{
    my $self = shift;

    my $filename = shift;

    my $filename_base = shift;

    my $options = shift;

    my $result;

    if (!$self->{build_2_dvi})
    {
	my $build_error = $self->build_2_dvi($filename, $filename_base, $options);

	if ($build_error)
	{
	    return $build_error;
	}
    }

    mkdir "ps";

    if ($options->{verbose})
    {
	print "$0: entering ps\n";
    }

    chdir "ps";

    if (!$options->{parse_only})
    {
	system "dvips '../$filename_base.dvi' -o '$filename_base.ps'";

	if ($?)
	{
	    $result = "dvips '../$filename_base.dvi' -o '$filename_base.ps'";
	}

    }

    if ($options->{verbose})
    {
	print "$0: leaving ps\n";
    }

    chdir "..";

    return $result;
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

    if ($?)
    {
	return "mkdir -p output/ps";
    }

    system "mkdir -p output/pdf";

    if ($?)
    {
	return "mkdir -p output/pdf";
    }

    system "mkdir -p output/html";

    if ($?)
    {
	return "mkdir -p output/html";
    }

    system "cp *.$filetype output/html";

    if ($?)
    {
	return "cp *.$filetype output/html";
    }

    system "cp *.$filetype output/ps";

    if ($?)
    {
	return "cp *.$filetype output/ps";
    }

    system "cp *.$filetype output/pdf";

    if ($?)
    {
	return "cp *.$filetype output/pdf";
    }

    return undef;
}


sub build_html
{
    my $self = shift;

    my $directory = $self->{name};

    return build_file_copy($self->{descriptor}->{'document name'}, 'html');
}


sub build_latex
{
    my $self = shift;

    my $options = shift;

    my $result;

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

	    $directory =~ /.*\/(.*)/;

	    my $filename_base = $1;

	    if (!$options->{parse_only})
	    {
		# generate ps output

		$result = $self->build_2_ps($filename, $filename_base);

		# generate pdf output

		$result = $result and $self->build_2_pdf($filename, $filename_base);

		# generate html output

		$result = $result and $self->build_2_html($filename, $filename_base);
	    }

	    chdir "..";
	}

	# else unknown source file type

	else
	{
	    print "$0: unknown file type for $filename";
	}
    }

    return undef;
}


sub build_pdf
{
    my $self = shift;

    my $directory = $self->{name};

    return build_file_copy($self->{descriptor}->{'document name'}, 'pdf');
}


sub build_png
{
    my $self = shift;

    my $directory = $self->{name};

    return build_file_copy($self->{descriptor}->{'document name'}, 'png');
}


sub build_ps
{
    my $self = shift;

    my $directory = $self->{name};

    return build_file_copy($self->{descriptor}->{'document name'}, 'ps');
}


sub build_mp3
{
    my $self = shift;

    my $directory = $self->{name};

    return build_file_copy($self->{descriptor}->{'document name'}, 'mp3');
}


sub build_redirect
{
    my $self = shift;

    my $directory = $self->{name};

    return create_http_redirect($directory, $self->{descriptor}->{redirect});
}


sub build_wav
{
    my $self = shift;

    my $directory = $self->{name};

    return build_file_copy($self->{descriptor}->{'document name'}, 'wav');
}


sub copy
{
    my $self = shift;

    my $options = shift;

    my $result;

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

	if ($?)
	{
	    $result = "make copy_document";
	}

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

		if ($?)
		{
		    $result = "cp $filename output/";
		}
		elsif (-d "figures")
		{

		    system "cp -rfp figures output/";

		    if ($?)
		    {
			$result = "cp -rfp figures output/";
		    }

		}
	    }

	    # else unknown source file type

	    else
	    {
		print "$0: unknown file type for $filename";

		$result = "unknown file type for $filename";
	    }
	}
    }

    if ($options->{verbose})
    {
	print "$0: leaving $directory\n";
    }

    chdir '..';

    return $result;
}


sub create_http_redirect
{
    my $document = shift;

    my $redirect_url = shift;

    my $options = shift;

    my $result;

    print "\n\nThe document ";
    print $document;
    print " is an http redirect to a website.\n\n";

    print "Entering the $document directory ";
    chdir $document;
    print `pwd`;
    print "\n\n";


    print  "-- creating directories --\n";

    system "mkdir -p output/ps";

    if ($?)
    {
	$result = "mkdir -p output/ps";
    }

    system "mkdir -p output/pdf";

    if ($?)
    {
	$result = "mkdir -p output/pdf";
    }

    system "mkdir -p output/html";

    if ($?)
    {
	$result = "mkdir -p output/html";
    }

    print "-- creating html file --\n";

    my @tmp = split(/\//,$document);

    my $doctitle = $tmp[-1];

    my $html_document = $document . "/" . $doctitle  . ".html";

    open(OUTPUT,">$html_document");
    print OUTPUT "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n<html>\n  <head>\n    <title>";
    print OUTPUT $html_document . " (http redirect)";
    print OUTPUT "</title>\n  </head>\n  <body><meta http-equiv=\"refresh\" content=\"0;URL=";
    print OUTPUT $redirect_url;
    print OUTPUT "\">\n  </body>\n</html>\n\n";
    close(OUTPUT);

    print "-- copying redirect file to output directories\n";

    system "cp -f $html_document output/ps";

    if ($?)
    {
	$result = "cp -f $html_document output/ps";
    }

    system "cp -f $html_document output/pdf";

    if ($?)
    {
	$result = "cp -f $html_document output/pdf";
    }

    system "cp -f $html_document output/html";

    if ($?)
    {
	$result = "cp -f $html_document output/html";
    }

    print "-- Done --\n\n";

    return $result;
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


sub new
{
    my $package = shift;

    my $options = shift;

    my $self
	= {
	   %$options,
	  };

    bless $self, $package;

    return $self;
}


sub prepare_publish_document
{
    my $self = shift;

    my $options = shift;

    my $result;

    my $directory = $self->{name};

    if ($options->{verbose})
    {
	print "$0: entering $directory\n";
    }

    if (!chdir $directory)
    {
	return "cannot change to directory $directory";
    }

    # read the descriptor

    if ($self->read_descriptor())
    {
	$result = "cannot read descriptor for $self->{name}";
    }

    # check for the obsolete tag first so we don't end up doing
    # any extra work.

    if ($self->is_obsolete())
    {
	print "This document is obsolete, skipping.\n";
    }

    # if we find a makefile

    elsif (-f 'Makefile' )
    {
	# that is what we use

	system "make prepare_publish_document";

	if ($?)
	{
	    $result = "make prepare_publish_document";
	}

    }

    # no makefile

    else
    {
	# find relevant output containing generated files

	my $outputs
	    = [
	       'output/html',
	      ];

	# loop over source files

	foreach my $output (@$outputs)
	{
	    my @tmp = split /\//, $directory;

	    my $target_directory = $tmp[-1];

	    if ($options->{verbose})
	    {
		print "$0: copying files for $directory to html/htdocs/neurospaces_project/userdocs/$target_directory\n";
	    }

	    # put it in the place for publication.

	    mkdir "../html/htdocs/neurospaces_project/userdocs/$target_directory";

	    #! note: -pr for BSD (MAC) compatibility.

	    system "cp -pr $output/* '../html/htdocs/neurospaces_project/userdocs/$target_directory'";

	    if ($?)
	    {
		$result = "cp -pr $output/* '../html/htdocs/neurospaces_project/userdocs/$target_directory'";
	    }

	}
    }

    if ($options->{verbose})
    {
	print "$0: leaving $directory\n";
    }

    chdir '..';

    return $result;
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

	return undef;
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


#
# Function to update any links in the html that it outputs
# to the userdocs system. Handles special cases.
#

sub update_html
{
    my $descriptor = shift;
    my $source_text = shift;

    print "--- Updating html links ---\n";

    $source_text =~ s(\\href\{\.\./([^}]*)\.pdf)(\\href\{../$1.html)g;

    $source_text =~ s(\\href\{\.\./([^}]*)\.tex)(\\href\{../$1.html)g;

    # If we have nothign but whitespace in between the itemize tags, remove
    # the whole line.

    #! this is a duplicated statement / operation, see above

    $source_text =~ s(\\begin\{itemize\}\s+\\end\{itemize\})( )g;

    # convert eps links to png links

    $source_text =~ s(\\includegraphics\{figures/([^}]*)\.eps)(\\href\{figures/$1.png)g;

    # here we handle special cases for pdf files. Since several files in the 
    # documentation can be pdf we need to check all of the published docs
    # for the pdf tag. Operation is a bit expensive.
    # NOTE: Duplicates some code from userdocs-tag-replace-items

    my $published_pdfs_yaml = `userdocs-tag-filter 2>&1 pdf published`;

    my $published_pdfs = YAML::Load($published_pdfs_yaml);

    foreach my $published_pdf (@$published_pdfs)
    {
	$published_pdf =~ /.*\/(.*)/;

	my $pdf = $1;

	$source_text =~ s(\\href\{\.\./$pdf/$pdf\.html)(\\href\{../$pdf/$pdf.pdf)g;
    }

    return $source_text;
}


1;



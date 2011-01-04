#!/usr/bin/perl -
#!/usr/bin/perl -d:ptkdb -w
#


use strict;


package GENESIS3::Documentation;


our $documents;


sub find_documentation
{
    use YAML;

    my $args = shift;

    my $names = $args->{names} || [];

    my $tags = $args->{tags} || [];

    # get all documents explicitly asked for

    $documents
	= {
	   map
	   {
	       $_ => 1,
	   }
	   (
	    @$names
	    ? @$names
	    : @{ local $/ ; @{$args->{tags}} ? [] : Load(`userdocs-tag-filter 2>&1 "published"`) },
	   ),
	  };

    # get all documents selected by tags

    foreach my $tag (@$tags)
    {
	local $/;

	my $documents_tag = Load(`userdocs-tag-filter 2>&1 "$tag"`);

	if (!scalar @$documents_tag)
	{
	    next;
	}
	
	$documents
	    = {
	       %$documents,
	       map
	       {
		   $_ => $tag,
	       }
	       @$documents_tag,
	      };
    }

    return $documents;
}


package GENESIS3::Documentation::Publications;


our $all_publication_results;


sub unique
{
    my @list = @_;

    my %seen = ();

    my @unique
	= (grep
	   { ! $seen{$_} ++ }
	   @list
	  );

    return @unique;
}


sub extract_processed_tags
{
    #! note the syntax to force perl to build an intermediate array result

    my $result
	= [
	   sort
	   @{
	       [
		unique
		map
		{
		    my $result = $all_publication_results->{$_}->{document}->{descriptor}->{tags};

		    @$result;
		}
		keys %$all_publication_results,
	       ],
	   },
	  ];

    return $result;
}


sub insert_publication_production_result
{
    my $document = shift;

    my $build_result = shift;

    my $document_name = $document->{name};

    $all_publication_results->{$document_name}
	= {
	   document => $document,
	   build_result => $build_result,
	  };
}


sub publish_production_results
{
    my $selectors = shift;

    use YAML;

    my $result;

    my $all_results
	= {
	   map
	   {
	       (
		scalar keys %{ $all_publication_results->{$_}->{build_result} }
		? ($all_publication_results->{$_}->{document}->{name} => $all_publication_results->{$_}->{build_result}, )
		: (),
	       );
	   }
	   keys %$all_publication_results,
	  };

    print Dump( { all_publication_results => $all_results, }, );

    use IO::File;

    my $results_file = IO::File->new(">/tmp/all_publication_results");

    if ($results_file)
    {
	print $results_file Dump( { all_publication_results => $all_results, }, );
    }
    else
    {
	print "$0: *** Error: cannot all_publication_results write to /tmp/all_publication_results\n";

	$result = "cannot all_publication_results write to /tmp/all_publication_results";
    }

    return $result;
}


sub start_publication_production
{
    $all_publication_results = {};
}


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


sub compile
{
    my $self = shift;

    my $options = shift;

    my $result;

    my $directory = $self->{name};

    # read the descriptor

    my $descriptor_error = $self->read_descriptor();

    if ($descriptor_error)
    {
	$result = "cannot read descriptor for $self->{name} ($descriptor_error)";

	return $result;
    }

    if ($options->{verbose})
    {
	print "$0: entering $directory\n";
    }

    if (!chdir $directory)
    {
	$result = "cannot change to directory $directory";

	return $result;
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

	system "make compile_document";

	if ($?)
	{
	    $result = 'make compile_document failed';
	}
    }

    # Here we check for the redirect attribute and perform actions as
    # necessary.

    elsif ($self->is_redirect())
    {
	$result = $self->compile_redirect();
    }
    elsif ($self->is_restructured_text())
    {
	$result = $self->compile_restructured_text();
    }
    elsif ($self->is_rich_text_format())
    {
	$result = $self->compile_rich_text_format();
    }
    elsif ($self->is_pdf())
    {
	$result = $self->compile_pdf();
    }
    elsif ($self->is_mp3())
    {
	$result = $self->compile_mp3();
    }
    elsif ($self->is_wav())
    {
	$result = $self->compile_wav();
    }
    elsif ($self->is_html())
    {
	$result = $self->compile_html();
    }
    elsif ($self->is_png())
    {
	$result = $self->compile_png();
    }
    elsif ($self->is_ps())
    {
	$result = $self->compile_ps();
    }
    else
    {
	$result = $self->compile_latex();
    }

    if ($options->{verbose})
    {
	print "$0: leaving $directory\n";
    }

    chdir '..';

    return $result;
}


sub compile_2_dvi
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

    $self->{compile_2_dvi}->{$filename} = 1;

    return undef;
}


sub compile_2_html
{
    my $self = shift;

    my $filename = shift;

    my $filename_base = shift;

    my $options = shift;

    my $result;

    if (!$self->{compile_2_dvi}->{$filename})
    {
	my $compile_error = $self->compile_2_dvi($filename, $filename_base, $options);

	if ($compile_error)
	{
	    return $compile_error;
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

    my $source_html = update_hyperlinks($self->{descriptor}, $source_text);

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
	#t some of these were already done by ->compile_2_dvi()

	system "latex '$filename'";

	if ($?)
	{
	    $result = "compiling $filename (latex '$filename': $?)";
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
	    $result = "compiling $filename (htlatex '$filename', $?)";
	}

   }

    if ($options->{verbose})
    {
	print "$0: leaving html\n";
    }

    chdir "..";

    return $result;
}


sub compile_2_pdf
{
    my $self = shift;

    my $filename = shift;

    my $filename_base = shift;

    my $options = shift;

    my $result;

    if (!$self->{compile_2_dvi}->{$filename})
    {
	my $compile_error = $self->compile_2_dvi($filename, $filename_base, $options);

	if ($compile_error)
	{
	    return $compile_error;
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
	    $result = "creating $filename_base.pdf from $filename_base.ps (ps2pdf '../ps/$filename_base.ps' '$filename_base.pdf', $?)";
	}

    }

    if ($options->{verbose})
    {
	print "$0: leaving pdf\n";
    }

    chdir "..";

    return $result;
}


sub compile_2_ps
{
    my $self = shift;

    my $filename = shift;

    my $filename_base = shift;

    my $options = shift;

    my $result;

    if (!$self->{compile_2_dvi}->{$filename})
    {
	my $compile_error = $self->compile_2_dvi($filename, $filename_base, $options);

	if ($compile_error)
	{
	    return $compile_error;
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
	    $result = "creating dvi from $filename (dvips '../$filename_base.dvi' -o '$filename_base.ps', $?)";
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

sub compile_file_copy
{
    my $self = shift;

    my $filetype = shift;

    system "rm -fr output";

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
	return "copying $filetype files to the html output directory (cp *.$filetype output/html, $?)";
    }

    system "cp *.$filetype output/ps";

    if ($?)
    {
	return "copying $filetype files to the postscript output directory (cp *.$filetype output/ps, $?)";
    }

    system "cp *.$filetype output/pdf";

    if ($?)
    {
	return "copying $filetype files to the pdf output directory (cp *.$filetype output/pdf, $?)";
    }

    return undef;
}


sub compile_html
{
    my $self = shift;

    my $directory = $self->{name};

    return $self->compile_file_copy('html');
}


sub compile_latex
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

	    my $filename_base = $1;

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

		# remove empty itemize environments (otherwise latex complains)

		$source_text =~ s(\\begin\{itemize\}\s+\\end\{itemize\})( )g;

		open(OUTPUT,">$filename");
		
		print OUTPUT $source_text;

		close(OUTPUT);
	    }

	    if (!$options->{parse_only})
	    {
		# generate ps output

		$result = $self->compile_2_ps($filename, $filename_base);

		# generate pdf output

		$result = $result or $self->compile_2_pdf($filename, $filename_base);

		# generate html output

		$result = $result or $self->compile_2_html($filename, $filename_base);
	    }

	    chdir "..";
	}

	# else unknown source file type

	else
	{
	    print "$0: unknown file type for $filename";
	}
    }

    return $result;
}


sub compile_pdf
{
    my $self = shift;

    my $directory = $self->{name};

    return $self->compile_file_copy('pdf');
}


sub compile_png
{
    my $self = shift;

    my $directory = $self->{name};

    return $self->compile_file_copy('png');
}


sub compile_ps
{
    my $self = shift;

    my $directory = $self->{name};

    return $self->compile_file_copy('ps');
}


sub compile_mp3
{
    my $self = shift;

    my $directory = $self->{name};

    return $self->compile_file_copy('mp3');
}


sub compile_redirect
{
    my $self = shift;

    my $directory = $self->{name};

    return create_http_redirect($directory, $self->{descriptor}->{redirect});
}


sub compile_restructured_text
{
    my $self = shift;

    my $directory = $self->{name};

    my $result;

    # find relevant source files

    my $filenames = $self->source_filenames();

    # loop over source files

    foreach my $filename (@$filenames)
    {
	# for restructured text sources

	if ($filename =~ /\.rst$/)
	{
	    chdir "output";

	    # prepare output: general rst processing

	    $filename =~ m((.*)\.rst$);

	    my $filename_base = $1;

# 	    if (!$options->{parse_only})
	    {
		# generate pdf output

# 		{
# 		    mkdir "pdf";

# # 		    if ($options->{verbose})
# 		    {
# 			print "$0: entering pdf\n";
# 		    }

# 		    chdir "pdf";

# # 		    if (!$options->{parse_only})
# 		    {
# 			system "rst2pdf '../$filename_base.rst' -o '$filename_base.pdf'";

# 			if ($?)
# 			{
# 			    $result = "rst2pdf '../$filename_base.rst' -o '$filename_base.pdf'";
# 			}

# 		    }

# # 		    if ($options->{verbose})
# 		    {
# 			print "$0: leaving pdf\n";
# 		    }

# 		    chdir "..";
# 		}

		# generate html output

		{
		    mkdir 'html';

		    mkdir 'html/figures';

# 		    if ($options->{verbose})
		    {
			print "$0: entering html\n";
		    }

		    chdir "html";

		    # read latex source

		    use IO::File;

		    my $source_file = IO::File->new("<../$filename");

		    my $source_text = join "", <$source_file>;

		    $source_file->close();

		    $source_file = IO::File->new(">$filename");

		    print $source_file $source_text;

		    $source_file->close();

		    # copy figures

		    system "cp -rp ../figures/* figures/";

		    #     if ($?)
		    #     {
		    # 	return "cp -rp ../figures/* figures/";
		    #     }

		    # generate html output

# 		    if (!$options->{parse_only})
		    {
			system "rst2html '../$filename' '$filename_base.html'";

			if ($?)
			{
			    system "rst2html.py '../$filename' '$filename_base.html'";

			    if ($?)
			    {
				$result = "creating html for $filename (rst2html(.py)? '../$filename' '$filename_base.html', $?)";
			    }
			}
		    }

# 		    if ($options->{verbose})
		    {
			print "$0: leaving html\n";
		    }

		    chdir "..";
		}
	    }

	    chdir "..";
	}

	# else unknown source file type

	else
	{
	    print "$0: unknown file type for $filename";
	}
    }

    return $result;
}


sub compile_rich_text_format
{
    my $self = shift;

    my $directory = $self->{name};

    my $result;

    # find relevant source files

    my $filenames = $self->source_filenames();

    # loop over source files

    foreach my $filename (@$filenames)
    {
	# for restructured text sources

	if ($filename =~ /\.rtf$/)
	{
	    chdir "output";

	    # prepare output: general rst processing

	    $filename =~ m((.*)\.rtf$);

	    my $filename_base = $1;

# 	    if (!$options->{parse_only})
	    {
		# generate latex output

		{
		    system "unrtf '../$filename_base.rtf' --latex >'$filename_base.tex'";

		    if ($?)
		    {
			$result = "creating latex from $filename (unrtf '../$filename_base.rtf' --latex >'$filename_base.tex', $?)";
		    }

		}

		# generate html output

		{
		    mkdir 'html';

		    mkdir 'html/figures';

# 		    if ($options->{verbose})
		    {
			print "$0: entering html\n";
		    }

		    chdir "html";

		    # read latex source

		    use IO::File;

		    my $source_file = IO::File->new("<../$filename");

		    my $source_text = join "", <$source_file>;

		    $source_file->close();

		    $source_file = IO::File->new(">$filename");

		    print $source_file $source_text;

		    $source_file->close();

		    # copy figures

		    system "cp -rp ../figures/* figures/";

		    #     if ($?)
		    #     {
		    # 	return "cp -rp ../figures/* figures/";
		    #     }

		    # generate html output

# 		    if (!$options->{parse_only})
		    {
			system "unrtf '../$filename' --html >'$filename_base.html'";

			if ($?)
			{
			    $result = "creating html for $filename (unrtf '../$filename' --html >'$filename_base.html', $?)";
			}
		    }

# 		    if ($options->{verbose})
		    {
			print "$0: leaving html\n";
		    }

		    chdir "..";
		}
	    }

	    chdir "..";
	}

	# else unknown source file type

	else
	{
	    print "$0: unknown file type for $filename";
	}
    }

    return $result;
}


sub compile_wav
{
    my $self = shift;

    my $directory = $self->{name};

    return $self->compile_file_copy('wav');
}


sub check
{
    my $self = shift;

    my $options = shift;

    my $result;

    print "Checking $self->{name}\n";

    my $descriptor_error = $self->read_descriptor();

    if ($descriptor_error)
    {
	$result = "cannot read descriptor for $self->{name} ($descriptor_error)";

	return $result;
    }

    if (!$self->{descriptor}->{tags}
	|| ref $self->{descriptor}->{tags} !~ /ARRAY/)
    {
	$result = "invalid tag specification for $self->{name}";
    }

    return $result;
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
	    $result = "make copy_document of $self->{name}, $?";
	}

    }
    else
    {
	# find relevant source files

	my $filenames = $self->source_filenames();

	# loop over source files

	foreach my $filename (@$filenames)
	{
	    # for latex and restructured text sources

	    if ($filename =~ /\.(rst|rtf|tex)$/)
	    {
		# create workspace directories for generating output

		mkdir "output";
		#mkdir 'output/figures';

		# copy source files

		system "cp $filename output/";

		if ($?)
		{
		    $result = "copying $filename to the output directory (cp $filename output/, $?)";
		}
		elsif (-d "figures")
		{

		    system "cp -rfp figures output/";

		    if ($?)
		    {
			$result = "copying $filename/figures to the output directory (cp -rfp figures output/, $?)";
		    }

		}

		if ($?)
		{
		}
		elsif (-d "snippets")
		{

		    system "cp -rfp snippets output/";

		    if ($?)
		    {
			$result = "copying $filename/snippets to the output directory (cp -rfp snippets output/, $?)";
		    }

		}
	    }

	    # else unknown source file type

	    else
	    {
		print "$0: unknown file type for $filename";

		$result = "unknown file type for $filename, expecting .rst, .rtf, or .tex filename extension";
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

    #my $html_document = $document . "/" . $doctitle  . ".html";
    my $html_document = $doctitle  . ".html";

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


sub expand
{
    my $self = shift;

    my $options = shift;

    my $result;

    # only expand in regular latex files

    if (not $self->is_latex())
    {
	return $result;
    }

    # expand contents of each level of the documentation

    my $contents_documents
	= {
	   'contents-level1' => 1,
	   'contents-level2' => 1,
	   'contents-level3' => 1,
	   'contents-level4' => 1,
	   'contents-level5' => 1,
	   'contents-level6' => 1,
	   'contents-level7' => 1,
	  };

    my $document_name = $self->{name};

    if ($contents_documents->{$document_name})
    {
	my $command = "userdocs-tag-replace-items '$document_name' '$document_name/output/$document_name.tex' --verbose";

	system $command;

	if ($?)
	{
	    $result = "for document '$document_name': failed to execute ($command, $?)\n";
	}
    }

    # expand related documentation links

    if (not $result)
    {
	# loop over all related information tags

	my $related_tags = $self->related_tags();

	if (not ref $related_tags)
	{
	    $result = $related_tags;

	    return $result;
	}

	foreach my $related_tag (@$related_tags)
	{
	    # expand the document

	    my $command = "userdocs-tag-replace-items $related_tag '$document_name/output/$document_name.tex' --verbose --exclude '$document_name'";

	    system $command;

	    if ($?)
	    {
		$result = "for document '$document_name': failed to execute ($command, $?)\n";

		last;
	    }
	}
    }

    # expand dynamically generated snippets

    if (-f "$document_name/output/$document_name.tex")
    {
	# expand the document

	my $command = "userdocs-snippet '$document_name/output/$document_name.tex' --verbose";

	system $command;

	if ($?)
	{
	    $result = "for document '$document_name': failed to execute ($command, $?)\n";

	    last;
	}
    }

    # return result

    return $result;
}


sub find_snippets
{
    my $self = shift;

    # convert document_filename to directory where it is stored

    my $document_filename = $self->{filename} || $self->{name};

    # remove filename and extension from the document filename

    $document_filename =~ s((.*)/.*)($1);

    # construct snippets directory name

    my $snippet_directory = $document_filename . "/snippets/";

    my $snippets
	= [
	   map
	   {
	       chomp; $_
	   }
	   `find $snippet_directory \\! -type d -name "*[^~]"`,
	  ];

    my $result
	= {
	   map
	   {
	       my $snippet_filename = $_;

	       s(.*/(.*))($1);

	       $_ => GENESIS3::Documentation::Snippet->new(
							   {
							    filename => $snippet_filename,
							    name => $_,
							   },
							  ),
	   }
	   @$snippets,
	  };

    return $result;
}


sub has_tag
{
    my $self = shift;

    my $tag = shift;

    my $descriptor_error = $self->read_descriptor();

    if ($descriptor_error)
    {
	die "$0: document descriptor cannot be read ($descriptor_error)";
    }

    return $self->{descriptor}->has_tag($tag);
}


sub is_html
{
    my $self = shift;

    return $self->has_tag('html');
}


sub is_latex
{
    my $self = shift;

    return not (
		$self->is_html()
		or $self->is_mp3()
		or $self->is_obsolete()
		or $self->is_pdf()
		or $self->is_png()
		or $self->is_ps()
		or $self->is_redirect()
		or $self->is_restructured_text()
		or $self->is_rich_text_format()
		or $self->is_wav()
	       );
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

    my $descriptor_error = $self->read_descriptor();

    if ($descriptor_error)
    {
	die "$0: document descriptor cannot be read ($descriptor_error)";
    }

    return defined $self->{descriptor}->{redirect};
}


sub is_restructured_text
{
    my $self = shift;

    return $self->has_tag('rst');
}


sub is_rich_text_format
{
    my $self = shift;

    return $self->has_tag('rtf');
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


sub nop
{
    my $self = shift;

    my $options = shift;

    my $result;

    return $result;
}


sub publish
{
    my $self = shift;

    my $options = shift;

    my $result;

    # read the descriptor

    my $descriptor_error = $self->read_descriptor();

    if ($descriptor_error)
    {
	$result = "cannot read descriptor for $self->{name} ($descriptor_error)";

	return $result;
    }

    my $directory = $self->{name};

    if ($options->{verbose})
    {
	print "$0: entering $directory\n";
    }

    if (!chdir $directory)
    {
	return "cannot change to directory $directory (now in " . `pwd` . ")";
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


sub related_tags
{
    my $self = shift;

    my $result;

    my $descriptor_error = $self->read_descriptor();

    if ($descriptor_error)
    {
	$result = "cannot read descriptor for $self->{name} ($descriptor_error)";

	return $result;
    }

    my $tags = $self->{descriptor}->{tags};

    $result = [];

    foreach my $tag (@$tags)
    {
	if ($tag =~ /^related-/)
	{
	    push @$result, $tag;
	}
    }

    return $result;
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
	   `ls *.rst`,
	   `ls *.rtf`,
	  ];

    return $result;
}


#
# Function to update hyperlinks in the source text
# to the userdocs system.
#

sub update_hyperlinks
{
    my $descriptor = shift;

    my $source_text = shift;

    print "--- Updating hyperlinks ---\n";

    $source_text =~ s(\\href\{\.\./([^}]*)\.pdf)(\\href\{../$1.html)g;

    $source_text =~ s(\\href\{\.\./([^}]*)\.tex)(\\href\{../$1.html)g;

    # remove empty itemize environments (otherwise latex complains)

    #! this is a duplicated statement / operation, see above

    $source_text =~ s(\\begin\{itemize\}\s+\\end\{itemize\})( )g;

    # convert eps links to png links

    $source_text =~ s(\\includegraphics\{figures/([^}]*)\.eps)(\\href\{figures/$1.png)g;

    # here we handle special cases for pdf files. Since several files in the
    # documentation can be pdf we need to check all of the published docs
    # for the pdf tag. Operation is a bit expensive.
    # NOTE: Duplicates code from userdocs-tag-replace-items

    my $published_pdfs_yaml = `userdocs-tag-filter 2>&1 pdf published`;

    my $published_pdfs = YAML::Load($published_pdfs_yaml);

    foreach my $published_pdf (@$published_pdfs)
    {
	$published_pdf =~ /.*\/(.*)/;

	my $document_name = $1;

	$source_text =~ s(\\href\{\.\./$document_name/$document_name\.html)(\\href\{../$document_name/$document_name.pdf)g;
    }

    return $source_text;
}


package GENESIS3::Documentation::Snippet;


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


sub read_content
{
    my $self = shift;

    if (exists $self->{content})
    {
	return '';
    }

    # slurp content

    open my $descriptor, $self->{filename}
	or return $!;

    local $/;

    $self->{content} = <$descriptor>;

    close $descriptor;

    return undef;
}


sub replacement_string
{
    my $self = shift;

    if (exists $self->{replacement_string})
    {
	return $self->{replacement_string};
    }

    # read the snippet content

    my $error = $self->read_content();

    if ($error)
    {
	#t no nice error propagation

	print STDERR "$0: $error";

	return undef;
    }

    # loop over all backquote strings

    my $content = $self->{content};

    while ($content =~ m/\G.*?`([^`]*)`/gs)
    {
	my $position = pos($content);

	# execute the command

	my $command = $1;

	my $replacement = `$command`;

	if ($?)
	{
	    print STDERR "$0: *** Error: running '$command' returned status $?\n";
	}

	# replace the command with its expansion

	if ($self->{verbose})
	{
	    print "For $self->{filename}: found $command at $position, replacing ... \n";
	}

	$content =~ s(`$command`)($replacement)g;

	# set the new position

	pos($content) = $position;
    }

    # fill in the replacement_string

    $self->{replacement_string} = $content;

    # return replacement_string

    return $content;
}


1;



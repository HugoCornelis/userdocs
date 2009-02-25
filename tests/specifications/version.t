#!/usr/bin/perl -w
#

use strict;


my $test
    = {
       command_definitions => [
			       {
				arguments => [
					      'VERSION',
					     ],
				command => 'cat',
				command_tests => [
						  {
						   description => "Is neurospaces startup successful ?",
						   read => 'neurospaces ',
						   timeout => 3,
						   write => undef,
						  },
						  {
						   # $Format: "description => \"Does the version information match with ${package}-${label} ?\","$
description => "Does the version information match with userdocs-docs-1 ?",
						   # $Format: "read => \"${package}-${label}\","$
read => "userdocs-docs-1",
						   write => "version",
						  },
						 ],
				description => "check version information",
			       },
			      ],
       description => "documentation versioning",
       name => 'version.t',
      };


return $test;



#!/usr/bin/perl -w
#

use strict;


my $test
    = {
       command_definitions => [
			       {
				command => './bin/userdocs-version',
				command_tests => [
						  {
						   # $Format: "description => \"Does the version information match with ${package}-${label} ?\","$
description => "Does the version information match with userdocs-alpha ?",
						   # $Format: "read => \"${package}-${label}\","$
read => "userdocs-alpha",
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



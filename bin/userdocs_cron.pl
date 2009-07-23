#!/usr/bin/perl


#                                                                                                          
# args ($sendto_email,$sendfrom_email,$subject,$message)                                                   
sub try_to_mail_status
{
    my $subject;
    my $message;
    my $sendto_email;
    my $sendfrom_email;

    if($sendto_email eq "")
    {
	return;
    }

    ($sendto_email,$sendfrom_email,$subject,$message) = @_;

    #todo figure out why I can't put the output of                                                          
    # `which sendmail` into a variable and put it in                                                        
    # place of the /usr/sbin/sendmail. A user may have                                                      
    # a different sendmail path.                                                                            

    open(MAIL, "|/usr/sbin/sendmail -oi -t");
    print MAIL "From: $sendfrom_email\n";
    print MAIL "To: $sendto_email\n";
    print MAIL "Subject: $subject\n\n";
    print MAIL "$message\n";
    close(MAIL);

}


$ENV{HOME}='/home/genesis';
$ENV{PATH} .= ':/bin:/usr/bin:/usr/local/bin';


system "neurospaces_pull --regex userdocs"; 

system "neurospaces_update --regex userdocs"; 

system "neurospaces_configure --regex userdocs";

system "neurospaces_install --regex userdocs";

system "make clean -C ~/neurospaces_project/userdocs/source/snapshots/0/";

system "make website-clean -C ~/neurospaces_project/userdocs/source/snapshots/0/";

system "make website-prepare -C ~/neurospaces_project/userdocs/source/snapshots/0/ > /tmp/userdocs_make.output";

#system "cat /tmp/userdocs_make.output |  mail -s \"userdocs has been built on darwin\" sysadminspam@gmail.com";


# now do a link check.
system "mkdir ~/neurospaces_project/userdocs/source/snapshots/0/html/htdocs/neurospaces_project/userdocs/webcheck";

system "webcheck -o ~/neurospaces_project/userdocs/source/snapshots/0/html/htdocs/neurospaces_project/userdocs/webcheck ~/neurospaces_project/userdocs/source/snapshots/0/html/htdocs/neurospaces_project/userdocs/";

my $text = `cat /tmp/userdocs_make.output`;

try_to_mail_status("sysadminspam@gmail.com",
		   "userdocs@darwin.cbi.utsa.edu",
		   "Userdocs has been built on darwin.",
		   "Userdocs has finished building.\n\n" . $text);


system "rm -f /tmp/userdocs_make.output";





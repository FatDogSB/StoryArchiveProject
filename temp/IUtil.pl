#!/home/aruba/bin/gnu/isqlperl
# use Test::Harness;
# use DB_File;
# use strict 'untie';
# Initial revision
#
#

use Socket;
use LWP::Simple;
use LWP::UserAgent;
use Mail::POP3Client;


$gPage = "http://www.cpan.org/doc/FAQs/index.html";
$gPage = "http://listings.ebay.com/aw/listings/list/category99/index.html";
$gPage = "http://listings.ebay.com/aw/listings/endtoday/category617/index.html";
$gPage = "http://www.wcsc.org/index.html";

&main ();
exit (0);


#----------------------------------------------------------
#
#----------------------------------------------------------
sub S_CountEmail
{
	local ($lMail) = new Mail::POP3Client("amber", "ng*Suck1", "pop.dnai.com");

	if ( ! $lMail )
	{
		print "ERROR: Could not create mail client\n";
	} else {
		local ($lCount) = $lMail->Count;
		print "There are $lCount new emails waiting for amber.\n";
	}

}	# S_CountEmail

#----------------------------------------------------------
# This gets a web page using a UserAgent object
#----------------------------------------------------------
sub S_GetWebPage2
{
	local (@lTempStr);
	local ($lMyAgent) = new LWP::UserAgent;	# Create User Agent object
	$lMyAgent->credentials (
	local ($lRequest) = new HTTP::Request ('GET', $gPage); # Create Request obj

	print "Objects Created: Getting web page...";

	local ($lResponse) = $lMyAgent->request($lRequest);

	print "done!\n";

	$lTempStr = $lResponse->{_content};

	print "$lTempStr \n";

	print "_msg = $lResponse->{_msg}\n";
	print "_protocol = $lResponse->{_protocol}\n";
	print "_previous = $lResponse->{_previous}\n";


	#open OUTFILE, ">test.html";
	#print OUTFILE $lResponse->{_content};
	#close OUTFILE;

}	# S_TestI

#----------------------------------------------------------
#----------------------------------------------------------
sub S_GetWebPage1
{
	local ($lName, $lAddress);

	$lName = "www.dnai.org";
#	$lAddress = inet_ntoa ( inet_aton("www.dnai.org") );
	# print "$lName = $lAddress\n";

	print "Getting web page...\n";
	local ($lContent) = get ("http://www.cpan.org/doc/FAQs/index.html");
	open (OUTFILE, ">test.html");
	print (OUTFILE $lContent);
	close OUTFILE;

}	# S_TestI

#-------------------------------------------------------------------------
# PrintMenu2 - Prints the menu
#-------------------------------------------------------------------------
sub PrintMenu2 {

    print "=============================================\n";
    print "              Main Menu\n";
    print "             HTML Utilitys\n";
    print "=============================================\n";
    print "Please choose an option:\n\n";
    print "\t1 - Get Web Page 1\n";
    print "\t2 - Get Web Page 2\n";
    print "\t3 - Count Email\n";
    print "\t4 - \n";
    print "\t6 - \n";
    print "\t7 - \n";
    print "\t8 - \n";
    print "\t9 - \n";
    print "\t5 - \n";
    print "\n\n";
    print "\t\tChoice: ";

}  # PrintMenu2

#-------------------------------------------------------------------------
# Menu - Provides a menu for choices.  Returns the choice number.
#  If the choice requires a path, this routine will ask for it and
#  error check the path before returning.  The path will be stored
#  in $g_Path;
#-------------------------------------------------------------------------
sub GetChoice {

    local ($l_finished) = 0;
    local ($l_choice) = 0;

    while ( $l_finished == 0) {
        &PrintMenu2 ();

        chop ($l_choice = <STDIN>);

        if ( ($l_choice > 0) && ($l_choice < 10) ) {
            $l_finished = 1;
        }
    }
    $l_choice;

} # GetChoice


#----------------------------------------------------------
#  Main
#----------------------------------------------------------
sub main {

    local ($l_finished) = 0;

    while ( ! $l_finished )
    {
        $g_choice = &GetChoice();

        if ( $g_choice == 1 )
        {
			&S_GetWebPage1();
            $l_finished = 1;
        } elsif ( $g_choice == 2 ) {
			&S_GetWebPage2();
            $l_finished = 1;
        } elsif ( $g_choice == 3 ) {
			&S_CountEmail();
            $l_finished = 1;
        } elsif ( $g_choice == 4 ) {
            $l_finished = 1;
        } elsif ( $g_choice == 5 ) {
            $l_finished = 1;
        } elsif ( $g_choice == 6 ) {
            $l_finished = 1;
        } elsif ( $g_choice == 7 ) {
            $l_finished = 1;
        } elsif ( $g_choice == 8 ) {
            $l_finished = 1;
        } elsif ( $g_choice == 9 ) {
            $l_finished = 1;
        }
    }




}

# End of main
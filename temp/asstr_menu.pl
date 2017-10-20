#!/home/aruba/bin/gnu/isqlperl
# use Test::Harness;
# use DB_File;
# use strict 'untie';
# Initial revision
#
#

use asstr;

&main ();
exit (0);

#-------------------------------------------------------------------------
#
#-------------------------------------------------------------------------
sub S_ScanModerated {
	my (@lTextArray, $lYear);

	# Call helper routine to return a list of all the story links
	# for a given year

	#for ( $lYear = 1997; $lYear < 2010; $lYear++ ) {
	#	@lTextArray = &asstr::getModeratedLinks ( year => $lYear );
	#}

	&asstr::getModeratedStories ( year => 1998, max_files => 100 );

}	# S_ScanModerated

#-------------------------------------------------------------------------
#
#-------------------------------------------------------------------------
sub S_ScanAuthors {
    my ($lLetter, $lObj);
    my (@lLetArray);

    @lLetArray = qw (M N O P Q R S T U V W X Y Z);
    @lLetArray = qw (A B C D E F G);
    foreach $lLetter ( @lLetArray ) {
        &asstr::getAuthors(letter => $lLetter);

    }



}   # S_ScanAuthors

#-------------------------------------------------------------------------
# Routine:      S_TestAuthorFileList
# Description:  Routine to exercise the new authorFileList routine
#-------------------------------------------------------------------------
sub S_TestAuthorFileList {
    my (@lFileArray);

    if ( 0 ) {
        @lFileArray = &asstr::authorFileList (
            author      => 'Major_Tom',
            base_url    => 'http://www.asstr.org/files/Authors/Major_Tom/',
            verbose     => 1,
        );
    }

    if ( 1 ) {
        @lFileArray = &asstr::authorFileList (
            author      => 'mack1137',
            base_url    => 'http://www.asstr.org/files/Authors/mack1137/',
            verbose     => 1,
        );
    }


}   # S_TestAuthorFileList


#-------------------------------------------------------------------------
#   Routine:        S_CleanAuthorFiles
#   Description:    This routine will find all the files in d:\temp\text_proc\ASSTR\new
#                   and do a basic cleanup on the files
#
#
#-------------------------------------------------------------------------
sub S_CleanAuthorFiles {
    &asstr::cleanAuthorFiles();
}   # S_CleanAuthorFiles


#-------------------------------------------------------------------------
# PrintMenu2 - Prints the menu
#-------------------------------------------------------------------------
sub PrintMenu2 {

    print "=============================================\n";
    print "              ASSTR Menu\n";
    print "             Site Utilitys\n";
    print "=============================================\n";
    print "Please choose an option:\n\n";
    print "\t1 - Scan Authors\n";
    print "\t2 - Scan ASSTR Moderated archive\n";
    print "\t3 - Test AuthorFileList\n";
    print "\t4 - \n";
    print "\t5 - Clean Author Files\n";
    print "\t6 - \n";
    print "\t7 - \n";
    print "\t8 - \n";
    print "\t9 - \n";
    print "\n\n";
    print "\t\tChoice: ";

}  # PrintMenu2


#-------------------------------------------------------------------------
# Menu - Provides a menu for choices.  Returns the choice number.
#  If the choice requires a path, this routine will ask for it and
#  error check the path before returning.  The path will be stored
#  in $g_Path;
#-------------------------------------------------------------------------
sub S_GetChoice {

    local ($l_finished) = 0;
    local ($l_choice) = 0;

    while ( $l_finished == 0) {
        &PrintMenu2 ();

        chop ($l_choice = <STDIN>);

        if ( ($l_choice >= 0) && ($l_choice < 10) ) {
            $l_finished = 1;
        }
    }
    $l_choice;

} # S_GetChoice


#----------------------------------------------------------
#  Main
#----------------------------------------------------------
sub main {
    my ($lChoice) = -1;
    my ($lFinished) = 0;

    # print "Hello World\n";
    # &FindSeries ("c:\\temp\\1\\dl");

    my ($lTemp) = $ARGV[0];
    if ( defined ($lTemp) and $lTemp != "" ) {
        $lChoice = $lTemp;
    }

    while ( $lFinished != 1 ) {

        if ( $lChoice == -1 ) {
            $lChoice = &S_GetChoice();
        }

        if ( $lChoice == "0" ) {
            $lFinished = 1;
        } elsif ($lChoice == "1") {
            &S_ScanAuthors();
        } elsif ($lChoice == "2") {
			&S_ScanModerated();
            $lFinished = 1;
        } elsif ($lChoice == "3") {
            &S_TestAuthorFileList();
            $lFinished = 1;
        } elsif ($lChoice == "4") {
            $lFinished = 1;
        } elsif ($lChoice == "5") {
            &S_CleanAuthorFiles ();
            $lFinished = 1;
        } elsif ($lChoice == "6") {
            $lFinished = 1;
        } elsif ($lChoice == "7") {
            $lFinished = 1;
        } elsif ($lChoice == "8") {
            $lFinished = 1;
        } elsif ($lChoice == "9") {
            $lFinished = 1;
        } elsif ($lChoice == "10") {
            $lFinished = 1;
        } elsif ($lChoice == "11") {
            $lFinished = 1;
        } elsif ($lChoice == "12") {
            $lFinished = 1;
        } elsif ($lChoice == "13") {
            $lFinished = 1;
        } elsif ($lChoice == "14") {
            $lFinished = 1;
        }
        $lChoice = -1;
    }


    my ($lRunTime) = time - $^T;

}

# End of main

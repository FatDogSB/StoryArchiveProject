
#!/home/aruba/bin/gnu/isqlperl
# use Test::Harness;
# use DB_File;
# use strict 'untie';
# Initial revision
#
#

use neatoUtil;
use LWP::UserAgent;
use WWW::Mechanize;
use File::Basename;
use asstr;

my $gBASE_DIR='d:\\temp\\1\\';
my $gBuffer = "";

my %gLE_URLS = ();

# This started at update.php?id=60

my $gBLBaseURL = 'http://neatopotato.net/xnovel/browse_series';
my $gBLIndexFile                                        = 'bl_index00.txt';
my $gBLOutputFile                                       = 'bd00.txt';

my $gUtilObj = undef;

&main ();
exit (0);


#-------------------------------------------------------------------------
# Routine:		ASSTRFetchRecentUploads
#-------------------------------------------------------------------------
sub S_ReadLocalFiles {
	my ($lUtilObj);
	
	if ( ! defined $gUtilObj ) {
		$gUtilObj = neatoUtil->new();
	}
	
	$gUtilObj->readLocalFiles( path => 'n:\\1\\1Backup\\xNovels' );	
	$gUtilObj->scanPotatoLinks ( url => $gBLBaseURL );

	#$gUtilObj->scanPotatoLinks ( url => $gBLBaseURL );
	
}	# ASSTRFetchRecentUploads


#-------------------------------------------------------------------------
# Routine:		ASSTRFetchRecentUploads
#-------------------------------------------------------------------------
sub ASSTRFetchRecentUploads {
	my ($lUtilObj);
	$lUtilObj = asstr->new();
	$lUtilObj->RFCollectRecent();
	
}	# ASSTRFetchRecentUploads


#-------------------------------------------------------------------------
# PrintMenu2 - Prints the menu
#-------------------------------------------------------------------------
sub PrintMenu2 {

    print "=============================================\n";
    print "              NeatoPotato Menu\n";
    print "              Utilitys\n";
    print "=============================================\n";
    print "Please choose an option:\n\n";
    print "\t1 - Read local files\n";
    print "\t2 - Read NeatoPotato\n";
    print "\t3 - \n";
    print "\t4 - \n";
    print "\t5 - \n";
    print "\t6 - \n";
    print "\t7 - \n";
    print "\t8 - \n";
    print "\t9 - \n";
    print "\t10 -\n";
	print "\t11 - \n";
	print "\t12 - \n";
	print "\t13 - \n";
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

        if ( ($l_choice >= 0) && ($l_choice <= 20) ) {
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
            &S_ReadLocalFiles();
            $lFinished = 1;
        } elsif ($lChoice == "2") {
        	&S_ScanSOL();
            $lFinished = 1;
        } elsif ($lChoice == "3") {
            $lFinished = 1;
        } elsif ($lChoice == "4") {
        	$lFinished = 1;
        } elsif ($lChoice == "5") {
        	&S_ImportLibrary();
            $lFinished = 1;
        } elsif ($lChoice == "6") {
        	&S_BreakBigFile ( input_file => 'bd06.txt', file_prefix => 'bdsml6_', size => 16); 
            $lFinished = 1;
        } elsif ($lChoice == "7") {
			&S_BDSMLDedup(new_file => 'bdsml_20150814.idx', prev_file => 'bdsml_20150801.idx');
            $lFinished = 1;
        } elsif ($lChoice == "8") {
        	&S_ScanLiterotica();
            $lFinished = 1;
        } elsif ($lChoice == "9") {
        	&S_LinkExperiment();
            $lFinished = 1;
        } elsif ($lChoice == "10") {
        	&S_EbookAuthors( dir => 'D:\\Temp\\Agent\\alt.binaries.e-book');
            $lFinished = 1;
        } elsif ($lChoice == "11") {
			&S_PipersDomain ( base_url => 'http://www.asstr.org/~Piper/', index_file => 'pipers_index.dat');
            $lFinished = 1;
        } elsif ($lChoice == "12") {
			&ASSTRRecentUploads();
            $lFinished = 1;
        } elsif ($lChoice == "13") {
			&ASSTRFetchRecentUploads();
            $lFinished = 1;
        } elsif ($lChoice == "14") {
            $lFinished = 1;
        }
        $lChoice = -1;
    }


    my ($lRunTime) = time - $^T;

}

# End of main

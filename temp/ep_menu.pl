
#!/home/aruba/bin/gnu/isqlperl
# use Test::Harness;
# use DB_File;
# use strict 'untie';
# Initial revision
#
#

use LWP::UserAgent;
use WWW::Mechanize;
use File::Basename;

my $gBASE_DIR='d:\\temp\\1\\redass\\';
my $gBuffer = "";

&main ();
exit (0);


#-------------------------------------------------------------------------
# Routine:		S_ScanDirs
#-------------------------------------------------------------------------
sub findFiles {
	my (%args) = @_;
	my ($lBaseDir);
	my ($lDirName, $lFile, $lFullPath, $lCmd, $lNewName, $lCount);
	
	$lBaseDir = $args{dir};
	chdir ($lBaseDir) or die ("Error: Could not chdir to : $lBaseDir : $!\n");
	
	# Now we should see a bunch of sub-dirs like 
	# clip
	$lCount = 1;
	print "Looking in $lBaseDir\n";
	foreach $lDirName ( sort glob "*" ) {
		print "\t\t$lDirName\n";
		
		# Use this dir name as the file name
		$lNewName = "RedAss-" . $lDirName . "_$lCount.mpg";
		$lCount++;
		print "New name: $NewName\n";

		$lCmd = "copy \"$lFullPath\\$lDirName\"                  \"$gBASE_DIR${lNewName}\"";
		$gBuffer .= $lCmd . "\n";
		
		next;
		chdir ($lDirName);
		$lFullPath = $lBaseDir . '\\' . $lDirName;
		
		foreach $lFile ( glob ("*.mpg") ) {
		
		}
		
		chdir ("..");
	}
	
}	# findFiles

#-------------------------------------------------------------------------
# Routine:		S_ScanDirs
#-------------------------------------------------------------------------
sub S_ScanDirs {
	my (@lDirList, $lDir);
	
	print "BaseDir: $gBASE_DIR\n";
	chdir ($gBASE_DIR) or die ("Error: Could not chdir to base dir: $gBASE_DIR : $!\n");
	foreach $lDir ( sort glob "*") {
		print "Found dir: $lDir\n";
		next if (index ($lDir, '.bat') > -1);
		push (@lDirList, $lDir);
		
		&findFiles( dir => $gBASE_DIR . $lDir );
	}
	
	# Create output batch file
	chdir ($gBASE_DIR);
	my $lBatchFileName = $gBASE_DIR . "ep_copy.bat";
	open (BATCH_FILE, ">$lBatchFileName");
	print BATCH_FILE $gBuffer . "\n";
	close (BATCH_FILE);
	
	print "Batch file created: $lBatchFileName\n";
	
}	# S_ScanDirs

#-------------------------------------------------------------------------
#-------------------------------------------------------------------------
sub S_ScanSOL {
	my ($lUA, $lURL, @lURLArray, $lResponse);
	
	push (@lURLArray, 'http://storiesonline.net/s/56730:77452');
	push (@lURLArray, 'http://storiesonline.net/s/56730:77452;1');
	push (@lURLArray, 'http://storiesonline.net/s/56730:77452;2');
	push (@lURLArray, 'http://storiesonline.net/s/56730:77472');		# Chapter 2

	$lURL = "http://storiesonline.net/s/56730:77452";
	
	my $lMech = WWW::Mechanize->new(
		agent 		=> 'Mozilla/5.0',
		cookie_jar 	=> {}
	);
	$lMech->agent_alias( 'Windows IE 6' );
	
	my $lURLLogin = 'http://storiesonline.net/login.php?';
	$lMech->get ($lURLLogin);
	$lMech->submit_form (
		form_number => 1,
		fields		=> {
			theusername	=> 'FatDog69',
			thepassword => 'bm1492!',
		},
		button		=> 'Login',
		
	);
	
	return;
	
	my $lUA = LWP::UserAgent->new;
	$lUA->timeout(10);
	$lUA->env_proxy();
	$lUA->agent('Mozilla/5.0');
	
	$lResponse = $lUA->get($lURL);
	
	if ( $lResponse->is_success ) {
		print "Got url: $lURL\n";
		my $lTemp = $lResponse->decoded_content();
		print "$lTemp\n";
	} else {
		die $lResponse->status_line;
	}
}	# S_ScanSOL

#-------------------------------------------------------------------------
#-------------------------------------------------------------------------
sub S_DedupEpub {
	my ($lCatalogDir, $lEpubDir, $lDupDir) = ('D:\1\ebook', 'D:\temp\agent\alt.binaries.e-book', 'D:\temp\agent\alt.binaries.e-book\duplicate');
	my (%lFileHash, $lFile, $lFileCount, $lRow, $lFileName, $lDupCount);
	
	if ( ! -e $lCatalogDir ) {
		print "Environment Error: catalog dir does not exist: $lCatalogDir\n";
		return;
	}

	if ( ! -e $lEpubDir ) {
		print "Environment Error: epub dir does not exist: $lCatalogDir\n";
		return;
	}

	# Get a list of all the current .rar files
	print "Scanning for download ebook .rar files ...\n";
	chdir ($lEpubDir) or die ("Error: Could not chdir to epub dir: $lEpubDir : $!\n");
	foreach $lFile ( glob ("*.*") ) {
		$lFileHash{$lFile} = 1;
		$lFileCount++;
	}
	
	print sprintf ("Total epub files found: $lFileCount\n");
	
	# Now go read the various catalog.txt files
	
	chdir ( $lCatalogDir ) or die ("Error: Could not chdir to catalog dir: $lCatalogDir : $!\n");
	foreach $lFile ( sort glob ("*.txt") ) {
		print "Reading catalog file: $lFile...\n";
		open (CAT_FILE, $lFile) or die ("Error: Could not open file for input: $lFile : $!\n");
		while ($lRow = <CAT_FILE>) {
			chomp ($lRow);
			my ($name, $dir, $ext);
			#($name, $dir, $ext) = fileparse($lRow, '\..*');
			$name = basename($lRow);
			#print "$name\n";
			if ( exists $lFileHash{$name} ) {
				#print "\texists : $name\n";
				$lFileHash{$name} = 0;
				$lDupCount++;
			}
		}
		close(CAT_FILE);
	}
	
	print "Total Dup Count: $lDupCount\n";
	
	chdir ($lEpubDir) or die ("Error: Could not chdir to epub dir: $lEpubDir : $!\n");
	my $lBatFile = "dedup.bat";
	open (OUT_FILE, ">$lBatFile") or die ("Error: could not open bat file for output: $lBatFile : $!\n");
	foreach $lFile ( sort keys %lFileHash ) {
		next if ( $lFileHash{$lFile} == 1) ;
		
		print OUT_FILE "move \"$lFile\" $lDupDir\n";
		
	}
	
	close (OUT_FILE);
	print "Batch file created: $lBatFile\n";
	
}	# S_DedupEpub
#-------------------------------------------------------------------------
# PrintMenu2 - Prints the menu
#-------------------------------------------------------------------------
sub PrintMenu2 {

    print "=============================================\n";
    print "              EP Menu\n";
    print "              Utilitys\n";
    print "=============================================\n";
    print "Please choose an option:\n\n";
    print "\t1 - Scan Dirs\n";
    print "\t2 - Read StoriesOnLine\n";
    print "\t3 - \n";
    print "\t4 - \n";
    print "\t5 - \n";
    print "\t6 - \n";
    print "\t7 - Dedupe e-book folder\n";
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
            &S_ScanDirs();
            $lFinished = 1;
        } elsif ($lChoice == "2") {
        	&S_ScanSOL();
            $lFinished = 1;
        } elsif ($lChoice == "3") {
            $lFinished = 1;
        } elsif ($lChoice == "4") {
            $lFinished = 1;
        } elsif ($lChoice == "5") {
            $lFinished = 1;
        } elsif ($lChoice == "6") {
            $lFinished = 1;
        } elsif ($lChoice == "7") {
			&S_DedupEpub();
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

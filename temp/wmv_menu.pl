#!/home/aruba/bin/gnu/isqlperl
# use Test::Harness;
# use DB_File;
# use strict 'untie';
# Initial revision
#
#

#use Image::ExifTool qw(:Public);
#use Dumper;
use File::Basename;

&main ();
exit (0);


#-------------------------------------------------------------------------
#-------------------------------------------------------------------------
sub S_ScanWMV {
	my (%args) = @_;
	my ($lPattern, @lFileList, $lFile, $lRowCount, $lFileInfo, $lKey);
	my ($lCmd, $lNewName, $lTitle, @lCmdArray);

	
	chdir ($args{path}) or die ("Error: could not chdir to directory: $args{path} : $!\n");
	
	foreach $lFile ( sort glob ($args{pattern}) ) {
		
		$lFileInfo = ImageInfo($lFile);
		if ( 0 ) {
		
			foreach $lKey ( sort keys %{$lFileInfo} ) {
				print "$lKey  = ${$lFileInfo}{$lKey}\n";
			}
		}
		$lTitle = ${$lFileInfo}{Title};
		$lNewName = "RedStripe-$lTitle-$lFile";
		#print sprintf ("%-12s : %s\n", $lFile, $lNewName);
		
		$lCmd = sprintf ("rename \"%s\"   \"%s\"", $lFile, $lNewName);
		push (@lCmdArray, $lCmd);
		#print "$lCmd";
		
		$lRowCount++;
		#last if ($lRowCount > 5);
	}
	
	open (BAT_FILE, ">fix_redstripe.bat") or die ("Error: Could not open file for output: fix_redstripe.bat : $!\n");
	foreach $lCmd ( @lCmdArray ) {
		print BAT_FILE "$lCmd\n";
	}
	close (BAT_FILE) or die ("Error: could not close batch file: $!\n");
	print "Batch file fix_redstripe.bat created\n";
}	# S_ScanWMV

#-------------------------------------------------------------------------
# Routine:		indexPosters
# Description:	This routine will take a directory and scan for video files
#				and extract the posters name that is usually the prefix on the
#				file name and put it into the parents hash
#
# Inputs:		hash - pointer to Hash
#				dir  - Diretory to scan
#-------------------------------------------------------------------------
sub indexPosters {
	my (%args) = @_;
	my (@lExtensionArray, $lFile, $lExt, $lPoster, $lKey);
	
	print "Scanning $args{dir} ...\n";
	@lExtensionArray = ('*.flv', '*.mov', '*.mp4');
	
	chdir ($args{dir}) or die ("Error: Could not chdir to directory: $args{dir} : $!\n");
	
	foreach $lExt ( @lExtensionArray ) {
		foreach $lFile ( sort glob ($lExt) ) {
			if ( index ($lFile , '-') > -1 ) {
				my @lTemp = split ('-', $lFile);
				$lKey = lc($lTemp[0]);

				${$args{hash}}{$lKey}{poster} = $lTemp[0];
				${$args{hash}}{$lKey}{count}++;
				${$args{hash}}{$lKey}{size} += -s $lFile;
				${$args{hash}}{$lKey}{title} .= "\t$lFile\n";
				
			}
		}
	}


}	#indexPosters

#-------------------------------------------------------------------------
#-------------------------------------------------------------------------
sub S_IndexPosters {
	my ($lKey, $lTotalSize);
	my %lPosterHash = ();
	
	&indexPosters(hash => \%lPosterHash, dir => "c:\\upgrades");
	&indexPosters(hash => \%lPosterHash, dir => "D:\\Temp\\1\\1xHamster");
	&indexPosters(hash => \%lPosterHash, dir => "N:\\1\\DONE-AVI-BD-560");
	&indexPosters(hash => \%lPosterHash, dir => "N:\\1\\DONE-AVI-BD-562");
	
	foreach $lKey ( sort keys %lPosterHash ) {
		#print sprintf ("%25s = %d files\n", $lPosterHash{$lKey}{poster}, $lPosterHash{$lKey}{count});
		print sprintf ("%-25s = %s \n", $lPosterHash{$lKey}{poster}, $lPosterHash{$lKey}{title});
		
		$lTotalSize += $lPosterHash{$lKey}{size};
	}
	
	my $lMegs = int ($lTotalSize / (1024 * 1024));
	print "Total Megs: $lMegs\n";
}	# S_IndexPosters

#-------------------------------------------------------------------------
#-------------------------------------------------------------------------
sub recurse {
	my ($path) = @_;
	
	#print "\tWorking in $path\n";
	
	# Append trailing slashs if not there
	$path .= "\\" if ( $path !~ m!/\/\$! );
	print "recurse: path = $path\n";
	
	# Loop through the files contained in the directory
	foreach my $lFile ( sort glob($path . '*' )) {
		print "Raw file: $lFile\n";
		# If the file is a directory
		if ( -d $lFile ) {
			print "$lFile\n";
			&recurse( $lFile );
			
		} else {
		
			my $lBaseName = basename($lFile);
			if ($lFile =~ m/\d\.jpg/) {
				print "\t$lFile\n";
			}
			if ( $lBaseName =~ m/\d\./ ) {
				print "\t\t$lFile\n";
			}
		}
		
	
	}
	
}	# recurse


#-------------------------------------------------------------------------
# Routine:		handle_file_2
# Description:	This routine is designed to examine a basename of a file,
#				copy it to a NewName variable, then decide if it needs 
#				changing or not.
#-------------------------------------------------------------------------
sub handle_file_2 {
	my ($aFile) = @_;
	my $lBaseName = basename($aFile);
	my ($lNewName);
	
	$lNewName = $lBaseName;
	
	if ($lNewName eq 'Download Adult Comics----shentai.org') {
		unlink ($lNewName);
		return;
	}

	if ($lNewName eq 'readme.txt') {
		unlink ($lNewName);
		return;
	}
	
	# Remove "_shentai.org" from the file name if it exists
	$lNewName =~ s/_shentai.org//g;
	$lNewName =~ s/shentai.org_//g;
	
	# Look for "1.jpg" and change to "01.jpg"
	$lNewName = '0' . $lNewName if ($lNewName =~ m/^\d\./);
	
	# Look for: "Catwalker_3.jpg" and change to "Catwalker_03.jpg"
	if ($lNewName =~ m/_\d\./ ) {
		$lNewName =~ s/_(\d)\./_0$1./;
	}
	
	# Look for: "0 (2)_shentai.org" and update page number to: "0 (02)_shentai.org"
	if ($lNewName =~ m/\(\d\)/ ) {
		$lNewName =~ s/\((\d)\)/\(0$1\)/;
	}
	
	if ( $lNewName ne $lBaseName ) {
		print "2test rename: $lBaseName to $lNewName\n";
	}
}	# handle_file_2

#-------------------------------------------------------------------------
#-------------------------------------------------------------------------
sub handle_file {
	my ($aFile) = @_;
	
	my $lBaseName = basename($aFile);
	if ( 1 ) {
		# Look for 1.jpg, 2.jpg etc
		if ($lBaseName =~ m/^\d\.jpg/) {
			my $lNewName = "0" . $lBaseName;
			rename ($lBaseName, $lNewName);
		}
		
		if ($lBaseName =~ m/1 \((\d+)\)/ ) {
			my $lNewName = sprintf ("%03d.jpg", $1);
			rename ($lBaseName, $lNewName);
		}
		if ( $lBaseName =~ m/ \((\d+)\)/ ) {
			my $lOldNum = $1;
			my $lNewName = $lBaseName;
			my $lNewNum = sprintf ("%03d", $lOldNum);
			$lNewName =~ s/\($lOldNum\)/\($lNewNum\)/;
			rename ($lBaseName, $lNewName);
		}
		
		# Look for "6_shentai.org.png" and add leading zeros
		if ( $lBaseName =~ m/^(\d)_/ ) {
			my $lNewName = '0' . $lBaseName;
			rename ($lBaseName, $lNewName);
		}
	
		# Look for "analyze-girl-3-1.jpg" and add leading zeros
		if ( $lBaseName =~ m/\-\d\-\d\./ ) {
			my $lNewName;
			$lNewName = $lBaseName;
			$lNewName =~ s/\-(\d)\./-0$1./g;
			rename ($lBaseName, $lNewName);
		}
		
		# Look for: Weird Family_8_shentai.org
		if ( $lBaseName =~ m/_\d_/ ) {
			$lNewName = $lBaseName;
			$lNewName =~ s/_(\d)_/_0$1_/g;
			rename ($lBaseName, $lNewName);
		}
	
	}
	
	if ( 0 ) {
		if ( $lBaseName =~ m/\.cbz$/ ) {
			print "$path $lBaseName\n";
		}
	}

}	# handle_file

#-------------------------------------------------------------------------
#-------------------------------------------------------------------------
sub recurse2 {
	my ($path) = @_;
	
	print "\tWorking in $path\n";
	chdir ($path);
	# Append trailing slashs if not there
	
	$path .= "\\" if ( $path !~ m!/\/\$! );
	
	# Loop through the files contained in the directory
	foreach my $lFile ( sort glob('*')) {
		# If the file is a directory
		if ( -d $lFile ) {
			&recurse2( $path . $lFile );
			chdir ($path);
			
		} else {
			&handle_file ($lFile);
		}
	
	}
	
}	# recurse2


#-------------------------------------------------------------------------
#-------------------------------------------------------------------------
sub S_RecursiveRename {
	my (%args) = @_;
	
	# Try accessing the starting path 
	if ( ! -e $args{path} ) {
		print "Argument Error: Starting path does not exist: $args{path}\n";
		return;
	}
	
	chdir ($args{path}) or die ("Error: Could not chdir to starting path: $args{path} : $!\n");
	print "Starting recursive rename at: $args{path}...\n";
	
	recurse2 ($args{path});
	
}	# S_RecursiveRename

#-------------------------------------------------------------------------
# Routine:		S_CreateCBZBat
# Description:	This routine will go to a folder, find all the sub-folders and create a BAT
#				file that will compress all the sub-folders to a .cbz file.
#
# Inputs:		bat_file - name of bat file to create
#				path - path to parent / incoming folder to examine for sub folders
#-------------------------------------------------------------------------
sub S_CreateCBZBat {
	my (%args) = @_;
	my (@lDirArray, $lFile, $lCmd, $lCBZFile);
	
	chdir ($args{path}) or die ("Error: Could not chdir to parent dir: $args{path} : $!\n");
	if ( -e $args{bat_file} ) {
		unlink ( $args{bat_file} ) or die ("Error: Could not remove pre-existing bat file: $args{bat_file} : $!\n");
	}

	print "Scanning path: $args{path} ...\n";
	
	foreach $lFile ( sort glob ('*') ) {
		next if ( ! -d $lFile );
		next if ( index ($lFile, 'FILES') > -1);
		
		$lCBZFile = $lFile;
		if ( length ($args{prefix}) > 2 ) {
			$lCBZFile = $args{prefix} . " - $lCBZFile";
		}
		print "\t$lCBZFile\n";
		
		$lCmd = 'winrar m -rzip "' . $lCBZFile . '.cbz" "' . $lFile . '"';
		push (@lDirArray, $lCmd);
	}
	
	open (BAT_FILE , ">$args{bat_file}") or die ("Error: Could not open file for output: $args{bat_file} : $!\n");
	foreach $lCmd ( @lDirArray ) {
		print BAT_FILE "$lCmd\n";
	}
	close(BAT_FILE);
	
	print "Bat file created: $args{bat_file}\n";
	
}

#-------------------------------------------------------------------------
# PrintMenu2 - Prints the menu
#-------------------------------------------------------------------------
sub PrintMenu2 {

    print "=============================================\n";
    print "              WMV Menu\n";
    print "             Site Utilitys\n";
    print "=============================================\n";
    print "Please choose an option:\n\n";
    print "\t1 - Scan WMV\n";
    print "\t2 - \n";
    print "\t3 - \n";
    print "\t4 - \n";
    print "\t5 - \n";
    print "\t6 - Index xHamster\n";
    print "\t7 - \n";
    print "\t8 - Rename 1.jpg, 2.jpg to 01.jpg, 02.jpg\n";
    print "\t9 - Create BAT file to compress folders to .cbz files\n";
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
            &S_ScanWMV( path => 'd:\\temp\\1', pattern => "spr-*.wmv");
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
        	&S_IndexPosters();
            $lFinished = 1;
        } elsif ($lChoice == "7") {
            $lFinished = 1;
        } elsif ($lChoice == "8") {
			#&S_RecursiveRename(path => 'D:\\temp\\1\\1Comix\\1images');
			&S_RecursiveRename(path => 'D:\\temp\\1\\agent\\alt.binaries.pictures.erotica.comics');
            $lFinished = 1;
        } elsif ($lChoice == "9") {
			#&S_CreateCBZBat( path => 'D:\\temp\\1\\agent\\alt.binaries.pictures.erotica.comics\\FOXER', bat_file => 'fix.bat');
			#&S_CreateCBZBat( path => 'D:\\temp\\1\\1comix\\1images\\BDSM', bat_file => 'fix.bat');
			&S_CreateCBZBat( 
				path => 'D:\temp\1\agent\alt.binaries.pictures.erotica.comics', 
				bat_file => 'milftoon.bat',
				prefix => '');
			
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

#   File: Finddup.pl
#
$gDLPath        = "c:\\Temp\\1";
$gArchiveDir    = "C:\\Temp\\1\\Archive";
$gSpamDir       = "C:\\temp\\1\\spam";
$gNewSpamDir	= "C:\\temp\\1\\newspam";
$gDupDir        = "C:\\temp\\1\\Dup";
$gNewsDir		= "D:\\temp\\news";
$gDLDir         = "C:\\temp\\1\\dl";
$gToViewDir     = "C:\\temp\\1\\ToView";
$gAgentDir      = "C:\\temp\\1\\agent";

$gDLCrcFile		= "C:\\dl.crc";
$gArchiveFile	= "C:\\archive.crc";
$gSpamFile		= "C:\\SPAM.CRC";
$gTempFile1		= "C:\\temp1.crc";
$gTempFile2		= "C:\\temp2.crc";
$gDate			= "";

$gMergeDir		= "D:\\temp\\1";

# This is an array of path-names & prefix strings for each file. A
# routine will find all the files in these dirs and add the prefix.

@gFilePrefixArray = (   "$gDLDir\\t\\at|AT",
                        "$gDLDir\\t\\aw|AW",
                        "$gDLDir\\t\\sdt|SDT",
                        "$gDLDir\\t\\mm|MM"
                    );

&main ();
exit (0);



#----------------------------------------------------------
#  S_BuildTable - This routine will call the buildtable
#  script to build the indicated table.
#
#----------------------------------------------------------
sub S_BuildTable {
    local ($l_dbname) = @_[0];
    local ($l_tablename) = @_[1];

    # See if the specified table already exists
    if ( &S_TableExists ($l_dbname, $l_tablename) == $TRUE )
    {
        print "Cannot create $l_tablename because it already exists\n";
        return $FALSE;
    }


    # Get full paths for things.  Sorry about the imbeded paths
    local ($l_sqlfile) = "/home/aruba/bin/sql/$l_tablename.sql";

    local ($l_tabledate) = "4/11/1997";

    # The command for buildtable is:
    #   buildtable  database-name  sql-file  table-date
    local ($l_cmd) =
    "/home/aruba/bin/scripts/buildtable $l_dbname  $l_sqlfile  $l_tabledate";

    system ($l_cmd);

    if ( &S_TableExists ($l_dbname, $l_tablename) == $TRUE ) {
        print "$l_tablename table built\n";
        return $TRUE;
    }
    print "Error: Could not build: $l_tablename\n";
    return $FALSE;

}   #S_BuildTable


#-------------------------------------------------------------------------
#  BuildCRCList
#  This routine will take a path and try to get the CRC of every file
#  in the path.  It will put the crcs in a file aDest sorted by the
#  32-bit CRC and file size value.
#  Ex)   BuildCRCList ("\\temp", "\\bob.crc")
#		will put the CRC of every file in \temp into the bob.crc file with
#		all the rows sorted.
#-------------------------------------------------------------------------
sub BuildCRCList {
	local ($aPath, $aDest) = @_;
	local ($lname, $lcrc16, $lSize, $lcrc32, $lCount, $lIndex);
	local (%lFilelist);
	local ($lOutCount, $lDupCount);


	# Get the CRC's of the new file
	print ("Getting CRC of $aPath\\*.* into $aDest\n");

	open (INFILE, "crc $aPath\\*.* |");
	$lCount = 0;
	$lDupCount = 0;
	while ( <INFILE> )
	{
		chop;
		# Only lines with data should have the string "crc32="
		if ( /crc32=/ )
		{
			$lCount++;
			$lname = substr ($_, 9, 12);
			$lname =~ s/ *$//g;		# Trim trailing spaces
			$lcrc16 = substr ($_, 29, 4);
			$lcrc32 = substr ($_, 41, 8);

			# Get the size of the file
			$lSize  = -s $aPath . "\\" . $lname;

			# Create the index from the CRC and size
			$lIndex = $lcrc32 . "-" . $lsize;


			# print "Name=$lname   Size=$lSize  CRC=$lcrc32 Index=$lIndex\n";

			# Add the file to our array if it does not already exist
			if ( $lFileList{$lIndex} ) {
				# Opps. Found a duplicate
				rename ("$aPath\\$lname", "$gDupDir\\$lname");
				$lDupCount++;
			} else {
				$lFileList{$lIndex} = $lcrc32 . "," . $lSize .",". $lname . ",Test";
			}
		}
	}

	close (INFILE);

	# Now get our array back in a sorted fashion
	print "Writing $lCount CRC's to $aDest\n";
	open (OUTFILE, ">$aDest");

	local ($lrow);
	foreach $lrow (sort (keys %lFileList)) {
		print OUTFILE "$lFileList{$lrow}\n";
		$lOutCount++;
		delete $lFileList{$lrow};
	}
	close (OUTFILE);

	print "$lOutCount actually written, $lDupCount moved to DUP!\n";
}  # BuildCRCList


#-------------------------------------------------------------------------
#  CompDLToList2
#  This routine will open the download CRC file and compare it to either
#  the ARCHIVE.CRC or SPAM.CRC files.
#  Every downloaded file that we have already seen will be moved to the
#  destination directory.
#   Ex) We have dl a file temp.jpg.  but this file has already been seen
#   in the ARCHIVE.CRC file.  This routine will move temp.jpg to
#	\archive\temp.jpg.
#-------------------------------------------------------------------------
sub CompDLToList2 {
    local ($aMasterFile, $aSrcDir, $aTargetDir) = @_;
	local ($lDLFile, $lArcFile);
	local ($lDLCrc, $lDLSize, $lDLName, $lArcCrc, $lArcSize, $lArcName);
	local ($lDLCount, $lArcCount) = 0;
    local ($lCmd);

	print "Comparing download $gDLCrcFile to Archive $aMasterFile..\n";


	# Open download.CRC and load all the data into a local array
	open (DOWNLOAD, $gDLCrcFile) || die ("Cannot open $gDLCrcFile\n");
	local (%lDLlist);
	$lDLCount = 0;
	while ( <DOWNLOAD> ) {
		($lDLCrc, $lDLSize, $lDLName) = split (/\,/, $_);
		$lDLlist{$lDLCrc . $lDLSize} = $_;
		$lDLCount++;
	}
	close (DOWNLOAD);

	print "$lDLCount rows read from $gDLCrcFile\n";

	open (ARCHIVE, $aMasterFile) || die ("Cannot open $aMasterFile\n");
	while ( <ARCHIVE> )
	{
		($lArcCrc, $lArcSize) = split (/\,/, $_);
		if ( $lDLlist{$lArcCrc . $lArcSize} )
		{
			($lDLCrc, $lDLSize, $lDLName) = split (/\,/, $lDLlist{$lArcCrc . $lArcSize});
            # rename ("$gDLPath\\$lDLName", "$aTargetDir\\$lDLName");
            $lCmd = "move /Y $aSrcDir\\$lDLName $aTargetDir";
            print "$lCmd\n";
			system ($lCmd);
		}
	}

	close (ARCHIVE);

}	# CompDLToList2


#-------------------------------------------------------------------------
#  Process New Files
#  This routine will try to collect the CRC's of the new files, then
#  it will move the ones we have seen to the Archive directory, and the
#  ones we think are SPAM to the SPAM directory.
#-------------------------------------------------------------------------
sub ProcessNewFiles {

	# Get the CRC's of the new files
	# $gDLPath = "\\temp2";
	# $gDLCrcFile = "\\bob.crc";

	&BuildCRCList ($gDLPath, $gDLCrcFile);

	# Compare the CRC's to ARCHIVE
    &CompDLToList2 ($gArchiveFile, $gDLPath, $gArchiveDir);

	# Compare the CRC's to SPAM
    &CompDLToList2 ($gSpamFile, $gDLPath, $gSpamDir);

}  # ProcessNewFiles


#-------------------------------------------------------------------------
# S_CleanUpDLDir
#  This routine will try to collect the CRC's of the new files, then
#  it will move the ones we have seen to the Archive directory, and the
#  ones we think are SPAM to the SPAM directory.
# Everything else is moved to the ..\toview directory
#-------------------------------------------------------------------------
sub S_CleanUpDLDir {

    &BuildCRCList ($gDLDir, $gDLCrcFile);

	# Compare the CRC's to ARCHIVE
    &CompDLToList2 ($gArchiveFile, $gDLDir, $gArchiveDir);

	# Compare the CRC's to SPAM
    &CompDLToList2 ($gSpamFile, $gDLDir, $gSpamDir);

    # Now move everything left to the ..\\ToView dir
    local (@lFileList) = glob ("$gDLDir\\*.*");
    local ($lFile, $lCmd);
    foreach $lFile (@lFileList) {
        $lCmd = "move /Y $lFile $gToViewDir";
        system ($lCmd);
    }

}  # S_CleanUpDLDir

#-------------------------------------------------------------------------
#  AddFiles2CRC2
#-------------------------------------------------------------------------
sub AddFiles2CRC2 {
	local ($aCrcFile, $aPath) = @_;
	local ($i, $j, $k, $last, $lRow);

	# Build a list of all the CRC's in the path in sorted order
	&BuildCRCList ($aPath, $gDLCrcFile);

	print "Opening output $gTempFile1\n";
	open (OUTFILE, ">$gTempFile1") || die ("Cannot open $gTempFile1 for output\n");

	# Open the two files and merge them into one
	print "Opening input $aCrcFile (j) \n ";
	open (FILE1, "$aCrcFile")      || die ("Cannot open $aCrcFile\n");
	$last = "";
	while ( <FILE1> ) {
		$lRow = $_;
		if ( $last NE substr ($lRow, 0, 12) ) {
			$last = substr ($lRow, 0, 12);
			print OUTFILE "$lRow";
		} else {
			print "Found dup crc\n";
		}
	}
	close (FILE1);


	print "Opening input $gDLCrcFile (j) \n ";
	open (FILE1, "$gDLCrcFile")      || die ("Cannot open $gDLCrcFile\n");
	$last = "";
	while ( <FILE1> ) {
		$lRow = $_;
		if ( $last NE substr ($lRow, 0, 12) ) {
			$last = substr ($lRow, 0, 12);
			print OUTFILE "$lRow";
		} else {
			print "Found dup crc\n";
		}
	}
	close (FILE1);
	close (OUTFILE);

	# Now the new file should be as big as the two original files
	# If not, dont sort
	$i = -s $gTempFile1;
	$j = -s $gDLCrcFile;
	$k = -s $aCrcFile;

	if ( $i >= (($j + $k)/2) )	{
		print "The new file is OK\n";
		system ("sort $gTempFile1 > $aCrcFile");
		print "$aCrcFile has been updated\n";
	} else {
		print "Error: $gTempFile1 had a problem \n";
	}


}	# AddFiles2CRC2

#-------------------------------------------------------------------------
#  AddFiles2CRC
#-------------------------------------------------------------------------
sub AddFiles2CRC {
	local ($aCrcFile, $aPath) = @_;
	local ($lDLCrc, $lDLSize, $lDLName, $lArcCrc, $lArcSize, $lArcName);
	local ($i, $j, $lFinished);

	# Build a list of all the CRC's in the path in sorted order
	# &BuildCRCList ($aPath, $gDLCrcFile);

	# Open the two files and merge them into one
	print "Opening input $gDLCrcFile (i)\n";
	open (FILE1, "<$gDLCrcFile")    || die ("Cannot open $gDLCrcFile\n");
	print "Opening input $aCrcFile (j) \n ";
	open (FILE2, "<$aCrcFile")      || die ("Cannot open $aCrcFile\n");

	print "Opening output $gTempFile1\n";
	open (OUTFILE, ">$gTempFile1") || die ("Cannot open $gTempFile1 for output\n");
	$lFinished = 0;
	$i = <FILE1>;
	$j = <FILE2>;
	while ( $lFinished == 0 ) {

		if ( substr ($i, 0, 11) LT substr ($j, 0, 11) )	{
			print OUTFILE "$i";
			$i = <FILE1>;
		} else {
			print OUTFILE "$j";
			$j = <FILE2>;
		}

	}

	close (FILE1);
	close (FILE2);
	close (OUTFILE);

}	# AddFiles2CRC


#-------------------------------------------------------------------------
#  AddArcSpam
#  This routine will add the contents of the current download directory
#  to the ARCHIVE.CRC file, and the contents of the NEWSPAM directory
#  to the SPAM.CRC file
#-------------------------------------------------------------------------
sub AddArcSpam {
	# Add the contents of the download directory to the ARCHIVE.CRC file
	&AddFiles2CRC2 ($gArchiveFile, $gDLPath);

	# Now the new spam files
	&AddFiles2CRC2 ($gSpamFile, $gNewSpamDir);

}	# AddArcSpam

#-------------------------------------------------------------------------
# MergeDirs - This routine will look at the individual directories and
#	attempt to merge all the files into a single directory.
#-------------------------------------------------------------------------
sub MergeDirs {
	local ($aSrc, $aDest) = @_;
	local ($lRow, $lFile, $lNewFile);
	local ($lDestSize, $lOrigSize);

	# Use the DOS dir command to give us a list of files
	print "Scanning $aSrc...\n";
	system ("dir /s/b/A-d $aSrc > $gTempFile1");

	open (DOWNLOAD, $gTempFile1) || die ("Cannot open dir list file ($gTempFile1)\n");
	while ( <DOWNLOAD> ) {
		chop;
		$lRow = $_;
		$lFile = $lRow;
		$lFile =~ s/(.*\\)//;		# Trim off the path

		# Construct the new path
		$lNewFile = $aDest . "\\" . $lFile;

		# See if a file already exists with the same name
		if ( ($lDestSize = -s $lNewFile) ) {
			# File already exists
			$lOrigSize = -s $lRow;
			print "File: $lFile -- Orig size = $lOrigSize,  Dest size = $lDestSize\n";
			if ( $lOrigSize == $lDestSize ) {
				# The two files have the same size, so they are probably
				# the same.  Overwrite

				rename ("$lRow", "$lNewFile");
			} else {
				print "Skipping $lFile\n";
			}
		} else {
			rename ("$lRow", "$lNewFile");
		}
	}


}	# MergeDirs


#-------------------------------------------------------------------------
# FindDupDL
#-------------------------------------------------------------------------
sub FindDupDL {
	local ($lCrc, $lSize, $lLast, $lRow);

	print "Looking for duplicate CRC's\n";

	&BuildCRCList ($gDLPath, $gDLCrcFile);

} # FindDupDL

#-------------------------------------------------------------------------
# S_AddFileNamePrefix
# There are several directories under the DL directory where files from
# specific studios go. We want to rename these. So if a file is in the
# "AW" directory, we want each file to be called "AW-xxxxx".
#-------------------------------------------------------------------------
sub S_AddFileNamePrefix {
    local ($lRow, $lDir, $lPrefix, $lFile, $lFullName, $lNewName);
    local (@lRawFiles, @lFiles);

    foreach $lRow (@gFilePrefixArray) {

        # Break out the path & prefix into separate variables

        ($lDir, $lPrefix) = split (/\|/, $lRow);

        print "Looking in ($lDir) for files to rename ...\n";

        # Get an array of all the files, then copy over file names
        # that dont already start with the prefix.

        @lRawFiles = glob ("$lDir\\*.j*");   # Array of "c:\temp\1\dl\t\aw\foo.jpg"..
        # print "@lRawFiles\n";
        @lFiles = ();

        foreach $lFullName (@lRawFiles) {
            # Separate the file name from the full path name
            $lFile = $lFullName;    # "C:\temp\1\dl\t\at\foo.jpg"
            $lFile =~ s/^.*\\//;    # "foo.jpg"

            # Make sure this file name does not already start with the prefix

            if ( $lFile =~ m/^$lPrefix/ ) {
                # print "Prefix ($lPrefix) match: $lFile\n";
            } else {
                push (@lFiles, $lFile);
                # print "$lDir - $lFile\n";
            }
        }

        # The @lFiles array has all our file names we want to rename.

        foreach $lFile (@lFiles) {
            $lNewName = $gDLDir . "\\" . $lPrefix . "-" . $lFile;

            # See if the file exists in the DL dir.

            if ( -e $lNewName ) {
                # Try an under-score instead of a dash
                $lNewName = $gDLDir . "\\" . $lPrefix . "_" . $lFile;
            }

            if ( -e $lNewName ) {
                $lNewName = $gDLDir . "\\" . $lPrefix . "=" . $lFile;
            }


            # Try leaving the file in the directory with the new name
            if ( -e $lNewName ) {
                $lNewName = $lDir . "\\" . $lPrefix . "-" . $lFile;
            }

            if ( -e $lNewName ) {
                $lNewName = $lDir . "\\" . $lPrefix . "_" . $lFile;
            }
            if ( -e $lNewName ) {
                $lNewName = $lDir . "\\" . $lPrefix . "=" . $lFile;
            }


            if ( ! -e $lNewName ) {
                print "rename $lDir\\$lFile $lNewName\n";
                rename ("$lDir\\$lFile", $lNewName);
            }


        }


    }

}   # S_AddFileNamePrefix

#-------------------------------------------------------------------------
# S_RemoveFileNameSpaces
# This routine will look in the provided down-load directory and
# find file names with spaces in them. These files will be re-named
# with "_" chars in place of the spaces
#-------------------------------------------------------------------------
sub S_RemoveFileNameSpaces
{
    local ($aDLDir) = @_;
    local ($lCmd, $lRename, $lOrigName, $lNewName);

    if (length ($aDLDir) < 4) {
        print "Download Dir ($aDLDir) does not appear valid. Exiting";
        return;
    }

    # Use the dos DIR command to find these file names
    $lCmd = "dir $aDLDir\\\"* *\" /b /o:n > $gDLCrcFile";
    print "$lCmd\n";
    system ($lCmd);

    # Send the output of the dir cmd straight into our program
    open (INFILE, "$gDLCrcFile") || die ("Could not open ($gDLCrcFile) for input\n");
    while ( <INFILE> )
    {
        chop;
        $lOrigName = $_;
        # print "$lOrigName\n";
        $lNewName = $lOrigName;
        $lNewName =~ s/ /_/g;       # Replace all spaces with underscores
        $lNewName =~ s/'//g;        # Replace quotes
        $lNewName =~ s/!//g;        # Replace exclimations
        $lNewName =~ s/copy_of_//g;
        $lRename = "rename $aDLDir\\\"$lOrigName\" $lNewName";
        print "$lRename\n";
        system ($lRename);
    }

    close (INFILE);

    return;
}   # S_RemoveFileNameSpaces

#-------------------------------------------------------------------------
# S_CleanUpDownLoadDir
# This routine will look for common file-name problems in the
# download dir directory and fix them.
# This includes:
#   - Files with spaces in their names
#   - Files with multiple . characters
#-------------------------------------------------------------------------
sub S_CleanUpDownLoadDir
{
    local (@lFileList);
    local ($lCmd, $lExtension, $lFileCount, $lMsg);
    local (@lMediaExtensions) = ("asf", "avi", "mpg", "mpeg", "mov",
                                 "qt", "rm", "ram", "viv", "wmv", "wma",
                                 "gif", "jpg");



    # New: Look in the AGENT directory for files to move over to the
    # download directory before cleaning things up.

    foreach $lExtension (@lMediaExtensions) {
        # print "$gAgentDir\\\*\.$lExtension\n";
        if (@lFileList = glob ("$gAgentDir\\\*\.$lExtension")) {
            $lFileCount = $#lFileList;
            $lMsg = sprintf ("Found %3d %4s files in AGENT", $lFileCount + 1,
                uc ($lExtension));

            $lCmd = "move /Y $gAgentDir\\\*\.$lExtension $gDLDir";
            # print "$lMsg - $lCmd\n";
            system ($lCmd);
        }
    }



    # The DL dir often has .txt files that are lef-overs from
    # the decoding process. Get rid of them
    $lCmd = "del $gDLDir\\*.tmp.*";
    system ($lCmd);

    # Sometimes files have 4-digit extensions. Convert the common ones
    # back to 3 digits.
    $lCmd = "rename $gDLDir\\*.jpeg *.jpg";
    print "$lCmd";
    system ($lCmd);

    $lCmd = "rename $gDLDir\\*.mpeg *.mpg";
    print "$lCmd";
    system ($lCmd);

    $lCmd = "del $gDLDir\\*.txt";
    system ($lCmd);

    $lCmd = "del $gDLDir\\*.htm";
    system ($lCmd);

    $lCmd = "del $gDLDir\\*.html";
    system ($lCmd);

    $lCmd = "del $gDLDir\\*.exe";
    system ($lCmd);

    $lCmd = "del $gDLDir\\*.csv";
    system ($lCmd);


    # Find file names with spaces and put "_" chars in place
    &S_RemoveFileNameSpaces ("c:\\temp\\1\\dl");

    # Look in the dl\t\SDT, AW, ... directories and put a "SDT-" or
    # "AW-" prefix in front of them.  Then move the files to the
    # dl directory.

    &S_AddFileNamePrefix ();



}   # S_CleanUpDownLoadDir

#-------------------------------------------------------------------------
# Routine:      S_GenerateGravityRules
# Description:  This routine will sort the list of "From" and "Subject"
#               strings into a neat rule for Gravity
#
#-------------------------------------------------------------------------
sub S_GenerateGravityRules {

    local ($lRow, $lMsg);
    local ($lLineLimit) = 40;
    local (@lResults) = ();
    local ($lCount);

    # this array is the "From" names of the posters whos items should
    # automatically be downloaded via the "Find Special" rule in Gravity.


    local (@gGRAV_FIND_SPECIAL_FROM) =
sort (
"<0>alebeard","<0>astra","Aldonze","Allan X","Amanda","Archiver","Arsby",
"Baldus","Beer Guy","Brenda","Casey","Cato","Chris","Damon","Davids","Dennis",
"Domald","Geneva","Ghostdog","GirlNapper","Hard Hubby","JENNY","Jake",
"Jane Doe","Jeannie","JennA","Jennifer","Kelli P","Matilda","Mel Lester","MileHighAma",
"Nchuck","Officer Friendly","PicChic","Poster Girl","PosterChic","Preston", "PS",
"Robert","Roger","Rose","Samuel","Sandy","Silly Tilly","SillyGirl","Sir Leonard",
"Texas Rose","The Hidden","The Ripper","Tom","allychuck","amateurbound",
"amber","amy","bad_uk_girl","brandy","briana","bubbles","castingcrew",
"charity","chastity","chuck","claudia","dana","debbie","drew","eagleG",
"imagerie\@sexy.com","jasmine","jill","jody","juliet","lilly","melody",
"mentor","miney","miney2","miney24","nichole","patriciasparty","redneck",
"robyn","ronnie","sasha","sassy","shauna","shygirl","tara","tasteofkitty",
"tenderwife","tracy","virginia","wonder woman","zoe"
);

    local (@gGRAV_FIND_SPECIAL_SUBJECT) =
sort(
"Aussies","Real Amateur","Shy Wives","Subslut","Thy Neighbor",
"Your Neighbor's Wife","amateurpain","megateencams","met",
"neighbor is a slut","reapersbondage","shy wife","too shy"
);


    # The From rule
    $lMsg = "";
    foreach $lRow (@gGRAV_FIND_SPECIAL_FROM) {
        if ( length ($lMsg) > 0 ) {
            $lMsg .= "|$lRow";
        } else {
            $lMsg .= "$lRow";
        }
        if ( length ($lMsg) > $lLineLimit ) {
            push (@lResults, "From contains reg. expr. \"$lMsg\"");
            # print "From contains reg. expr. \"$lMsg\"";
            $lMsg = "";
        }
    }

    # The Subject rule
    $lMsg = "";
    foreach $lRow (@gGRAV_FIND_SPECIAL_SUBJECT) {
        if ( length ($lMsg) > 0 ) {
            $lMsg .= "|$lRow";
        } else {
            $lMsg .= "$lRow";
        }
        if ( length ($lMsg) > $lLineLimit ) {
            push (@lResults, "Subject contains reg. expr. \"$lMsg\"");
            # print "Subject contains reg. expr. \"$lMsg\"";
            $lMsg = "";
        }
    }


    # Report
    $lCount = 0;
    for ( $lCount = 0; $lCount < $#lResults; $lCount++ ) {
        print "$lResults[$lCount] Or\n";
    }
    print "$lResults[$lCount]\n";

    # Look in the registry for the keys










}   # S_GenerateGravityRules


#-------------------------------------------------------------------------
# PrintMenu2 - Prints the menu
#-------------------------------------------------------------------------
sub PrintMenu2 {

    print "=============================================\n";
    print "              Main Menu - $gDate\n";
    print "=============================================\n";
    print "Please choose an option:\n\n";
    print "\t1 - Find already ARCHIVED files\n";
    print "\t2 - Add to ARCHIVE and SPAM\n";
    print "\t3 - Consolidate Directories\n";
    print "\t4 - Search for renamed/dup files\n";
    print "\t5 - Clean up downloaded files\n";
    print "\t6 - Clean out DL Directory\n";
    print "\t7 - Generate Gravity rules\n";
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
        # See if there are command line arguments
        if ($ARGV[0] == undef) {
            $g_choice = &GetChoice();
        } else {
            $g_choice = $ARGV[0];
        }

        if ( $g_choice == 1 ) {
			&ProcessNewFiles ();
            $l_finished = 1;
        } elsif ( $g_choice == 2 ) {
			&AddArcSpam ();
            $l_finished = 1;
        } elsif ( $g_choice == 3 ) {
			&MergeDirs($gNewsDir, $gMergeDir);
            $l_finished = 1;
        } elsif ( $g_choice == 4 ) {
			&FindDupDL();
            $l_finished = 1;
        } elsif ( $g_choice == 5 ) {
            &S_CleanUpDownLoadDir();
            $l_finished = 1;
        } elsif ( $g_choice == 6 ) {
            &ExamineDownLoadDir ();
            $l_finished = 1;
        } elsif ( $g_choice == 7 ) {
            &S_GenerateGravityRules ();
            $l_finished = 1;
        } elsif ( $g_choice == 8 ) {
            print "Choice Not Implemented Yet\n";
            $l_finished = 1;
        } elsif ( $g_choice == 9 ) {
            print "Choice Not Implemented Yet\n";
            $l_finished = 1;
        }
    }
}

# End of main

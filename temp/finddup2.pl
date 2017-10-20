#   File: Finddup2.pl
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


# COMMON DISK SIZES
my $gKILO_BYTE				= 1024;
my $gMEGA_BYTE				= 1024 * 1024;
my $gGIGA_BYTE				= 1024 * 1024 * 1024;

my $gCD_BLOCK_SIZE			= 2048;				# CD Has 2048 bytes per block
my $gCD_CAPACITY_BYTES		= 681984000;		# Number of bytes in a CD RW using Mode 1 (74 minute)
my $gCD_TOTAL_BLOCKS		= $gCD_CAPACITY_BYTES/$gCD_BLOCK_SIZE;	# 333,000

my $gDVD_CAPACITY_BYTES		= 4699947008;		# Bytes on a DVD
my $gDVD_BLOCK_SIZE			= 32768;			# Bytes on a DVD Block
my $gDVD_TOTAL_BLOCKS		= $gDVD_CAPACITY_BYTES/$gDVD_BLOCK_SIZE;	# 143431

# This is an array of path-names & prefix strings for each file. A
# routine will find all the files in these dirs and add the prefix.

@gFilePrefixArray = (   "$gDLDir\\t\\at|AT",
                        "$gDLDir\\t\\aw|AW",
                        "$gDLDir\\t\\sdt|SDT",
                        "$gDLDir\\t\\mm|MM"
                    );

&main ();
exit (0);



#-------------------------------------------------------------------------
#-------------------------------------------------------------------------
sub S_CDSize {
	my ($aFileSize) = @_;
	my $lNewSize;

	$lNewSize = sprintf ("%d", $aFileSize / $gCD_BLOCK_SIZE);
	$lNewSize = ($lNewSize + 1) * $gCD_BLOCK_SIZE;

	return ($lNewSize);

}	# S_CDSize;

#-------------------------------------------------------------------------
#-------------------------------------------------------------------------
sub S_ScanAudioBooks {
	my ($aPath) = @_;
	my %lColHash = ();

	print "Reading: $aPath\n";

	my (@lFileArray, $lFileName, $lPattern, $lCleanName, $lCleanSize, $lCDPercent);

	foreach $lFileName (sort glob ($aPath . "*.mp3") ) {
		# Take the file name and replace all the numbers with '?' chars to try to condense them
		# so we can group them together.

		$lPattern = $lFileName;
		$lPattern =~ s/^.*\\//;			# Remove path
		$lPattern =~ s/\d/\?/g;			# Change: "Alias-001.mp3" to "Alias-???.mp?"

		if (exists $lColHash{$lPattern} ) {
			$lColHash{$lPattern}{file_count}++;

			# Round up the file size to 256 bytes

			$lColHash{$lPattern}{total_size} += &S_CDSize( -s $lFileName );
		} else {
			print "New :\t$lPattern\n";
			$lColHash{$lPattern}{file_count} = 1;
			$lColHash{$lPattern}{total_size} = &S_CDSize( -s $lFileName );
			$lColHash{$lPattern}{disk_number} = 0;			# Will be filled if assigned to a disk
		}

	}

	# Report;
	print "\n\n";
	print "Count\tFileSize\tCD\%\tPattern\n";

	foreach $lPattern (sort keys %lColHash) {
		$lCleanName = $lPattern;
		$lCleanName =~ s/\.mp\?//g;
		$lCleanName =~ s/\?//g;
		$lCleanName = substr ($lCleanName, 0, 40);

		$lCleanSize = $lColHash{$lPattern}{total_size};
		$lCleanSize = sprintf ("%3.1f", $lCleanSize / ($gMEGA_BYTE));

		# Calculate percentage on a CD these files would take up:

		$lCDPercent = $lColHash{$lPattern}{total_size};
		$lCDPercent = $lCDPercent / $gCD_CAPACITY_BYTES;


		print sprintf ("%3d\t%10d M\t%0.2f\t%-40s\n", 
			$lColHash{$lPattern}{file_count},
			$lCleanSize,
			$lCDPercent,
			$lCleanName);
	}


	# Now go through the list again and calculate how to combine the files into a CD or DVD.



}	# S_ScanAudioBooks


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

#------------------------------------------------------------------------------------------------------------------
# Routine:		LookForDups2
# Description:	Will look for duplicate files in a directory
#------------------------------------------------------------------------------------------------------------------
sub LookForDups2 {
	my ($aPath) = @_;
	my (%lDirHash) = ();
	my ($lCmd, $lRow);
	my ($lFileSize, $lFileName);

	$lCmd = "dir /-C $aPath\\*.*";

	open (FILE_LIST, "$lCmd|") || die ("Error: Cannot get dir list on ($aPath)\n");
	while (<FILE_LIST>) {
		chomp;
		$lRow = $_;

		# Remove leading spaces
		#$lRow =~ s/^ +//;
		next if ($lRow =~ /<DIR>/ || length ($lRow) < 30);
		if ( $lRow =~ m/^\d\d\/\d\d\/\d\d\d\d/) {
			$lRow = substr ($lRow, 22, 100);
			$lRow =~ s/ +//;
			$lRow =~ m/^(\d+) (.+)/;
			$lFileSize = $1;
			$lFileName = $2;
			$lFileSize = sprintf ("%010d", $lFileSize);

			if (exists $lDirHash{$lFileSize}) {
				$lDirHash{$lFileSize} .= "|$lFileName";
				print "$lFileSize - $lDirHash{$lFileSize}\n";
			} else {
				$lDirHash{$lFileSize} = "$lFileName";
			}
		}

	}
	close FILE_LIST;

	# Now look for multiple files in our hash and do a CRC check on them.


}	 # LookForDups2


#-------------------------------------------------------------------------
# PrintMenu2 - Prints the menu
#-------------------------------------------------------------------------
sub PrintMenu2 {

    print "=============================================\n";
    print "              Main Menu - $gDate\n";
    print "=============================================\n";
    print "Please choose an option:\n\n";
    print "\t1 - Find Duplicate Files\n";
    print "\t2 - \n";
    print "\t3 - \n";
    print "\t4 - \n";
    print "\t5 - \n";
    print "\t6 - Scan Audiobooks\n";
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
			&LookForDups2 ("C:\\1\\AB17\\");
            $l_finished = 1;
        } elsif ( $g_choice == 2 ) {
            $l_finished = 1;
        } elsif ( $g_choice == 3 ) {
            $l_finished = 1;
        } elsif ( $g_choice == 4 ) {
            $l_finished = 1;
        } elsif ( $g_choice == 5 ) {
            $l_finished = 1;
        } elsif ( $g_choice == 6 ) {
			&S_ScanAudioBooks("C:\\1\\AB17\\");
            $l_finished = 1;
        } elsif ( $g_choice == 7 ) {
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

# File: cd_cat2.pl

$| = 1; # Print Immediatly

##################
# Global Section #
##################

$gCD_DRIVE_LETTER   = "R";
$gCD_DRIVE_LETTER2  = "R";
$gCRC_DIR           = "D:\\crc";
$gWORKING_DIR       = "D:\\temp\\1";               # Where to read new files from
$gDOWNLOAD_DIR      = "D:\\temp\\1\\dl";           # Where the bulk download files are
$gARCHIVE_DIR       = "D:\\temp\\1\\archive";      # Where to move previously-seen files
$gSPAM_DIR          = "D:\\temp\\1\\spam";         # Where to move previously-seen files
$gNEW_SPAM_DIR      = "D:\\temp\\1\\newspam";      # Where to read new spam files from
$gTO_SORT_DIR       = "D:\\temp\\1\\tosort";       # Where files await sorting to the prep directory
$gCD_PREP_DIR       = "D:\\temp\\p";               # Where files await burning
$gGREP_PGM          = "D:\\dosa\\utils\\grep.exe";

# The ARCHIVE.CRC file is everything burned onto a CD
# The RECENT.CRC file is everything kept on the hard drive, but not on a CD yet
# The SPAM.CRC file is all spam

$gARCHIVE_FILE      = $gCRC_DIR . "\\archive.crc";
$gRECENT_FILE       = $gCRC_DIR . "\\recent.crc";
$gSPAM_FILE         = $gCRC_DIR . "\\spam.crc";
$gTEMP_CRC_FILE     = $gCRC_DIR . "\\temp.crc";

# This is the base-name for CRC Catalog files
$gCATALOG_BASE      = "BACKUP";     # becomes "BACKUPnnn.crc"
$gCATALOG_BASE      = "AVI-DVD";     # becomes "BACKUPnnn.crc"



$gVERBOSE = 0;
$gDEBUG   = 0;

$gIS_WIN_NT = 1;

&main();
exit (0);



#-----------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------
sub S_FixBDFilenames {
   local ($aDir) = @_;
   my (@lCmdArray, $lFileName);
   my ($lNewName);

   my %lPREFIX_HASH = (
      'FB'  => "FuckedAndBound",
      'CB'  => "ChantasBitches",
      'CM'  => "CaptiveMale",
   );

   chdir ($aDir) or die ("Error: Could not cd to $aDir\n");

   foreach $lFileName ( sort glob ("*.*") ) {

      next if ($lFileName =~ m/par2/);

      # 052 - CB - 2006-12-29 - Aubrey Adams.wmv
      next unless ( $lFileName =~ m/^(\d\d\d) \- (\w\w) - (\d\d\d\d\-\d\d\-\d\d) - (.*)/);
      my ($lEpisode, $lPrefix, $lDate, $lTitle) = ($1, $2, $3, $4);

      next unless ( exists $lPREFIX_HASH{$lPrefix});

      $lNewName = $lPREFIX_HASH{$lPrefix} . " - $lDate - $lTitle";

      push (@lCmdArray, "$lFileName|$lNewName");

      #print "$lNewName\n";
   }


   foreach $lFileName ( sort glob ("*.*") ) {

      next if ($lFileName =~ m/par2/);

      # 20050410-01 Jewell Air Chair.rm
      next unless ( $lFileName =~ m/^(\d{8}\-\w{2}) (.*)/);

      $lNewName = "HofG-$lFileName";

      # Fix .rm.jpg problems
      $lNewName =~ s/\.rm\.jpg$/\.jpg/;

      # Fix 20050404-01 Sasha Monet ~00.03.33.jpg
      $lNewName =~ s/\~\d\d\.\d\d\.\d\d//;

      #push (@lCmdArray, "$lFileName|$lNewName");

      #print "$lNewName\n";

   }

   # Print a report:
   foreach $lFileName ( @lCmdArray ) {
      my ($lOld, $lNew) = split (/\|/, $lFileName);
      print "rename $lOld $lNew\n";
      rename ($lOld, $lNew) or die ("Error: Could not rename $lOld to $lNew : $!\n");
   }


}  # S_FixDBFilenames

#-----------------------------------------------------------------------------------
# Routine:      ParseDirRow
# Description:  This routine will take a text row as the output of a dos
#               "dir /-C /x" command. This looks something like:
#                 date time        size    FOOBU~01.jpg  fubar_output.jpg
#                 date time        size                  test.jpg
#                 Notice that if the file name is long, the row shows a 8.3
#               form and the long form. But if the file name is already 8.3,
#               only the 8.3 is shown.
#
# Input:        aRow - String as described above
#
# Returns:      lDate - Date string like "mm/dd/yy"
#               lTime - Time string like "hh:mma"
#               lSize - File size in bytes
#               lShort Name - Short name of the file in UPPER Case
#               lLong Name - Long name of the file as provided
#-----------------------------------------------------------------------------------
sub ParseDirRow {
    local ($aRow) = @_;
    local ($lDate, $lTime, $lSize, $lShortName, $lLongName) = ("", "", "", "", "");
    local ($lExt);      # For the filename extension

    # Replace all the spaces with pipe-symbols
    # $aRow =~ s/ +/\|/g;       # NO: Messes up file names with spaces

    # Remove the comma's from the file size strings
    $aRow =~ s/\,//g;


    # The Win98 DIR command produces a different format than the WinNT
    # version

    if ($gIS_WIN_NT) {
        $lDate = substr ($aRow, 0, 9);
        $lTime = substr ($aRow, 11, 6);
        $lSize = substr ($aRow, 20, 18);
        $lSize =~ s/\s+//;  # get rid of spaces
        $lShortName = substr ($aRow, 39, 12);
        $lShortName =~ s/\s+//;
        $lLongName = substr ($aRow, 55, 20);
        print "Long Name = $lLongName\n";
    } else {
        ($lShortName, $lExt, $lSize, $lDate, $lTime, $lLongName) = split (/\|/, $aRow);
        $lShortName .= "." . $lExt;
    }


    # Trick: If we dont get a long name, we have a file name that fits 8.3
    # So we need to make the long name = the short name, then upper-case
    # the short name
    if ( length ($lLongName) == 0 ) {
        $lLongName = $lShortName;
        $lShortName = uc $lShortName;
    }

    # print "$aRow Long =($lLongName)\n";

    return ($lDate, $lTime, $lSize, $lShortName, $lLongName);

}   # ParseDirRow

#-----------------------------------------------------------------------------------
# Routine:      GetFileNameSize
# Description:  This routine will take a path name to a directory,
#               and return a string consisiting of:
#                   File Name | Size in Bytes
#
# Input:        aDir - Full path name like "\temp\dl" or "R:\misc"
# Returns:      array of strings, one for each file
#
# Note:         File names can be long, and contain spaces:
#                   this is a space file name.txt
#-----------------------------------------------------------------------------------
sub GetFileNameSize {
    local ($aDir) = @_;
    local (@lReturn) = ();
    local (@lFileList) = ();
    local ($lRow, $lSize, $lFileName);

    if ( ! (-e $aDir) ) {
        print "Error: FIOD2 - Directory ($aDir) does not exist\n";
        return (@lReturn);
    }

    @lFileList = glob ("$aDir\\*.*");
    foreach $lRow (@lFileList) {
        # lRow is a full-path name: "C:\temp\1\xxx.yyy"
        $lSize = -s $lRow;          # Get the file size
        $lFileName = $lRow;         # Copy the full name
        $lFileName =~ s/^.*\\//;    # Strip the path
        push (@lReturn, "$lFileName\|$lSize");                                    #
        # print "$lFileName\|$lSize\n";
    }

    return (@lReturn);

}   # GetFileNameSize

#-----------------------------------------------------------------------------------
# Routine:      S_GetCRC32OfFiles
# Description:  This routine will take a directory string ("C:\temp\2") and
#               get the CRC values for every file in the directory. It
#               returns a Hash like this:
#                   $lHash{"command.com"} = HHHHhhhh
#                   $lHash{"system.com"}  = HHHHhhhh
#               The index is the file name, the HHHhhh is the 32 bit CRC
#
# Input:        aDir - Directory string "C:\temp\new"
#				aVolumnName - Name of CD rom: "avi-dvd-123"
#
# Returns:      %lHash - Hash array of file names and CRC32 values
#-----------------------------------------------------------------------------------
sub S_GetCRC32OfFiles {
    local ($aDir, $aVolumnName) = @_;
    local (%lHash) = ();
    local ($lOutputFile) = "\\crc.out";
    local ($lFileName, $lCRC32, $lRow, $lStageDir);

    local ($lCmd) = "d:\\dosa\\utils\\crc32.exe $aDir\\*.* > $lOutputFile";

	# New: see if the d:\avi\avi-dvd-123 directory still exists.

	$lStageDir = "d:\\1\\$aVolumnName";
	if ( -e $lStageDir) {
		$lCmd = "d:\\dosa\\utils\\crc32.exe $lStageDir\\*.* > $lOutputFile";
	}

    print "Command: ($lCmd)\n";
    system ($lCmd);

    open (CRCFILE, "$lOutputFile") || die ("Error: Cannot open CRC file ($lOutputFile) for input\n");
    while ( <CRCFILE> ) {
        $lRow = $_;                 # "C:\temp\1\fubar.gif    CRC32(0xhhhhhhhh)"
        # print "$lRow\n";
        $lRow =~ m/^(.+) /;
        $lFileName = $1;            # "C:\temp\1\dl\fubar.gif"
        $lFileName =~ s/^.*\\//;    # Strip everything BEFORE the final \ char

        $lRow =~ m/0x(\w+)\)$/;
        $lCRC32 = uc ($1);

        # SPECIAL: Sometimes the CRC value is only 7 chars so we need to
        # pad with a "0" at the begining.

        while ( length ($lCRC32) < 8 ) {
            $lCRC32 = "0" . "$lCRC32";
        }


        print "($lFileName) - ($lCRC32)\n";
        $lHash{$lFileName} = "$lCRC32";
    }

    close (CRCFILE);
    unlink ($lOutputFile);

    return (%lHash);

}   # S_GetCRC32OfFiles

#-----------------------------------------------------------------------------------
# Routine:      ScanOneDir
# Description:  This routine will take a directory path and look for all
#               the files in the directory. For each file found, a row will
#               be created looking like:
#                   CRC32 | size in bytes | File Name | Path | Volume Name
#
# Input:        aVolumeName - Volume name of the CD/Drive scanned
#               aDir - Full path name to a directory: "E:\Temp\Foo"
#
# Returns:      lFileArray - An array of strings as described above,
#               one per file
#-----------------------------------------------------------------------------------
sub ScanOneDir {
    local ($aVolumeName, $aDir) = @_;
    local (@lFileArray) = ();
    local (@lReturnArray) = ();
    local ($lWin98Cmd, $lWinNTCmd, $lCmd);
    local ($lRow, $lPos, $lEntry);
    local ($lDate, $lTime, $lSize, $lLongName);
    local ($lPath);
    local ($lCount) = 0;

    print "Reading directory ($aDir): \n" if ($gVERBOSE == 1);

    # If the starting point is "X:\", we want to store the path name
    # to each file as "\" WITHOUT a drive letter

    $lPath = $aDir;
    if ( substr ($lPath, 1,1) == ":" ) {
        $lPath = substr ($lDir, 2);     # Grab everything past the colen
    }

    # Step 1: Use the external CRC program to get the CRC values from all
    # the files in our directory. Store these values in a hash using the
    # short name as the key

    local (%lCRCHash) = &S_GetCRC32OfFiles ($aDir, $aVolumeName);

    # Step 2: Get an array of FileNames | Size

    @lFileArray = &GetFileNameSize ($aDir);

    $lCount = $#lFileArray;

    $lCount = 0;
    foreach $lRow (@lFileArray) {

        ($lLongName, $lSize) = split (/\|/, $lRow);

        # Use the long-name as the key to our CRC array and format the
        # output row

        if ( $lCRCHash{$lLongName} ) {
            $lEntry = "$lCRCHash{$lLongName}\|$lSize\|$lLongName\|$lPath\|$aVolumeName";
            $lEntry = &NormalizeCRCRow ($lEntry);
            push (@lReturnArray, $lEntry);
            $lCount++;
            print "$lEntry\n";
        } else {
            print "Error: Could not find CRC for: $lShortName\n";
        }
    }

    print " $lCount files found\n" if ($gVERBOSE == 1);

    return (sort @lReturnArray);

}   # ScanOneDir

#-----------------------------------------------------------------------------------
# Routine:      CatalogFilesOnPath
# Description:  This routine will take a drive letter and return an array listing
#               every file on the drive. It will NOT include sub-directory
#               names as files.
# Input:        aDriveVolume - Name to identify this disk volume
#               aStarting Path - Where to start searching: "E:\" or "C:\temp\p"
#
# Returns:      An array of strings, one per file that looks like this:
#
#               CRC 32 | File size in bytes | Long file name | Path | Drive Volume
#
#-----------------------------------------------------------------------------------
sub CatalogFilesOnPath {
    local ($aDriveVolume, $aStartingPath) = @_;
    local ($lRow, $lCount, $lFileCount);
    local (@lFileArray) = ();
    local (@lTempArray) = ();
    local (@lDirList) = ();
    local ($lDir);

    if ( $gVERBOSE == 1 ) {
        print "Scaning Files On Path ($aDriveVolume, $aStartingPath) \n";
    }

    # Get an array of all the directory's on the drive under the
    # starting path

    ## Need to add the starting directory
    push (@lDirList, $aStartingPath);

    open (INFILE, "dir /s /b /A:D $aStartingPath|");
    while ( <INFILE> ) {
        $lRow = $_;
        chomp ($lRow);

        # lRow should be something like "E:\Temp"
        if ( length ($lRow) > 3 ) {
            # print "GDT: $lRow\n";
            push (@lDirList, $lRow);
        }
    }
    close (INFILE);

    ## FOR DEBUGGING
    if ( $gDEBUG == 1 ) {
        @lDirList = ();
        push (@lDirList, "e:\\misc");
    }

    # For each directory, we want to get a list of the files,
    # the CRC, Size, path and file names in a single string.
    #
    $lCount = 0;

    foreach $lDir (@lDirList) {
        @lTempArray = &ScanOneDir ($aDriveVolume, $lDir);
        $lFileCount = $#lTempArray;
        if ( $lFileCount > 0 ) {
            push (@lFileArray, @lTempArray);
            $lCount += $lFileCount;
        }
    }


    print "Found $lCount files on drive $aStartingPath\n";

    return (@lFileArray);

}   # CatalogFilesOnPath




#-----------------------------------------------------------------------------------
# Routine:      MoveFiles
# Description:  This routine will take a destination path, and an array
#               of full file-names and run a bunch of these commands:
#                   move /Y fn1 destination
#
# Input:        aDestDir - full-path name to a destination directory
#               @aFileList - Array of file names
#
#-----------------------------------------------------------------------------------
sub MoveFiles {
    local ($aDestDir, @aFileList) = @_;
    local ($lCmd, $lRow);


    if ( -e $aDestDir ) {
        foreach $lRow (@aFileList) {
            $lCmd = "move /Y $lRow $aDestDir";
            print "$lCmd\n";
            system ($lCmd);
        }
    } else {
        print "Error - Move Files: Dest Dir ($aDestDir) does not exist\n";
    }

}   # MoveFiles

#-----------------------------------------------------------------------------------
# Routine:      SearchArchiveFile
# Description:  This routine will take the name of a archive CRC file, an
#               array of file CRC's and a path, and return an array of
#               full-path file names if we have seen these files before
#
# Input:        aArchiveFile - full-path name to an archive CRC file
#                   "c:\crc\archive.crc"
#               aSrcDir - full-path string to where the files in aCRCList
#                   are located. This will be used to return the full-path
#                   names to the parent
#               aCRCList - Array of strings for files sitting in a directory
#                   somewhere. Each string has CRC32 | Filesize | Name ||..
#
# Returns:      lFileArray - Array of full-path strings to the files that
#                   were found in the Archive File.
#
#-----------------------------------------------------------------------------------
sub SearchArchiveFile {
    local ($aArchiveFile, $aSrcDir, @aCRCList) = @_;
    local (@lReturn) = ();          # The array of file names
    local ($lRow, $lCRC32, $lSize, $lWorking, $lArchive);
    local ($lFileName);

    # Check that the archive file exists

    if ( ! (-e $aArchiveFile) ) {
        print "Error: Archive File ($aArchiveFile) does not exist\n";
        return (@lReturn);
    }

    print "Opening CRC file ($aArchiveFile)\n";

    open (ARCHIVE_FILE, "$aArchiveFile") || die ("Error: Cannot open ($aArchiveFile) for input\n");

    # Each row looks like "CRC32 | Size | Name | vol |..." We only want
    # the CRC32 | Size as a string.

    $lArchive = <ARCHIVE_FILE>;
    chomp ($lArchive);
    $lArchive =~ s/^(\w+\|\w+).*/$1/;

    # Run through the archive file until the current row is = or >
    # than the first row in our list of files

    $lWorking = $aCRCList[0];           # Grab the first member
    $lWorking =~ s/^(\w+\|\w+).*/$1/;   # Get just "CRC32 | Size"

    foreach $lRow (@aCRCList) {

        # The row looks like "CRC32 | Size | Name | vol |..." We only want
        # the CRC32 | Size as a string.

        $lWorking = $lRow;
        $lWorking =~ s/^(\w+\|\w+).*/$1/;
        print "Looking for Working = $lWorking\n";
        while ( $lArchive lt $lWorking ) {
            $lArchive = <ARCHIVE_FILE>;
            chomp ($lArchive);
            $lArchive =~ s/^(\w+\|\w+).*/$1/;
            if (length ($lArchive) < 2) {
                last;
            }
        }

        ($lCRC32, $lSize, $lFileName) = split (/\|/, $lRow);
        # print "Looking for $lFileName...";

        # See if we have a match
        if ( $lWorking eq $lArchive ) {
            # Pull out the file-name from the CRC array
            ($lCRC32, $lSize, $lFileName) = split (/\|/, $lRow);
            # Some file names have spaces
            if ( $lFileName =~ m/ / ) {
                $lFileName = "\"$aSrcDir\\$lFileName\"";
            } else {
                $lFileName = "$aSrcDir\\$lFileName";
            }
            # print "Found it: $lFileName\n";
            push (@lReturn, "$lFileName");
        } else {
            # print "Couldnt find ($lFileName) in archive file\n";
        }
    }

    print "Closing CRC file: $aArchiveFile\n";
    close (ARCHIVE_FILE);

    return (@lReturn);

}   # SearchArchiveFile

#-----------------------------------------------------------------------------------
# Routine:      S_GenerateRecentFile
# Description:  This routine will scan several directories on the current
#               hard drive and create a "RECENT.CRC" file for them. In
#               theory, this should be every file not yet burned into a CD
#
# Input:        aRecentFile - Full path and name for the recent.crc file
#
# Output:       a sorted file
#
#-----------------------------------------------------------------------------------
sub S_GenerateRecentFile {
    local ($aRecentFile) = @_;
    local (@lDirList) = ();
    local (@lCRCList) = ();
    local ($lRow);
    local ($lCmd);

    # First, make sure we dont have a temp.crc file left over

    if ( -e $gTEMP_CRC_FILE ) {
        unlink ($gTEMP_CRC_FILE);
    }

    # Call a routine with a starting path name and have it CRC all the files
    # under the starting path

    @lCRCList = &CatalogFilesOnPath ("recent", "C:\\temp\\p");

    # Dont forget our to-sort directory

    local (@lTemp) = &CatalogFilesOnPath ("recent", "C:\\temp\\1\\tosort");

    push (@lCRCList, @lTemp);
    @lTemp = ();

    # Write this to a temp file

    open (OUTFILE, ">$gTEMP_CRC_FILE") || die ("Error: GRF - Cannot open ($gTEMP_CRC_FILE) for output\n");

    foreach $lRow (@lCRCList) {
        print OUTFILE "$lRow\n";
    }
    close (OUTFILE);

    @lCRCList = ();

    # Now use the Sort comand on the temp file to create a nice RECENT.CRC file

    $lCmd = "sort $gTEMP_CRC_FILE > $aRecentFile";

    print "Sorting recent file" if ($gVERBOSE == 1);
    system ($lCmd);
    unlink ($gTEMP_CRC_FILE);


}   # S_GenerateRecentFile

#-----------------------------------------------------------------------------------
# Routine:      FilterWorkingFiles
# Description:  This routine will examine all the files in the working
#               directory and compare them to the current ARCHIVE and
#               SPAM CRC files. If a file has been seen before from the
#               ARCHIVE file, it is moved to the ARCHIVE directory. If
#               a file has been seen before from the SPAM file, it is
#               moved to the SPAM directory.
#
# Input:        aSrcDir - full path to the working directory
#
#
#
#-----------------------------------------------------------------------------------
sub FilterWorkingFiles {
    local ($aSrcDir) = @_;
    local (@lCRCList) = ();
    local ($lCount, $lArchiveCount, $lSpamCount) = (0,0,0);
    local (@lArchiveList);
    local (@lRecentList);
    local (@lSpamList);


    # Call a routine that will create CRC32 | size | File Name | Path | volume
    # strings for each file found.

    @lCRCList = &ScanOneDir ("work", $aSrcDir);

    $lCount = $#lCRCList + 1;
    print "Found $lCount files in $aSrcDir\n";

    # Note: There could be several identical files in the source directory
    # but with different file names. We should clean these up here

    if ( $lCount > 0 ) {

        # Call a routine that will compare the files in the working
        # directory to our seen-before CRC files

        @lArchiveList = &SearchArchiveFile ($gARCHIVE_FILE, $aSrcDir, @lCRCList);
        @lRecentList  = &SearchArchiveFile ($gRECENT_FILE,  $aSrcDir, @lCRCList);
        if ( $#lRecentList > 0 ) {
            push (@lArchiveList, @lRecentList);
        }
        $lArchiveCount = $#lArchiveList + 1;
        @lSpamList  = &SearchArchiveFile ($gSPAM_FILE,  $aSrcDir, @lCRCList);


    }


    # Move the files found in the ARCHIVE file to the ARCHIVE directory
    &MoveFiles ($gARCHIVE_DIR, @lArchiveList);

    # Move the files found in the SPAM file to the SPAM directory
    &MoveFiles ($gSPAM_DIR, @lSpamList);


    # Print statistics
    print "Total Files = $lCount, Archive = $lArchiveCount, Spam = $lSpamCount\n";

}   # FilterWorkingFiles


#-----------------------------------------------------------------------------------
# Routine:      GetDriveVolume
# Description:  This routine will take a drive letter and return the volume
#               name of the drive
#
# Input:        aDriveLetter
#
# Returns:      The drive volume (as returned by the "VOL" command
#-----------------------------------------------------------------------------------
sub GetDriveVolume {
    local ($aDriveLetter) = @_;
    local ($lRow);
    local ($lVolumeName) = "no-name";
    local ($lOutFile) = "c:\\vol.out";

    if ( length ($aDriveLetter) != 1 ) {
        print "GDV: Invalid Drive Letter ($aDriveLetter)\n";
        return ($lVolumeName);
    }

    # Use the dos "VOL" command to get the volume name

    system ("vol $aDriveLetter: > $lOutFile");
    open (INFILE, "$lOutFile");
                            # "Volume in drive X has no label" or
                            # "Volume in drive X is yyyyyyyyy"
    while (<INFILE>) {
        $lRow = $_;
        chomp ($lRow);

        if ($lRow =~ m/Volume in/) {
            # Strip the first 22 chars from the row
            $lRow = substr ($lRow, 22);
            $lVolumeName = $lRow;
        }
    }
    close (INFILE);
    unlink ($lOutFIle);

    # Trim trailing spaces
    $lVolumeName =~s / +$//;
    # Replace embeded spaces with under-score chars
    $lVolumeName =~ s/ /_/g;

    return ($lVolumeName);

}   # GetDriveVolume

#-----------------------------------------------------------------------------------
# Routine:      CreateCRCCatalog
# Description:  This routine will take a starting path and a output file name
#               and get the CRC of every file and write it out to the output
#               file
#
# Inputs:       aStartPath - String like "E:\" or "C:\temp"
#               aVolume - Name of the volume the file belongs to
#               aFileName - Name of the file to write the CRC valuse to
#
# Output:       A file with the CRC values for the files found.
#
#-----------------------------------------------------------------------------------
sub CreateCRCCatalog {
    local ($aStartPath, $aDriveVolume, $aFileName) = @_;

    if ( $gVERBOSE == 1 ) {
        print "Create CRC Catalog $aDriveVolume, Starting path = $aStartPath, Output File = $aFileName\n";
    }

    # Get a full directory of the CD rom

    local (@lFileList) = &CatalogFilesOnPath ($aDriveVolume, $aStartPath);

    # Open an output file with a ".CRC" extension and write the
    # file info to the file

    open (OUTFILE, ">$aFileName") || die ("Error: Could not open ($lFileName) for output\n");
    local ($lRow);

    foreach $lRow (sort (@lFileList)) {
        print OUTFILE "$lRow\n";
    }
    close (OUTFILE);

    print "Output file is: $aFileName\n" if ($gVERBOSE == 1);

}   # CreateCRCCatalog

#-----------------------------------------------------------------------------------
# Routine:      CatalogCDRom
# Description:  This routine will read the volume label of the current CD
#               rom and create a file (volume_name.crc) with info about
#               every file found.
#               Each row in the file will look like this:
#               CRC 32 | File size in bytes | Long file name | Path | Drive Volume
#
# Output:       A file with the catalog of all the files on the CD rom
#-----------------------------------------------------------------------------------
sub CatalogCDRom {
    local ($aDriveLetter) = @_;

    local ($lDriveVolume, $lFileName, $lStartPath);


    $lDriveVolume = &GetDriveVolume ($aDriveLetter);
    print "CCR: Drive ($aDriveLetter) volume is: $lDriveVolume\n";
    if ( length ($lDriveVolume) < 2 ) {
        $lDriveVolume = "crc_cat";
    }

    # Create a name for the local output file. Use the volume name with
    # a ".crc" extension

    $lFileName = $gCRC_DIR . "\\" . $lDriveVolume . "\.crc";

    # The routine needs to know where to start looking for the files. Just
    # let it start at the root of the CD rom

    $lStartPath = $aDriveLetter . ":\\";    # Add backslash and colen

    # Call a routine to scan the files

    &CreateCRCCatalog ($lStartPath, $lDriveVolume, $lFileName);




}   # CatalogCDRom

#-----------------------------------------------------------------------------------
# Routine:      FindSeries
# Description:  This routine will take a directory path, look at all the
#               file names and try to find groups of files that look like
#               they are parts of a series. Things like "sss_01.jpg", "sss_02.jpg"
#               and others.
#
# Input:        aPath - Path to the directory containing the files.
#
#
#-----------------------------------------------------------------------------------
sub FindSeries {
    local ($aPath) = @_;
    local (%lFileHash) = ();
    local (@lFileList);
    local ($lFile, $lTemp, $lPos);

    # Get a list of all the files

    local (@lFileList) = glob ($aPath . "\\\*\.\*");

    # Look for files with names like XXXnn.jpg. We are going to strip off
    # the extension, and the numbers to leave "XXX". This will be used as
    # a key for a hash that will count how many files we have that start
    # with XXX.

    local (%lFileHash) = ();

    foreach $lFile (sort (@lFileList)) {
        chomp ($lFile);

        # Trim off any extension

        $lPos = rindex ($lFile, ".");
        if ( $lPos > 0 ) {
            $lFile = substr ($lFile, 0, $lPos);
            # print "$lFile ";
        }

        # Trim off the path

        $lPos = rindex ($lFile, "\\");
        if ( $lPos > 0 ) {
            $lFile = substr ($lFile, $lPos + 1);
            # print "$lFile ";
        }


        # See if this file ends with numbers

        $lTemp = $lFile;       # remember original file name
        if ( $lFile =~ s/\d+$// ) {

            # It DOES end with numbers. But we have to make sure
            # we dont have "am32" to give us a pattern of "am*" which
            # will pull in too much stuff.
            if ( length ($lFile) > 3 ) {

                # Add this base to our hash. But we want to replace the
                # numbers like "fubar_0032" with "fubar_????" so we only
                # find this pattern later.

                while ( length ($lFile) < length ($lTemp) ) {
                    $lFile .= "?";  # Add a ? char for each digit we stripped
                }

                print "$lFile\n";

                if ( $lFileHash{$lFile} ) {
                    $lFileHash{$lFile} += 1;
                } else {
                    $lFileHash{$lFile} = 1;
                }
            }
        }
    }


    # Now go through the hash and find file-prefix's that have
    # 5 or more files ending in number

    @lFileList = ();
    foreach $lFile (keys %lFileHash) {
        if ( $lFileHash{$lFile} > 5 ) {
            print "$aPath\\$lFile\.\*   -- $lFileHash{$lFile} files\n";
            push (@lFileList, glob ($aPath . "\\$lFile\*\.\*"));
        }
    }

    foreach $lFile (@lFileList) {
        # print "$lFile\n";
    }

}   # FindSeries


#---------------------------------------------------------------------------
# Routine:      NormalizeCRCRow
# Description:  The CRC files have 2 key fields: CRC32 | Size
#               But the CRC32 value may have leading zeros which are
#               stripped off, and the size may need leading zeros.
#               This routine takes a full CRC row and returns it with
#               the CRC32 and Size fields zero-padded so they can be
#               compared with a sring search or sort routine.
#
# Input:        aRow - A CRC row like: "CRC32 | Size | Name | Path | Vol"
#
# Output:       lReturn - The same row with the CRC32 string and Size string
#                   padded with zeros.
#
#---------------------------------------------------------------------------
sub NormalizeCRCRow {
    local ($aRow) = @_;
    local ($lCRCStr, $lSizeStr);
    local ($lReturn);
    local ($lFoundChange) = 0;

    # Strip the CRC32, size strings from the row.

    $aRow =~ s/^(\w+)\|(\w+)\|(.*)/$3/;    # Remove CRC32| and SIZE|
    $lCRCStr = $1 . "|";                 # cccc|
    $lSizeStr = $2 . "|";                # ssss|

    while ( length ($lCRCStr) < 9 ) {
        $lCRCStr = "0" . "$lCRCStr";
        $lFoundChange++;
    }

    while ( length ($lSizeStr) < 9 ) {
        $lSizeStr = "0" . "$lSizeStr";
    }

    $lReturn = $lCRCStr . $lSizeStr . $aRow;

    if ( $lFoundChange > 0 ) {
        print "NR: $lReturn\n";
    }

    return ($lReturn);

}   # NormalizeCRCRow

#---------------------------------------------------------------------------
# Routine:      S_WashArchive
# Description:  This routine will take an archive file and check each row
#               to make sure it does not contain header crap and has a
#               unique CRC32|Filesize combination. It will also yell if
#               the source file is not in sorted order
#
# Input:        aInFile - Name of the archive file to be washed
#               aOutFile - Name for the new archive file
#
# Returns:      ## - The number of fatal errors found
#---------------------------------------------------------------------------
sub S_WashArchive {
    local ($aInFile, $aOutFile) = @_;
    local ($lRow, $lCount, $lErrorCount);
    local ($lCRC32, $lSize, $lTemp, $lPrevious);

    open (INFILE, "$aInFile")   || die ("Error: WashArchive - could not open ($aInFile) for input\n");
    open (OUTFILE, ">$aOutFile") || die ("Error: WashArchive - could not open ($aOutFile) for output\n");

    $lPrevious = "";
    $lCount = 0;
    $lErrorCount = 0;

    while ( <INFILE> ) {
        $lRow = $_;

        # Look for rows that start with "File..." from the Sort routine
        #if ( $lRow =~ m/^File/ ) {
        #    next;
        #}

        ($lCRC32, $lSize) = split (/\|/, $lRow);
        $lTemp = "$lCRC32\|$lSize";

        #if ( $lTemp == $lPrevous ) {
        #    print "Found duplicate: ($lTemp) -- skipping\n";
        #    print "Found duplicate: ($lTemp) -- skipping\n" if ($gVERBOSE == 1);
        #    next;
        #}

        # The current row should have a CRC/size string greater
        # in size than the previous if the file is correctly sorted

        if ( $lTemp < $lPREVIOUS ) {
            print "Error: Source file is not sorted: $lTemp\n";
            $lErrorCount++;
        }

        # If a file has a CRC value of "00001234", the string appears as
        # "1234". We need to pad with "0" characters

        if ( length ($lCRC32) < 8 ) {
            # Strip off the CRC value from the row
            $lRow =~ s/^(\w+)\|(.*)/$2/;
            $lCRC32 = $1 . "|";
            while ( length ($lCRC32) < 9 ) {
                $lCRC32 = "0" . "$lCRC32";
            }


            # Put the row back together
            $lRow = $lCRC32 . $lRow;
            #print "WA: $lRow\n";

        }

        # Good row. Print it out
        print OUTFILE "$lRow";
        print "$lRow";
        $lPrevious = $lTemp;        # Save CRC32 | Size to test next row
    }


    close (OUTFILE);
    close (INFILE);

    print "WashArchive: Found ($lErrorCount) errors\n";

    return ($lErrorCount);

}   # S_WashArchive

#---------------------------------------------------------------------------
# Routine:      S_GenerateMasterArchive
# Description:  This routine will take all the "BACKUP*.CRC" files
#               and merge them to produce the sorted ARCHIVE.CRC
#               file.
#---------------------------------------------------------------------------
sub S_GenerateMasterArchive
{
    local ($lCmd, $lChar);
    local ($lTempFile1) = $gCRC_DIR . "\\new_arc.out";
    local ($lErrorCount);
    local ($i);


    # See if we need to cleanup from a previous-failed run
    if ( -e $lTempFile1 ) {
        print "Found old $lTempFile1 Deleting...\n";
        unlink ($lTempFile1);
    }

    # Now the fun: run these kind of commands:
    #   >grep '^0' BACKUP*.crc | sort > new_arc.out
    #   >grep '^1' BACKUP*.crc | sort > new_arc.out
    #   >grep '^A' BACKUP*.crc | sort > new_arc.out
    # This will create a fully-sorted CRC file by pulling out
    # all the CRC's that begin with 0, then with 1, ...F

    # Loop through 0-9

    $lChar = '0';
    while ( $lChar <= '9' ) {
        # Use GREP to grab the rows, write to the temp file
        # something like: "grep '^2' c:\crc\backup*.crc | sort >> new_archive.out"

        $lCmd = "$gGREP_PGM -q \"^$lChar\" $gCRC_DIR\\$gCATALOG_BASE\*\.crc \| sort >> $lTempFile1";
        print "$lCmd\n" if ($gDEBUG == 1);
        system ($lCmd);

        $lChar++;   # Go to the next character
    }

    $i = 65;
    $lChar = chr($i++);
    while ( $i <= 71 ) {
        # Use GREP to grab the rows, write to the temp file
        # something like: "grep '^2' c:\crc\backup*.crc | sort >> new_archive.out"
        $lCmd = "$gGREP_PGM -q \"^$lChar\" $gCRC_DIR\\$gCATALOG_BASE\*\.crc \| sort >> $lTempFile1";
        print "$lCmd\n" if ($gDEBUG == 1);
        system ($lCmd);
        $lChar = chr($i++);     # Go to the next character
    }


    # Preserve the old ARCHIVE.CRC file

    if ( -e $gARCHIVE_FILE ) {
        system ("rename $gARCHIVE_FILE archive.old");
    }

    # The new archive file has a bunch of likes "File ..." and we also have
    # some duplicate rows from burning files into several CD's. Call a
    # routine to clean this up. Write the good rows to ARCHIVE.CRC.

    $lErrorCount = 0;

    $lErrorCount = &S_WashArchive ($lTempFile1, $gARCHIVE_FILE);

    if ( $lErrorCount > 0 ) {
        print "Restoring old ARCHIVE.CRC file because of wash errors...\n";
        unlink ($gARCHIVE_FILE);    # Remove the created ARCHIVE.CRC file
        system ("rename $gCRC_DIR\\archive.old $gARCHIVE_FILE");
        print "Check the ($lTempFile1) for errors\n";
    } else {
        # Things went well, so clean up
        unlink ("$gCRC_DIR\\archive.old");
        unlink ("$lTempFile1");
    }


}   #S_GenerateMasterArchive

#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
sub GetKey {
    local ($aRow) = @_;
    local ($lCRC, $lSize) = split (/\|/, $aRow);
    print "GK: $lCRC, $lSize\n";
    return ("$lCRC\|$lSize");
}   # GetKey

#---------------------------------------------------------------------------
# Routine:      S_Compare2Archive
# Description:  This routine will take a .crc file and compare each row
#               to the ARCHIVE.CRC file. Files NOT found will be reported
#---------------------------------------------------------------------------
sub S_Compare2Archive {
    local ($aNewFile, $aArchiveFile) = @_;
    local ($lMatchCount, $lErrorCount) = (0,0);
    local ($lCRC, $lSize, $lTemp, $lArchiveRow, $lNewRow);

    if ( ! -e $aNewFile ) {
        print "Comp2Arc: Input file ($aNewFile) does not exist\n";
        return;
    }
    if ( ! -e $aArchiveFile ) {
        print "Comp2Arc: Archive file ($aNewFile) does not exist\n";
        return;
    }

    open (NEWFILE, "$aNewFile")     || die ("C2A: Error - cannot open ($aNewFile) for input");
    open (ARCFILE, "$aArchiveFile") || die ("C2A: Error - cannot open ($aArchiveFile) for input");

    $lArchiveRow = &GetKey($lTemp = <ARCFILE>);
    $lNewRow = &GetKey ($lTemp = <NEWFILE>);

    print "First Archive Row: $lArchiveRow\n";
    print "First New Row    : $lNewRow\n";

    #  Get the ARCHIVE ptr synced up with the first new row
    #
    while ( $lArchiveRow < $lNewRow ) {
        $lArchiveRow = &GetKey($lTemp = <ARCFILE>);
        # print "$lArchiveRow\n";
    }
    print "Synced up ($lArchiveRow - $lNewRow)\n";

    while ( $lNewRow ) {

        # Get the CRC32|Size from the new file
        while ( $lNewRow < $lArchiveRow ) {
            $lArchiveRow = &GetKey($lTemp = <ARCFILE>);
        }

        # This should be equal
        if ( $lNewRow ==  $lArchiveRow ) {
            $lMatchCount++;
        } else {
            print "Error: Could not find ($lNewRow) in archive file\n";
            $lErrorCount++;
        }

        # Get the next row from the new file
        $lNewRow = &GetKey ($lTemp = <NEWFILE>);
    }

    close (ARCFILE);
    close (NEWFILE);

}   # S_Compare2Archive

#---------------------------------------------------------------------------
# Routine:      S_ChallengeArchive
# Description:  This routine will find all the BACKUP*.crc files and make
#               shure the global ARCHIVE.CRC contains each row.
#
#               *** FOR TEST USE ONLY
#
#---------------------------------------------------------------------------
sub S_ChallengeArchive {

    local ($lFile);
    local (@lFileList) = glob ("$gCRC_DIR\\BACK*.crc");

    foreach $lFile (sort @lFileList) {
        print "Checking: $lFile\n";
        &S_Compare2Archive ("$lFile", "$gARCHIVE_FILE");
        die ("Exiting after 1 file");
    }


}   # S_ChallengeArchive

#---------------------------------------------------------------------------
# Routine:      S_ZeroPadCRCFiles
# Description:  The CRC32 routine does not display leading zeros. This
#               messes up the comparisons.
#               This routine takes a directory name and looks for all
#               *.CRC files. Each one is scanned and the CRC32 and SIZE
#               strings are zero-padded:
#                   CRC32:  Old = 123456
#                   CRC32:  New = 00123456
#
# Input:        aDir - Directory with all the CRC files
#
#---------------------------------------------------------------------------
sub S_ZeroPadCRCFiles {
    local ($aDir) = @_;
    local ($lFile);
    local ($lRow, $lCRC32, $lSize);
    local ($lTempFile) = "temp._crc";

    if ( -e $lTempFile ) {
        unlink ($lTempFile);
    }

    local (@lFileList) = glob ($aDir . "\\*.crc");
    print "@lFileList\n";

    foreach $lFile (@lFileList) {

        print "ZP: Processing $lFile\n";
        system ("rename $lFile $lTempFile");
        open (INFILE,  "$lTempFile") || die ("ZP: Error: Cannot open ($lTempFile) for input\n");
        open (OUTFILE, ">$lFile")    || die ("ZP: Error: Cannot open ($lFile) for output\n");
        while ( <INFILE> ) {
            $lRow = $_;
            chomp ($lRow);
            $lRow = &NormalizeCRCRow ($lRow);
            print OUTFILE "$lRow\n";
        }

        close (OUTFILE);
        close (INFILE);
        unlink ($lTempFile);
    }


}   # S_ZeroPadCRCFiles

#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
sub S_CreateLocalCRCFiles {
   my ($aStartDir) = @_;
   my ($lDir, $lFile);
   my @lDirArray = ();
   my @lTempArray = ();

   print "LocalCRCFiles starting\n";
   if ( ! -e $aStartDir ) {
      print "Error: Start dir does not exist: $aStartDir\n";
      return;
   }

   print "Going to: $aStartDir\n";
   chdir ($aStartDir) or die ("Error: Could not chdir to $aStartDir : $!\n");

   push (@lTempArray, sort glob ("AVI-DVD-*") );
   push (@lTempArray, sort glob ("AVI-BD-*") );

   foreach $lDir ( @lTempArray ) {
      # Skip unless the file is a directory
      next if ( ! -d $lDir );

      # Skip if there is already a .crc file in the directory

      my @array = glob ( "$lDir\\*.crc");
      next if ( scalar ( @array ) >= 1 );

      print "Needs Processing: $lDir\n";
      push (@lDirArray, $lDir);
   }

   foreach $lDir ( @lDirArray ) {
      # Want the file name like: d:\\AVI-DVD-1001\\AVI-DVD-1001.crc
      my $lCRCFile = $aStartDir . $lDir . '\\';
      my $lTemp = $lDir;
      $lTemp =~ s/\-done//;
      $lCRCFile .= $lTemp . ".crc";
      print "CRC file = $lCRCFile\n";

      my @lCRCArray = &ScanOneDir ($lTemp, "$aStartDir" . $lDir);

      open (CRC_FILE, ">$lCRCFile") or die ("Error: Could not open file for output: $lCRCFile : $!\n");
      foreach my $lRow ( @lCRCArray ) {
         print "\t$lRow\n";
         print CRC_FILE "$lRow\n";
      }
      close (CRC_FILE) or die ("Error: Could not close output file: $lCRCFile : $!\n");

      # Copy the new .crc file to the master \\crc directory.

      if ( -s $lCRCFile > 5 ) {
         unlink ( $gCRC_DIR . "\\$lTemp") if ( -e $gCRC_DIR . "\\$lTemp");
         system ("copy $lCRCFile $gCRC_DIR");
      }

   }


}  # S_CreateLocalCRCFiles

#---------------------------------------------------------------------------
#	Routine: S_FixFileNames
# 	Description:	This routine will try to update file names in \temp\1 so
#					dpg. becomes DigitalPictures., and "daredorm" becomes
#					DareDorm.
#---------------------------------------------------------------------------
sub S_FixFileNames {
   my ($aPath) = @_;
   my (@lFileArray, $lFileName, $lNewFileName);
   my (@lPrefixArray, $lPrefix);

   @lStripPrefixArray = qw (c69 cb esexxx iak inya ktr lust tbp oro manlove mistress \[NoDRM\] inya ppm rank sex4ever sexo tbp xcite xs xxx4u);

   # Has of prefix subsutitions to convert "atk-june" to "AmatureTeenKingdom-june"
   %lPrefixSub = (
      'empty'                 => {name    => '',            qual => '',       genre => '',           res => '', example => '', filter => 0,},
      '18cup'                 => {name    => '18CloseUp',            qual => '',       genre => 'teen',           res => 'high', example => '', filter => 0,},
      '18f'                   => {name    => '18Flesh',              qual => 'medium', genre => 'teen-lesbian',   res => 'medium', example => 'inya-18f', url => '18flesh.com', filter => 0,},
      '18flesh'               => {name    => '18Flesh',              qual => 'medium', genre => 'teen-lesbian',   res => 'medium', example => 'inya-18f', url => '18flesh.com', filter => 0, },
      '18og'                  => {name    => '18OnlyGirls',          qual => 'high',   genre => 'teen',           res => 'high', example => 'ktr.18og.', filter => 0, },
      '18virginsex'           => {name    => '18VirginSex',          qual => 'good',   genre => 'teen',           res => 'medium', example => '', filter => 0, },
      '18vs'                  => {name    => '18VirginSex',          qual => 'good',   genre => 'teen',           res => 'medium', example => 'ktr.18vs.', filter => 0, },
      '18xg'                  => {name    => '18XGirls',             qual => 'high',   genre => 'teen',           res => 'high', example => 'ktr.18xg.', filter => 0, },
      '18yold'                => {name    => '18YearOld',            qual => 'high',   genre => 'teen',           res => '', url => 'PornPros.com', example => 'cp-18yoldkke174', filter => 0, },
      '1kf'                   => {name    => 'OneThousandFacials',   qual => 'low',    genre => 'oral',           res => 'low', example => 'ktr.1kf', filter => 0,},
      '2c1d'                  => {name    => '2Chicks1Dick',         qual => 'low',    genre => 'threesomes',     res => 'low', url => '2chicks1dick.com', example => 'ktr.2c1d.e22', filter => 1, },
      '8tw'                   => {name    => '18World',              qual => '',       genre => 'teen',           res => '', example => '', filter => 0, },
      'abb'                   => {name    => 'AbbyWinters',          qual => 'high',   genre => 'teen-les',       res => 'high', example => '', filter => 0, },
      'abt'                   => {name    => 'AbusedBlackTrannies',  qual => 'medium',    genre => 'bdsm', res => 'medium', url => 'abusedblacktrannies.com', example => 'oro-mbf', filter => 0, },
      'abbywinters'           => {name    => 'AbbyWinters',          qual => 'high',   genre => 'teen-les',       res => 'high', example => '', filter => 0, },
      'awinters'              => {name    => 'AbbyWinters',          qual => 'high',   genre => 'teen-les',       res => 'high', example => '', filter => 0, },
      'aw'                    => {name    => 'AbbyWinters',          qual => 'high',   genre => 'teen-les',       res => 'high', example => '', filter => 0, },
      'aca'                   => {name    => 'AmatureCanada',        qual => 'low',    genre => 'amat-teen',      res => '', example => '', filter => 0, },
      'acs'                   => {name    => 'AmatureCoupleSex',     qual => 'medium', genre => 'amat',           res => 'medium', example => 'ssh0p-acs.', filter => 0, },
      'adl'                   => {name    => 'AnalDildoLesbians',    qual => '',       genre => 'lesbian',        res => 'low', url => 'analdildolesbians.com', example => 'ktr.adl.e03', filter => 0, },
      'ams'                   => {name    => 'AmateureSmothering',   qual => 'low',    genre => 'bdsm',            res => 'low', example => 'ktr.ams', filter => 0,},
      'g'                     => {name    => 'AbbyWinters',          qual => '',       genre => 'teen-les',       res => '', example => '', filter => 0, },
      'analhell'              => {name    => 'AnalHell',             qual => '',       genre => 'anal',           res => '', example => '', filter => 0, },
      'analpetite'            => {name    => 'AnalPetite',           qual => '',       genre => 'teen-anal',      res => '', example => '', filter => 0, },
      'analrecruiters'        => {name    => 'AnalRecruiters',       qual => '',       genre => 'anal',           res => 'high', example => 'iak-ananlrecruiters', filter => 0, },
      'analstretched'         => {name    => 'AnalStretched',        qual => '',       genre => 'anal',           res => 'low', example => 'iak-analstretched', filter => 0, },
      'analteenangels'        => {name    => 'AnalTeenAngels',       qual => '',       genre => 'teen-anal',      res => '', example => '', filter => 0, },
      'analtryouts'           => {name    => 'AnalTryOuts',          qual => '',       genre => 'anal',     res => '', example => '', filter => 0, },
      'aph'                   => {name    => 'AnalPantyHose',        qual => '',       genre => 'anal',     res => '', example => '', filter => 0, },
      'amatureteenmovs'       => {name    => 'AmatureTeenMovs',      qual => '',       genre => 'teen',     res => '', example => '', filter => 0, },
      'archangel'             => {name    => 'ArchAngel',            qual => '',       genre => '',     res => '', example => '', filter => 0, },
      'ass'                   => {name    => 'AssSmoothie',          qual => '',       genre => 'anal',     res => 'low', example => 'rank-ass', url => 'AssSmothie.com', filter => 0, },
      'at'                    => {name    => 'AssTitans',            qual => 'high',   genre => 'anal',     res => 'high', example => 'cb.at.08', url => '', filter => 0, },
      'ata'                   => {name    => 'AnalTeenAngels',       qual => 'high',   genre => 'teen',     res => 'high', example => 'cb.ata', filter => 0, },
      'atm'                   => {name    => 'AmatureTeenMovs',      qual => '',       genre => 'teen',     res => '', example => '', filter => 0, },
      'atmov'                 => {name    => 'AmatureTeenMovs',      qual => '',       genre => 'teen',     res => '', example => '', filter => 0, },
      'atmovs'                => {name    => 'AmatureTeenMovs',      qual => 'low',    genre => 'teen',     res => 'low', example => 'inya-atmovs', filter => 0, },
      'atk'                   => {name    => 'AmatureTeenKingdom',   qual => '',       genre => 'teen',     res => '', example => '', filter => 0, },
      'atk'                   => {name    => 'AmatureTeenKingdom',   qual => '',       genre => 'teen',     res => '', example => '', filter => 0, },
      'awinters'              => {name    => 'AbbyWinters',          qual => '',       genre => 'les',   res => '', example => '', filter => 0, },
      'bbp'                   => {name    => 'BallBustingPornstars', qual => 'medium', genre => 'bdsm',  res => 'low', example => 'oro-bbp', filter => 0, },
      'bd'                    => {name    => 'BrutalDildos',         qual => '',       genre => 'dildo', res => '', example => 'ktr.bd', filter => 0, },
      'bep'                   => {name    => 'BetaPorn',             qual => 'high',   genre => 'teen',  res => 'high', example => 'ktr.bep', filter => 0, },
      'bfs'                   => {name    => 'BrutalFaceSitting',    qual => 'medium', genre => 'bdsm',  res => 'bdsm', example => 'ktr.bfs', filter => 0, },
      'bgbs'                  => {name    => 'BoundGangBangs',       qual => 'highs',  genre => 'bdsm',  res => 'high', example => 'ktr.bgbs', filter => 0, },
      'bob'                   => {name    => 'BlacksOnBlonds',       qual => 'high',   genre => 'iracial',  res => 'high', example => 'ktr.bob', filter => 0, },
      'bri'                   => {name    => 'BrutalInvasion',       qual => 'high',   genre => 'bdsn',  res => 'high', example => 'sexo-bri', filter => 0, },
      'bmta'                  => {name    => 'BangMyTeenAss',        qual => 'high',   genre => 'teen-anal', res => 'high', example => 'bmta', url => 'bangmyteenass.com', filter => 0, },
      'bmtass'                => {name    => 'BangMyTeenAss',        qual => 'high',   genre => 'teen-anal', res => 'high', example => 'bmta', url => 'bangmyteenass.com', filter => 0, },
      'cf'                    => {name    => 'CumFu',                qual => 'medium', genre => 'asian', res => 'medium', url => 'muffia.com', example => 'cb.cf', filter => 0, },
      'cov'                   => {name    => 'cov',                  qual => '',       genre => '3some,teen?', res => 'medium', example => 'oro-cov', filter => 0, },
      'cpa'                   => {name    => 'CreampieAngels',       qual => 'high',   genre => 'teen',  res => 'high', example => 'ktr.cpa', filter => 0, },
      'cr'                    => {name    => 'CollegeRules',         qual => 'high',   genre => 'teen', res => 'high', example => 'ktr.cr', filter => 0, },            
      'cs'                    => {name    => 'CreampiedSweeties',    qual => 'medium', genre => 'teen', res => 'medium', url => 'CreampiedSweeties.com', example => 'ktr.cs', filter => 0, },
      'ctsex'                 => {name    => 'CasualTeenSex',        qual => '',       genre => 'teen', res => 'low', example => '', filter => 0, },
      'cts'                   => {name    => 'CasualTeenSex',        qual => 'medium', genre => 'teen', res => 'high', example => '', filter => 0, },      
      'casualteensex'         => {name    => 'CasualTeenSex',        qual => '',       genre => 'teen', res => '', example => '', filter => 0, },
      'cutiesgalore'          => {name    => 'CutiesGalore',         qual => '',       genre => 'teen', res => '', example => '', filter => 0, },
      'd18'                   => {name    => 'Disgraced18',          qual => 'high',   genre => 'bdsm', res => 'high', example => 'ktr.d18', filter => 0, },
      'deb'                   => {name    => 'DeviceBondage',        qual => 'high',   genre => 'bdsm', res => 'high', example => 'ktr.tuf', filter => 0, },
      'devicebondage'         => {name    => 'DeviceBondage' ,       qual => 'high',   genre => 'bdsm', res => '', example => '', filter => 0, },
      'ddm'                   => {name    => 'DareDorm',             qual => 'high',   genre => 'teen', res => 'high', example => 'ktr.ddm', filter => 0, },
      'daredorm'              => {name    => 'DareDorm',             qual => 'high',   genre => 'teen', res => 'high', example => 'daredorm', filter => 0, },
      'dh'                    => {name    => 'DreamHonies',          qual => '',       genre => 'les',  res => '', example => '', filter => 0, },
      'dms'                   => {name    => 'DildoMachineSex',      qual => '',       genre => 'gonzo', res => '', example => '', filter => 0, },
      'don'                   => {name    => 'DongerBrothers',       qual => 'high',   genre => 'big dicks', res => 'high', example => 'rank-don', url => 'realitygang.com', filter => 0, },
      'dominatedgirls'        => {name    => 'DominatedGirls',       qual => '',       genre => 'bdsm', res => '', example => '', filter => 0, },
      'doubleteamedteens'     => {name    => 'DoubleTeamedTeens',    qual => '',       genre => 'teen', res => '', example => '', filter => 0, },
      'dpm'                   => {name    => 'YoungDommes',          qual => 'high',   genre => 'bdsm', res => 'high', example => 'oro.dpm', filter => 0, },
      'ds'                    => {name    => 'DungeonSex',           qual => 'high',   genre => 'bdsm', res => 'high', example => 'ds-15022', filter => 0, },
      'dso'                   => {name    => 'DrunkSexOrgy',         qual => '',       genre => '', res => '', example => '', filter => 0, },
      'dtp'                   => {name    => 'DixiesTrailerPark',    qual => 'medium', genre => 'amat', res => 'low', example => 'oro-dtp', filter => 0, },
      'dpg'                   => {name    => 'DigitalPlayground',    qual => 'high',   genre => 'gonzo', res => 'high', example => 'oro-dpm', filter => 0, },
      'dpm'                   => {name    => 'YoungDommes',          qual => 'high',   genre => 'femdom', res => 'high', example => 'oro-dpm', filter => 0, },
      'eb'                    => {name    => 'EverythingButt',       qual => 'High',   genre => 'bdsm',   res => 'high', example => 'ktr.eb', filter => 0,},
      'everythingbutt'        => {name    => 'EverythingButt',       qual => 'High',   genre => 'bdsm',   res => 'high', example => 'ktr.eb', filter => 0,},
      'electrosluts'          => {name    => 'ElectroSluts',         qual => 'High',   genre => 'bdsm',   res => 'electrosluts', example => 'ktr.eb', filter => 0,},
      'ej'                    => {name    => 'EllieJay',             qual => '',       genre => 'amat-brit', res => 'low', example => 'EllieJay.com', filter => 0, },
      'exc'                   => {name    => 'ExclusiveTeenPorn',    qual => '',       genre => 'teen', res => '', example => '', filter => 0, },
      'exk'                   => {name    => 'ExtremeKream',         qual => 'low',    genre => 'teen-les',   res => 'low', example => 'ktr.exk', filter => 0,},
      'exploitedteens'        => {name    => 'ExploitedTeens',       qual => '',       genre => 'teen', res => 'medium', example => '', filter => 0, },
      'evilangel'             => {name    => 'EvilAngel',            qual => 'high',   genre => 'gonzo', res => 'medium', example => '', filter => 0, },
      'fd'                    => {name    => 'FuckingDungeon',       qual => '',       genre => 'bdsm', res => '', example => '', filter => 0, },
      'fad'                   => {name    => 'FirstAnalDate',        qual => 'High',   genre => 'teen-anal', res => 'high', example => 'oro-faq', filter => 0, },
      'faq'                   => {name    => 'FirstAnalQuest',       qual => 'High',   genre => 'teen-anal', res => 'high', example => 'oro-faq', filter => 0, },
      'fca'                   => {name    => '',                     qual => 'low',    genre => '', res => 'low', url => 'StudioSexy.com', example => 'yy-fca', filter => 0, },
      'fhgs'                  => {name    => 'FuckedHardGF',         qual => 'medium', genre => 'amat', res => 'medium', example => 'fhgs.e29', filter => 0, },
      'fif'                   => {name    => 'FistFreaks',           qual => 'low',    genre => 'fist', res => 'low', example => 'ktr.fif.e29', filter => 0, },
      'firstanalquest'        => {name    => 'FirstAnalQuest',       qual => 'High',   genre => 'teen-anal', res => 'high', example => 'iak-firstanalquest', filter => 0, },
      'fob'                   => {name    => 'fob',                  qual => '',       genre => 'boobs', res => 'medium', example => 'ieva-fob', filter => 0, },
      'fs'                    => {name    => 'FuckStudies',          qual => 'High',   genre => 'Teen', res => 'high', example => 'fs.e07.jennifer.dixon.anal', filter => 0, },
      'ftb'                   => {name    => 'FuckTheBabysitter',    qual => 'med',    genre => 'Teen', res => 'med', url => 'xmovies.com', example => 'xs-ftp', filter => 0, },
      'fmn'                   => {name    => 'ForcedMale',           qual => 'low',    genre => 'femdom', res => 'medium', example => 'oro-fmn', filter => 0, },
      'fsws'                  => {name    => 'FirstSexWithSister',   qual => 'med',    genre => 'Teen', res => 'medium', example => 'oro-fsws', filter => 0, },
      'fv'                    => {name    => 'muffia',               qual => '',       genre => '', res => 'medium', example => 'cb.fv', url => 'muffia.com', filter => 0, },
      'fum'                   => {name    => 'FuckingMachines',      qual => 'high',   genre => 'bdsm', res => 'medium', example => 'cb.fv', url => 'muffia.com', filter => 0, },
      'fuckingmachines'       => {name    => 'FuckingMachines',      qual => 'high',   genre => 'bdsm', res => 'medium', example => 'cb.fv', url => 'muffia.com', filter => 0, },
      'galgirls'              => {name    => 'GalacticGirls',        qual => 'medium', genre => 'scifi', res => 'medium', example => 'inya-galgirls', url => 'galacticgirls.com', filter => 0, },
      'gfr'                   => {name    => 'GFRevenge',            qual => 'Good',   genre => 'Amature', res => 'Medium', example => 'ktr.gfr', url => '', filter => 0, },
      'gfrevenge'             => {name    => 'GFRevenge',            qual => 'Good',   genre => 'Amature', res => 'Medium', example => 'ktr.gfr', url => '', filter => 0, },
      'gdp'                   => {name    => 'GirlsDoPorn',          qual => 'Good',   genre => 'Amature', res => 'Medium', example => 'gdp.', url => '', filter => 0, },
      'grg'                   => {name    => 'GothRockGirls',        qual => 'Good',   genre => 'Lesbian', res => 'Medium', example => 'inya.grg.e02', url => 'gothrockgirls.com', filter => 0, },
      'h18'                   => {name    => 'HDV18',                qual => '',       genre => 'teen', res => '', example => '', filter => 0, },
      'hannashoneypot'        => {name    => 'HannasHoneyPot',       qual => '',       genre => 'teen-les', res => '', example => '', filter => 0, },
      'hardt'                 => {name    => 'HardTied'      ,        qual => 'high',   genre => 'bdsm', res => 'high', example => 'ktr.tuf', filter => 0, },
      'hardtied'              => {name    => 'HardTied'      ,        qual => 'high',   genre => 'bdsm', res => 'high', example => 'ktr.tuf', filter => 0, },
      'hgb'                   => {name    => 'HardCoreGangBang',     qual => 'high',   genre => 'bdsm', res => '', example => '', filter => 0, },
      'hardcoregangbang'      => {name    => 'HardCoreGangBang',     qual => 'high',   genre => 'bdsm', res => '', example => '', filter => 0, },
      'hometoyteens'          => {name    => 'HomeToyTeens',         qual => '',       genre => 'teen', res => 'high', example => '', filter => 0, },
      'hot'                   => {name    => 'HerOldTeacher',        qual => '',       genre => 'teen-old', res => '', example => '', filter => 0, },
      'hotb'                  => {name    => 'HouseOfTaboo',         qual => 'High',   genre => 'bdsm', res => 'High', example => 'ktr.hotb', filter => 0, },
      'ht'                    => {name    => 'HogTied'      ,        qual => 'high',   genre => 'bdsm', res => 'high', example => 'ktr.tuf', filter => 0, },
      'hogtied'               => {name    => 'HogTied'      ,        qual => 'high',   genre => 'bdsm', res => 'high', example => 'ktr.tuf', filter => 0, },
      'iabbt'                 => {name    => 'ItsABigBlackThing',    qual => 'low',    genre => 'solo', res => 'low', url => 'itsabigblackthing.com', example => 'ktr.iabbt.09', filter => 0, },
      'ilo'                   => {name    => 'ILoveYouMadison',      qual => 'high',   genre => 'solo', res => 'high', url => 'ILoveYouMadison.com', example => 'rank-ilo', filter => 0, },
      'iloveminiskirts'       => {name    => 'ILoveMiniSkirts',      qual => '',       genre => '', res => '', example => '', filter => 0, },
      'innocenthigh'          => {name    => 'InnocentHigh',         qual => '',       genre => 'teen', res => '', example => '', filter => 0, },
      'intermixedsluts'       => {name    => 'IntermixedSluts',      qual => '',       genre => 'interracial', res => '', example => '', filter => 0, },
      'jiz'                   => {name    => 'jiz',                  qual => '',       genre => '', res => '', example => 'rank-jiz', filter => 0, },
      'jtm'                   => {name    => 'JustTeenMovies',       qual => 'high',   genre => 'teen', res => 'high', example => 'sexo-jtm', filter => 0, },
      'justteensite'          => {name    => 'JustTeenSite',         qual => '',       genre => 'teen', res => '', example => '', filter => 0, },
      'kat'                   => {name    => 'KickAssTeens',         qual => 'medium', genre => 'teen', res => 'low', example => 'oro-kat.09.05.31', filter => 0, },
      'kha'                   => {name    => 'KarupsHomegrownAmat',  qual => 'high',   genre => 'amat', res => 'high', example => 'kha-1321', filter => 0, },
      'iabbt'                 => {name    => 'ItsABigBlackThing',    qual => 'low',    genre => 'black',  res => 'low', example => 'ktr.iabbt', filter => 0,},
      'latinaabuse'           => {name    => 'LatinaAbuse',          qual => 'high',   genre => 'gonzo', res => '', example => '', filter => 0, },
      'lesbotraining'         => {name    => 'LesboTraining',        qual => '',       genre => 'teen-les', res => '', example => '', filter => 0, },
      'lc'                    => {name    => 'LezCuties',            qual => 'high',   genre => 'teen-les', res => 'high', example => '', filter => 0, },
      'lezcuties'             => {name    => 'LezCuties',            qual => 'high',   genre => 'teen-les', res => 'high', example => 'cb.lc', filter => 0, },
      'lezhoneys'             => {name    => 'LezboHoneys',          qual => 'High',   genre => 'lesbian', res => 'high', url => 'lezbohoneys.com', example => 'inya-lezhoneys.', filter => 0, },
       'lhc'                  => {name    => 'LittleHellCat',        qual => '',       genre => 'gonzo', res => 'low', example => '', filter => 0, },
       'll'                   => {name    => 'LeluLoves',            qual => '',       genre => 'amat', res => 'low', example => '', filter => 0, },
       'lta'                  => {name    => 'LetsTryAnal',          qual => '',       genre => 'amat', res => 'high', example => '', filter => 0, },
      'littleamy'             => {name    => 'littleamy',            qual => '',       genre => 'teen', res => 'high', example => '', filter => 0, },
      'little_teases'         => {name    => 'LittleTeases',         qual => '',       genre => 'teen', res => '', example => '', filter => 0, },
       'lima'                 => {name    => '',                     qual => '',       genre => 'europorn', res => 'high', url => '', example => 'inya-lima.e04.maria', filter => 0, },
       'lm'                   => {name    => 'LittleMutt',           qual => 'high',   genre => 'teen', res => 'high', url => 'LittleMutt.com', example => 'inya-lm', filter => 0, },
       'ls'                   => {name    => 'LadySonia',            qual => '',       genre => 'Solo', res => 'medium', example => 'ieva-ls', filter => 0, },
      'lustforanal'           => {name    => 'LustForAnal',          qual => '',       genre => 'anal', res => '', example => '', filter => 0, },
      'm'                     => {name    => '',                     qual => '',       genre => '', res => '', example => '', filter => 0, },
      'm18'                   => {name    => 'MyEighteen',           qual => 'low',    genre => 'teen', res => '', example => '', filter => 0, },
      'm18t'                  => {name    => 'MyEighteen',           qual => 'low',    genre => 'teen', res => '', example => '', filter => 0, },
      'my18t'                 => {name    => 'MyEighteens',          qual => '',       genre => 'teen', res => 'low,high', example => '', filter => 0, },
      'my18teens'             => {name    => 'MyEighteens',          qual => '',       genre => 'teen', res => 'low', example => '', filter => 0, },
      'm'                     => {name    => 'Muffia',               qual => '',       genre => '', res => '', url => 'Muffia.com', example => '', filter => 0, },
      'mbb'                   => {name    => 'MommyBlowsBest',       qual => 'low',    genre => 'MILF', res => 'low', example => 'ktr.mbb.09', filter => 1, },
      'mbf'                   => {name    => 'MyBestFetish',         qual => 'medium',    genre => 'bdsm', res => 'medium', url => 'mybestfetish.com', example => 'oro-mbf', filter => 0, },
      'mbt'                   => {name    => 'MomsBangTeens',        qual => 'high',    genre => 'MILF', res => 'high', url => 'mybestfetish.com', example => 'mbt-150504', filter => 0, },
      'mh'                    => {name    => 'MilfHumiliation',      qual => '',       genre => 'bdsm', res => 'high', example => '', filter => 0, },
      'mhumiliation'          => {name    => 'MilfHumiliation',      qual => '',       genre => 'bdsm', res => 'high', example => 'ieva-mh', filter => 0, },
      'mic'                   => {name    => 'MomsInCharge',         qual => 'high',   genre => 'milf', res => 'high', url => '', example => 'mic-19312', filter => 0, },
      'missyouth   '          => {name    => 'MissYouth',            qual => 'medium', genre => 'solo', res => 'medium', example => 'inya-missyouth', filter => 0, },
      'mkd'                   => {name    => 'MyKinkyDiary',         qual => 'medium',  genre => 'bdsm', res => 'low', example => 'ktr.mkd.e22', filter => 0, },
      'mmgs'                  => {name    => 'MommysGirl',           qual => 'high',   genre => 'milf', res => 'high', url => '', example => 'mic-19312', filter => 0, },
      'msp'                   => {name    => 'MadSexParty',          qual => '',       genre => '', res => '', example => '', filter => 0, },
      'mtbl'                  => {name    => 'MissToriBlack',        qual => '',       genre => '', res => '', example => '', url => 'MissToriBlack.com', filter => 0, },
      'mtg'                   => {name    => 'MakeTeenGape',         qual => 'High',   genre => 'teen',   res => 'high', example => 'ktr.mtg', filter => 0,},
      'mts'                   => {name    => 'MomsTeachSex',         qual => 'high',   genre => 'milf', res => 'high', url => '', example => 'mts-19312', filter => 0, },
      'mtt'                   => {name    => 'MomsTeachingTeens',    qual => 'low',    genre => 'old-young', res => 'low', example => '', filter => 0, },
      'mtv'                   => {name    => 'MyTeenVideos',         qual => 'high',   genre => 'teen', res => 'high', example => 'ktr.mtv', url => 'MyTeenVideos.com', filter => 0, },
      'momsteachingteens'     => {name    => 'MomsTeachingTeens',    qual => '',       genre => '', res => '', example => '', filter => 0, },
      'mightymistress'        => {name    => 'MightyMistress',       qual => '',       genre => 'bdsm', res => '', example => '', filter => 0, },
      'mms'                   => {name    => 'MightyMistress',       qual => 'high',   genre => 'bdsm', res => 'high', example => '', filter => 0, },
      'mydirtyteengirlfriend' => {name    => 'MyDirtyTeenGirlfriend',qual => '',       genre => '', res => '', example => '', filter => 0, },
      'mvft'                  => {name    => 'MyVeryFirstTime',      qual => 'high',   genre => 'amat', res => 'high', example => 'mvft-150505', filter => 0, },
      'myt'                   => {name    => 'MyTeenVideos',         qual => '',       genre => 'teen', res => 'low', example => 'rank-myt', filter => 0, },
      'myteenvid'             => {name    => 'MyTeenVideo',          qual => 'high',   genre => 'teen', res => 'high', example => 'oro-myteenvid', filter => 0, },
      'nastyrawsex'           => {name    => 'NastyRawSex',          qual => '',       genre => '', res => '', example => '', filter => 0, },
      'news'                  => {name    => 'NewSensations',        qual => '',       genre => 'misc', res => 'high', example => 'news-150504', filter => 0, },
      'newsensations'         => {name    => 'NewSensations',        qual => '',       genre => 'misc', res => 'high', example => 'news-150504', filter => 0, },
      'nb'                    => {name    => 'NewbieBlack',          qual => '',       genre => 'black', res => 'low', example => 'ieva-nb', filter => 0, },
      'nub'                   => {name    => 'Nubiles',              qual => 'high',   genre => 'teen', res => 'high', example => 'rank-nub', url => 'nubiles.net', filter => 0, },
      'ocuties'               => {name    => 'OnlyCuties',           qual => '',       genre => 'teen', res => '', example => '', filter => 0, },
      'onlycuties'            => {name    => 'OnlyCuties',           qual => '',       genre => 'teen', res => '', example => '', filter => 0, },
      'olipain'               => {name    => 'OliviaPain',           qual => '',       genre => 'gonzo', res => 'high', example => '', filter => 0, },
      'osg'                   => {name    => 'OsakaSchoolGirls',     qual => 'low',    genre => 'teen', res => 'low', example => 'ktr.osg', filter => 0, },
      'parisrain'             => {name    => 'ParisRain',            qual => '',       genre => 'teen', res => 'high', example => 'inya-parisrain', filter => 0, },
      'peternorth'            => {name    => 'PeterNorth',           qual => '',       genre => 'teen', res => 'high', example => 'inya-parisrain', filter => 0, },
      'ptra'                  => {name    => 'PigTailsRoundAsses',   qual => 'low',    genre => 'gonzo', res => 'low', example => 'cb.prta.e158', filter => 1, },
      'pm'                    => {name    => 'PoolMilf',             qual => 'low',    genre => 'milf', res => 'low', example => 'ktr.pm', filter => 1, },
      'psy'                   => {name    => 'PrivateSociety',       qual => 'low',    genre => 'amat', res => 'low', example => 'oro-psy', filter => 0, },
      'prvs'                  => {name    => 'PrivateSociety',       qual => 'low',    genre => 'amat', res => 'low', example => 'oro-psy', filter => 0, },
      'pud'                   => {name    => 'PublicDisgrace',       qual => 'high',   genre => 'bdsm', res => 'high', example => 'ktr.pub', filter => 0, },
      'publicdisgrace'        => {name    => 'PublicDisgrace',       qual => 'high',   genre => 'bdsm', res => 'high', example => 'ktr.pub', filter => 0, },
      'punkyjaine'            => {name    => 'PunkyJaine',           qual => '',       genre => 'teen', res => '', example => '', filter => 0, },
      'r18'                   => {name    => 'Rough18',              qual => 'high',   genre => 'teen', res => 'high', example => 'krt.r18.e03.kate.and.tom', filter => 0, },
      'rhu'                   => {name    => 'RipHerUp',             qual => 'low',    genre => 'bdsm', res => 'low', example => 'ktr.rhu', filter => 0, },
      'rig'                   => {name    => 'RightOffTheBoat',      qual => 'low',    genre => 'teen', res => 'low', example => '', filter => 1, },
      'roccosiffredi'         => {name    => 'RoccoSiffredi',        qual => 'high',   genre => 'gonzo', res => 'high', example => '', filter => 0, },
      'rg'                    => {name    => '',                     qual => 'low',    genre => 'hidden cam', res => 'low', example => 'oro-rg', filter => 0, },
      'rp'                    => {name    => 'RealPeachez',          qual => '',       genre => 'Solo', res => 'low', example => '', filter => 0, },
      'rtc'                   => {name    => 'RussianTeensClub',     qual => '',       genre => 'teen', res => 'high', url => 'sextronix.com', example => 'inya-rtc', filter => 0, },
      'pvi'                   => {name    => 'PainVixens',           qual => 'high',   genre => 'bdsm', res => 'high', url => 'painvixens.com', example => 'ktr.pvi', filter => 0, },
      'realityjunkies'        => {name    => 'RealityJunkies',       qual => 'high',   genre => 'gonzo', res => 'high', example => '', filter => 0, },
      'russianteenobsession'  => {name    => 'RussianTeenObsession', qual => '',       genre => 'teen', res => '', example => '', filter => 0, },
      'sas'                   => {name    => 'SexAndSubmission',     qual => 'high',   genre => 'bdsm', res => 'high', example => 'ktr.pub', filter => 0, },
      'seb'                   => {name    => 'SexuallyBroken',       qual => 'high',   genre => 'bdsm', res => 'high', example => 'seb-15022', filter => 0, },
      'sed'                   => {name    => 'SexualDisgrace',       qual => 'high',   genre => 'bdsm', res => 'high', example => 'seb-15022', filter => 0, },
      'sexandsubmission'      => {name    => 'SexAndSubmission',     qual => 'high',   genre => 'bdsm', res => 'high', example => 'seb-15022', filter => 0, },
      'smul'                  => {name    => 'SheMadeUsLesbians',    qual => 'medium', genre => 'teen', res => 'medium', example => 'smul.e04', filter => 0, },
      'spb'                   => {name    => 'SpunkBunnies',         qual => '',       genre => 'amat', res => '', example => '', filter => 0, },
      'soc'                   => {name    => 'SoccerMomScore',       qual => 'low',    genre => 'gonzo', res => 'low', example => 'rank-soc', filter => 0, },
      'soh'                   => {name    => 'ShameOnHer',           qual => '',       genre => 'gonzo', res => '', example => '', filter => 0, },
      'sr'                    => {name    => 'SashaRose',            qual => 'high',   genre => 'teen', res => 'hi', example => 'ktr-sr', url => 'sasharose.com', filter => 0, },
      'st'                    => {name    => 'SpringThomas',         qual => 'low',    genre => 'interracial', res => 'low', example => 'ktr-st', url => 'springthomas.com', filter => 1, },
      'stb'                   => {name    => 'SpankThatBrat',        qual => 'medium', genre => 'bdsm', res => 'low', example => 'tb.stb', filter => 0, },
      'stc'                   => {name    => 'StrapOnCum',           qual => 'high',   genre => 'teen', res => 'high', example => 'oro-stc.e04', filter => 0, },
      'sto'                   => {name    => 'StockingsOnPornstars', qual => '',       genre => 'gonzo', res => 'low', example => 'rank-sto', filter => 1, },
      'stretchedoutsnatch'    => {name    => 'StretchedOutSnatch',   qual => '',       genre => '', res => 'low', example => '', filter => 0, },
      'sweetheartvideo'       => {name    => 'SweetheartVideo',      qual => 'high',   genre => 'gonzo', res => 'high', example => '', filter => 0, },
      'sweetsinner'           => {name    => 'SweetSinner',          qual => 'high',   genre => 'gonzo', res => 'high', example => '', filter => 0, },
      'sv'                    => {name    => 'SpoiledVirgins',       qual => 'good',   genre => 'teen', res => 'medium', example => 'ktr.sv', url => 'spoiledvirgins.com', filter => 0, },
      'tasp'                  => {name    => 'TaniaSpice',           qual => 'medium', genre => 'Latina', res => 'medium', example => 'inya-tasp', filter => 0, },
      'tat'                   => {name    => 'TabooTrannys',         qual => 'medium', genre => 'Tranny', res => 'high', example => 'manlove-tat', filter => 0, },
      'tf'                    => {name    => 'TeensFilled',          qual => 'high',   genre => 'teen', res => 'high', url => 'internalpass.com', example => 'ktr.tf', filter => 0, },
      'tm'                    => {name    => 'TheMinion',            qual => 'low',    genre => 'gonzo', res => 'low', url => 'theminion.com', example => 'ktr.tm', filter => 1, },
      'tpf'                   => {name    => 'ThePainFiles',         qual => 'medium',    genre => 'bdsm', res => 'low', url => 'thepainfiles.com', example => 'oro-tpf', filter => 0, },
      'ts'                    => {name    => 'TaniaSpice',           qual => 'medium', genre => 'Latina', res => 'medium', example => 'inya-tasp', filter => 0, },
      'teachmefisting'        => {name    => 'TeachMeFisting',       qual => '',       genre => 'fist', res => '', example => '', filter => 0, },
      'teendreams'            => {name    => 'TeenDreams',           qual => '',       genre => 'teen', res => '', example => '', filter => 0, },
      'tebu'                  => {name    => 'TeenBurg',             qual => 'high',   genre => 'teen', res => 'high', example => 'inya-tebu.', filter => 0, },
      'teenagegroupsex'       => {name    => 'TeenageGroupSex',      qual => '',       genre => 'teen', res => '', example => '', filter => 0, },
      'teennamite'            => {name    => 'TeennAMite',           qual => '',       genre => 'teen', res => 'high', example => 'iak-teennamite', filter => 0, },
      'teenburg'              => {name    => 'TeenBurg',             qual => '',       genre => 'teen', res => '', example => '', filter => 0, },
      'teensexfusion'         => {name    => 'TeenSexFusion',        qual => '',       genre => '', res => '', example => '', filter => 0, },
      'tiny4k'                => {name    => 'Tiny4K',               qual => 'high',   genre => 'teen', res => 'high', example => 'tiny4k', filter => 0, },
      'tpf'                   => {name    => 'ThePainFiles',         qual => '',       genre => 'bdsm', res => 'low', example => 'oro-tpf', filter => 0, },
      'tsm'                   => {name    => 'TeenSexMovs',          qual => '',       genre => 'teen', res => 'high', example => '', filter => 0, },
      'ttb'                   => {name    => 'TeensWantBlack',       qual => 'high',   genre => 'ir',   res => 'high', example => 'ttb.e01', filter => 0, },
      'tto'                   => {name    => 'TheTrainingOfO',       qual => 'high',   genre => 'bdsm', res => 'high', example => 'ktr.tto', filter => 0, },
      'teensexmovs'           => {name    => 'TeenSexMovs',          qual => '',       genre => 'teen', res => 'high', example => '', filter => 0, },
      'teensexmania'          => {name    => 'TeenSexMania',         qual => '',       genre => 'teen', res => 'high', example => '', filter => 0, },
      'tuf'                   => {name    => 'TheUpperFloor',        qual => 'high',   genre => 'bdsm', res => 'high', example => 'ktr.tuf', filter => 0, },
      'theupperfloor'         => {name    => 'TheUpperFloor',        qual => 'high',   genre => 'bdsm', res => 'high', example => 'ktr.tuf', filter => 0, },
      'ttoo'                  => {name    => 'TheTrainingOfO',       qual => 'high',   genre => 'bdsm', res => 'high', example => 'ppm-ttoo', filter => 0, },
      'thetrainingofo'        => {name    => 'TheTrainingOfO',       qual => 'high',   genre => 'bdsm', res => 'high', example => 'ppm-ttoo', filter => 0, },
      'twi'                   => {name    => 'Twisties',             qual => '',       genre => 'soft', res => 'high', example => '', filter => 1, },
      'vlb'                   => {name    => 'VivalBuss',            qual => 'low',    genre => 'unk',  res => 'low', example => 'cb.vlb.e35', filter => 0,},
      'wbl'                   => {name    => 'WebeLez',              qual => 'medium', genre => 'fist', res => 'low', example => 'xs-wbl', filter => 0, },
      'wip'                   => {name    => 'WiredPussy',           qual => 'high',   genre => 'bdsm', res => 'high', example => 'ktr.wip', filter => 0, },
      'wpa'                   => {name    => 'WhippedAss',           qual => 'high',   genre => 'bdsm', res => 'high', example => 'ktr.wip', filter => 0, },
      'whippedass'            => {name    => 'WhippedAss',           qual => 'high',   genre => 'bdsm', res => 'high', example => 'ktr.wip', filter => 0, },
      'wkp'                   => {name    => 'WickedPictures',       qual => 'high',   genre => 'gonzo', res => 'high', example => 'ktr.wip', filter => 0, },
      'wickedpictures'        => {name    => 'WickedPictures',       qual => 'high',   genre => 'gonzo', res => 'high', example => 'wickedpictures', filter => 0, },
      'wld'                   => {name    => 'Wasteland',            qual => 'medium', genre => 'bdsm', res => 'medium', example => 'oro-wld.e41', filter => 0, },
      'wmw'                   => {name    => 'WankMyWood',           qual => 'low',    genre => 'handjob', res => 'low', example => 'ktr.wmw.e22', filter => 0, },
      'yat'                   => {name    => 'YoungAnalTryouts',     qual => 'high',   genre => 'teen', res => 'high', example => 'ktr.yat', filter => 0, },
      'ygf'                   => {name    => 'YoungGirlFriend',      qual => '',       genre => 'teen', res => 'high,low', example => 'inya-ygf.', filter => 0, },
      'ylp'                   => {name    => 'YoungLegalPorn',       qual => 'high',   genre => 'teen', res => 'high', example => 'ktr.ylp', filter => 0, },
      'yoloib'                => {name    => 'YoungLibertines',      qual => '',       genre => 'teen', res => 'low', example => 'inya-yoloib.', filter => 0, },
      'yosexparty'            => {name    => 'YoungSexParty',        qual => 'medium', genre => 'teen', res => 'low', example => 'yosexparty.e01', filter => 0, },
      'yphv'                  => {name    => 'YoungPornHomeVideos',  qual => 'low',    genre => 'teen', res => 'low', example => 'ktr.yphv.09.', filter => 0, },
); # lPrefixSub

   chdir ($aPath) or die ("Error: Could not chdir to directory: $aPath : $!\n");

   foreach $lFileName ( sort glob ("*.*") ) {
      $lNewFileName = $lFileName;

      # Change "EM - something to "TEM - something"

      $lNewFileName =~ s/^EM \- /TEM\-/;
      $lNewFileName =~ s/^TEM\s+-\s+/TEM\-/;

      # Change fd_ to FuckingDungeon
      $lNewFileName =~ s/^fd_/FuckingDungeon-/;
      $lNewFileName =~ s/_fud_/-/;

      foreach $lPrefix ( @lStripPrefixArray ) {
         $lNewFileName =~ s/^$lPrefix\-//g;
         $lNewFileName =~ s/^$lPrefix\.//g;
      }

	  # Change sbyymmdd.mp4
	  if ($lNewFileName =~ m/pd(\d\d)(\d\d)(\d\d)\.mp4/) {
		$lNewFileName = "PublicDisgrace-$1.$2.$3.mp4";
	  }
	  
	  if ($lNewFileName =~ m/hardtied(\d\d)(\d\d)(\d\d)\.mp4/) {
		$lNewFileName = "HardTied-$1.$2.$3.mp4";
	  }
	  
	  
      if ($lNewFileName =~ m/^awinters[a-z]/) {
         $lNewFileName =~ s/^awinters/awinters\-/;
      }
      if ( $lNewFileName =~ m/^mhumiliation[a-z]/) {
         $lNewFileName =~ s/^mhumiliation/mhumiliation\-/;
      }


      # See if the file looks like aaa- and see if we have a translation
      if ($lNewFileName =~ m/^(\w+)([-._])(.*)/ ) {
         my ($lFirst, $lLast) = (lc($1),$3);
         #print "first = $lFirst\n";
         if ( exists $lPrefixSub{$lFirst} ) {
            my $temp = $lPrefixSub{$lFirst}{name} . '-' . $lLast;
            $lNewFileName = $temp;
         }
      }

      # Find "something.09.05.06." and change it to "something-090506-"
      $lNewFileName =~ s/\.(\d\d)\.(\d\d)\.(\d\d)\./-$1.$2.$3./;
      $lNewFileName =~ s/\-(16)(\d\d)(\d\d)\./-$1.$2.$3./;
      $lNewFileName =~ s/\-(17)(\d\d)(\d\d)\./-$1.$2.$3./;

	  # Find 17MMYY and c
	  
	  
      $lNewFileName =~ s/_640x480_h_full//i;

      # Special for Nubiles
      $lNewFileName =~ s/^nubilesa([0..9])/Nubiles-Audri-$1/i;
      $lNewFileName =~ s/^nubilesab([0..9])/Nubiles-AmyBrooke-$1/i;
      $lNewFileName =~ s/^nubilesaj([0..9])/Nubiles-AshleyJane-$1/i;
      $lNewFileName =~ s/^nubilesar([0..9])/Nubiles-AshlynRae-$1/i;
      $lNewFileName =~ s/^nubilesc([0..9])/Nubiles-Carey-$1/i;
			$lNewFileName =~ s/^nubilescj([0..9])/Nubiles-ChloeJames-$1/i;
      $lNewFileName =~ s/^nubilesd([0..9])/Nubiles-Dachuki-$1/i;
      $lNewFileName =~ s/^nubilesgi([0..9])/Nubiles-Galina-$1/i;
      $lNewFileName =~ s/^nubilesh([0..9])/Nubiles-Hanna-$1/i;
      $lNewFileName =~ s/^nubilesk([0..9])/Nubiles-Kaylee-$1/i;
      $lNewFileName =~ s/^nubileskl([0..9])/Nubiles-Kiralanai-$1/i;
      $lNewFileName =~ s/^nubilesld([0..9])/Nubiles-LexiDiamond-$1/i;
      $lNewFileName =~ s/^nubilesma([0..9])/Nubiles-MileyAnne-$1/i;
      $lNewFileName =~ s/^nubilesmm([0..9])/Nubiles-MollyMadison-$1/i;
      $lNewFileName =~ s/^nubilesm([0..9])/Nubiles-Mirjam-$1/i;
      $lNewFileName =~ s/^nubilesn([0..9])/Nubiles-Natisha-$1/i;
      $lNewFileName =~ s/^nubilesss([0..9])/Nubiles-SarahSweets-$1/i;
      $lNewFileName =~ s/^nubilesp([0..9])/Nubiles-Palova-$1/i;
      $lNewFileName =~ s/^nubileskj([0..9])/Nubiles-KatieJordin-$1/i;
      $lNewFileName =~ s/^nubiles([0..9])/Nubiles-$1/i;

      # Special for Only Cuties
      $lNewFileName =~ s/^ocuties/OnlyCuties/;
      #$lNewFileName =~ s/^ocutiesjpc([0..9])/OnlyCuties-$1/i;

      # Subject to change
      $lNewFileName =~ s/^tee[-.]/TeenModels-/i;

      $lNewFileName =~ s/^wildrose[^-]/WildRose-/i;
      $lNewFileName =~ s/^wildrose/WildRose/i;

      $lNewFileName =~ s/^you[.-]/YoungBusty-/i;
      $lNewFileName =~ s/^yb_/YoungBusty-/i;

      $lNewFileName =~ s/^younglib[^-]/YoungLibertines-/i;
      $lNewFileName =~ s/^younglib/YoungLibertines/i;

      $lNewFileName =~ s/^ym[^-]/YoungModels-/i;
      $lNewFileName =~ s/^youngmodels/YoungModels/i;

      # I am seeing MyEighteen-.0905 stuff so fix this here
      $lNewFileName =~ s/-\./-/g;

      # I am seeing 09.06.06VikiSchoolgirSltripTease so fix this
      # I am seeing 090606VikiSchoolgirSltripTease so fix this
      $lNewFileName =~ s/(\d\d\.\d\d\.\d\d)(\w+)/$1-$2/;
      $lNewFileName =~ s/(\d{6})(\w)/$1-$2/;

      # I am seeing: rank-tee-e13teenslutnikifairfuckstogetouttatown
      $lNewFileName =~ s/(e\d\d)(\w+)/$1-$2/;

      $lNewFileName =~ s!.xxx.wmv-thm!!;

      # EXTENSIONS

      $lNewFileName =~ s/\.mpeg$/\.mpg/;

      if ($lNewFileName =~ m/ForcedMale-(\d\d\.\d\d\.\d\d)/) {
         my $lTemp = $lNewFileName;

         # Convert oro-fmn.08.04.05.sadistic.sherry.ball.torture.milks.a.slaveboy.wmv
         # to:     oro-fmn.08.04.05SadisticSherryBallTortureMilksASlaveboyWmv
         $lTemp =~ s/[.-]([a-z])/\u$1/g;
         # This will take "soon.wmv" and make it "SoonWmv"
         $lTemp =~ s/Wmv$/\.wmv/;
         # Now we have: ForcedMale-08.12.17TheSmootheTalker.wmv
         $lTemp =~ s/(\d\d)\.(\d\d)\.(\d\d)/20$1$2$3\-/;

         $lNewFileName = $lTemp;
      }


      if ($lNewFileName =~ m/(Wasteland)[.-](e\d\d)[.-](.*)(\.wmv)/) {

         my $lTemp      = $lNewFileName;
         my $lPrefix    = $1;
         my $lEpisode   = $2;
         my $lBody      = '.' . $3;
         my $lExtension = $4;

         # Convert oro-fmn.08.04.05.sadistic.sherry.ball.torture.milks.a.slaveboy.wmv
         # to:     oro-fmn.08.04.05SadisticSherryBallTortureMilksASlaveboyWmv
         # This will take "soon.wmv" and make it "SoonWmv"

         $lBody =~ s/[.-]([a-z])/\u$1/g;

         # Put back "wmv" instead of Wmv

         $lNewFileName = "Wasteland-$lEpisode-$lBody" . $lExtension;
      }

      #  Look for .XXX.720p. and other things at the end
      my $lTemp = index ($lNewFileName, '.XXX.');
      if ( $lTemp > -1 ) {
         my $lExt = substr($lNewFileName, rindex($lNewFileName, '.'), length($lNewFileName));
         $lNewFileName = substr($lNewFileName, 0, $lTemp) . $lExt;
      }

      # Make it happen if we see a difference

      if ($lNewFileName ne $lFileName ) {
         print sprintf ("%-30s : %-30s\n", $lFileName, $lNewFileName);
         #next unless $lNewFileName =~ m/^TEM/;
         rename ($lFileName, $lNewFileName) or die ("Error: Could not rename ($lFileName, $lNewFileName) : $!\n");
      }

   }


}  # S_FixFileNames

#--------------------------------------------------------------------------
# Routine to remove the "xHamster.com" from the end of file names and remove
# the "Amateur-" and "Pro-" prefix if present
#--------------------------------------------------------------------------
sub S_FixHamster {
	my ($aPath) = @_;
	my ($lFileName, $lNewFileName, $lPos);
	my (@lFileArray);
	
	chdir ($aPath) or die ("Error: Could not chdir to directory: $aPath : $!\n");
	
	my @lSubStrings = (
		' BDSM Porn Video 90',
		' Free Porn 28',
		', Free HD Porn 13',
		', Free BDSM Porn Video 7d ',
	);
	
	
	print "Processing: $aPath ..\n";
	push (@lFileArray, sort glob ("*.flv"));
	push (@lFileArray, sort glob ("*.mp4"));
	
	foreach $lFileName (sort @lFileArray ) {
		$lNewFileName = $lFileName;
		
		# We often see this type of file name: latexjane-with Boots, Free Femdom Porn Video 22 xHamster
		# Look for ", Free" and "xHamster"
		if ( index ($lNewFileName, 'xHamster') > -1 ) {
			$lPos = index ($lNewFileName, ', Free');
			$lPos = index ($lNewFileName, ' Free') if ( $lPos == -1 );
			if ( $lPos > -1 ) {
				my $lExt;
				$lNewFileName =~ m/(\.\w+)$/;
				$lExt = $1;
				$lNewFileName = substr($lNewFileName, 0, $lPos) . $lExt;
				print "Old:New = $lFileName : $lNewFileName\n";
			}
			
		}
		
		# This is to fix problems left by previous runs
		if (1) {
			$lNewFileName =~ s/ Gay Porn \w\w\./\./i;
			$lNewFileName =~ s/\, Porn \w\w\./\./i;
			$lNewFileName =~ s/ Free BDSM \& Bondage Porn Video \w\w\./\./i;
			$lNewFileName =~ s/ Free Mistress & Amateur Porn Video \w\w\./\./i;
			$lNewFileName =~ s/\,\.flv/\.flv/;
			$lNewFileName =~ s/ \.m/\.m/g;
			$lNewFileName =~ s/ \- Pornhub\.com//;
		}
	
		$lNewFileName =~ s/\, HD Porn \w\w xHamster//i;
		$lNewFileName =~ s/\, Porn \w\w xHamster//i;
		$lNewFileName =~ s/ HD Porn Video \w\w \- xHamster//i;
		$lNewFileName =~ s/, HD Porn Video \w\w \- xHamster//i;
		$lNewFileName =~ s/ Porn Video \w\w \- xHamster//i;
		$lNewFileName =~ s/, Free .*\.flv/.flv/i;
		$lNewFileName =~ s/ HD Porn .*\.flv/.flv/i;
		$lNewFileName =~ s/, Free Porn .*\.flv/.flv/i;
		$lNewFileName =~ s/ Free Porn .*\.flv/.flv/i;
		$lNewFileName =~ s/ Porn Video \w\w\.flv/.flv/i;
		$lNewFileName =~ s/ Porn \w\w\.flv/.flv/i;
		#$lNewFileName =~ s/\, Free \w+ \w+ \w+ \w+ xHamster//i;
		#$lNewFileName =~ s/ Free \w+ \w+ \w+ \w+ xHamster//i;
		#$lNewFileName =~ s/ Free \w+ \w+ \w+ \w+//i;
		#$lNewFileName =~ s/ Free \w+ \w+ \w+//i;
		#$lNewFileName =~ s/ \- xHamster\.com//i;
		#$lNewFileName =~ s/ \- xHamster//i;
		#$lNewFileName =~ s/ xHamster//i;
		#$lNewFileName =~ s/ Free \w+ Porn Video \w+ \- xHamster//i;
		$lNewFileName =~ s/ Redtube\, [^\.]+\././i;
		$lNewFileName =~ s/ Redtube [^\.]+\././i;
		if ( $lFileName =~ m/HD Porn Video/ ) {
			$lNewFileName =~ s/ \w+ \& \w+ HD Porn Video \w+\././i;
		}
		#$lNewFileName =~ s/ Free Porn \w+\././i;
		
		$lNewFileName =~ s/^Amat\-//i;
		$lNewFileName =~ s/^Amateur\-//i;
		$lNewFileName =~ s/^Pro\-//i;
		$lNewFileName =~ s/^\s+//i;
		
		$lNewFileName =~ s/ \- Video \- Femdom\-Fetish\-Tube\.com\.+/\./i;
		
		$lNewFileName =~ s/ \- MOTHERLESS\.COM//;
		
		
		#$lNewFileName =~ s/\, Free HD Porn \d+//;
		#$lNewFileName =~ s/, Free BDSM Porn Video \w\w //;
		#$lNewFileName =~ s/, Free Amateur Porn \w\w//i;
		#$lNewFileName =~ s/ BDSM Porn Video \d+//;
		#$lNewFileName =~ s/  Free Porn \d+//;
		#$lNewFileName =~ s/ Free Teen Porn Video \d\d//i;
		
		
		
		# Handle Spanking Tube videos
		$lNewFileName =~ s/Spanking Tube Your source for free Spanking and Bondage Videos //i;
		$lNewFileName =~ s/ \- SpankingTube\.com//i;
		$lNewFileName =~ s/ \- \- Spanking Tube//i;
		# Handle XVIDEOS with new downloader: [544x408] Silent Night 2 - XVIDEOS.COM.mp4
		$lNewFileName =~ s/ \- XVIDEOS\.COM//i;
		$lNewFileName =~ s/^\[\d+x\d+\] //i;
		
		if ($lNewFileName ne $lFileName) {
			print "$lNewFileName replaces $lFileName\n";
			rename ($lFileName, $lNewFileName) or die ("Rename error: $lFileName - $lNewFileName : $!\n");
		}
	}
	
}	# S_FixHamster

#---------------------------------------------------------------------------
#
#
# Inputs:   aBatFile - full path to batch file to create
#           aSrcPath - Path like: D:\\1\\AVI used to find directories to copy
#           aDestPath   - Path string like: "Z:\\AVI" - where to copy directories to
#---------------------------------------------------------------------------
sub S_TransferBat {
   my ($aBatFile, $aSrcPath, $aDestPath) = @_;
   my ($lDir, $lCmd);
   my $lCmdBuffer = "";

   print "S_TransferBat starting\n";
   chdir ($aSrcPath) or die ("Error: could not chdir to source dir: $aSrcPath : $!\n");

   foreach  $lDir ( sort glob ("AVI-DVD-*") ) {
      # See if this directory exists on the remote side
      my $lDestDir = $lDir;

      if ( -e $aDestPath . "\\$lDestDir" ) {
         next;
      }

      # Remove the -done and check again if it exists on the dest dir
      $lDestDir =~ s/-done//;
      if ( -e $aDestPath . "\\$lDestDir" ) {
         next;
      }

      $lCmd = "xcopy $lDir $aDestPath\\$lDir /E /I";
      print "$lCmd\n";

      $lCmdBuffer .= "$lCmd\n";

   }

   open (BAT_FILE, ">$aBatFile") or die ("Error: could not open file for output: $aBatFile : $!\n");
   print BAT_FILE $lCmdBuffer;
   close (BAT_FILE) or die ("Error: Could not close output file: $aBatFile : $!\n");

   print "Xcopy batch file created: $aBatFile\n";

}  # S_TransferBat

#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
sub S_PrefixFiles {
	my (%args) = @_;
	my ($lFile, @lFileArray, $lCmd);
	chdir ($args{path}) or die ("Error: Could not chdir to path: $args{path} : $!\n");
	
	foreach $lFile (sort glob ($args{pattern}) ) {
		$lFile =~ s/full/Full/;
		$lFile =~ s/elise/Elise/;
		$lFile =~ s/chelsa/Chelsa/;
		$lFile =~ s/celia/Celia/;
		$lFile =~ s/bever/Bever/;
		$lFile =~ s/alica/Alica/;
		$lFile =~ s/alex/Alex/;
		$lFile =~ s/hard/Hard/;
		$lFile =~ s/lil/Lil/;
		$lFile =~ s/pant/Pant/;
		$lFile =~ s/down/Down/;
		$lFile =~ s/pixie/Pixie/;
		$lFile =~ s/kord/Kord/;
		$lFile =~ s/strict/Strict/;
		$lFile =~ s/tutor/Tutor/;
		
		$lCmd = "rename \"$lFile\"\t\t\t\t\"$args{prefix}-$lFile\"";
		push (@lFileArray, $lCmd);
		#print "$lCmd\n";
	}

	open (BAT_FILE, ">fix.bat") or die ("Error: Could not open file for output: fix.bat : $!\n");
	foreach $lCmd ( @lFileArray ) {
		print BAT_FILE "$lCmd\n";
	}
	close (BAT_FILE);
	
}	# S_PrefixFiles

#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
sub S_ValidateAVIBD {
	my ($aPath) = @_;
	my ($lFile, $lFileCount);
	
	$lFileCount = 0;
	foreach $lFile ( sort glob ("$aPath\\*.*") ) {
		$lFileCount++;
	}
	
	return (1) if ( $lFileCount > 3 );
	return (0);
}	# S_ValidateAVIBD

#---------------------------------------------------------------------------
# Routine:		S_ToNDrive
# Description:	This routine will create a .bat file that contains rows like:
#
#				mkdir N:\1\AVI-BD-458
#				...
#				move /Y D:\1\AVI-BD-485\*.*    N:\1\AVI-BD-485
#---------------------------------------------------------------------------
sub S_ToNDrive {
	my (%args) = @_;
	my ($lFile, @lFileArray);
	my ($lLocalPath, $lRemotePath);
	
	chdir ($args{path}) or die ("Error: could not chdir to $args{path} : $!\n");
	
	foreach $lFile ( sort glob ("AVI-BD*") ) {
		next if ( ! -d $lFile );
		if ( &S_ValidateAVIBD( $lFile ) ) {
			print "To N: $lFile\n";
			push (@lFileArray, $lFile);
		}
	}

	open (BAT_FILE, ">$args{batch_file}") or die ("Error: Could not open file for output: $args{batch_file} : $!\n");
	
	foreach $lFile ( @lFileArray ) {
		$lLocalPath  = $args{path} . "\\$lFile";
		$lRemotePath = $args{remote_path} . $lFile;
		if ( ! -e $lRemotePath ) {
			print BAT_FILE "mkdir $lRemotePath\n";
		}	
	}
	print BAT_FILE "\n\n";
	
	foreach $lFile ( @lFileArray ) {
		$lLocalPath  = $args{path} . "\\$lFile";
		$lRemotePath = $args{remote_path} . $lFile;
		print BAT_FILE "move /Y $lLocalPath\\*.*  $lRemotePath\n";
	}

	
	close (BAT_FILE) or die ("Error: Could not close output file: $args{batch_file} : $!\n");
	
	print "Output File created: $args{batch_file}\n";
	
}	# S_ToNDrive

#---------------------------------------------------------------------------
# Routine:      &Sec2HMS
# Description:  This routine will take a number of seconds and convert
#               it to a string of the form: hh:mm:ss
#
# Input:        aSec - Number of seconds as an int
#
# Output:       String of the form "hh:mm:ss"
#---------------------------------------------------------------------------
sub Sec2HMS {
    local ($aSec) = @_;
    local ($lHour, $lMin, $lSec) = (0,0,0);
    local ($lTimeStr);

    $lSec = $aSec;

    # Extract the hours
    $lHour = int ($lSec/3600);
    if ( $lHour > 0 ) {
        $lSec = $aSec - ($lHour * 3600);
    }

    $lMin = int ($lSec/60);
    if ( $lMin > 0 ) {
        $lSec = $lSec - ($lMin * 60);
    }

    $lTimeStr = "";
    if ( $lHour > 0 ) {
        $lTimeStr = sprintf ("%02s:%02s:%02s", $lHour, $lMin, $lSec);
    } elsif ($lMin > 0) {
        $lTimeStr = sprintf ("%02s:%02s", $lMin, $lSec);
    } else {
        $lTimeStr = sprintf ("%02s", $lSec);
    }

    return ($lTimeStr);

}   # Sec2HMS


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
sub S_AudiobookList {
   my ($aDir) = @_;
   chdir ($aDir) or die ("Error: Could not cd to $aDir\n");
   my @lFileArray = sort glob ("*.mp3");
   open (OUT_FILE, ">d:\\temp\\abook.csv") or die ("Error: could not open output file: $!\n");
   foreach my $lFile ( @lFileArray ) {
      my $lSize = -s $lFile;
      print OUT_FILE "$lFile,$lSize\n";
   }

   close (OUT_FILE);
}  # S_AudiobookList

#---------------------------------------------------------------------------
# Routine:      S_PrintMenu
# Description:  This routine will print the main menu of choices.
#
# Returns:      <none>
#---------------------------------------------------------------------------
sub S_PrintMenu
{
    print "--------------------------------------------\n";
    print "        CD Catalog - Main Menu\n";
    print "--------------------------------------------\n";
    print "Please choose an option:\n";
    print "\t0  - Exit\n";
    print "\t1  - Look for Duplicates: Working\n";
    print "\t2  - \n";
    print "\t3  - Build new RECENT File\n";
    print "\t4  - Look for Duplicates: Download\n";
    print "\t5  - Zero-Pad CRC files\n";
    print "\t6  - Challenge Archive\n";
    print "\t7  - Find Series (under development)\n";
    print "\t8  - Create CD catalog\n";
    print "\t9  - Generate Master Archive\n";
    print "\t10 - Create local .CRC files\n";
    print "\t11 - Fix file names in temp\n";
    print "\t12 - Make to_z_drive.bat file\n";
    print "\t13 - Make Audiobook name,size file\n";
    print "\t14 - Fix BD File Names\n";
    print "\t15 - to_n_drive.bat\n";
    print "\t\tChoice: ";

}   #S_PrintMenu

#---------------------------------------------------------------------------
# Routine:      S_GetChoice
# Description:  This routine will print a menu of choices for the user,
#               then pause for some input. It will return a value of 0-9
#               depending upon the users selection.
#---------------------------------------------------------------------------
sub S_GetChoice
{
    local ($lFinished) = 0;
    local ($lChoice) = -1;

    while ( $lFinished == 0 ) {
        &S_PrintMenu();
        $lChoice = <STDIN>;
        chomp ($lChoice);


        if ( $lChoice > -1 && $lChoice < 25 ) {
            print "Found Choice ($lChoice)\n";
            $lFinished = 1;
        }
    }

    return ($lChoice);

}   #S_GetChoice

#---------------------------------------------------------------------------
# Main
#---------------------------------------------------------------------------
sub main {
    local ($lChoice) = -1;
    local ($lFinished) = 0;

    # print "Hello World\n";
    # &FindSeries ("c:\\temp\\1\\dl");

    local ($lTemp) = $ARGV[0];
    if ( $lTemp != "" ) {
        $lChoice = $lTemp;
    }

    while ( $lFinished != 1 ) {

        if ( $lChoice == -1 ) {
            $lChoice = &S_GetChoice();
            print "main: got choice ($lChoice)\n";
        }

        if ( $lChoice == "0" ) {
            $lFinished = 1;
        } elsif ($lChoice == "1") {
            &FilterWorkingFiles ($gWORKING_DIR);
            $lFinished = 1;
        } elsif ($lChoice == "2") {
            $lFinished = 1;
        } elsif ($lChoice == "3") {
            &S_GenerateRecentFile ($gRECENT_FILE);
            $lFinished = 1;
        } elsif ($lChoice == "4") {
            &FilterWorkingFiles ($gDOWNLOAD_DIR);
            $lFinished = 1;
        } elsif ($lChoice == "5") {
            &S_ZeroPadCRCFiles ("D:\\crc");
            $lFinished = 1;
        } elsif ($lChoice == "6") {
            &S_ChallengeArchive();
            $lFinished = 1;
        } elsif ($lChoice == "7") {
            &FindSeries ($gDOWNLOAD_DIR);
            $lFinished = 1;
        } elsif ($lChoice == "8") {
            &CatalogCDRom ($gCD_DRIVE_LETTER);
            $lFinished = 1;
        } elsif ($lChoice == "9") {
            &S_GenerateMasterArchive();
            $lFinished = 1;
        } elsif ($lChoice == "10") {
            &S_CreateLocalCRCFiles("d:\\1\\");
            $lFinished = 1;
        } elsif ($lChoice == "11") {
            &S_FixFileNames ("d:\\temp\\1");
            #&S_FixHamster("d:\\temp\\1\\1xHamster");
            &S_FixHamster("d:\\upgrades");
            &S_FixHamster("d:\\upgrades\\1span");
            $lFinished = 1;
        } elsif ($lChoice == "12") {
            &S_TransferBat ("d:\\1\\to_z_drive.bat", "d:\\1", "Z:\\");
            $lFinished = 1;
        } elsif ($lChoice == "13") {
            &S_AudiobookList ("d:\\Temp\\agent\\alt.binaries.mp3.audiobooks");
            $lFinished = 1;
        } elsif ($lChoice == "14") {
            &S_FixBDFilenames ("d:\\Temp\\agent\\abm.bdsm");
            $lFinished = 1;
        } elsif ($lChoice == "15") {
        	&S_ToNDrive(path => "d:\\1", batch_file => "to_n_drive2.bat", remote_path => "N:\\1\\");
            $lFinished = 1;
        }
    }


    local ($lRunTime) = time - $^T;
    print "Run Time: " . &Sec2HMS ($lRunTime) . "\n";

}       # Main

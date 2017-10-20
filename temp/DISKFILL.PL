# File: DiskFIll.pl

use File::Basename;

$| = 1; # Print Immediatly

##################
# Global Section #
##################

$gCD_DRIVE_LETTER   = "D";
$gCD_DRIVE_LETTER2  = "R";
$gCRC_DIR           = "D:\\CRC";                # Where the CRC files live
$gWORKING_DIR       = "D:\\temp\\1";            # Where to read new files from
$gDOWNLOAD_DIR      = "D:\\temp\\1\\dl";        # Where the bulk download files are
$gARCHIVE_DIR       = "D:\\temp\\1\\archive";   # Where to move previously-seen files
$gSPAM_DIR          = "D:\\temp\\1\\spam";      # Where to move previously-seen files
$gNEW_SPAM_DIR      = "D:\\temp\\1\\newspam";   # Where to read new spam files from
$gTO_SORT_DIR       = "D:\\temp\\1\\tosort";    # Where files await sorting to the prep directory
$gCD_PREP_DIR       = "D:\\temp\\p";            # Where files await burning
$gAVI_PREP_DIR      = "D:\\1\\AVI";             # Where files await burning

# This is the base-name for CRC Catalog files
$gCATALOG_BASE      = "BACKUP";     # becomes "BACKUPnnn.crc"


$gVERBOSE = 0;
$gDEBUG   = 0;

$gIS_WIN_NT = 1;

&main();
exit (0);


#-----------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------
############################################################################
sub S_RenameToons       #10/12/2008 1:43PM
############################################################################
{
    my ($lDir, $lPrefix);
    my (@lArray, $lFile);
    my ($lMaxLen, $lNewFile);
    my $lRow;

    $lDir = "D:\\temp\\1\\agent\\alt.binaries.pictures.erotica.cartoons";
    $lDir = "D:\\temp\\1\\agent\\alt.binaries.erotica.cartoons";

    chdir ($lDir) or die ("Error: Could not chdir to: $lDir : $!\n");

    #@lArray = sort glob ("RD-t*.jpg");
    @lArray = sort glob ("*.jpg");

    open (OUT_FILE, ">fix.bat") or die ("Error: could not open fix.bat : $!\n");
    foreach $lFile (@lArray) {
        $lFile = '"' . $lFile . '"';
        $lNewFile = $lFile;

        $lNewFile =~ s/RD\-t/RD\-T/;
        $lNewFile =~ s/the/The/;
        #$lNewFile =~ s/and/And/g;
        $lNewFile =~ s/big/Big/g;
        $lNewFile =~ s/blow/Blow/g;
        $lNewFile =~ s/about/About/g;
        $lNewFile =~ s/penetration/Penetration/g;
        $lNewFile =~ s/couple/Couple/g;
        $lNewFile =~ s/school/School/g;
        $lNewFile =~ s/camp/Camp/g;
        $lNewFile =~ s/black/Black/g;
        $lNewFile =~ s/condom/Condom/g;
        $lNewFile =~ s/relation/Relation/g;
        $lNewFile =~ s/valley/Valley/g;
        $lNewFile =~ s/panties/Panties/g;
        $lNewFile =~ s/little/Little/g;
        $lNewFile =~ s/house/House/g;
        $lNewFile =~ s/good/Good/g;
        $lNewFile =~ s/party/Party/g;
        $lNewFile =~ s/horny/Horny/g;
        $lNewFile =~ s/housewives/Housewives/g;
        $lNewFile =~ s/beach/Beach/g;
        $lNewFile =~ s/impales/Impales/g;
        $lNewFile =~ s/kimmy/Kimmy/g;
        $lNewFile =~ s/kevin/Kevin/g;
        $lNewFile =~ s/kell/Kell/g;
        $lNewFile =~ s/emmy/Emmy/g;
        $lNewFile =~ s/classmate/Classmate/gi;
        $lNewFile =~ s/princess/Princess/g;
        $lNewFile =~ s/latchkey/LatchKey/g;
        $lNewFile =~ s/comforts/Comforts/g;
        $lNewFile =~ s/adventure/Adventure/g;
        $lNewFile =~ s/marriage/Marriage/g;
        $lNewFile =~ s/pool/Pool/g;
        $lNewFile =~ s/park/Park/g;
        $lNewFile =~ s/trash/Trash/g;
        $lNewFile =~ s/toyplay/ToyPlay/g;
        $lNewFile =~ s/careof/CareOf/g;
        $lNewFile =~ s/lounge/Lounge/g;


        $lNewFile =~ s/girl/Girl/g;
        $lNewFile =~ s/gal/Gal/g;
        $lNewFile =~ s/grow/Grow/g;
        $lNewFile =~ s/friends/Friends/g;
        $lNewFile =~ s/dad/Dad/g;
        $lNewFile =~ s/kid/Kid/g;
        $lNewFile =~ s/fun/Fun/g;
        $lNewFile =~ s/niece/Niece/g;
        $lNewFile =~ s/nephew/Nephew/g;
        $lNewFile =~ s/uncle/Uncle/g;
        $lNewFile =~ s/student/Student/g;
        $lNewFile =~ s/teacher/Teacher/g;
        $lNewFile =~ s/parent/Parent/g;
        $lNewFile =~ s/friend/Friend/g;
        $lNewFile =~ s/teen/Teen/g;
        $lNewFile =~ s/daughter/Daughter/g;
        $lNewFile =~ s/sister/Sister/g;
        $lNewFile =~ s/son/Son/g;
        $lNewFile =~ s/boy/Boy/g;
        $lNewFile =~ s/child/Child/g;
        $lNewFile =~ s/baby/Baby/g;
        $lNewFile =~ s/dad/Dad/g;
        $lNewFile =~ s/father/Father/gi;
        $lNewFile =~ s/husband/Husband/gi;
        $lNewFile =~ s/grandpa/Grandpa/gi;
        $lNewFile =~ s/wife/Wife/g;
        $lNewFile =~ s/mom/Mom/g;
        $lNewFile =~ s/youth/Youth/g;
        $lNewFile =~ s/teacher/Teacher/g;
        $lNewFile =~ s/doctor/Doctor/g;
        $lNewFile =~ s/dave/Dave/g;
        $lNewFile =~ s/orgy/Orgy/g;
        $lNewFile =~ s/view/View/g;
        $lNewFile =~ s/problem/Problem/g;
        $lNewFile =~ s/knock/Knock/g;
        $lNewFile =~ s/dick/Dick/g;
        $lNewFile =~ s/boobs/Boobs/g;
        $lNewFile =~ s/tits/Tits/g;
        $lNewFile =~ s/titt/Titt/g;
        $lNewFile =~ s/cock/Cock/g;
        $lNewFile =~ s/penis/Penis/g;
        $lNewFile =~ s/pussy/Pussy/g;
        $lNewFile =~ s/gangbang/GangBang/gi;
        $lNewFile =~ s/stripper/Stripper/g;
        $lNewFile =~ s/slut/Slut/g;
        $lNewFile =~ s/sex/Sex/g;
        $lNewFile =~ s/fuck/Fuck/g;
        $lNewFile =~ s/cum/Cum/g;
        $lNewFile =~ s/love/Love/g;
        $lNewFile =~ s/\!//g;
        $lNewFile =~ s/\,//g;
        $lNewFile =~ s/with/With/g;

        # Find spaces "bowling alley" and change to Alley

        $lNewFile =~ s/\s([a-z])/ \u$1/g;

        $lNewFile =~ s/\"([a-z])/\"\u$1/g;

        $lNewFile =~ s/\s//g;
        $lNewFile =~ s/^\"/\"RD-/;

        $lNewFile =~ s/\((\d)\)/\-$1/g;

        print "$lFile - $lNewFile\n";

        print OUT_FILE sprintf ("rename %-40s    %s\n", $lFile, $lNewFile);


    }

    close (OUT_FILE);


}   # S_RenameToons
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
        # lRow is a full-path name: "D:\temp\1\xxx.yyy"
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
# Description:  This routine will take a directory string ("D:\temp\2") and
#               get the CRC values for every file in the directory. It
#               returns a Hash like this:
#                   $lHash{"command.com"} = HHHHhhhh
#                   $lHash{"system.com"}  = HHHHhhhh
#               The index is the file name, the HHHhhh is the 32 bit CRC
#
# Input:        aDir - Directory string "D:\temp\new"
#
# Returns:      %lHash - Hash array of file names and CRC32 values
#-----------------------------------------------------------------------------------
sub S_GetCRC32OfFiles {
    local ($aDir) = @_;
    local (%lHash) = ();
    local ($lOutputFile) = "\\crc.out";
    local ($lFileName, $lCRC32, $lRow);

    local ($lCmd) = "crc32.exe $aDir\\*.* > $lOutputFile";
    #print "Command: ($lCmd)\n";
    system ($lCmd);

    open (CRCFILE, "$lOutputFile") || die ("Error: Cannot open CRC file ($lOutputFile) for input\n");
    while ( <CRCFILE> ) {
        $lRow = $_;                 # "D:\temp\1\fubar.gif    CRC32(0xhhhhhhhh)"
        # print "$lRow\n";
        $lRow =~ m/^(.+) /;
        $lFileName = $1;            # "D:\temp\1\dl\fubar.gif"
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
    if ( substr ($lPath, 1,1) eq ":" ) {
        $lPath = substr ($lDir, 2);     # Grab everything past the colen
    }

    # Step 1: Use the external CRC program to get the CRC values from all
    # the files in our directory. Store these values in a hash using the
    # short name as the key

    local (%lCRCHash) = &S_GetCRC32OfFiles ($aDir);

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
#               aStarting Path - Where to start searching: "E:\" or "D:\temp\p"
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
# Routine:      S_GetFileType
# Description:  This routine will take a file name and try to determine
#               it's type from the file extension.
#
# Returns:
#               UNK - default return
#               ASF - for .asf/.mov files
#               AVI - for .avi file
#               JPG - for .jpg/.jpeg/.gif
#               MPG - for .mpg and mpeg files
#               RAM - for .ram/.rm
#               WMV - for .wmv files
#-----------------------------------------------------------------------------------
sub S_GetFileType {
    local ($aFileName) = @_;
    local ($lExt);
    local ($lType) = "UNK";


    my ($name, $path, $suffix) = fileparse ($aFileName, '\.[^\.]*');
    $suffix = uc(substr ($suffix, 1));  # remove period and upper case


    if ($suffix =~ m/ASF/) {
        $lType = "ASF";
    } elsif ($suffix =~ m/AVI/) {
        $lType = "AVI";
    } elsif ($suffix =~ m/JPG|JPEG|GIF/) {
        $lType = "JPG";
    } elsif ($suffix =~ m/MPG|MPEG/) {
        $lType = "MPG";
    } elsif ($suffix =~ m/RM|RAM/) {
        $lType = "RAM";
    } elsif ($suffix =~ m/WMV/) {
        $lType = "WMV";
    }


    # print "$aFileName - $suffix - $lType\n";


    return ($lType);

}   # S_GetFileType

#-----------------------------------------------------------------------------------
# Routine:      S_ReportAVI
# Description:  This routine will scan D:\1\AVI and report on how many
#               files exist, size and a break-down by extension type
#
# Input:        aDir - Full path name to the AVI directory
#
#-----------------------------------------------------------------------------------
sub S_ReportAVI {
    local ($aDir) = @_;
    local (@lFileArray) = ();
    local ($lCount);
    local ($lTotalSize) = 0;
    local ($lGigSize, $lMegSize);
    local ($lRow, $lFileName, $lFileSize, $lFileType);
    local ($lMsg, $i, $lExtension);

    local (%lSizeByType) = ();

    # This returns an array of "File Name | File Size"
    @lFileArray = &GetFileNameSize ($aDir);

    $lCount = $#lFileArray;

    print "$aDir contains ($lCount) Files\n";

    foreach $lRow (@lFileArray) {

        ($lFileName, $lFileSize) = split (/\|/, $lRow);

        $lTotalSize += $lFileSize;
    }

    # Calculate the size in Megs and Gigs

    $lMegSize = $lTotalSize / (1024 * 1000);
    $lGigSize = $lTotalSize / (1024 * 1000 * 1000);

    # Create a good string

    if ($lGigSize > 2.0) {
        $lMsg = sprintf ("\tTotal Size = %2.3f Gig\n", $lGigSize);
    } elsif ($lMegSize > 2.0) {
        $lMsg = sprintf ("\tTotal Size = %2.2f Megs\n", $lMegSize);
    }

    print $lMsg;

    # Change the array.
    # The array currently looks like rows of : <file names> | <file size>
    # We now want: <File Type> | <file size> | <file name>

    for ($i = 0; $i < $lCount; $i++) {

        ($lFileName, $lFileSize) = split (/\|/, $lFileArray[$i]);

        # Examine the extension and decide what type of file it is
        $lFileType = &S_GetFileType($lFileName);

        # Add this file size to our list for this type
        $lSizeByType{$lFileType} += $lFileSize;

        # Pad the file size with zeros
        $lFileSize = sprintf ("%010d", $lFileSize);

        $lFileArray[$i] = "$lFileType|$lFileSize|$lFileName";
        # print "$lFileArray[$i]\n";
    }

    # Print out the report by file type

    foreach $lFileType (sort(keys(%lSizeByType))) {
        $lFileSize = $lSizeByType{$lFileType};
        $lMsg = sprintf ("$lFileType - %7.2f Megs", $lFileSize/(1024 * 1000));
        print "\t$lMsg \n";
    }


}   # S_ReportAVI


#-----------------------------------------------------------------------------------
# Routine:      S_ReportThemes
# Description:  This routine will print a report of the file sizes under -
#               the /1/avi directory
#-----------------------------------------------------------------------------------
sub S_ReportThemes
{
    my (@lDirArray, $lDir, @lFileArray, $lObj, $lFileName, $lFileSize, $lTotal);
    my ($lGigSize, $lMegSize, $lMsg);

    @lDirArray = qw (D:\\1\\avi\\avi D:\\1\\avi\\fist D:\\1\\avi\\sp D:\\1\\avi\\teen D:\\1\\avi\\wet D:\\temp\\1\\mm D:\\temp\\1 D:\\temp\\1\\agent\\alt.binaries.e-book);

    foreach $lDir ( sort @lDirArray ) {

        # This returns an array of "File Name | File Size"
        @lFileArray = &GetFileNameSize ($lDir);
        $lTotal = 0;
        foreach $lObj (@lFileArray) {
            $lFileSize = 0;
            ($lFileName, $lFileSize) = split (/\|/, $lObj);
            #Round the file size up to 256 bytes
            $lFileSize = int ($lFileSize / 1024) + 1;
            $lFileSize = $lFileSize * 1024;

            $lTotal += $lFileSize;
        }

        # Calculate the size in Megs and Gigs

        $lMegSize = $lTotal / (1024 * 1000);
        $lGigSize = $lTotal / (1024 * 1000 * 1000);

        # Create a good string

        if ($lGigSize > 2.0) {
            $lMsg = sprintf ("\tTotal Size = %2.2f Gig\n", $lGigSize);
        } elsif ($lMegSize > 2.0) {
            $lMsg = sprintf ("\tTotal Size = %2.2f Megs\n", $lMegSize);
        }

        print "\t$lDir :\t";
        print $lMsg;

    }


}   #S_ReportThemes

#-----------------------------------------------------------------------------------
# Routine:      S_ReportCondensed
# Description:  This routine will scan D:\1\AVI and report on how many
#               files exist, size and a break-down by extension type.
#               Then it finds series of files.
#
# Input:        aDir - Full path name to the AVI directory
#
#-----------------------------------------------------------------------------------
sub S_ReportCondensed {
    local ($aDir) = @_;
    local (@lFileArray) = ();
    local ($lCount);
    local ($lTotalSize) = 0;
    local ($lGigSize, $lMegSize);
    local ($lRow, $lFileName, $lFileSize, $lFileType);
    local ($lFileType2, $lFileName2, $lFileSize2);
    local ($lMsg, $i, $j, $lExtension);

    local (%lSizeByType) = ();

    # This returns an array of "File Name | File Size"
    @lFileArray = &GetFileNameSize ($aDir);

    $lCount = $#lFileArray;

    print "$aDir contains ($lCount) Files\n";

    foreach $lRow (@lFileArray) {

        ($lFileName, $lFileSize) = split (/\|/, $lRow);

        $lTotalSize += $lFileSize;
    }

    # Calculate the size in Megs and Gigs

    $lMegSize = $lTotalSize / (1024 * 1000);
    $lGigSize = $lTotalSize / (1024 * 1000 * 1000);

    # Create a good string

    if ($lGigSize > 2.0) {
        $lMsg = sprintf ("\tTotal Size = %2.3f Gig\n", $lGigSize);
    } elsif ($lMegSize > 2.0) {
        $lMsg = sprintf ("\tTotal Size = %2.2f Megs\n", $lMegSize);
    }

    print $lMsg;

    # Change the array.
    # The array currently looks like rows of : <file names> | <file size>
    # We now want: <File Type> | <file name> | <file size>

    for ($i = 0; $i < $lCount; $i++) {

        ($lFileName, $lFileSize) = split (/\|/, $lFileArray[$i]);

        # Examine the extension and decide what type of file it is
        $lFileType = &S_GetFileType($lFileName);

        # Add this file size to our list for this type
        $lSizeByType{$lFileType} += $lFileSize;

        # Pad the file size with zeros
        $lFileSize = sprintf ("%010d", $lFileSize);

        $lFileArray[$i] = "$lFileType|$lFileName|$lFileSize";
        # print "$lFileArray[$i]\n";
    }

    # Print out the report by file type

    #foreach $lFileType (sort(keys(%lSizeByType))) {
    #    $lFileSize = $lSizeByType{$lFileType};
    #    $lMsg = sprintf ("$lFileType - %-5.2f Megs", $lFileSize/(1024 * 1000));
    #    print "\t$lMsg \n";
    #}


    # Try a sort

    @lFileArray = sort {uc($a) cmp uc($b)} @lFileArray;

    local (@lCArray) = ();

    $i=0;
    $j=0;

    for ($i = 0; $i < $#lFileArray; $i++) {
        #print "$lRow\n";

        &S_FileWildcard($lFileArray[$i], $lFileArray[$j]);

        ($lFileType, $lFileName, $lFileSize) = split (/\|/, $lFileArray[$i]);
        ($lFileType2, $lFileName2, $lFileSize2) = split (/\|/, $lFileArray[$i+1]);
        print "$lFileName\n";

        $i++;
    }





}   # S_ReportCondensed


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
    local ($lOutFile) = "D:\\vol.out";

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
# Routine:		S_FindSeries4
#-----------------------------------------------------------------------------------
sub S_FindSeries4 {
	my ($aPath) = @_;
	my (@lFileList, %lHash, $lFileName, $lFileSub, $lPrevious);
	my ($lKey);
	my %lKeyHash = ();


	chdir ($aPath);
    @lFileList = sort (glob ("*.*"));
	$lPrevious = "";
	foreach $lFileName (@lFileList) {


		$lKey = $lFileName;
		$lKey =~ s/\d//g;			# Remove numbers

		if (exists $lKeyHash{$lKey}) {
			print "\t$lFileName\n";
			next;
		} else {
			# Found a new starting file
			print "$lFileName - $lKey\n";

			$lKeyHash{$lKey}++;

		}
	}




}	# S_FindSeries4

#-----------------------------------------------------------------------------------
# Routine:		CharsInCommon
# Description:	This routine will take 2 file names and return the substring
#				from the begining of the names that they have in common
#-----------------------------------------------------------------------------------
sub CharsInCommon {
	my ($aFile1, $aFile2) = @_;
	my ($lCommon, $i);

	$i = 1;
	while (substr ($aFile1, 0, $i) eq substr ($aFile2, 0, $i)) {
		$i++;
	}
	$i--;

	# We could have "Tom-InTheNight-CD02-0"
	return (substr($aFile1, 0, $i))
}	# CharsInCommon

sub FindSeries3 {
    my ($aPath) = @_;
    my (%lFileHash) = ();
    my (@lFileList, $lFileName, $lLCFile, $i, $lCommon);

	chdir ($aPath);
    @lFileList = sort (glob ("*.*"));

	$i = 0;
	while ($i < scalar (@lFileList) - 1) {

		$lCommon = &CharsInCommon ($lFileList[$i], $lFileList[$i+1]);

		print "($lFileList[$i], $lFileList[$i+1]) = $lCommon\n";

		$i += 2;
	}

}	# FindSeries3

#-----------------------------------------------------------------------------------
# Routine:      FindSeries2
# Description:  This routine will take a directory path, look at all the
#               file names and try to find groups of files that look like
#               they are parts of a series. Things like "sss_01.jpg", "sss_02.jpg"
#               and others.
#
# Input:        aPath - Path to the directory containing the files.
#
#				Pass 1: "AAA-abcdefgh.yyy" type of file names
#
#-----------------------------------------------------------------------------------
sub FindSeries2 {
    my ($aPath) = @_;
    my (%lFileHash) = ();
    my (@lFileList, $lFileName, $lLCFile);
	my (@lLeftOver);

	chdir ($aPath);
    @lFileList = sort (glob ("*.*"));

	foreach $lFileName (@lFileList) {
		$lLCFile = lc ($lFileName);
		next if (index ($lLCFile, ".bat") != -1 or index ($lLCFile, ".me") != -1 or index ($lLCFile, ".txt") != -1);

		if ($lLCFile =~ m/\d+/) {
			# Replace everything past the first number with "*"
			$lLCFile =~ m/^([^\d]*)/;
			$lLCFile = $1 . "*.*";
			$lFileHash{$lLCFile}{count}++;
			$lFileHash{$lLCFile}{size} += -s $lFileName;
			$lFileHash{$lLCFile}{name} .= "$lFileName|";
		} else {
			# Store file names without numbers in the left over array
			print "Skipping: $lLCFile\n";
			push (@lLeftOver, $lLCFile);
		}

		#print "\t$lFileName - $1\n";
	}


	# We sometimes get single files that dont match any others, but have a number in their
	# name. Find these and put them into the leftover array and remove from hash.

	foreach $lLCFile (sort keys %lFileHash) {
		if ($lFileHash{$lLCFile}{count} == 1) {
			my $lName = $lFileHash{$lLCFile}{name};
			$lName =~ s/\|//g;
			push (@lLeftOver, $lName);
			delete $lFileHash{$lLCFile};
		}
	}

	foreach $lLCFile (sort keys %lFileHash) {
		print "$lLCFile:\n\t, $lFileHash{$lLCFile}{count} files\tsize = $lFileHash{$lLCFile}{size}\n";
	}


	foreach $lLCFile (sort @lLeftOver) {
		print "Single: $lLCFile\n";
	}
}	# FindSeries2

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
    local (@lFileList, $i);
    local ($lFile, $lTemp, $lPos, $lFinished);
	local ($lExtension, $lKey, $lNewKey);
	local (%lSeriesHash) = ();

	print "Changing to : $aPath\n";
	chdir "$aPath";

    # Get a list of all the files

    local (@lFileList) = sort (glob ("*.*"));

	# Put the file names into a hash so we can remove them as we find matches

	foreach $lKey (@lFileList) {
		chomp ($lKey);
		#print "\t$lKey\n";
		$lFileHash{$lKey} = 1;
	}

    # Look for files with names like XXXnn.jpg. We are going to strip off
    # the extension, and the numbers to leave "XXX". This will be used as
    # a key for a hash that will count how many files we have that start
    # with XXX.


	$i = 0;

	# Test 1: See if we found a file-name ending in yyyy22.*

	foreach $lKey ( keys %lFileHash) {
		$lFile = $lKey;

        # Trim off any extension

        $lPos = rindex ($lFile, ".");
        if ( $lPos > 0 ) {
			$lExtension = substr($lFile, $lPos, 11);
            $lFile = substr ($lFile, 0, $lPos);

			#print "$lFile  - $lExtension\n";
        }

		# Test 1: See if we found a file-name ending in yyyy22.*

		if ($lFile =~ m/\d+$/) {

			# yes. put a wild-card in place

			$lFile =~ s/\d+$//;
			$lFile .= '*' . $lExtension;

			if (exists $lSeriesHash{$lFile}) {
				$lSeriesHash{$lFile}++;
			} else {
				#print "Adding ($lFile) to series\n";
				$lSeriesHash{$lFile} = 1;
			}

			delete ($lFileHash{$lKey});
		}
    }

	# Test 2: look for AB- or ABC- at the begining

	foreach $lKey ( keys %lFileHash) {
		$lFile = $lKey;

        # Trim off any extension

        $lPos = rindex ($lFile, ".");
        if ( $lPos > 0 ) {
			$lExtension = substr($lFile, $lPos, 11);
            $lFile = substr ($lFile, 0, $lPos);

			#print "$lFile  - $lExtension\n";
        }

		if ($lFile =~ m/^(\w{2}-)/) {

			$lNewKey = $1 . '*' . $lExtension;

			if (exists $lSeriesHash{$lNewKey}) {
				$lSeriesHash{$lNewKey}++;
			} else {
				$lSeriesHash{$lNewKey} = 1;
				#print "Adding wild-card ($lNewKey)\n";
			}
			delete ($lFileHash{$lKey});
		}

	}


	# Test 3: Look for "Danny_goes_home-Vol13_a.mp3"
	my $lPrevious = "";
	my $lPreviousKey = "";
	my $lIndex = 0;
	my $lFinished = 0;

	while ( ! $lFinished) {

TOP_OF_LOOP:

		foreach $lKey (sort keys %lFileHash) {
			$lFile = $lKey;

			# Trim off any extension

			$lPos = rindex ($lFile, ".");
			if ( $lPos > 0 ) {
				$lExtension = substr($lFile, $lPos, 11);
				$lFile = substr ($lFile, 0, $lPos);
			}

			if ($lPrevious ne "") {

				# Take the current file name and the previous file name and see how many chars match from the left end
				$lIndex = &FindMatchingIndex ($lPrevious, $lFile);

				if ($lIndex > 0 && ( (100 * $lIndex / length ($lPrevious)) > 51)) {
					# Looks like a match.
					$lNewKey = substr ($lPrevious, 0, $lIndex - 1) . '*' . $lExtension;
					$lSeriesHash{$lNewKey}++;
					print "Adding ($lNewKey) to series\n";

					# Delete everything from our hash that matches this new key
					$lNewKey = substr ($lNewKey, 0, $lIndex - 1);
					foreach $lKey (sort keys %lFileHash) {
						if (index ($lKey, $lNewKey) == 0 && index ($lKey, $lExtension) > 0) {
							print "\tDeleting $lKey : $lNewKey\n";
							delete ($lFileHash{$lKey});
						}
					}

					goto TOP_OF_LOOP;

				}


			}

			$lPrevious = $lFile;
			$lPreviousKey = $lKey;

		}

		$lFinished = 1;
	}


	# Print the wild-card series

	#foreach $lKey (sort %lSeriesHash) {
	#	#print "Series - $lKey \n";
	#}

	# Print the left over

	foreach $lKey (sort keys %lFileHash) {
		print "Left Over: $lKey\n";
	}


	my ($lSize, $lTotalSize);;
	# Get the file sizes for our wild cards
	foreach $lKey  (sort keys %lSeriesHash) {
		#print "$lKey \n";
		$lTotalSize = 0;
		@lFileList = glob ($lKey);
		foreach $lFile (@lFileList) {
			$lSize = (-s $lFile);
			print "\t $lFile - $lSize\n";
			$lTotalSize += $lSize;
		}

		print "$lKey\t\t - $lTotalSize\n\n";
	}


}   # FindSeries


#---------------------------------------------------------------------------
# Routine:		FindMatchingIndex
# Description:	This routine will take 2 strings and compare them char by
#				char and return the first position they are different.
#				Example:
#					Str1:  "Super_Shots-Vol13-great"
#					Str2:  "Super_Shots-Vol14-great"
#				would return 17 because the first 17 chars match exactly
# Input:		aStr1 - first string
#				aStr2 - second string
#
# Returns:		Number of letters that match
#---------------------------------------------------------------------------
sub FindMatchingIndex {
	my ($aStr1, $aStr2) = @_;

	if ($aStr1 eq $aStr2) {
		return (length ($aStr1));
	}

	while (length ($aStr1) > 1) {
		if (index ($aStr2, $aStr1) == 0) {
			return length ($aStr1);
		}
		chop ($aStr1);
	}

	return (0);	# No match

}	# FindMatchingIndex

#---------------------------------------------------------------------------
# Routine:		S_PrefixFiles
# Description:	This routine will take a batch file name and expect to
#				find a list of file names in the file. If the batch file
#				name is 'hgd', every file listed in the file will be
#				prefixed with 'hgd'
#---------------------------------------------------------------------------

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
    print "\t0 - Exit\n";
    print "\t1 - Report AVI\n";
    print "\t2 - Report themes under AVI\n";
    print "\t3 - Find Series - New\n";
    print "\t4 - Prefix Files\n";
    print "\t5 - \n";
    print "\t6 - Rename Toons\n";
    print "\t7 - \n";
    print "\t8 - \n";
    print "\t9 - Find Series - Audiobooks\n";
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


        if ( $lChoice > -1 && $lChoice < 10 ) {
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

    # print "DiskFill starting\n";
    # &FindSeries ("D:\\temp\\1\\dl");

    local ($lTemp) = $ARGV[0];
    if ( $lTemp ne "" ) {
        $lChoice = $lTemp;
    }

    while ( $lFinished != 1 ) {

        if ( $lChoice == -1 ) {
            $lChoice = &S_GetChoice();
        }

        if ( $lChoice eq "0" ) {
            $lFinished = 1;
        } elsif ($lChoice eq "1") {
            &S_ReportAVI($gAVI_PREP_DIR);
            $lFinished = 1;
        } elsif ($lChoice eq "2") {
            &S_ReportThemes ();
            #&S_ReportCondensed($gAVI_PREP_DIR);
            $lFinished = 1;
        } elsif ($lChoice eq "3") {
			#&FindSeries2 ("D:\\temp\\1\\mm");
			&FindSeries2 ("D:\\1\\avi");
			#&FindSeries3 ("D:\\temp\\1\\audiobooks");
            $lFinished = 1;
        } elsif ($lChoice eq "4") {
			&S_PrefixFiles();
            $lFinished = 1;
        } elsif ($lChoice eq "5") {
            $lFinished = 1;
        } elsif ($lChoice eq "6") {
            &S_RenameToons();
            $lFinished = 1;
        } elsif ($lChoice eq "7") {
            $lFinished = 1;
        } elsif ($lChoice eq "8") {
            $lFinished = 1;
        } elsif ($lChoice eq "9") {
			&S_FindSeries4 ("D:\\1\\audiobooks");
            $lFinished = 1;
        }
    }


    local ($lRunTime) = time - $^T;
    print "Run Time: " . &Sec2HMS ($lRunTime) . "\n";

}       # Main

#!/home/aruba/bin/gnu/isqlperl
# use Test::Harness;
# use DB_File;
# use strict 'untie';
# Initial revision
#
#

use para;

my $gDOCTYPE_HTML = '
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
';

my $gHEAD_TITLE = '
<head>
<title>fill_me</title>
</head><body>
';

my $gHEAD_TITLE_CSS = '
<head>
<title>fill_me</title>
<link rel="stylesheet" type="text/css" href="base.css"></link>
</head><body>
';


my $gBODY_HTML = '
</body> </html>
';

&main ();
exit (0);



#-------------------------------------------------------------------------
# S_CompressSubjectText
# This routine will remove all non alpha characters, spaces and upper-case
# the alphas so that this subject line will sort in correct order.
#-------------------------------------------------------------------------
sub S_CompressSubjectText {
	local ($aSubject) = @_;
	#local ($lOrig) = $aSubject;

	$aSubject =~ s/Subject: //;
	$aSubject =~ s/Subject://;
	$aSubject =~ s/\.//g;
	$aSubject =~ s/\+//g;
	$aSubject =~ s/\?//g;
	$aSubject =~ s/\///g;
	$aSubject =~ s/\*//g;
	$aSubject =~ s/\,//g;
	$aSubject =~ s/\(//g;
	$aSubject =~ s/\)//g;
	$aSubject =~ s/\{//g;
	$aSubject =~ s/\}//g;
	$aSubject =~ s/\[//g;
	$aSubject =~ s/\]//g;
	$aSubject =~ s/\<//g;
	$aSubject =~ s/\>//g;
	$aSubject =~ s/_//g;
	$aSubject =~ s/-//g;
	$aSubject =~ s/\~//g;
	$aSubject =~ s/\!//g;
	$aSubject =~ tr/a-z/A-Z/;	# Upper case everything
	$aSubject =~ s/\"//g;
	$aSubject =~ s/\'//g;
	$aSubject =~ s/THE //g;
	$aSubject =~ s/A //g;
	$aSubject =~ s/\(//g;
	$aSubject =~ s/ //g;

	# print "Orig/Compressed = ($lOrig / $aSubject)\n";
	return ($aSubject);

}	# S_CompressSubjectText

#-------------------------------------------------------------------------
# S_GetSubjectBreaks
# This routine will take a story file and locate the starting row
# for each individual Subject:
# It returns an array of the form:
#			345|Subject: My first story
#			1251|Subject: The other side
#
# The number is the ending row for the message with the matching subject.
#-------------------------------------------------------------------------
sub S_GetSubjectBreaks {
	local ($aInFileName) = @_;
	local (@lIndex) = ();	# contains row-number | subject line pairs
	local ($lLine, $lRowNum, $lBlankRowNum, $lSubjectCount);
	local ($lPrevLine) = "";
	local ($lPrevSubject, $lTemp);

	$lRowNum = 1;	# Start with row #1 to match editors line counts
	$lBlankRowNum = 0;
	$lSubjectCount = 0;

	open (INFILE, $aInFileName) || die "Could not open $aInFileName for input\n";
	while ( <INFILE> ) {
		$lLine = $_;
		chop ($lLine);

		# Track the second previous blank line
		# if (length ($lLine) == 0 && length ($lPrevLine) == 0) {
		if (length ($lLine) == 0) {
			$lBlankRowNum = $lRowNum;
		}

		# See if we found a new Subject: line
		if ( index ($lLine, "Subject:") == 0 ) {
			$lSubjectCount++;

			# We want to skip the first one and continue to find the
			# next "Subject:" string. So the last blank line is
			# associated with the previous "Subject:" text.

			if ( $lSubjectCount > 1 )
			{
				# Found it. We want to grab the previous blank line row num, and
				# put it with the subject line like this: "235|Subject: My Story"
				# A later routine will use the row numbers to break the large file
				# into smaller parts based on the previous blank line.

				# Upper case the PREVIOUS Subject: line and
				# remove white-space
				$lTemp = &S_CompressSubjectText($lPrevSubject);
				$lTemp = $lBlankRowNum . "|" . $lTemp;
				push (@lIndex, $lTemp);

				# For Debugging
				if ( $lSubjectCount < 5 ) {
					# print "$lPrevSubject ends on line $lBlankRowNum\n";
				}
			}

			$lPrevSubject = $lLine;
		}

		$lRowNum++;
		$lPrevLine = $lLine;
	}

	close (INFILE);

	# Now we have to take care of the last message EXCEPT we
	# use the last row in the file as the end.
	$lTemp = &S_CompressSubjectText($lPrevSubject);
	$lTemp = $lRowNum . "|" . $lTemp;
	push (@lIndex, $lTemp);

	# print "$lPrevSubject ends on line $lRowNum\n";

	return (@lIndex);
}	# S_GetSubjectBreaks


#-------------------------------------------------------------------------
# Routine:		S_TagText
# Description:  This routine takes an array of text rows and formats them
#				to an output file.
#-------------------------------------------------------------------------
sub S_TagText {
	my ($aBuf, $aOutPath, $aFileCount) = @_;
	my ($lOutFile, $lxTitle);
	my ($lRow, $lRowNum, $lEndRow);
	my ($lPrevLen, $lLen, $lNextLen);
	my ($lParagraphStart, $lParagraphEnd, @lText);

	# Calculate how many rows in the buffer:

	$lEndRow = scalar @$aBuf;

	# Calculate an output file name
	$lOutFile = sprintf ("story%04d.xhtml", $aFileCount);
	print "$lOutFile - $lEndRow\n";

	if ( -e $aOutPath . $lOutFile ) {
		unlink ($aOutPath . $lOutFile);
	}

	open (OUT_FILE, ">$aOutPath" . "$lOutFile") or die ("Error: Could not open file for output: $!\n");

	# Xhtml header

	print OUT_FILE "$gDOCTYPE_HTML\n";
	$lxTitle = $gHEAD_TITLE_CSS;
	$lxTitle =~ s/fill_me/$lOutFile/;
	print OUT_FILE "$lxTitle\n";

	$lPrevLen = 1;
	$lLen = 1;
	$lRowNum = 0;
	foreach $lRow (@{$aBuf}) {

		$lLen = length ($lRow);
		$lNextLen = 1;
		if (exists $$aBuf[$lRowNum + 1]) {
			$lNextLen = length ($$aBuf[$lRowNum + 1]);
		}

		# See if we need to wrap <p> or </p> tags

		if ($lPrevLen == 1 and $lLen > 2) {
			#$lRow = "<p>$lRow";
			$lParagraphStart = $lRowNum;
			@lText = ();

		}

		if ( $lLen > 2 and $lNextLen == 1) {
			chomp ($lRow);
			#$lRow .= "</p>\n";
			$lParagraphEnd = $lRowNum;
			push (@lText, $lRow);

			my $lPara = para->new(start => $lParagraphStart, end => $lParagraphEnd, text => \@lText);

			#$lPara->print_text();
			#<STDIN>;
			$lPara->analyze_class();

			print OUT_FILE $lPara->print_text();

		} else {
			push (@lText, $lRow);
		}


		#print OUT_FILE $lRow;

		$lPrevLen = $lLen;
		$lRowNum++;
	}


	print OUT_FILE $gBODY_HTML;
	close (OUT_FILE);


}	# S_TagText

#-------------------------------------------------------------------------
# Routine:		S_DecomposeFile
#-------------------------------------------------------------------------
sub S_DecomposeFile {
	my ($aInFile, $aOutPath) = @_;
	my (@lSubjectArray);
	my ($lRow, $lRowCount, @lBuf, $i, $lStoryCount);
	my ($lEndRow, $lSub);

	if ( ! -e $aInFile ) {
		print "Error: Input file does not exist: $aInFile\n";
		return;
	}
	print "DF: Starting with : $aInFile\n";

	# Call a routine to read the big file and return row-numbers for each
	# separate story. The row numbers are before the newsgroup headers.

	@lSubjectArray = &S_GetSubjectBreaks ($aInFile);
	$lRowCount = 0;
	$lStoryCount = 0;
	($lEndRow, $lSub) = split (/\|/, $lSubjectArray[$lStoryCount]);


	open (IN_FILE, $aInFile) or die ("Error: Could not open file for input: $aInFile\n");
	while ($lRow = <IN_FILE>) {
		$lRowCount++;

		# See if we have hit the end of the current story
		if ($lRowCount >= $lEndRow) {

			&S_TagText (\@lBuf, $aOutPath, $lStoryCount);

			# Get the end row-number for our next story
			$lStoryCount++;
			($lEndRow, $lSub) = split (/\|/, $lSubjectArray[$lStoryCount]);
			#print "New End Row: $lEndRow\n";
			@lBuf = ();

		}

		push (@lBuf, $lRow);



	}

	close (IN_FILE);



}	# S_DecomposeFile

#-------------------------------------------------------------------------
# Routine:		S_CreateUword
# Description:	Test routine for the uword object
#-------------------------------------------------------------------------
sub S_CreateUword {
	my ($aInFile) = @_;
	my (@lSubjectArray, $lRowCount, $lStoryCount, $lEndRow, $lSub);
	my $lOutFile = 'c:\\temp\\www\\darcy.xhtml';

	if ( ! -e $aInFile ) {
		print "Error: Input file does not exist: $aInFile\n";
		return;
	}
	print "DF: Starting with : $aInFile\n";

	# Call a routine to read the big file and return row-numbers for each
	# separate story. The row numbers are before the newsgroup headers.

	@lSubjectArray = &S_GetSubjectBreaks ($aInFile);
	$lRowCount = 0;
	$lStoryCount = 0;
	($lEndRow, $lSub) = split (/\|/, $lSubjectArray[$lStoryCount]);

	open (IN_FILE, $aInFile) or die ("Error: Could not open file for input: $aInFile\n");
	while ($lRow = <IN_FILE>) {
		$lRowCount++;

		# See if we have hit the end of the current story
		if ($lRowCount >= $lEndRow) {

			#my $lPara = para->new(start => $lParagraphStart, end => $lParagraphEnd, text => \@lText);

			my $lPost = uword->new(text => \@lBuf);
			$lPost->ScanExistingTags();			# Identify the markup tags that pre-exist
			$lPost->tag_ngheader();				# Find and tag newsgroup header
			#$lPost->tag_sbreak();				# Find and tag chapter breaks
			#$lPost->d_print();
			print "Writing: $lOutFile";
			$lPost->writeFile (file => $lOutFile);
			print "\n";
			<STDIN>;

			# Get the end row-number for our next story
			$lStoryCount++;
			($lEndRow, $lSub) = split (/\|/, $lSubjectArray[$lStoryCount]);
			#print "New End Row: $lEndRow\n";
			@lBuf = ();

		}

		push (@lBuf, $lRow);

	}

	close (IN_FILE);

}	# S_CreateUword



#-------------------------------------------------------------------------
# Routine: S_EntagTextFile
# Description:  Adds tags to text file
#-------------------------------------------------------------------------
sub S_EntagTextFile {
    my ($aInFile, $aOutFile) = @_;
    my (@lSubjectArray, $lRowCount, $lStoryCount, $lEndRow, $lSub);
    my (@lBuf);

    if ( ! -e $aInFile ) {
        print "Error: input file does not exist: $aInFile\n";
        return;
    }
    print "Process id: $$\n";

    # Call a routine to read the big file and return row-numbers for each
    # separate story. The row numbers are before the newsgroup headers.

    @lSubjectArray = &S_GetSubjectBreaks ($aInFile);
    $lRowCount = 0;
    $lStoryCount = 0;
    ($lEndRow, $lSub) = split (/\|/, $lSubjectArray[$lStoryCount]);

    open (IN_FILE, $aInFile) or die ("Error: Could not open file for input: $aInFile\n");
    while ($lRow = <IN_FILE>) {
        $lRowCount++;

        # See if we have hit the end of the current story
        if ($lRowCount >= $lEndRow) {


            @lBuf = ();
        }
        push (@lBuf, $lRow);
    }

}   ##S_EntagTextFile

#-------------------------------------------------------------------------
# PrintMenu2 - Prints the menu
#-------------------------------------------------------------------------
sub PrintMenu2 {

    print "=============================================\n";
    print "              Main Menu\n";
    print "             xHTML Utilitys\n";
    print "=============================================\n";
    print "Please choose an option:\n\n";
    print "\t1 - Create xhtml from large file\n";
    print "\t2 - \n";
    print "\t3 - Create uWord\n";
    print "\t4 - Entag Text File\n";
    print "\t5 - \n";
    print "\t6 - \n";
    print "\t7 - \n";
    print "\t8 - Clean JPG FileNames\n";
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
        $g_choice = &GetChoice();

        if ( $g_choice == 1 ) {
			&S_DecomposeFile ("c:\\temp\\pxhtml.txt", "C:\\temp\\www\\");
        } elsif ( $g_choice == 2 ) {

            $l_finished = 1;
        } elsif ( $g_choice == 3 ) {
            &S_CreateUword ("c:\\temp\\f_xhtml.txt");
        } elsif ( $g_choice == 4 ) {
            &S_EntagTextFile ("C:\\temp\\stories00a.txt", "C:\\temp\\a_xhtml.txt");
            $l_finished = 1;
        } elsif ( $g_choice == 5 ) {
            $l_finished = 1;
        } elsif ( $g_choice == 6 ) {
            $l_finished = 1;
        } elsif ( $g_choice == 7 ) {
            $l_finished = 1;
        } elsif ( $g_choice == 8 ) {
            &S_FixFileNames ("C:\\temp\\1\\agent\\alt.binaries.erotica.cartoons");
            $l_finished = 1;
        } elsif ( $g_choice == 9 ) {
            $l_finished = 1;
        } else {
			$l_finished = 1;
		}
    }


}

# End of main

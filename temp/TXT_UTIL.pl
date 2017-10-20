#!/home/aruba/bin/gnu/isqlperl
# use Test::Harness;
# use DB_File;
# use strict 'untie';
# Initial revision
#
#
$HEADER	= 1;
$SCAN_DELAY = 30;          # Delay time in seconds between scans of tables
$SCAN_COUNT = 10000;           # Number of times to scan

# For SUBJECT Processing
$gTempFileName = "temp.txt";
$gPartNum = 1;
$gTotalParts = 1;
$gAuthor;
$gKeycodes;
$gErrorCount;

my $gWorkingDir = 'd:\\temp\\asstr\\01-raw';
# Define a file name to write lines of text containing graphic/binary
# characters that this script does not know how to handle.
$gBadcharFile = "badchar.txt";

$gDIVIDER = "\n\{-----------------------------------------------------\}\n\n";

# These are the text that starts lots of common lines we want to
# filter out of text files. If a line begins with one of these,
# it will be removed.

@gFilterLines = (
    "           http://www.arcticera.com/stories",
    "         http://www.arcticera.com/stories",
    "-----= Posted via Newsfeeds",
    "-----==  Over 80,000 Newsgroups",
    "Approved: ",
    "Before you buy",
    "Bytes: ",
    "Cc: ",
    "Cache-Post-Path: ",
	 "    charset=",
    "Comments: ",
    "Content-Disposition: ",
    "Content-Language: ",
    "Content-Transfer-Encoding:",
    "Content-Type: ",
    "Courtesy: ",
    "Date: ",
	 "Delivered-To: ",
    "Did you like this story",
    "Do you love to read about sex",
    "Followup-To: ",
    "Get Your Private, ",
	 "If you enjoyed this work, ",
    "JMDigest-Score: ",
    "Lines: ",
    "MIME-Version: ",
    "Message-ID: ",
    "NNTP-Posting-Date: ",
    "NNTP-Posting-Host: ",
    "Organization: ",
    "Path: ",
    "References: ",
    "Reply-To: ",
	 "Return-Path: ",
    "Sender: ",
    "Sent via Deja.com",
    "Status: ",
    "This is a multi-part message in MIME format",
    "User-Agent: ",
    "X-Abuse-Info: ",
    "X-Accept-Language: ",
    "X-Admin: ",
    "X-Airnote: ",
    "X-Archived-At: ",
    "X-Article-Creation-Date: ",
    "X-Apparently-From: ",
	 "x-assm-no-berne-warning: ",
	 "x-asstr-message-id-hack: ",
    "X-Attachments: ",
    "X-Authentication-Warning: ",
    "X-Cache: ",
    "X-Comment",
    "X-Complaints-To:",
    "X-Disclaimer: ",
    "X-Envelope-From: ",
    "X-Http",
    "X-Is-Review: ",
    "X-Keywords:",
    "X-MSMail-Priority: ",
    "X-Mailer: ",
    "X-MimeOLE: ",
    "X-MIME-Autoconverted: ",
    "X-Moderator-Contact: ",
    "X-Moderator-ID: ",
    "X-MyDeja",
    "X-Newsreader: ",
    "X-No-Archive: ",
    "X-Newsposter: ",
    "X-Original-Message-ID: ",
    "X-Original-Path: ",
    "X-Originating-Host: ",
    "X-Originating-Ip: ",
    "X-Post-Date: ",
    "X-Post-Path: ",
    "X-Priority: ",
    "X-Property: ",
    "X-Remailer-Contact: ",
    "X-Report: ",
    "X-Sender: ",
    "X-Sender-Ip: ",
    "X-Sent-Mail: ",
    "X-Server-Date: ",
    "X-Status:",
    "X-Story-Submission: ",
    "X-To: ",
    "X-Trace: ",
    "X-UID: ",
    "X-WebTV-Signature: ",
    "X-Wren-Trace: ",
    "X-XS4ALL-Date: ",
    "Xref: ",
    "________________",
    "get off at http://dreemluvr",
    "http://www.incestdreams.com/index.html",
    "http://www.newsfeeds",
	"<!--",
	"<meta ",
	"<SCRIPT",
	"</SCRIPT",
	"+-------",
	'\| &lt',
	'\| Archive',
	'&lt;',
	"runScroll",
	'//--',
	'<pre>',
	'+-------',
	);

# Define a list of author names so we can convert " by Steve " into "{Steve}"
@gAuthors = (
	"Admiral Cartwright",
	"Adrian Hunter and Chelsea Shepard",
	"Adrian Hunter",
	"Al Steiner",
	"Arc Light",
	"C\.D\.E\.",
	"Caesar",
	"Carl Hunter",
	"Carol Collins",
	"Chelsea Shepard",
	"Creampie Eater",
	"Dafney Dewitt",
	"Dark Dreamer",
	"DarkPaladin",
	"David Shaw",
	"Delta",
	"Desdmona",
	"Dr Wu",
	"DrSpin",
	"Dr\. Wu",
	"Ernie Walker",
	"Farleven",
	"Gary Cirby",
	"GenericJoe",
	"Ghostrider",
	"HaRkOnIn",
	"Imma Scared",
	"Jack Woody",
	"Joe the Cuckold",
	"K\. Black",
	"Kael Goodman",
	"Karen Black",
	"Katie",
	"Knobbie Knobbs",
	"Kristen",
	"Leta and Mkarl",
	"Leta with Mkarl",
	"Lingus",
	"Lord Malinov",
	"M\. Carlo",
	"Mad Gerald",
	"Master Chris",
	"Matt Twassel",
	"Mkarl",
	"Orestes",
	"Otzchiim",
	"Paladin",
	"Pamela",
	"Parker",
	"PJ",
	"Poison Ivan",
	"Rajah Dodger",
	"Rose Red",
	"S\. Bockman",
	"Santbarb",
	"Shakespeare_I\._Aint",
	"Sharmila Sanyal",
	"Stepdaddy",
	"Stephen Douglas",
	"StoryMaster",
	"Sweet Sue",
	"Tammie Walker",
	"Taoman",
	"The Depraved Canuck",
	"The StoryMaster",
	"Thndrshark",
	"Tiffany",
	"Tiramisu",
	"Twassel",
	"Vickie Tern",
	"Victor Bruno",
	"Wonder Mike",
	"lcdrjmc\@aol\.com",
	);

$gSubject;
@gText;
@gStandingFile = (  "bu10_score_98.html",
                    "bu12_score_98.html",
                    "bu14_score_98.html",
                    "gu10_score_98.html",
                    "gu12_score_98.html",
                    "gu14_score_98.html"
				 );
@gTable = ();
@gWebText = ();		# Will contain the html code for a single soccer team
					# game schedule.

@gTeamSched = ();  	# Each row contains a string that represents 1 game.
@gWebaTLA = ();	# This array contains the name of every web page
					# generated by this code.  It is used to create an
					# aTLA page that links to each teams individual
					# game schedule.

@gTemplateTop;		# Holds the top of the template.html file
@gTemplateBottom;	# Holds the bottom of the template.html file.
$gTEMPLATE_FILE = "template.html";
$gSCHED_TEMPLATE_FILE = "sched_template.html";
$gSCHED_aTLA_OUTFILE = "sched_aTLA.html";



&main ();
exit (0);

#-------------------------------------------------------------------------
# S_AnalyzeFormat
# This routine will attempt to analyze the format of each text file.
#-------------------------------------------------------------------------
sub S_AnalyzeFormat
{
	my ($aFileName) = @_;
	my ($lInFile, $lOutFile);
	my ($lOutFile);
	my ($lCmd);

	# See if the parent routine gave us a file name
	if ( length ($aFileName) < 1 )
	{
		# Get the input file name
		system ("cls");
		printf "File Name: ";
		$lOutFile = <STDIN>;
		chop ($lOutFile);
	} else {
		$lOutFile = $aFileName;
	}

	if ( length ($lOutFile) > 3 ) {
		printf "Analyzing format for ($lOutFile)\n";

		# Create a unique file name for the temporary file
		$lInFile = "_" . "$lOutFile";

		# delete any temp file that is left over
		&S_EraseFile ($lInFile);
		system ("rename $lOutFile $lInFile");

		# Call a routine to analyze the format
		#
		#

		&S_DoFormatAnalysis ($lInFile, $lOutFile);
		print "Format lines added. (Input/Output): ($lInFile / $lOutFile)\n";

	} else {
		printf "** NO INPUT FILE SPECIFIED **\n";
	}

	# Now make sure we did not cut our file in half
	&S_TestFileSizes ($lInFile, $lOutFile);

}	# S_AnalyzeFormat

#-------------------------------------------------------------------------
# S_GetFormatCode
# This routine will examine the @gText array and analyze the body of
# the text so later routines can reformat it.
# Format Codes:
#	0 - Text is left-justified with indents to seperate paragraphs
#	1 - Text is left-justified without indents to seperate paragraphs
#	2 - All text is indented and needs to be out-dented.
#-------------------------------------------------------------------------
#-------------------------------------------------------------------------
# S_DoFormatAnalysis
#	If an article is left-justified with indents
#-------------------------------------------------------------------------
sub S_DoFormatAnalysis {
	my ($aInFileName, $aOutDir) = @_;
	my ($lOutFileName);
	my ($lArticleFormat);

	open (INFILE, $aInFileName) || die "Could not open $aInFileName for input\n";
	open (OUTFILE, ">bob.txt");
	print "Doing format analysis for $aInFileName:\n";

	while ( <INFILE> ) {
		# Call a routine that will find the next story article and pull the text
		# into the global "gText" and the subject line into the global "gSubject"
		if ( &S_GetNextStory() == 1 )
		{

		}
	}

	close (OUTFILE);
	close (INFILE);

}	# S_PareseTextFile

#-------------------------------------------------------------------------
# S_CompressSubjectText
# This routine will remove all non alpha characters, spaces and upper-case
# the alphas so that this subject line will sort in correct order.
#-------------------------------------------------------------------------
sub S_CompressSubjectText {
	my ($aSubject) = @_;
	my ($lOrig) = $aSubject;

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
	my ($aInFileName) = @_;
	my (@lIndex) = ();	# contains row-number | subject line pairs
	my ($lLine, $lRowNum, $lBlankRowNum, $lSubjectCount);
	my ($lPrevLine) = "";
	my ($lPrevSubject, $lTemp);

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
# S_SplitSubjectBreaks
# This routine will take a file name and the array of subject-break
# info for the file and create a bunch of individual files with one
# story per file.  The file names will be like "t0000.tmp". The
# file names and the subject lines they contain will be returned.
#
# Inputs:	aInFileName - Name of the input file
# 			aBreakIndex - Array of the form:
#                 "121|This is My story"
#                 "264|A funny thing happned"
#                  The number is the ending row for the message
#                 (The "S_GetSubjectBreaks() routine does this for us)
#
# Output:	%SubjectArray - This is an associative array that uses
#           	the "Subject: aaa bbb" portion as the index, and the
#				file name as the member like this:
#					SubjectArray["Subject: aaa"] = "t0000.tmp"
#					SubjectArray["Subject: Hello"] = "t0231.tmp"
#				This allows us to know what file contains what message
#
#-------------------------------------------------------------------------
sub S_SplitSubjectBreaks {
	my ($aInFileName, @aBreakIndex) = @_;
	my (%lSubjectArray) = ();				# Our output
	my ($lRowCount, $lFileName, $lFileCount, $lEndRow);
	my ($lSubject, $lLine, $lIndex, $i);

	$lRowCount = 0;
	$lFileCount = 0;
	$i = 0;

	# Open the story file and write the rows for each message
	# to a different file. Track the Subject: line with
	# the file name so we can re-assemble the file in sorted order

	system "del *.tmp";
	open (INFILE, $aInFileName) || die "Could not open $aInFileName for input\n";
	$lRowCount = 0;

	# Open the first output file to start things off
	$lFileName = "t" . sprintf ("%04d", $lFileCount) . ".tmp";
	($lEndRow, $lSubject) = split (/\|/,$aBreakIndex[$lFileCount]);

	# Associate this file name with this subject line. Use the
	# "Compress" routine to strip out spaces, and puncuation
	# so we get a better alphabetical sort later.

	$lIndex = &S_CompressSubjectText($lSubject);
	$lSubjectArray{$lIndex} = $lFileName;

	$lFileCount++;
	open (TXTFILE, ">$lFileName") || die "Could not open $lFileName for output\n";
	while ( <INFILE> ) 	{
		$lLine = $_;
		print TXTFILE "$lLine";

		$lRowCount++;

		# See if we reached the last row before the next message
		if ( $lRowCount == $lEndRow ) {
			# Found the end. Close the file and open the next one.
			close (TXTFILE);


			# Get the next temp file name
			$lFileName = "t" . sprintf ("%04d", $lFileCount) . ".tmp";

			# Get the next ending row number
            ($lEndRow, $lSubject) = split (/\|/, $aBreakIndex[$lFileCount]);


			# Track this file name with this subject line
			$lIndex = &S_CompressSubjectText($lSubject);

			# If we have 2 or more identical subject lines, one will
			# over-write the other. Work to create a unique
			# index string for the second, third,...

			while ( defined ($lSubjectArray{$lIndex} ) ) {
				print "Error: Index ($lIndex) is already defined\n";
				$lIndex = $lIndex . "-" . $i;
				$i++;
			}

			# Now we should have a unique index
			$lSubjectArray{$lIndex} = $lFileName;

			# for debugging
			# print "next file:($lFileName) takes row $lEndRow\n";

			$lFileCount++;
			open (TXTFILE, ">$lFileName") || die "Could not open $lFileName for output\n";
		}

	}

	close (TXTFILE);
	close (INFILE);

	# Our %lSubjectArray now looks like
	#     lSubjectArray["Subject: fubar"] = "t0000.tmp"
	#     lSubjectArray["Subject: this is mine"] = "t0001.tmp"


	return (%lSubjectArray);
}   # S_SplitSubjectBreaks

#-------------------------------------------------------------------------
# S_BreakFile2
# This routine will take a story file and break each storie into a
# individual file.
# This looks for a blank-line ahead of each Subject: line
#-------------------------------------------------------------------------
sub S_BreakFile2 {
	my ($aInFileName) = @_;
	my (@lBreakIndex) = ();	# contains row-number | subject line pairs
	my (%lSubjectArray) = ();	# contains Subject | file name pairs
	my ($lSubject, $lLine, $lFileName, $lRowCount, $lEndRow);
	my ($lFileCount) = 0;

	# Call a routine to analyze the story file and return a array
	# that tells us the end-row of each story, and the "Subject:"
	# line for each one.

	@lBreakIndex = &S_GetSubjectBreaks ($aInFileName);

	# Use the break index array to split the big file up into smaller
	# story files. It will return a Associative array with the
	# subject lines as the index and the file names as the members.
	# This will allow us to pull the smaller story files into a
	# single file, but sorted by Subject header

	%lSubjectArray = &S_SplitSubjectBreaks ($aInFileName, @lBreakIndex);


	# Our %lSubjectArray now looks like
	#     lSubjectArray["Subject: fubar"] = "t0000.tmp"
	#     lSubjectArray["Subject: this is mine"] = "t0001.tmp"
	#
	# Using the index, grab the file names in order and put them into
	# a new file

	my ($lOldFileName) = "_" . $aInFileName;
	rename ($aInFileName, $lOldFileName);
	open (OUTFILE, ">$aInFileName") || die ("Cannot open $aInFileName for output\n");

	foreach $lSubject (sort (keys(%lSubjectArray))) {
		$lFileName = $lSubjectArray{$lSubject};
		# print "Out: $lFileName - $lSubject\n";

		print OUTFILE "$gDIVIDER";

		# Grab the story file and put it's lines into the output file
		open (INFILE, "$lFileName") || die ("Cannot open $lFileName for input!\n");
		while ( <INFILE> ) 	{
			print OUTFILE $_;
		}
		close (INFILE);
		# unlink (INFILE);	# Delete the temp file
	}

	close (OUTFILE);
	system "del *.tmp";
	print "Original file moved to : $lOldFileName\n";
	print "Sorted output written to : $aInFileName\n";

} # S_BreakFile2


#-------------------------------------------------------------------------
# S_SortStories
# This routine will sort the stories found in ONE text file to itself
#
#-------------------------------------------------------------------------
sub S_SortStories {

    &S_BreakFile2 ("c:\\temp\\temp\\comb.txt");
}	# S_SortStories

#-------------------------------------------------------------------------
# S_CompareFileSizes
# Many routines take a file, and filter it to another file. Sometimes
# there is a problem and the output file is much smaller than the input
# file. In this case, we want to exit so we don't trash things.
# This routine checks 2 file names and compares the sizes. If the output
# is too small (less than 90%) of the input, a message is printed and
# the program will hard EXIT
#-------------------------------------------------------------------------
sub S_TestFileSizes {
	my ($aInFile, $aOutFile) = @_;
	my ($lInFileSize, $lOutFileSize, $lSize);

	if ( (-e $aInFile) && (-e $aOutFile) ) 	{
		$lInFileSize = -s $aInFile;
		$lOutFileSize = -s $aOutFile;

		# The output is often a bit smaller. Allow 10%
		$lSize = $lInFileSize * 0.80;
		if ( $lOutFileSize < $lSize ) {
			print "Error: In/Out files ($aInFile / $aOutFile) sizes are ($lInFileSize / $lOutFileSize)\n";
			print "       This is greater than a 10 % difference\n";
			print "       Exiting program to prevent loss\n";
			exit (1)
		}
	} else {

		print "Error: one of the input/output files ($aInFile, $aOutFile) does not exist\n";
		exit (1);
	}

}	# S_TestFileSizes

#-------------------------------------------------------------------------
# S_EraseFile
# This routine will take a file name and test to see if it exists. If so,
# it will erase it by using the dos DEL routine.
#-------------------------------------------------------------------------
sub S_EraseFile {
	my ($aFileName) = @_;
	my ($lCmd) = "del $aFileName";

	if (-e $aFileName) {
		system $lCmd;
	}
}	# S_EraseFile




#-------------------------------------------------------------------------
# Routine:      _ResortExistingFile
# Description:  This routine will take an already sorted file, but
#               perhaps with other stories added or subject lines
#               changed, and sort it again.
#
#-------------------------------------------------------------------------
sub _ResortExistingFile {
    my ($aFile) = @_;

    my ($lFile, @lBreakIndex, $lRow, %lSubjectArray);
    my ($lSubject, $lFileName, $lTempFile);
    my ($lOrigSize, $lNewSize);

    $lFile = $aFile;

    chdir ("c:\\temp\\text") or die ("Error: Could not chdir to c:\\temp\\text\n");
    print "Sorting file: $lFile\n";

	# Call a routine to analyze the story file and return a array
	# that tells us the end-row of each story, and the "Subject:"
	# line for each one.

    # 111111|BREEDER17MFFFF
    # 111231|BREEDER18MFFFF

    @lBreakIndex = &S_GetSubjectBreaks ($lFile);

	# Use the break index array to split the big file up into smaller
	# story files. It will return a Associative array with the
	# subject lines as the index and the file names as the members.
	# This will allow us to pull the smaller story files into a
	# single file, but sorted by Subject header

    %lSubjectArray = &S_SplitSubjectBreaks ($lFile, @lBreakIndex);

	# Our %lSubjectArray now looks like
	#     lSubjectArray["Subject: fubar"] = "t0000.tmp"
	#     lSubjectArray["Subject: this is mine"] = "t0001.tmp"
	#
	# Using the index, grab the file names in order and put them into
	# a new file


    $lTempFile = "_sorting.new";
    open (OUT_FILE, ">$lTempFile") or die ("Error: Could not open file for output: $lTempFile : $!\n");
	foreach $lSubject (sort (keys(%lSubjectArray))) {
		$lFileName = $lSubjectArray{$lSubject};
        open (IN_FILE, "$lFileName") or die ("Error: Could not open file for input: $lFileName : $!\n");

        while ($lRow = <IN_FILE>) {
            print OUT_FILE $lRow;
        }
        close (IN_FILE) or die ("Error: Could not close input file: $lFileName : $!\n");

        unlink ($lFileName) or die ("Error: Could not unlink temp file: $lFileName : $!\n");

    }

    close (OUT_FILE) or die ("Error: Could not close output file: $lTempFile : $!\n");

    print "Testing sorted file for size: $lTempFile...\n";

    $lOrigSize = -s $lFile;
    $lNewSize  = -s $lTempFile;

    print "Orig Size: $lOrigSize\n";
    print "New  Size: $lNewSize\n";

    # Allow a few bytes to disappear

    if ( $lNewSize > $lOrigSize - 20) {
        unlink ($lFile) or die ("Error: cannot unlink orig file $lFile : $!\n");
        rename ($lTempFile, $lFile) or die ("Error: cannot rename $lTempFile to $lFile : !\n");
    }


    print "$lFile sorted\n";

}   # _ResortExistingFile


#-------------------------------------------------------------------------
# Routine:      S_ResortExistingFile
# Description:  This routine will take an already sorted file, but
#               perhaps with other stories added or subject lines
#               changed, and sort it again.
#
#-------------------------------------------------------------------------
sub S_ResortExistingFile {
    my ($lFile, @lFileArray, $lPath);

    $lPath = "c:\\temp\\text";
    chdir ($lPath) or die ("Error: Could not chdir to $lPath : $!\n");

    # Files are like "A00.txt" B00.txt"...

    foreach $lFile (glob ("?00.txt")) {
        &_ResortExistingFile ($lFile);
    }

}   # S_ResortExistingFile


#-------------------------------------------------------------------------
# S_AlphatizeTextFile
# This routine will take a story file and break each story into a
# individual file. Then the individual files will be written to
# files like "A00.txt", "B00.txt", etc.
#-------------------------------------------------------------------------
sub S_AlphatizeTextFile {

    my ($aInFileName, $aDestDir) = @_;
	my (@lBreakIndex) = ();	# contains row-number | subject line pairs
	my (%lSubjectArray) = ();	# contains Subject | file name pairs
	my ($lSubject, $lLine, $lFileName, $lRowCount, $lEndRow);
	my ($lFileCount) = 0;
    my ($lTemp);

    print "Sorting ($aInFileName) \n";

	# Call a routine to analyze the story file and return a array
	# that tells us the end-row of each story, and the "Subject:"
	# line for each one.

	@lBreakIndex = &S_GetSubjectBreaks ($aInFileName);

	# Use the break index array to split the big file up into smaller
	# story files. It will return a Associative array with the
	# subject lines as the index and the file names as the members.
	# This will allow us to pull the smaller story files into a
	# single file, but sorted by Subject header

	%lSubjectArray = &S_SplitSubjectBreaks ($aInFileName, @lBreakIndex);

	# Our %lSubjectArray now looks like
	#     lSubjectArray["Subject: fubar"] = "t0000.tmp"
	#     lSubjectArray["Subject: this is mine"] = "t0001.tmp"
	#
	# Using the index, grab the file names in order and put them into
	# a new file


	foreach $lSubject (sort (keys(%lSubjectArray))) {
		$lFileName = $lSubjectArray{$lSubject};

        print "Subject ($lSubject) \n";
        open (INFILE, $lFileName) || die ("Could not open ($lFileName) for input\n");

        $lTemp = "";
        $lTemp = $lSubject;     # "The ..."
        $lTemp =~ s/[^A-Z]//g;
        $lTemp =~ s/ //g;

        $lTemp = $aDestDir . "\\" . substr ($lTemp, 0, 1) . "00.txt";

        open (OUTFILE, ">>$lTemp") || die ("Could not open ($lTemp) for output\n");

        # print OUTFILE "$gDIVIDER";

		# Grab the story file and put it's lines into the output file
        open (INFILE, "$lFileName") || die ("Cannot open $lFileName for input!\n");
        while ( <INFILE> )  {
            print OUTFILE $_;
        }
        close (OUTFILE);
        close (INFILE);
        unlink ($lFileName);  # Delete the temp file
	}

    # unlink ($aInFileName);

} # S_AlphatizeTextFile

#-------------------------------------------------------------------------
# S_SortTextStories
# This routine will look for all the .TXT files in the source directory
# and for each file found it will break the file up into individual
# text files
#  Output is A00.TXT, B00.TXT ...
#-------------------------------------------------------------------------
sub S_SortTextStories {

        # S_AlphatizeTextFile (<src file name> , <dest directory> );
    &S_AlphatizeTextFile ("c:\\temp\\text\\storiesk.txt", "C:\\TEMP\\text\\");
    &S_AlphatizeTextFile ("c:\\temp\\text\\storiesm.txt", "C:\\TEMP\\text\\");
    &S_AlphatizeTextFile ("c:\\temp\\text\\storieso.txt", "C:\\TEMP\\text\\");

}	# S_SortTextStories


#-------------------------------------------------------------------------
# S_StripCommonHeadings -
# Looks for common things that follow the word "Subject: "
# and strips them off:
# Subject: Repost - xxx         Subject: xxx
# Subject: Repost- xxx			Subject: xxx
# Subject: Repost-xxx           Subject: xxx
# Subject: Repost : xxx         Subject: xxx
# Subject: Repost: xxx          Subject: xxx
# Subject: Repost:xxx           Subject: xxx
#-------------------------------------------------------------------------
sub S_StripCommonHeadings {
	my ($aInLine, $aTLA) = @_;


	$aInLine =~ s/Subject: $aTLA - /Subject: /gii;
	$aInLine =~ s/Subject: $aTLA -/Subject: /gii;
	$aInLine =~ s/Subject: $aTLA- /Subject: /gii;
	$aInLine =~ s/Subject: $aTLA-/Subject: /gii;


	$aInLine =~ s/Subject: $aTLA : /Subject: /gii;
	$aInLine =~ s/Subject: $aTLA :/Subject: /gii;
	$aInLine =~ s/Subject: $aTLA: /Subject: /gii;
	$aInLine =~ s/Subject: $aTLA:/Subject: /gii;

    $aInLine =~ s/Subject: $aTLA, /Subject: /gii;
    $aInLine =~ s/Subject: $aTLA! /Subject: /gii;

	$aInLine =~ s/Subject: $aTLA;/Subject: /gii;

    # finally

	$aInLine =~ s/Subject: $aTLA /Subject: /gii;

	return ($aInLine);

}	# S_StripCommonHeadings


#-------------------------------------------------------------------------
# S_StripTLA - Removes common Three letter acrynoms like:
# 	{ASSM}
# 	(ASSM)
# 	[ASSM]
# 	ASSM -
# 	ASSM-
# 	ASSM
#-------------------------------------------------------------------------
sub S_StripTLA {
	my ($aInLine, $aTLA) = @_;

	$aInLine =~ s/ \{$aTLA\} / /gii;
	$aInLine =~ s/ \{$aTLA\}/ /gii;
	$aInLine =~ s/\{$aTLA\}/ /gii;

	$aInLine =~ s/ \[$aTLA\] / /gii;
	$aInLine =~ s/ \[$aTLA\]/ /gii;
	$aInLine =~ s/\[$aTLA\]/ /gii;

	$aInLine =~ s/ \($aTLA\) / /gii;
	$aInLine =~ s/ \($aTLA\)/ /gii;
	$aInLine =~ s/\($aTLA\)/ /gii;

    $aInLine =~ s/ \*$aTLA\* / /gii;
    $aInLine =~ s/ \*$aTLA\*/ /gii;
    $aInLine =~ s/\*$aTLA\*/ /gii;

    $aInLine =~ s/ $aTLA\. / /gii;
    $aInLine =~ s/ $aTLA\./ /gii;
    $aInLine =~ s/$aTLA\./ /gii;

    $aInLine =~ s/ $aTLA://gii;

	return ($aInLine);

}	# S_StripTLA

#-------------------------------------------------------------------------
# S_ScrubTextLine
# This routine will take a line of text and try to erase/substitute
# out any special characters left in by various word processors.
#-------------------------------------------------------------------------
sub S_ScrubTextLine {
	my ($lLine) = @_;
	my ($lChar, @a, $lPos, $lc);
	my ($lApros)   = pack ("C*", 226,32,32,32,32,45,32,153);
	my ($lExclaim) = pack ("C*", 166, 32,32,32,32,45,32,166);

	# Look for funny editing characters to swap out

	$lLine =~ s/\t/    /g;		# Replace Tab chars with spaces
	$lLine =~ s/\&nbsp; / /g;	# HTML space
	$lLine =~ s/\<BR\>//g;		# HTML break

	# Look for complex sequences of characters before looking for
	# individual characters.

	$lLine =~ s/$lApros/\'/g;
	$lLine =~ s/$lExclaim/\!/g;
	$lLine =~ s///g;
	$lLine =~ s/ //g;

	$lChar = chr (12);			# LF
	$lLine =~ s/$lChar//g;
	$lChar = chr (13);			# CR
	$lLine =~ s/$lChar//g;

	$lChar = chr (127);			# Funny triangle symbol
	$lLine =~ s/$lChar//g;


	$lChar = chr (128);			# A list of some type
	$lLine =~ s/$lChar/    - /g;

	$lChar = chr (132);			# Funny A with Colon above it
	$lLine =~ s/$lChar/\"/g;

	$lChar = chr (133);			# Funny A with quote above it
	$lLine =~ s/$lChar//g;


	$lChar = chr (139) . chr (139);			# funny i char
	$lLine =~ s/$lChar/ - /g;

	$lChar = chr (139);			# funny i char
	$lLine =~ s/$lChar/ - /g;


	$lChar = chr (140);			# back-quote
	$lLine =~ s/$lChar/\`/g;
	$lChar = chr (145);			# back-quote
	$lLine =~ s/$lChar/\`/g;
	$lChar = chr (146);			# apostriphie
	$lLine =~ s/$lChar/\'/g;
	$lChar = chr (147);			# open quote
	$lLine =~ s/$lChar/\"/g;
	$lChar = chr (148);			# close quote
	$lLine =~ s/$lChar/\"/g;

	$lChar = chr (150);			# U with umlout
	$lLine =~ s/$lChar//g;

	$lChar = chr (169);			# Copyright Symbol?
	$lLine =~ s/$lChar//g;

	$lChar = chr (173);			# funny upside-down quote
	$lLine =~ s/$lChar//g;

	$lChar = chr (178);
	$lLine =~ s/$lChar/\"/g;

	$lChar = chr (179);			# Vertical line
	$lLine =~ s/$lChar/\"/g;

	$lChar = chr (185);
	$lLine =~ s/$lChar/\'/g;

	$lChar = chr (233);
	$lLine =~ s/$lChar/\'/g;

	$lChar = chr (237);
	$lLine =~ s/$lChar/\'/g;


	$lChar = chr (239);			# Accent like naive
	$lLine =~ s/$lChar/i/g;

	# Return <> chars
	$lLine =~ s/\&lt;/\</g if ( index ($lLine, '&lt;') > -1 );
	$lLine =~ s/\&gt;/\>/g if ( index ($lLine, '&gt;') > -1 );

	$lLine =~ s/`/'/g if ( index ($lLine, '`') > -1 );

	# Look for &#8220; sequences and replace them with chars
	if ( index ($lLine, '&#82') > -1 ) {
		$lLine =~ s/\&#8217;/'/g;		# Aprostrophie
		$lLine =~ s/\&#8220;/"/g;		# Double Quote
		$lLine =~ s/\&#8221;/"/g;		# Double Quote
	}

	# The unpack/pack is another way to look for special
	# characters, but we do this above. The code is left
	# here to announce any missed characters.
	# Note: this only works for char to char substitions.

	@a = unpack ("C*", $lLine);
	$lPos = 0;
	foreach $lc (@a) {
	# 	if ( $lc == 12  ) { $a[$lPos] = ord ' ';}
	# 	if ( $lc == 13  ) { $a[$lPos] = ord ' ';}
	# 	if ( $lc == 128 ) { $a[$lPos] = ord '-';} # bullet list
	# 	if ( $lc == 133 ) { $a[$lPos] = ord '.';}
	# 	if ( $lc == 140 ) { $a[$lPos] = ord '`';}
	# 	if ( $lc == 145 ) { $a[$lPos] = ord "`";}
	# 	if ( $lc == 146 ) { $a[$lPos] = ord "'";}
	# 	if ( $lc == 147 ) { $a[$lPos] = ord '"';}
	# 	if ( $lc == 148 ) { $a[$lPos] = ord '"';}
	# 	if ( $lc == 150 ) { $a[$lPos] = ord ' ';}
	# 	if ( $lc == 169 ) { $a[$lPos] = ord ' ';}
	# 	if ( $lc == 178 ) { $a[$lPos] = ord '"';}
	# 	if ( $lc == 179 ) { $a[$lPos] = ord '"';}
	# 	if ( $lc == 185 ) { $a[$lPos] = ord "'";}
	# 	if ( $lc == 233 ) { $a[$lPos] = ord "'";}
	#
		if ( $lc != 10 && ($lc < 32 || $lc > 126) )  {
			# $a[$lPos] = " ";
			open (BADFILE, ">>$gBadcharFile");
			print BADFILE "$lLine\n";
			print BADFILE "$lLineCount) Pos ($lPos) = $lc (@a[$lPos], @a[$lPos+1], @a[$lPos+2], @a[$lPos+3], @a[$lPos+4], @a[$lPos+5], @a[$lPos+6], @a[$lPos+7])\n";
			close (BADFILE);
		}

		$lPos++;
	}
	# $lLine = pack ("C*", @a);


	return ($lLine);
} # S_ScrubTextLine

#-------------------------------------------------------------------------
# S_ScrubSubjectLine
#-------------------------------------------------------------------------
sub S_ScrubSubjectLine {
	my ($lLine) = @_;
	my ($lOutLine) = "";


	# Look for common things in {} () []
	$lLine = &S_StripTLA ($lLine, "ASSM");
	$lLine = &S_StripTLA ($lLine, "ASSD");
	$lLine = &S_StripTLA ($lLine, "A.S.S.");
	$lLine = &S_StripTLA ($lLine, "ASS");
	$lLine = &S_StripTLA ($lLine, "RE");
	$lLine = &S_StripTLA ($lLine, "RP");
    $lLine = &S_StripTLA ($lLine, "NEW");
    $lLine = &S_StripTLA ($lLine, "incest story");

	# Look for common things like "Subject: RP:"
	$lLine = &S_StripCommonHeadings ($lLine, "-");
	$lLine = &S_StripCommonHeadings ($lLine, "ASS -");
	$lLine = &S_StripCommonHeadings ($lLine, "ASSB");
	$lLine = &S_StripCommonHeadings ($lLine, "AMA");
    $lLine = &S_StripCommonHeadings ($lLine, "ASA Story");
    $lLine = &S_StripCommonHeadings ($lLine, "ASSM NEW");
    $lLine = &S_StripCommonHeadings ($lLine, "ASSM RP");
    $lLine = &S_StripCommonHeadings ($lLine, "ASSM Rp");
    $lLine = &S_StripCommonHeadings ($lLine, "ASS/M");
	$lLine = &S_StripCommonHeadings ($lLine, "by request");
	$lLine = &S_StripCommonHeadings ($lLine, "NEW STORY");
    $lLine = &S_StripCommonHeadings ($lLine, "*NEW*");
	$lLine = &S_StripCommonHeadings ($lLine, "NEW");
	$lLine = &S_StripCommonHeadings ($lLine, "<NEW>");
	$lLine = &S_StripCommonHeadings ($lLine, "RP by req.");
	$lLine = &S_StripCommonHeadings ($lLine, "RP");
	$lLine = &S_StripCommonHeadings ($lLine, "RE");
	$lLine = &S_StripCommonHeadings ($lLine, "REPOST");
	$lLine = &S_StripCommonHeadings ($lLine, "STORY");
	$lLine = &S_StripCommonHeadings ($lLine, "Story");
	$lLine = &S_StripCommonHeadings ($lLine, "ST");
	$lLine = &S_StripCommonHeadings ($lLine, "St");


	# Look for some other common things that dont fit regular patterns
	$lLine =~ s/Subject: \. +/Subject: /;

	$lLine =~ s/ +\d{4,10}$//;

	$lLine =~ s/Subject: Krinsen\'s collection: /Subject: /gi;

	$lLine =~ s/Subject: sex \"/Subject: \"/g;

    $lLine =~ s/Subject: -\"/Subject: \"/g;
    $lLine =~ s/Subject: -/Subject: /g;

    $lLine =~ s/Subject: :\"/Subject: \"/g;

	$lLine =~ s/ - Great \w+ Story\!?//;
	$lLine =~ s/\.\. Great \w+ Story\!?//;


	$lLine =~ s/ASSB -- //g;
	$lLine =~ s/ASSB.. //g;

	$lLine =~ s/\&lt;/\</g if ( index ($lLine, '&lt;') > -1 );
	$lLine =~ s/\&gt;/\>/g if ( index ($lLine, '&gt;') > -1 );

	# This funny thing often appears
	$lLine =~ s/\<\*\>//g;

	# Find N/N and surround with brackets
	# Look for "part 2"
	$lLine =~ s/part (\d+) of (\d+)/ \[$1\/$2\] /gi;
	$lLine =~ s/part (\d)\s/ \[0$1\/\?\?\] /gi;
	$lLine =~ s/part (\d+)\s/ \[$1\/\?\?\] /gi;
	$lLine =~ s/part (\d+\/\d+)/ \[$1]/gi;
	$lLine =~ s/part (\d)/ \[0$1\/\?\?\]/gi;

	$lLine =~ s/ch (\d+) of (\d+)/ \[$1\/$2\] /gi;
	$lLine =~ s/ch (\d)\s/ \[0$1\/\?\?\] /gi;
	$lLine =~ s/ch (\d+)\s/ \[$1\/\?\?\] /gi;
	$lLine =~ s/ch (\d+\/\d+)/ \[$1]/gi;
	$lLine =~ s/ch (\d)/ \[0$1\/\?\?\]/gi;

	# Look for " 1/4 " and put brackets around it
	$lLine =~ s/ (\d+\/\d+) / \[$1\] /g;
	$lLine =~ s/ \((\d+\/\d+\)) / \[$1\] /g;	# Handle (1/2)

	# Look for [5/6)] and fix it
	$lLine =~ s/(\[\d\/\d)\)\]/$1\]/;

#		$lLine =~ s/ Re: //gi;
#		$lLine =~ s/Rp by Rq: //gi;
#		$lLine =~ s/(Anonymouse)//gi;
#		$lLine =~ s/(Repost) //gi;
#		$lLine =~ s/(Repost)//gi;
#		$lLine =~ s/Another 120 Stories //gi;
#
	# We may have left some extra spaces
	$lLine =~ s/  / /gi;
	$lLine =~ s/  / /gi;

	return ($lLine);
}	# S_ScrubSubjectLine


#-------------------------------------------------------------------------
# S_HandleAuthor
#  Often, Subject lines start with the authors name like:
# 		Subject: (PJ)
# 		Subject: {Kellis}
# This routine will take a "Subject:" line, look for author names at
# the begining and move the text to the end of the line.
#-------------------------------------------------------------------------
sub S_HandleAuthor {
	my ($aLine) = @_;
	my ($lEndChar);
	my ($lAuthorName);
	my ($lTarget);
	my ($i, $j);

	# Look for Ann Douglas stories
	if ( $aLine =~ /Subject: AnnD/i ) {
		$aLine =~ s/Subject: AnnD/Subject: /gi;
		$aLine .= " {AnnD}";
	}

	if ( $aLine =~ /Subject: Kristen's collection: /i ) {
		$aLine =~ s/Subject: Kristen's collection: /Subject: /gi;
	}

	# Author Names

	# $aLine =~ s/by leta with mkarl/\{Leta with Mkarl\}/gi;
	# $aLine =~ s/by mkarl/\{Mkarl\}/gi;
	# $aLine =~ s/by david shaw/\{David Shaw\}/gi;
	# $aLine =~ s/by taoman/\{Taoman\}/gi;
	# $aLine =~ s/by the storymaster/\{StoryMaster\}/gi;
	# $aLine =~ s/by poison ivan/\{Poison Ivan\}/gi;
	# $aLine =~ s/by genericjoe/\{GenericJoe\}/gi;
	# $aLine =~ s/by s\. bockman/\{S\. Bockman\}/gi;
	# $aLine =~ s/by rajah dodger/\{Rajah Dodger\}/gi;
	# $aLine =~ s/by lingus/\{Lingus\}/gi;
	# $aLine =~ s/by carol collins/\{Carol Collins\}/gi;
	# $aLine =~ s/by kael goodman/\{Kael Goodman\}/gi;
	# $aLine =~ s/by delta/\{Delta\}/gi;
	# $aLine =~ s/by the depraved canuck/\{The Depraved Canuck\}/gi;
	# $aLine =~ s/by creampie eater/\{Creampie Eater\}/gi;
	# $aLine =~ s/by sweet sue/\{Sweet Sue\}/gi;

	## New: Look for "by author" and convert it to {author}
	foreach $lAuthorName (@gAuthors) {
		if ( $aLine =~ /\bby $lAuthorName\b/i ) {
			# Remove the text from the subject line
			$aLine =~ s/\bby $lAuthorName\b//i;
			# Put the author at the end in curly braces
			$aLine .= " \{$lAuthorName\}";
			print "Put ($lAuthorName) at the end\n";
		}
	}


	# Some Articles start like:
	#	Subject: [Lingus] aaaaaa
	#	Subject: [Black Demon] aaaaaa
	# We want to change this to:
	# 	Subject: aaaaa {Lingus}
	#	Subject: aaaaa {Black Demon]

	# Look for the word "Subject: " followed by "({["
	if ( $aLine =~ /Subject: [\(\{\[]/ ) {

		# The opening "(" is at char pos 9. Find the ending character
		$lEndChar = 0;
		if ( index ($aLine, "(") == 9 ) {
			$lEndChar = index ($aLine, ")");
		} elsif ( index ($aLine, "{") == 9 ) {
			$lEndChar = index ($aLine, "}");
		} elsif ( index ($aLine, "[") == 9 ) {
			$lEndChar = index ($aLine, "]");
		}

		if ( $lEndChar > 9 ) {
			# Grab everything between () as the authors name
			$lAuthorName = substr ($aLine, 9, $lEndChar - 8);

			# Remove the authors name from the begining
			$aLine = "Subject: " . substr ($aLine, $lEndChar + 1);

			# Put the authors name at the end between  {} chars
			chop ($lAuthorName);	# Trim trailing ) char
			$aLine .= " {" . substr ($lAuthorName, 1) . "}";
		}


	}


	# We may have left some extra spaces
	$aLine =~ s/  / /gi;

	return ($aLine);


}	# S_HandleAuthor


#-------------------------------------------------------------------------
# S_HandleChapters
# This routine looks for things like: (1/2) and 5/11 and reformats
# them to "[1/2]" or "[05/11]"
#
#-------------------------------------------------------------------------
sub S_HandleChapters {
	my ($aLine) = @_;
	my ($x, $y);


	# See if the line already has brackets around chapter numbers
	if ( $aLine =~ /\[\d/ ) {
		# Nothing to do
		# print "Already has brackets: $aLine\n";
		return ($aLine);
	}

	# Convert roman numerials
	$aLine =~ s/ III / 3 /;
	$aLine =~ s/ II / 2 /;
	$aLine =~ s/ IV / 4 /;
	$aLine =~ s/ V / 5 /;
	$aLine =~ s/ VI / 6 /;
	$aLine =~ s/ VII / 7 /;
	$aLine =~ s/ IIX / 8 /;
	$aLine =~ s/ IX / 9 /;
	$aLine =~ s/ X / 10 /;
	$aLine =~ s/ XIII / 13 /;
	$aLine =~ s/ XII / 12 /;
	$aLine =~ s/ XI / 11 /;


	# Convert some text

	$aLine =~ s/ part thirteen/ \[13\/\?\?\]/i;
	$aLine =~ s/ part fourteen/ \[14\/\?\?\]/i;
	$aLine =~ s/ part fifteen/ \[15\/\?\?\]/i;
	$aLine =~ s/ part sixteen/ \[16\/\?\?\]/i;
	$aLine =~ s/ part seventeen/ \[17\/\?\?\]/i;
	$aLine =~ s/ part eightteen/ \[18\/\?\?\]/i;
	$aLine =~ s/ part nineteen/ \[19\/\?\?\]/i;

	$aLine =~ s/ part one/ \[1\/\?\]/i;
	$aLine =~ s/ part two/ \[2\/\?\]/i;
	$aLine =~ s/ part three/ \[3\/\?\]/i;
	$aLine =~ s/ part four/ \[4\/\?\]/i;
	$aLine =~ s/ part five/ \[5\/\?\]/i;
	$aLine =~ s/ part six/ \[6\/\?\]/i;
	$aLine =~ s/ part seven/ \[7\/\?\]/i;
	$aLine =~ s/ part eight/ \[8\/\?\]/i;
	$aLine =~ s/ part nine/ \[9\/\?\]/i;

	$aLine =~ s/ part IIX / \[8\/\?\] /i;
	$aLine =~ s/ part IX / \[9\/\?\] /i;
	$aLine =~ s/ part X / \[10\/\?\] /i;
	$aLine =~ s/ part III / \[3\/\?\] /i;
	$aLine =~ s/ part II / \[2\/\?\] /i;
	$aLine =~ s/ part I / \[1\/\?\] /i;
	$aLine =~ s/ part IV / \[4\/\?\] /i;
	$aLine =~ s/ part VI / \[6\/\?\] /i;
	$aLine =~ s/ part V / \[5\/\?\] /i;

#	$aLine =~ s/ one/ 1/gi;
#	$aLine =~ s/ two/ 2/gi;
#	$aLine =~ s/ three/ 3/gi;
#	$aLine =~ s/ four/ 4/gi;
#	$aLine =~ s/ five/ 5/gi;
#	$aLine =~ s/ six/ 6/gi;
#	$aLine =~ s/ seven/ 7/gi;
#	$aLine =~ s/ eight/ 8/gi;
#	$aLine =~ s/ nine/ 9/gi;
#	$aLine =~ s/ ten/ 10/gi;

	# Look for any two numbers like "(x/x)" and convert to " [x/x] "
	if ( $aLine =~ /\(\d\/\d\)/  ) {
		$aLine =~ s/\((\d)\/(\d)\)/ \[$1\/$2\] /g;
		# print "Added [x/x]: $aLine\n";
		return $aLine;
	}

	# Look for (1/2) type patterns. Replace with [1/2]
    # if ( $aLine =~ /\(\d\)/ ) {
    if ( $aLine =~ /\(\d\// ) {
		# Replace the "()" chars with "[]" chars
		$aLine =~ s/\((\d)\/(\d)\)/ \[$1\/$2\] /;
		$aLine =~ s/\((\d)\/(\d\d)\)/ \[0$1\/$2\] /;
		$aLine =~ s/\((\d\d)\/(\d\d)\)/ \[$1\/$2\] /;
		# print "Replaced parens with brackets: $aLine\n";
		return ($aLine);
	}


    # Look for (11/12) type patterns. Replace with [11/12]
    if ( $aLine =~ /\(\d\d\// ) {
		# Replace the "()" chars with "[]" chars
		$aLine =~ s/\((\d)\/(\d)\)/ \[$1\/$2\] /;
		$aLine =~ s/\((\d)\/(\d\d)\)/ \[0$1\/$2\] /;
		$aLine =~ s/\((\d\d)\/(\d\d)\)/ \[$1\/$2\] /;
		# print "Replaced parens with brackets: $aLine\n";
		return ($aLine);
	}


	# Look for bare numbers sitting out like "2/5"
	if ( $aLine =~ /\d\/\d/ ) {
		$aLine =~ s/ (\d\d\d)\/(\d\d\d)/\ \[$1\/$2\] /;
		$aLine =~ s/ (\d\d)\/(\d\d\d)/\ \[0$1\/$2\] /;
		$aLine =~ s/ (\d)\/(\d\d\d)/\ \[00$1\/$2\] /;

		$aLine =~ s/ (\d\d)\/(\d\d)/\ \[$1\/$2\] /;
		$aLine =~ s/ (\d)\/(\d\d)/\ \[0$1\/$2\] /;

		$aLine =~ s/ (\d)\/(\d)/\ \[$1\/$2\] /;
		# print "Added Brackets: $aLine\n";
		return ($aLine);
	}

	# Look for chapter indicators like: "3 of 5" and make it " [3/5] "
	if ( $aLine =~ /\d of \d/ ) {
		$aLine =~ s/(\d\d) of (\d\d)/ \[$1\/$2\]/g;
		$aLine =~ s/(\d) of (\d\d)/ \[0$1\/$2\]/g;
		$aLine =~ s/(\d) of (\d)/ \[$1\/$2\]/g;
		return ($aLine);
	}

	# Look for text like: "part x"
	if ( $aLine =~ /part \d/i ) {
		print "Found (part d) \n: ($aLine)\n";
		$aLine =~ s/part (\d\d\d)/ \[$1\/\?\?\?\]/gi;
		$aLine =~ s/part (\d\d)/ \[$1\/\?\?\]/gi;
		$aLine =~ s/part (\d)/ \[$1\/\?\]/gi;
		return ($aLine);
	}

	return ($aLine);
}	# S_HandleChapters

#-------------------------------------------------------------------------
# S_CleanSubject
# This routine will take both an input and output file name and write
# the input file to the output file name. When it finds a line that
# begins with "Subject:", it will attempt to reformt it and clean
# it up.
#-------------------------------------------------------------------------
#sub S_CleanSubject {
#    my ($lInFileName, $lOutFileName) = @_;
#    my ($lInLine, $lOutLine);
#
#    system "del $lOutFileName";
#
#    open (INFILE, $lInFileName) || die "Could not open $lInFileName for input\n";
#    open (OUTFILE, ">$lOutFileName");
#
#    while ( <INFILE> ) {
#        $lInLine = $_;
#        if ( index ($lInLine, "Subject:") == 0 ) {
#            # Here is the stuff we need to trim
#            print "calling funny procedure";
#            $lOutLine = &S_aTLASubjectLine($lInLine);
#
#            # print "$lOutLine\n";
#        }
#
#    }
#
#    close (INFILE);
#    close (OUTFILE);
#}   # S_CleanSubject




#-------------------------------------------------------------------------
# S_FindKeycodes
#-------------------------------------------------------------------------
sub S_FindKeycodes {
	my ($lSubjectLine) = @_;
	my ($lPosA, $lPosB);

	# Set default values
	$gKeycodes = "";

	# Look for the obvious {author}
	$lPosA = index ($lSubjectLine, "(");
	if ( $lPosA != -1 )
	{
		$lPosB = index ($lSubjectLine, ")");

		# Strip out author name

		# Remove {author} from the string

		return ($lSubjectLine);

	}

	# Look for the magic string " bye "
	$lPosA = index ($lSubjectLine, " by ");



	return ($lSubjectLine);

}	# S_FindKeycodes




#-------------------------------------------------------------------------
# S_FindAuthor
#-------------------------------------------------------------------------
sub S_FindAuthor {
	my ($lSubjectLine) = @_;
	my ($lPosA, $lPosB);

	# Set default values
	$gAuthor = "";

	# Look for the obvious {author}
	$lPosA = index ($lSubjectLine, "{");
	if ( $lPosA != -1 )
	{
		$lPosB = index ($lSubjectLine, "}");

		# Strip out author name

		# Remove {author} from the string

		return ($lSubjectLine);

	}

	# Look for the magic string " bye "
	$lPosA = index ($lSubjectLine, " by ");



	return ($lSubjectLine);

}	# S_FindAuthor

#-------------------------------------------------------------------------
# S_FindPartNum
# This routine will take a input subject line and try to parse out
# if this is Part 1 of 1 or part 2 of 25.
#
# The return values will be stored in gPartNum and gTotalParts vars.
# This routine will return the subject line with the part numbers
# removed:
#  Input:   Subject: "My Story" [1/1] {me} (mf)
#  Output:  Subject: "My Story" {me} (mf)
#
# Input:	Subject: "The tail" (mf) {adrian} part nine of twenty-nine
# Output:	Subject: "The tail" (mf) {adrian}
#
#
#-------------------------------------------------------------------------
sub S_FindPartNum {
	my ($lSubjectLine) = @_;
	my ($lNewSubjectLine);
	my ($lPosA, $lPosB);

	# Set default values
	$gPartNum = 1;
	$gTotalParts = 1;
	$lNewSubjectLine = $lSubjectLine;

	# Look for the obvious [1/1]
	$lPosA = index ($lSubjectLine, "[1/1]");
	if ( $lPosA > -1) {
		$lNewSubjectLine =~ s/\[1\/1\]//;
		return ($lNewSubjectLine);
	}



	return ($lNewSubjectLine);

}	# S_FindPartNum

#-------------------------------------------------------------------------
# S_ParseSubject
# This routine will take a input subject line and try to break it out
# into individual pieces: title, author, part number, keycodes.
# Then it creates a new subject line of the form:
# 	Subject: "title" [X/Y] {Author} (Keycodes)
#
# Returns:		Number of errors. If any are encountered, we cannot
#				create a new subject line.
#
#-------------------------------------------------------------------------
sub S_ParseSubject {
	my ($lOrigLine) = @_;

	$gErrorCount = 0;

	# Find the part numbers first. If none, it becomes [1/1]
	$lOrigLine = &S_FindPartNum ($lOrigLine);

	# Find the authors name
	$lOrigLine = &S_FindAuthor($lOrigLine);

	# Find keycodes
	$lOrigLine = &S_FindKeycodes ($lOrigLine);


}	# S_ParseSubject

#-------------------------------------------------------------------------
# S_HandleStory4Free
# We often see subject lines like:
#  Subject: [STORY4FREE] - (M/F) "A great Story"
# This routine will re-format this to our more standard form
#-------------------------------------------------------------------------
sub S_HandleStory4Free {
my ($aSubject) = @_;
my ($lTitle, $lKeyCodes);


	# Strip out the [STORY..] stuff
	$aSubject =~ s/\[STORY4FREE SITE\] - //;

	# See if there are any keycodes. Remove them if so

	$lKeyCodes = "";
	if ($aSubject =~ s/ \((.*)\)//) {
		$lKeyCodes = "($1)";
	}

	# Sometimes the title is NOT in quotes

	$lTitle = "";
	if ($aSubject =~ m/\"/) {
		# Start with the title
		$aSubject =~ m/\"(.*)\"/;
		$lTitle = $1;

	} else {
		# Handle a string like: "Subject: A Pool Orgy"
		$lTitle = $aSubject;
		$lTitle =~ s/Subject: //;
	}

	$lTitle =~ s/ .$//g;

	return ("Subject: \"$lTitle\" $lKeyCodes");
}	# S_HandleStory4Free

#-------------------------------------------------------------------------
# S_HandleSubjectStory
# This routine handles a special case where the subject line looks like one of these:
#	Subject: Story: Birthday Suprise (M/F, Trans)
#   Subject: Story: Student Bodies -- FFF/M, school
#-------------------------------------------------------------------------
sub S_HandleSubjectStory {
	my ($aSubject) = @_;
	my ($lTitle, $lKeyCodes, $lTemp);

	# Get rid of the known prefix
	$lTemp = $aSubject;
	$aSubject =~ s/Subject: Story: //i;

	# See if we have the "--" situation
	if ($aSubject =~ m/ \-\- /) {

		$aSubject =~ s/ \-\- (.*)//;
		$lKeyCodes = $1;

		#$aSubject =~ m/$(.*) \-+/;
		$lTitle = $aSubject;


		return ("Subject: \"$lTitle\" ($lKeyCodes)");
	}

	# See if we have the "-" situation
	if ($aSubject =~ m/ \- /) {

		$aSubject =~ s/ \- (.*)//;
		$lKeyCodes = $1;

		#$aSubject =~ m/$(.*) \-+/;
		$lTitle = $aSubject;


		#print "Story: \"$lTitle\" ($lKeyCodes)\n";
		#<STDIN>;
		return ("Subject: \"$lTitle\" ($lKeyCodes)");
	}




	# We sometimes see "Subject: STORY: The Stalker (horror, trans)"

	if ($aSubject =~ s/ \((.*)\)$//) {
		$lKeyCodes = $1;
		$lTitle = $aSubject;
		return ("Subject: \"$lTitle\" ($lKeyCodes)");
	}


	# If we get here, we dont know how to handle it so just return the good stuff

	#print "Dont Know: $aSubject\n";
	#<STDIN>;

	return ("$lTemp");

}	# S_HandleSubjectStory


#-------------------------------------------------------------------------
# S_CleanSubject
#
# This routine will open a input file and output file and copy all the
# rows from one to the other.
# When it finds a row begining with "Subject:", it will try to re-format
# the line so it has the form:
# 	Subject: "title" [X/Y] {Author} (Keycodes)
#-------------------------------------------------------------------------
sub S_CleanSubject {
    my ($lInFileName, $lOutFileName) = @_;
	my ($lInLine, $lOldSubject, $lNewSubject);

	system "del $lOutFileName";

    print "CleanSubject: Input/Output is: ($lInFileName / $lOutFileName)\n";

	open (INFILE, "$lInFileName")   || die "Could not open $lInFileName for input\n";
	open (OUTFILE, ">$lOutFileName") || die "could not open $lOutFileName";

	# Read every line in the input file and write it to the
	# output file. If we see a "Subject:" line header, try and
	# parse it out.

	while ( <INFILE> ) {
		$lInLine = $_;
		chop ($lInLine);

		# Remove special characters left in by word processors
		# $lInLine = &S_ScrubTextLine($lInLine);

		if ( index ($lInLine, "Subject:") == 0 ) {

                $lOldSubject = $lInLine;
                $lNewSubject = $lInLine;

				# We see a lot of lines like: "Subject: Story: My Title -- aa/bb, ff/mm"

				if ($lNewSubject =~ m/Subject: STORY: /) {
					$lNewSubject = &S_HandleSubjectStory ($lNewSubject);
				}

				# Scrub common crap from the subject line like "Re:",
				# Repost:, etc
				#

                $lNewSubject = &S_ScrubSubjectLine ($lNewSubject);

				if ($lNewSubject =~ m/STORY4FREE SITE/) {
					$lNewSubject = &S_HandleStory4Free($lNewSubject);
				}


				# Look for authors names in the begining, move it to the end
                $lNewSubject = &S_HandleAuthor($lNewSubject);

				# Look for part text "1/2" or others and put them in brackets
				#$lNewSubject = &S_HandleChapters ($lNewSubject);

			  # Try to parse out the title/author/parts/keycodes
			  # from the subject line. Then reconstruct the line
			  # using the format:
			  # Subject: "title" [x/y] {author} (keycodes)
			  #
			  # $lNewSubject = &S_ParseSubject ($lNewSubject);

			  $lNewSubject =~ s/  / /g;		# Clean extra spaces out
			  	# print "$lNewSubject\n";
				print OUTFILE "$lNewSubject\n";

               if ( ! ($lOldSubject eq $lNewSubject) ) {
                    print "OLD: $lOldSubject\n";
                    print "NEW: $lNewSubject\n\n";
					#<STDIN>;
               }

		} else {
			print OUTFILE "$lInLine\n";
		}
	}


	close (OUTFILE);
	close (INFILE);

	print "CleanSubject: Output file is ($lOutFileName)\n";

}	# S_CleanSubject

#-------------------------------------------------------------------------
# S_FixSubjectLines
#-------------------------------------------------------------------------
sub S_FixSubjectLines {
	my ($aFileName) = @_;
	my ($lInFile, $lOutFile);
	my ($lCmd);

	chdir ($gWorkingDir) or die ("Error: Could not chdir to: $gWorkingDir : $!\n");
	# See if the parent routine gave us a file name
	if ( length ($aFileName) < 1 )
	{
		# Get the input file name
		system ("cls");
		print "Ready to process files from: $gWorkingDir\n";
		printf "File Name: ";
		$lOutFile = <STDIN>;
		chop ($lOutFile);
		if ( ! -e $lOutFile ) {
			die ("Error: input file ($lOutFile) does not exist\n");
		}
	} else {
		$lOutFile = $aFileName;
	}

	if ( length ($lOutFile) > 3 ) {
		printf "Processing file ($lOutFile)\n";

		$lInFile = $lOutFile;
		$lInFile =~ s/\.txt$/\-a\.txt/
		# Make sure we don't have our temporary file already existing
		&S_EraseFile ($lInFile);
		system "rename $lOutFile $lInFile";

		# Call a routine that will read each line in the input file
		# and write it to the output file. It will look for
		# "Subject:" lines and try to clean them up.
		&S_CleanSubject ($lInFile, $lOutFile);
		print "Subject Lines fixed. (Input/Output): ($lInFile / $lOutFile)\n";

		# &S_BreakFile2 ($lOutFile);

	} else {
		printf "** NO INPUT FILE SPECIFIED **\n";
	}

	# Now make sure we did not cut our file in half
	&S_TestFileSizes ($lInFile, $lOutFile);

}	# S_FixSubjectLines


#-------------------------------------------------------------------------
# S_StripFunnyCharacters
#-------------------------------------------------------------------------
sub S_StripFunnyCharacters {
	my ($aFileName) = @_;
	my ($lInFile, $lOutFile);
	my ($lLine);
	my ($lCmd);

	# See if the parent routine gave us a file name
	if ( length ($aFileName) < 1 )
	{
		# Get the input file name
		system ("cls");
		printf "File Name: ";
		$lOutFile = <STDIN>;
		chop ($lOutFile);
	} else {
		$lOutFile = $aFileName;
	}

	if ( length ($lOutFile) > 3 ) {
		printf "Stripping word processing chars from ($lOutFile)\n";

		$lInFile = "_" . $lOutFile;
		# Make sure we don't have our temporary file already existing
		&S_EraseFile ($lInFile);
		system "rename $lOutFile $lInFile";

		# Read the input file char by char and write it to the output
		# file, stripping/replacing characters as needed.
		open (INFILE, $lInFile) or die "Cannot open $lInFile for input\n";
		open (OUTFILE, ">$lOutFile") or die "Cannot open $lOutFile for output\n";
		my ($lC, $lPos, $lFinished, $lLineCount, @a);
		$lFinished = 1;
		$lLineCount = 1;
		until ($lFinished == 0) {
		    $lLine = <INFILE>;
			# chop ($lLine);
			if ( length ($lLine) == 0 )  {
				$lLine = <INFILE>;	# get next row
				if ( length ($lLine) == 0 )
				{
					print "Found 2 zero-length input line at line ($lLineCount)\n";
					$lFinished = 0;
				}
			}

			# Look for and replace the funny characters. Print out
			# any ones that are unexpected.
			$lLine = &S_ScrubTextLine ($lLine);

			print OUTFILE "$lLine";
			$lLineCount++;
		}

		close OUTFILE;
		close INFILE;

		# Call a routine that will read each line in the input file
		# and write it to the output file. It will look for
		# "Subject:" lines and try to clean them up.


	} else {
		printf "** NO INPUT FILE SPECIFIED **\n";
	}

	# Now make sure we did not cut our file in half
	&S_TestFileSizes ($lInFile, $lOutFile);

}	# S_StripFunnyCharacters



#-------------------------------------------------------------------------
# S_SortBySubject
#-------------------------------------------------------------------------
sub S_SortBySubject {
	my ($aFileName) = @_;
	my ($lOutFile);
	my ($lCmd);

	chdir ($gWorkingDir) or die ("Error: Could not chdir to working dir: $gWorkingDir : $!\n");

	# See if the parent routine gave us a file name
	if ( length ($aFileName) < 1 )
	{
		# Get the input file name
		system ("cls");
		print "Ready to process files from: $gWorkingDir\n";
		printf "File Name: ";
		$lOutFile = <STDIN>;
		chop ($lOutFile);
		if ( ! -e $lOutFile ) {
			die ("Error: input file ($lOutFile) does not exist\n");
		}
	} else {
		$lOutFile = $aFileName;
	}

	if ( length ($lOutFile) > 3 ) {
        printf "Sorting file ($lOutFile)\n";
		$lInFile = $lOutFile;
		$lInFile =~ s/\-[a-z].txt$/.txt/;
		$lInFile =~ s/\.txt$/\-c\.txt/;
		system ("copy $lOutFile $lInFile");

		&S_BreakFile2 ($lOutFile);

	} else {
		printf "** NO INPUT FILE SPECIFIED **\n";
	}

	print "File sorted. Output file: $lOutFile\n";

}	# S_SortBySubject

#-------------------------------------------------------------------------
# S_FilterLine
# This routine will take an input line and decide if it should be
# filtered out.
# Returns:		0 - The line should be printed
#				3 - This line and the next two should be skipped
#
#-------------------------------------------------------------------------
sub S_FilterLine
{
	my ($aLine) = @_;
	my ($i);

   if ( $aLine =~ /^--$/ ) {
        return (1);
   }

   if ( $aLine =~ /^------------------------------------------------------------/ ) {
       	return 1;
   }

   if ( $aLine =~ /{-------------------------------------/ ) {
       	return 1;
   }

	# Look for a bunch of "X-<something>:"
	if ( index ($aLine, 'X-') == 0 ) {
		return (1);
	}
	# There is an array of things to look for
	foreach (@gFilterLines) {
		if ( $aLine =~ /^$_/i ) {
			return (1);
		}
	}

	# Now we look for more complicated things
	if ( $aLine =~ /^Warning\! Turns your wife\/lover into a Dominatrix./i ) {
		for ( $i = 0; $i < 4; $i++ )
		{
			$aLine = <INFILE>;	# Skip over lines
		}
		return (1);
	}

	if ( $aLine =~ /^The DOMestic discussion list has been going/i ) {
		for ( $i = 0; $i < 5; $i++ )
		{
			$aLine = <INFILE>;	# Skip over lines
		}
		return (1);
	}

	if ( $aLine =~ /^The DOMestic digest is free/i ) {
		for ( $i = 0; $i < 5; $i++ )
		{
			$aLine = <INFILE>;	# Skip over lines
		}
		return (1);
	}

    if ( $aLine =~ /Courtesy:/i ) {
        $aLine = <INFILE>;  # Skip over lines
		return (1);
	}

    if ( $aLine =~ /Pursuant to the Berne Convention,/i ) {
        while (length ($aLine) > 8) {
            $aLine = <INFILE>;  # Skip over lines
        }

		return (1);
	}


    if ( $aLine =~ /Do You Yahoo/i ) {
        while (length ($aLine) > 3) {
            $aLine = <INFILE>;  # Skip over lines
        }
		return (1);
	}

    if ( $aLine =~ /----- ASSM Moderation System Notice-/i ) {
        while (length ($aLine) > 3) {
            $aLine = <INFILE>;  # Skip over lines
        }
		return (1);
	}

    if ( $aLine =~ /Cum get hundreds more at$/i ) {
        while (length ($aLine) > 3) {
            $aLine = <INFILE>;  # Skip over lines
        }
		return (1);
	}

    if ( $aLine =~ /Hosting for these free sex stories supplied by/i ) {
        while (length ($aLine) > 3) {
            $aLine = <INFILE>;  # Skip over lines
        }
		return (1);
	}

    if ( $aLine =~ /(<1st attachment end>|<1st attachment begin>)/ ) {
		return (1);
	}


    if ( $aLine =~ /\(\)\(\)\(\)\(\)/ ) {
        while (length ($aLine) > 3) {
            $aLine = <INFILE>;  # Skip over lines
        }
		print OUTFILE "\n";
		return (1);
	}
    if ( $aLine =~ /----=/ ) {
        while (length ($aLine) > 3) {
            $aLine = <INFILE>;  # Skip over lines
        }

		return (1);
	}

	return (0);

}	# S_FilterLine


#-------------------------------------------------------------------------
# S_RemoveLines
# This routine will take an input and output file name and write the
# input to the output, removing some lines
#-------------------------------------------------------------------------
sub S_RemoveLines
{
	my ($aInFileName, $aOutFileName) = @_;
	my ($lInLine);
	my ($lSkipXLines);

	open (INFILE, "$aInFileName")   || die "Could not open $aInFileName for input\n";
	open (OUTFILE, ">$aOutFileName") || die "could not open $aOutFileName for output";

	while ( <INFILE> ) {
		$lInLine = $_;
		chop ($lInLine);


		# Call a routine to decide if we should print the current line
		# out, or skip this and the following X lines.

		$lSkipXLines = &S_FilterLine ($lInLine);
		if ( $lSkipXLines == 0 )
		{
			# Look for common bad chars and then print the line
            # $lInLine =~ s/“/"/g;
            # $lInLine =~ s/”/"/g;
            # $lInLine =~ s/’/'/g;

			$lInLine = &S_ScrubTextLine ($lInLine);

			print OUTFILE "$lInLine\n";

			if ( index ($lInLine, "Subject:") == 0 ) {
				print ".";
			}

		} else {
			$lSkipXLines--;
			while ( $lSkipXLines > 0 ) {
				$lInLine = <INFILE>;
			}
		}

	}	# while <INFILE>


	close (OUTFILE);
	close (INFILE);
	print "\n";

}	# S_RemoveLines

#-------------------------------------------------------------------------
# S_StripExtraLines
# This routine will ask for a file name and filter un-wanted Usenet
# text lines from it
#-------------------------------------------------------------------------
sub S_StripExtraLines
{
	my ($aFileName) = @_;
	my ($lInFile, $lOutFile);
	my ($lOutFile);
	my ($lCmd);

	chdir ($gWorkingDir) or die ("Error: could not cd to working dir: $gWorkingDir : $!\n");
	# See if the parent routine gave us a file name
	if ( length ($aFileName) < 1 )
	{
		# Get the input file name
		system ("cls");
		print "Ready to process file in: $gWorkingDir\n";
		printf "File Name: ";
		$lOutFile = <STDIN>;
		chop ($lOutFile);
	} else {
		$lOutFile = $aFileName;
	}

	if ( length ($lOutFile) > 3 ) {
		printf "Stripping extra lines from ($lOutFile)\n";

		# Create a unique file name for the temporary file
		$lInFile = $lOutFile;
		if ( $lInFile =~ m/\-a\.txt/ ) {
			$lInFile =~ s/\-a\.txt/\-b\.txt/;
		} else {
			$lInFile =~ s/\.txt/\-b\.txt/;
		}

		# delete any temp file that is left over
		&S_EraseFile ($lInFile);
		system ("rename $lOutFile $lInFile");

		# Call a routine that will read each line in the input file
		# and write it to the output file. It will try to remove
		# Garbage newsgroup lines

      print "In file: $lInFile, OutFile : $lOutFile\n";
		&S_RemoveLines ($lInFile, $lOutFile);
		print "Extra Lines removed. (Input/Output): ($lInFile / $lOutFile)\n";

	} else {
		printf "** NO INPUT FILE SPECIFIED **\n";
	}

	# Now make sure we did not cut our file in half
	&S_TestFileSizes ($lInFile, $lOutFile);

}	# S_StripExtraLines


#-------------------------------------------------------------------------
# S_ProcessNewFile
# This routine will ask for a file name and do 3 things to the file:
#  - Clean up the "Subject:" header lines
#  - Strip extra Newsgroup and common "garbage" lines
#  - Sort the articles by "Subject:" headers
#
#-------------------------------------------------------------------------
sub S_ProcessNewFile
{
	my ($aFileName) = @_;
	my ($lInFile);
	my ($lOut1, $lOut2, $lOut3);
	my ($lCmd);


	# See if the parent routine gave us a file name
	if ( length ($aFileName) < 1 )
	{
		# Get the input file name
		system ("cls");
		printf "File Name: ";
        $lInFile = <STDIN>;
        chop ($lInFile);
	} else {
        $lInFile = $aFileName;
	}

	if ( length ($lInFile) > 3 ) {
		printf "Processing file ($lInFile)\n";

		# IMPORTANT: We need to strip out special characters
		# that might result in a unexpected EOF in the middle
		# of the file in any of the other routines.

	    &S_StripFunnyCharacters($lInFile);

		# Call a routine that will read each line in the input file
		# and write it to the output file. It will look for
		# "Subject:" lines and try to clean them up.
		&S_FixSubjectLines($lInFile);


		# Call a routine that will read each line in the input file
		# And strip out funny newsgroup lines.
		&S_StripExtraLines ($lInFile)

		# Finally, sort the entire text file by the Subject header
		&S_SortBySubject ($lInFile);

	} else {
		printf "** NO INPUT FILE SPECIFIED **\n";
	}


}	# S_ProcessNewFile



#-------------------------------------------------------------------------
#-------------------------------------------------------------------------
sub S_CreateSubjectFile {
	my ($aFile) = @_;
	my ($lRow);
	if ( ! -e $aFile ) {
		print "Error: Input file does not exist: $aFile\n";
		return;
	}

	chdir ($gWorkingDir) or die ("Error: Could not cd to working dir: $gWorkingDir\n");
	open (OUT_FILE, ">subject.txt") or die ("$!");
	open (IN_FILE, $aFile) or die ("$!");
	while ( $lRow = <IN_FILE> ) {
		if ( index ($lRow, 'Subject: ') == 0 ) {
			print OUT_FILE $lRow;
		}
	}
	close (IN_FILE);
	close (OUT_FILE);
	print "Subject file created: subject.txt";


}	# S_CreateSubjectFile

#-------------------------------------------------------------------------
#-------------------------------------------------------------------------

sub S_TestSUClean {
	my ($aFile) = @_;
	my ($lOrigLine, $lNewLine, $lNewLine2);

	if ( ! -e $aFile ) {
		die ("Error: Subject file does not exist: $aFile\n");
	}

	print "Testing subject clean starting\n";

	open (IN_FILE, $aFile) or die ("$!\n");
	while ( $lOrigLine = <IN_FILE> ) {
		$lNewLine = &S_ScrubSubjectLine ($lOrigLine);
		$lNewLine2 = $lNewLine;

		# Look for "part 2"
		$lNewLine2 =~ s/part (\d+) of (\d+)/ \[$1\/$2\] /gi;
		$lNewLine2 =~ s/part (\d)\s/ \[0$1\/\?\?\] /gi;
		$lNewLine2 =~ s/part (\d+)\s/ \[$1\/\?\?\] /gi;

		# Look for " 1/4 " and put brackets around it
		$lNewLine2 =~ s/ (\d+\/\d+) / \[$1\] /g;
		$lNewLine2 =~ s/ \((\d+\/\d+\)) / \[$1\] /g;	# Handle (1/2)


		# Look for [3/30] and promote to [03/30]
		if ( $lNewLine2 ne $lNewLine ) {
			print "$lNewLine\n$lNewLine2\n\n";
			<STDIN>;
		}
	}
	close (IN_FILE);
}
# S_TestSUClean

#-------------------------------------------------------------------------
# PrintMenu2 - Prints the menu
#-------------------------------------------------------------------------
sub PrintMenu2 {

    print "=============================================\n";
    print "              Main Menu\n";
    print "             HTML Utilitys\n";
    print "=============================================\n";
    print "Please choose an option:\n\n";
    print "\t1 - Clean up Subject headers\n";
    print "\t2 - Strip lines from file\n";
    print "\t3 - Sort a file by SUBJECT headings\n";
    print "\t4 - Do everything \n";
    print "\t5 - Analyze format\n";
    print "\t6 - Strip funny characters\n";
    print "\t7 - Sort files into A00, B00, etc\n";
    print "\t8 - \n";
    print "\t9 - Re-Sort existing file\n";
    print "\t10 - Create subject.txt file\n";
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

    my ($l_finished) = 0;
    my ($l_choice) = 0;

    while ( $l_finished == 0) {
        &PrintMenu2 ();

        chop ($l_choice = <STDIN>);

        if ( ($l_choice > 0) && ($l_choice < 15) ) {
            $l_finished = 1;
        }
    }
    $l_choice;

} # GetChoice


#----------------------------------------------------------
#  Main
#----------------------------------------------------------
sub main {

	print "There are ($#ARGV) arguments\n";
	if ( $ARGV[0] != undef ) { print "Arg 1 = $ARGV[0]\n";}
	if ( $ARGV[1] != undef ) { print "Arg 2 = $ARGV[1]\n";}
	if ( $ARGV[2] != undef ) { print "Arg 3 = $ARGV[2]\n";}

	# &S_BreakFile2 ("s.txt");



#	while ( <> )
#	{
#		print "($_) \n";
#	}

    my ($l_finished) = 0;

    while ( ! $l_finished )
    {
        $g_choice = &GetChoice();

        if ( $g_choice == 1 )
        {
            $l_finished = 1;
			&S_FixSubjectLines("");

        } elsif ( $g_choice == 2 ) {

            $l_finished = 1;
            &S_StripExtraLines("");

        } elsif ( $g_choice == 3 ) {
            $l_finished = 1;
			&S_SortBySubject ("");
        } elsif ( $g_choice == 4 ) {
            &S_ProcessNewFile ('');
            $l_finished = 1;
        } elsif ( $g_choice == 5 ) {
			&S_AnalyzeFormat ();
            $l_finished = 1;
        } elsif ( $g_choice == 6 ) {
			&S_StripFunnyCharacters("");
            $l_finished = 1;
        } elsif ( $g_choice == 7 ) {
            &S_SortTextStories();
            $l_finished = 1;
        } elsif ( $g_choice == 8 ) {
            $l_finished = 1;
        } elsif ( $g_choice == 9 ) {
            &S_ResortExistingFile ();
            $l_finished = 1;
        } elsif ( $g_choice == 10 ) {
			&S_CreateSubjectFile ( "d:\\temp\\ASSTR\\01-Raw\\1998b-b.txt" );
            $l_finished = 1;
        } elsif ( $g_choice == 11 ) {
			&S_TestSUClean( "d:\\temp\\ASSTR\\01-Raw\\1998b-b.txt");
        }
    }


}

# End of main

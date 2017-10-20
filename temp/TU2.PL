# File: TU2.pl
# use String::CRC32;
#use Text::Wrapper;
require "asstr_para.pl";

$| = 1; # Print Immediatly


#####################
# Constants Section #
#####################

$gDIVIDER = "\n\{-----------------------------------------------------------------------\}\n\n";

# When we put a CRC32 value as a header, this is the header prefix

$gSTORY_CRC_HEADER  = "TEXT-CRC:";

# This is how many characters we want to pull for the start and end CRC

$gCHAR_COUNT_CRC    = 256;

# This is how many blank-rows we allow in an article

$gBLANK_ROW_LIMIT   = 1;

# This is a limit on how many lines of garbage text to delete in a single
# block. This is in case a garbage footer has no line-breaks between
# it and the text.

$gMAX_GARBAGE_BLOCK = 12;

# Controls printing deleted sections of text to the screen

$gPRINT_DELETED_TEXT = 0;

# This defines how long a uuencoded line "Mxxxxxxxx" is

$gUUENCODE_LINE_LENGTH  = 61;

# This defines the size limit on a uuencode file before we decide to
# create a new "002.uue" file name.

$gUUENCODE_MAX_SIZE     = (1024 * 5000);

# This defines the standard extension for files that this
# code looks for

$gFEXT              = ".txt";

#----------------------------------
# Paragraph Analysis constants
#----------------------------------

# This defines how many Alpha characters (A-Z, 0-9) a row must have
# to qualify as a legitimate text row.

$gPA_MIN_CHAR_COUNT         = 15;

# This defines the default-indent value that makes us suspicious that
# a line of text is Poetry/Header and not article text

$gPA_POETRY_INDENT          = 25;

# If a article has indents, we should use it to "guess" the poetry
# indent limit. This value is multiplied against the average indent
# to give us a more specific POETRY_INDENT.

$gPA_POETRY_INDENT_FACTOR   = 4;

# This defines our standard indent of spaces we want to use when
# reformatting text

$gSTD_INDENT                = "    ";

##################
# Global Section #
##################

# A global text array to hold the contents of 1 newsgroup article

@gText = ();

# A global counter to tell us how big the gText array is

$gGTextSize     = -1;

# A global variable that tells us what the average indention is
# for the text in the body of gText. See the S_AnalyzeIndent()
# routine for details.

$gAverageIndent = 0;

$gWORKING_DIR       = "D:\\temp\\ASSTR\\01-Raw";            # Where to read new files from

$gTEMP_FILE         = "$gWORKING_DIR\\temp.out";

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
    "Centaur",
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
    "Dulcinea",
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
    "Katie McN",
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


# This is a list of Garbage lines. If found, all the rows around these
# lines will be deleted

    @gGarbage = (
        "-- ASSM Moderation System Notice--",
        "Cum get hundreds more at",
        "Cum get thousands more at",
        "Do You Love Celeb Fakes?",
        "Do You Love to read about sex?",
        "Do You Yahoo",
        "Get 250 business cards for free",
        "Get Your Private, Free E-mail from MSN",
        "Get your FREE download of MSN Explorer",
        "HTML removed pursuant to http",
        "Posted Via News.HornyRob.Com",
        "Posted Via Uncensored-News",
        "Pursuant to the Berne Convention,",
        "Remember - You can get into more FREE",
        "Remember - You can get access to more",
        "Sign up for FREE PRIVATE UNMONITORED email",
        "The Fem Dom Training Software. Runs on all computers",
        "The DOMestic digest is free of charge.",
        "--' Story submission `-+-",
        "--=_NextPart_000"
        );


# The ARCHIVE.CRC file is everything burned onto a CD
# The RECENT.CRC file is everything kept on the hard drive, but not on a CD yet
# The SPAM.CRC file is all spam

$gARCHIVE_FILE      = $gCRC_DIR . "\\archive.crc";

$gVERBOSE = 1;
$gDEBUG   = 0;

$gIS_WIN_NT = 1;

&main();
exit (0);

#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
sub  S_FixKristenFile {
	my (%args) = @_;
	my ($lFile, $lTempFile, $lRow);
	my (@lBuffer, $lRowNum);
	my ($lRN_Subject, $lRN_ArchiveName, $lRN_AuthorsName, $lRN_StoryTitle);
	my ($lTitle, $lAuthor, $lKeywords, $lPart1, $lPart2, $lTemp);

	chdir ($args{path}) or die ("Error: Could not cd to : $args{path} : $!\n");
	$lFile = $args{file};
	if ( ! -e $lFile ) {
		die ("Error: Txt file does not exist: $lFile\n");
	}

	print "Fixing Kristen file: $lFile ...\n";
	$lTempFile = 'kristen_temp.txt';
	open (OUT_FILE, ">$lTempFile") or die ("Error: Could not open file for output: $lTempFile : $!\n");
	open (IN_FILE, $lFile) or die ("Error: Could not open file for input: $lFile : $!\n");
	$lRow = <IN_FILE>;
	($lRowNum, $lRN_Subject, $lRN_ArchiveName, $lRN_AuthorsName, $lRN_StoryTitle) = (0, -1, -1, -1, -1);
	($lPart1, $lPart2) = (1,1);
	while ( $lRow = <IN_FILE> ) {

		push (@lBuffer, $lRow);

		if ( index ($lRow, 'Subject:') == 0 ) {
			$lRN_Subject = $lRowNum;
		}

		if ( index ($lRow, 'Archive name:') > -1 ) {
			$lRN_ArchiveName = $lRowNum;
		}
		if ( index ($lRow, 'Authors name:') > -1 ) {
			$lRN_AuthorsName = $lRowNum;
		}

		if ( index ($lRow, 'Story title') > -1 ) {
			$lRN_StoryTitle = $lRowNum;
		}
		if ( index ($lRow, 'Archive title:') > -1 ) {
			$lRN_StoryTitle = $lRowNum;
		}


		# Read in the rows until we see "{--------------------"
		if ( index ($lRow, '{------------------------------') == 0 ) {
			print "Found end. Row $lRowNum\n";

			($lTitle, $lAuthor, $lKeywords) = ("", "", "");

			# Extract the title like: Story title : Drunk Wife at Concert
			if ( $lRN_StoryTitle > 0 ) {
				my ($a, $b) = split (':', $lBuffer[$lRN_StoryTitle]);
				chomp ($b);
				$b =~ s/^\s+//;
				$b =~ s/\s+$//;
				$b =~ s/\"//g;
				$lTitle = $b;

				# Remove "Chapter N of M"
				$lTitle =~ s/chapter \d+ of \d+//i;
				$lTitle =~ s/part \d+ of \d+//i;
				$lTitle =~ s/\s+\-\s+//;

			}

			# Authors name : by nonono69 (nonono69@hotmail.com)
			if ( $lRN_AuthorsName > 0 ) {
				my ($a, $b) = split (':', $lBuffer[$lRN_AuthorsName]);
				chomp ($b);
				# Remove the email address in perens if found
				if ( index ($b, '(') > -1 ) {
					$b = substr ($b, 0, index ($b, '('));
				}
				$b =~ s/^\s+//;
				$b =~ s/\s+$//;
				# Remove by .. if it exists
				$b =~ s/by\s+//i;
				$lAuthor = $b;
			}

			# See if we see Chapter 4 of 13 for parts
			if ( $lRN_StoryTitle > 0 ) {
				$lTemp = $lBuffer[$lRN_StoryTitle];
				if ( $lTemp =~ m/chapter (\d+) of (\d+)/i ) {
					($lPart1, $lPart2) = ($1, $2);
					if ( $lPart2 > 10 ) {
						$lPart1 = sprintf ("%02d", $lPart1);
					}
				} elsif ($lTemp =~ m/part (\d+) of (\d+)/i) {
					($lPart1, $lPart2) = ($1, $2);
					if ( $lPart2 > 10 ) {
						$lPart1 = sprintf ("%02d", $lPart1);
					}
				} elsif ($lTemp =~ m/\- (\d+)/) {
					$lPart1 = $1;
					$lPart2 = '?';
				}
			}

			# Look for story codes like: Archive name: 1959.txt (MF, cons) or
			#
			if ( $lRN_ArchiveName > 0 ) {
				$lTemp = $lBuffer[$lRN_ArchiveName];
				if ( $lTemp =~ m/\((.*)\)/ ) {
					$lKeywords = $1;
				}
			}
			if ( $lKeywords eq "" and $lRN_StoryTitle > 0 ) {
				$lTemp = $lBuffer[$lRN_StoryTitle];
				if ( $lTemp =~ m/\((.*)\)/ ) {
					$lKeywords = $1;
				}
			}



			if ( $lRN_AuthorsName > 0 and $lRN_StoryTitle > 0) {
				#print "Subject: $lBuffer[$lRN_Subject]";
				my $lSubject = "Subject: \"$lTitle\" [$lPart1/$lPart2] \{$lAuthor\} ($lKeywords)";
				$lBuffer[$lRN_Subject] = "$lSubject\n";
				print OUT_FILE join ('', @lBuffer);
				#print "Subject:     $lSubject\n";
				#print "\tTitle:     $lTitle\n";
				#print "\tParts:     [$lPart1/$lPart2]\n";
				#print "\tKeywords:  {$lKeywords}\n" if (length ($lKeywords) > 1);
				#print "\tArchive:   $lBuffer[$lRN_ArchiveName]" if ($lRN_ArchiveName > 0);
				#print "\tAutor:     $lAuthor\n";
			}


			# Reset our counters for the next block

			@lBuffer = ();
			($lRowNum, $lRN_Subject, $lRN_ArchiveName, $lRN_AuthorsName, $lRN_StoryTitle) = (0, -1, -1, -1, -1);
			($lPart1, $lPart2) = (1,1);
		} else {
			$lRowNum++;
		}



	}

	# Need to take care of the last story
	if ( $lRN_AuthorsName > 0 and $lRN_StoryTitle > 0) {
		#print "Subject: $lBuffer[$lRN_Subject]";
		my $lSubject = "Subject: \"$lTitle\" [$lPart1/$lPart2] \{$lAuthor\} ($lKeywords)";
		$lBuffer[$lRN_Subject] = "$lSubject\n";
		print OUT_FILE join ('', @lBuffer);
		#print "Subject:     $lSubject\n";
		#print "\tTitle:     $lTitle\n";
		#print "\tParts:     [$lPart1/$lPart2]\n";
		#print "\tKeywords:  {$lKeywords}\n" if (length ($lKeywords) > 1);
		#print "\tArchive:   $lBuffer[$lRN_ArchiveName]" if ($lRN_ArchiveName > 0);
		#print "\tAutor:     $lAuthor\n";
	}



	close (OUT_FILE);
	close (IN_FILE);

	print "Output file created: $lTempFile\n";
}	# S_FixKristenFile

#---------------------------------------------------------------------------
# Routine:      FillGTextArray
# Description:  This routine will take a file-name argument and read the
#               rows of the text file into the global array gText.
#               The array of text is later used for analysis or to strip
#               out garbage headers/footers/etc.
#
#               Note: Each row is CHOMPED to remove the CR/LF at the end.
#
# Input:        aFileName - full path name to a text/story file
#
# Output:       @gText - filled with the rows from the file
#
# Returns:      0 - Success, 1 - errors
#
#---------------------------------------------------------------------------
sub FillGTextArray {
    local ($aFileName) = @_;
    local ($lRow, $lRowCount);
    local ($lTemp);

    @gText = ();        # Initialize the global array

    if ( ! (-e $aFileName) ) {
        print "FGT: Error - file ($aFileName) does not exist\n";
    }

    open (GTEXT, "$aFileName") || die ("Error - FGT - Cannot open ($aFileName) for input\n");
    $lRowCount = 0;
    while ( <GTEXT> ) {
        $lRow = $_;
        chomp ($lRow);

        # Special: Sometimes the rows end in "=" signs so we need to
        # append the following row onto this one. but we dont want do
        # do this if we are in the middle of uuencoded text so look for
        # the row to start with a capitol M.

        if ($lRow =~ m/[A-Za-z\"\.\'\,] *=$/) {
            chomp ($lRow);
        }

        while ($lRow =~ m/[A-Za-z\"\.\'\,] *=$/ &&
               ! ($lRow =~ m/^M/)) {
            $lTemp = <GTEXT>;
            chomp ($lTemp);
            $lRow =~ s/=$/$lTemp/;
        }

        push (@gText, $lRow);
        $lRowCount++;
    }

    close (GTEXT);

    # Update the globals so everyone knows how big the array is

    $gGTextSize = $#gText;


    return (0);

}   # FillGTextArray

#---------------------------------------------------------------------------
# Routine:      ScrubGTextEquals
# Description:  This routine will look for lines of text ending in "="
#               or "=20" and handle it.
#---------------------------------------------------------------------------
sub ScrubGTextEquals {

    local ($lFoundEquals, $lBuffer, $lEqualCount, $lFirstEqual);
    local ($i, $lSize);
    local ($lSubjectRow) = -1;
    local ($lBuf);

    $lFirstEqual = -1;
    $lFoundEquals = 0;
    $lSize = $#gText;

    $lEqualCount = 0;
    for ( $i = 0; $i < $lSize; $i++ ) {

        if ( $gText[$i] =~ m/^Subject\: / ) {
            $lSubjectRow = $i;
        }

        if ( $gText[$i] =~ m/[a-z] \=$/ ) {
            $lEqualCount++;
            if ( $lFirstEqual == -1 ) {
                $lFirstEqual = $i;
            }
        }
    }


    if ( $lEqualCount < 15 ) {
        return;
    }

    print "Found lots of ending = signs: " . substr ($gText[$lSubjectRow], 9, 50) . "\n";

    # Put all the text into a single buffer

    $lBuf = ();
    for ( $i = $lFirstEqual; $i < $lSize; $i++ ) {
        $lBuf .= $gText[$i] . "\n";
    }

    # Get rid of ending " =20" characters
    $lBuf =~ s/ ?\=20\n/\n/g;


    # Now get rid of parts of rows ending in " ="

    $lBuf =~ s/ \=\n+/ /g;

    # look for "rather\nthe new guys"
    $lBuf =~ s/([a-z])\n+([a-z])/$1 $2/g;


    print "$lBuf\n";

}   # ScrubGTextEquals

#---------------------------------------------------------------------------
# Routine:      ScrubGTextDeHyphen
#---------------------------------------------------------------------------
sub ScrubGTextDeHyphen {
    local ($i, $j);
    local ($lSize) = $#gText;
    local ($lChoice);
    local ($lLast, $lFirst);


    # For testing/development
    for ( $i = 0; $i <= $lSize; $i++ ) {
        if ( $gText[$i] =~ m/[a-z]+\-$/ ) {
            $lLast = $gText[$i];
            #print "1:$lLast\n";
            $lLast =~ s/.* (\w+\-)$/$1/;    # Save the last word and "-"
            #print "2:$lLast\n";

            # The first word of the next line is sometimes 2 rows away
            $j = $i + 1;
            $lFirst = $gText[$j];
            while ( length ($lFirst) < 2 ) {
                $lFirst = $gText[$j++];
            }

            #print "3:$lFirst\n";
            $lFirst =~ s/^(\w+).*/$1/;
            #print "4:$lFirst\n";

            print "a-Keep Hyphen, x-Join\n";
            print "$lLast\n";
            print "$lFirst\n";

            #print "$gText[$i]\n";
            #print "$gText[$i + 1]\n";
            #print "$gText[$i + 2]\n";
            print "\n-------------------------------\n";
            $lChoice = getc;
            chomp ($lChoice);
        }

    }


}   # ScrubGTextDeHyphen

#---------------------------------------------------------------------------
# Routine:      GetUUEFileName
# Description:  This routine will return a file name like "001.uue" or
#               "002.uue". It does this by seeing how big the existing
#               uue file is and creating a new file name if the existing
#               files are too big.
#
# Input:        (none)
#
# Returns:      Full path name to a uue file: "C:\temp\003.uue" to contain
#               the next uuencoded section.
#
#---------------------------------------------------------------------------
sub GetUUEFileName {
    local (@lFileList) = glob ("$gWORKING_DIR\\*.uue");
    local ($lFileName) = "$gWORKING_DIR\\001.uue";  # First-time
    local ($lFileSize);
    local ($lCount);


    $lCount = 1;
    while ( 1 ) {
        $lFileName = sprintf ("%s\\%03d\.uue", $gWORKING_DIR, $lCount);
        if ( -e $lFileName  ) {
            $lFileSize = -s $lFileName;
            if ( $lFileSize < $gUUENCODE_MAX_SIZE ) {
                return ($lFileName);
            }
        } else {
            print "Creating new UUE file: $lFileName\n";
            return ($lFileName);
        }

        $lCount++;
    }

}   # GetUUEFileName

#---------------------------------------------------------------------------
# Routine:      ScrubGTextHandleUUE
# Description:  This routine will examine the current contents of the gText
#               array and try to determine if it contains UUENCODED rows.
#               If so, it should be written out to a different file with
#               a "UUE" extension instead of a .txt file
#
#               Note: Some articles are ALL uuencoded text. Others are
#               text with some embeded uuencoding. This routine will simply
#               write uuencoded rows to a "001.uue" file and blank these
#               rows from the gText array.
# Input:        (none)
#
#---------------------------------------------------------------------------
sub ScrubGTextHandleUUE {
    local ($lResult) = 0;       # Default return
    local ($lSize) = $#gText;
    local ($lRow);
    local ($lSubjectRow) = "";
    local ($lStart) = -1;
    local ($lEnd) = -1;
    local ($lStartCount) = 0;
    local ($lEndCount) = 0;
    local ($lFileName);
    local ($i);
    local ($lTemp1, $lTemp2);

    # Go through the rows looking for "begin 666" and "end" combinations
    # Note where the "Subject:" row is as well

    for ( $i = 0; $i < $lSize; $i++) {
        if ( $gText[$i] =~ m/^Subject: /) {
            $lSubjectRow = $i;
        }

        if ( $gText[$i] =~ m/^begin [644|666|755]/ ) {
            $lStartCount++;

            # We only want to capture the first "begin 666" in the text

            if ( $lStart == -1 ) {
                $lStart = $i;
            }
        }

        if ( $gText[$i] =~ m/^end$/ ) {
            $lEndCount++;
            $lEnd = $i;
        }
    }

    # Decide: does the article contain uuencoded stuff

    if ( $lStartCount == $lEndCount && $lStartCount > 0 ) {

        # We want the write the UUENCODED rows to a external file and blank
        # the rows in the gText array.

        print "Found UUEncoded article: " . substr ($gText[$lSubjectRow], 9, 50) . "\n";
        $lFileName = &GetUUEFileName();
        open (UUEFILE, ">>$lFileName") || die ("HUUE: Error - could not open ($lFileName) for appending\n");
        for ( $i = $lStart; $i <= $lEnd; $i++ ) {

            # Special: look for "begin 644 xxx yy zz" and convert the spaces
            # to underscore characters. We want to avoid spaces in the
            # file names.

            #if ( $gText[$i] =~ m/begin [644|666]/ ) {
            #    $gText[$i] =~ m/(begin \d+) (.*)/;
            #    $lTemp1 = $1;
            #    $lTemp2 = $2;
            #    print "Temp1 ($lTemp1) - Temp2 ($lTemp2)\n";
            #    $lTemp2 =~ s/ +/_/g;
            #    $gText[$i] = "$lTemp1 $lTemp2";
            #}

            print UUEFILE "$gText[$i]\n";
            $gText[$i] = "";
        }
        print UUEFILE "\n\n";   # Just some extra padding
        close (UUEFILE);
    }
    return ($lResult);

}   # ScrubGTextHandleUUE

#---------------------------------------------------------------------------
# Routine:      ScrubGTextRoller
# Description:  A lot of Andrew Roller's text have a huge footer that
#               needs to be stripped off, and his indents for his
#               paragraphs have to be shortened. This routine tries to
#               identify a Roller posting and clean it up
#
#---------------------------------------------------------------------------
sub ScrubGTextRoller {
    local ($lFoundRoller) = -1;
    local ($lSize, $lStart, $lEnd);

    $lSize = $#gText;
    $lStart = -1;
    $lEnd = -1;

    # Start at the bottom and work back
    for ( $lEnd = $lSize; $lEnd > 0; $lEnd-- ) {
        if ( $gText[$lEnd] =~ m/Great art books by David Hamilton / ||
             $gText[$lEnd] =~ m/Great books by David Hamilton: /    ||
             $gText[$lEnd] =~ m/END of story EMISSION/i             ||
             $gText[$lEnd] =~ m/When visiting Barnes and Noble/i
        ) {
            $lFoundRoller = $lEnd;
            last;
        }
    }

    if ( $lFoundRoller > 0 ) {

        # Search back from where we found the text for a "30" on a line by itself
        # or "------ Dreamgirls".
        # This marks the begining of the footer we want to delete

        for ( $lStart = $lFoundRoller; $lStart > 0; $lStart-- ) {
            if ( $gText[$lStart] =~ m/^30$/ || $gText[$lStart] =~ m/\-+ Dreamgirls/ ) {
                last;
            }
        }
        if ( $lStart > 0  && $gText[$lStart] =~ m/^30$/) {
            $lStart++;      # Move 1 line down from the "30" so it stays
        }

        # Search forward from where we found the text for a blank line

        for ( $lEnd = $lFoundRoller; $lEnd < $lSize; $lEnd++ ) {
            if ( length ($gText[$lEnd]) == 0 ) {
                last;
            }
        }

        # Delete the text if start and end look reasionable

        if ( $lStart != -1 && $lEnd != -1 && $lStart < $lEnd ) {

            if ( $gPRINT_DELETED_TEXT > 0 ) {
                print "Deleting Roller footer of (" . $lEnd - $lStart . ") rows\n";
                print "--------------------------------------------\n";
            }

            for ( ; $lStart < $lEnd; $lStart++ ) {
                print "X : " . substr ($gText[$lStart], 0, 55) . "\n" if ($gPRINT_DELETED_TEXT > 0);
                $gText[$lStart] = "";
            }
            print "--------------------------------------------\n" if  ($gPRINT_DELETED_TEXT > 0);
        }

    }

    # Excessive indents

    if ( $lFoundRoller > 0 ) {

        # Search from the top of the text for the word "Chapter". After
        # this row, take every row and re-indent with 4 spaces if it
        # starts with more than 4 spaces

        $lStart = -1;
        for ( $lStart = 0; $lStart < $lSize; $lStart++ ) {
            if ( $gText[$lStart] =~ m/ +Chapter/ ) {
                $lStart++;
                last;
            }
        }

        # This will reduce the spaces and add extra carriage returns. But
        # only if the spaces go from 2-20. This way we dont mess up
        # headers if the article contains mulitple sections.

        for ( ; $lStart < $lSize; $lStart++ ) {
            $gText[$lStart] =~ s/^ {2,20}/\n    /;
        }
    }


}   # ScrubGTextRoller

#---------------------------------------------------------------------------
# Routine:      ScrubGTextHTML
# Description:  This routine will look for the key strings like <HTML>
#               and </HTML> in gText and blank all rows between these 2
#
#---------------------------------------------------------------------------
sub ScrubGTextHTML {
    local ($lSize, $lStart, $lEnd);

    $lSize = $#gText;

    # If we find "DOCTYPE HTML" grab the row number. IF we find </HTML>
    # Grab this row number. At the end, decide if we can blank out
    # all the rows between.

    $lStart = -1;
    $lEnd = -1;
    for ( $i = 0; $i < $lSize; $i++ ) {
        if ( $gText[$i] =~ m/\<\!DOCTYPE HTML PUBLIC / ) {
            $lStart = $i;
        }

        if ( $gText[$i] =~ m/\<\/HTML\>/ ) {
            $lEnd = $i;
        }
    }

    # Did we find it?
    if ( $lStart != -1 && $lEnd != -1 && $lStart < $lEnd ) {
        print "Stripping HTML:\n" if ($gPRINT_DELETED_TEXT > 0);
        for ( ; $lStart <= $lEnd; $lStart++ ) {
            $gText[$lStart] = "";
        }
    }


}   # ScrubGTextHTML

#---------------------------------------------------------------------------
# Routine:      ScrubGTextCompress
# Description:  This routine will get rid of multiple blank-lines from
#               the rows of text in the global array gText. It is used
#               near the end of the scrub process because it WILL change
#               what rows various things are on
#---------------------------------------------------------------------------
sub ScrubGTextCompress {
    local ($lSize, @lMyArray, $lBlankCount);

    #
    # Compress out blank lines from gText
    #

    $lSize = $#gText;
    @lMyArray = ();
    $lBlankCount = 0;

    for ( $i = 0; $i < $lSize; $i++ ) {

        # Simply move rows from gText to MyArray

        if ( length ($gText[$i]) == 0 ) {
            $lBlankCount++;
        } else {
            $lBlankCount = 0;
        }

        if ( $lBlankCount <= $gBLANK_ROW_LIMIT ) {
            push (@lMyArray, $gText[$i]);
        }
    }

    # Copy the compressed rows back to gText

    @gText = @lMyArray;

    # Update the globals

    $gGTextSize = $#gText;

}   # ScrubGTextCompress

#---------------------------------------------------------------------------
# Routine:      ScrubGText
# Description:  The gText array holds rows from newsgroup articles. These
#               often contain lots of header/footer garbage. This routine
#               will go through the current contents of gText and try
#               to scrub out garbage rows by setting these rows to "". At
#               the end, multiple-blank lines will be removed (so that gText
#               will shrink in size.) This might mess up row-pointers.
#
# Input:        (none)
#
# Output:       gText - cleaned up a bit
#
#---------------------------------------------------------------------------
sub ScrubGText {
    local (@lMyArray) = ();
    local ($i, $lSize, $lBlankCount);
    local ($lTarget);
    local ($lStart, $lEnd);

    # Take the list of known garbage lines and run through the gText array
    # to see if they exist. If found, search back for the previous blank
    # line, then forward for the next and blank out all the rows between.
    $lSize = $#gText;

    foreach $lTarget (@gGarbage) {
        for ( $i = 0; $i < $lSize; $i++ ) {
            if ( $gText[$i] =~ m/$lTarget/i ) {

                # Found one. Look for the previous blank line

                $lStart = $i;
                while ( $lStart > 0 && length ($gText[$lStart]) > 0 ) {
                    $lStart--;
                }

                # Look for the next blank line

                $lEnd = $i;
                while ( $lEnd < $lSize && length ($gText[$lEnd]) > 0 ) {
                    $lEnd++;
                }

                # Sanity check: sometimes a garbage block is butt-up
                # against real text. So make sure we only have a
                # block of about 10 lines before we go deleting things
                if ( ($lEnd - $lStart) < $gMAX_GARBAGE_BLOCK ) {
                    print "-----------------------------------\n" if ($gPRINT_DELETED_TEXT > 0);
                    print "Deleting the following text: ($lTarget)\n" if ($gPRINT_DELETED_TEXT > 0);
                    for ( ; $lStart < $lEnd; $lStart++ ) {
                        print "X : " . substr ($gText[$lStart], 0, 55) . "\n" if ($gPRINT_DELETED_TEXT > 0);
                        $gText[$lStart] = "";
                    }
                    print "-----------------------------------\n\n" if ($gPRINT_DELETED_TEXT > 0);
                }
            }
        }
    }


    # Call a routine that will tell us if the article is uuencoded text and
    # should be written to a different file.


    &ScrubGTextHandleUUE ();

    # Call a routine that will look for imbeded HTML page and strip this
    # stuff out.

    &ScrubGTextHTML ();

    # Call a routine that will look for one of Andrew Roller's little
    # tomes and clean it up

    &ScrubGTextRoller ();

    # Call a routine that will remove multiple blank-lines left by the
    # prevous processes

    &ScrubGTextCompress ();

    # Call a routine that will de-hyphenate short lines of text

    # &ScrubGTextDeHyphen ();

    # Try and handle lines ending in "=" or "=20"

    ## Does not work yet
    #&ScrubGTextEquals();

}   # ScrubGText


#---------------------------------------------------------------------------
# Routine:      S_PrintParaStats
# Description:  This routine will print the paragraph starting row numbers,
#               the gross length, and the compressed length.
#
#---------------------------------------------------------------------------
sub S_PrintParaStats {
    local (@lPara) = @_;
    local ($lStart) = -1;
    local (@lRowSize) = ();
    local (@lCompressedSize) = ();
    local (@lParaSize) = ();
    local ($lRow, $lText, $lSize);
    local ($lPrintCount, $lMsg, $i);
    local ($lParaCount) = $#lPara;
    local ($lStart, $lEnd);
    local ($lPrintLimit) = 14;
    local ($lWidth) = 56;

    foreach $lRow (@lPara) {
        $lText = $gText[$lRow];

        # Get the gross length of the first row
        $lSize = length ($lText);
        push (@lRowSize, $lSize);

        # Get the compressed size by stripping non-alpha chars
        $lText = uc ($lText);
        $lText =~ s/[^A-Z0-9]//g;
        $lSize = length ($lText);

        push (@lCompressedSize, $lSize);
    }

    # Now add up all the chars in the entire paragraph
    for ($i = 0; $i < $lParaCount; $i++) {
        $lStart = $lPara[$i];           # Starting Row index
        if ($i == $lParaCount) {
            $lEnd = $#gText;    # Use the last row of the text
        } else {
            $lEnd   = $lPara[$i + 1] - 1;   # Ending row index 1 above next paragraph
        }
        $lMsg = "";
        while ($lStart <= $lEnd) {
            $lMsg .= uc ($gText[$lStart]);
            $lStart++;
        }

        # lMsg now has all the rows of the paragraph in 1 row
        $lMsg =~ s/[^A-Z0-9]//g;
        $lSize = length ($lMsg);
        push (@lParaSize, $lSize);
    }


    # Printing Section

    print "-----------------------------------\n\n";
    $lPrintCount = 0;
    while ($lPrintCount < $lPrintLimit && $lPrintCount < $#lPara) {

        $lMsg = sprintf ("P-%02d \| (%02d/%02d/%3d): %s",
            $lPrintCount,
            $lRowSize[$lPrintCount],
            $lCompressedSize[$lPrintCount],
            $lParaSize[$lPrintCount],
            substr ($gText[$lPara[$lPrintCount]], 0, $lWidth));

        print "$lMsg\n";
        $lPrintCount++;
    }

    return ($lStart);

}   # S_PrintParaStats


#---------------------------------------------------------------------------
# Routine:      S_GuessStartParacount
# Description:  This routine will try and guess the starting row of text
#               based on the number of paragraphs found.
#
#---------------------------------------------------------------------------
sub S_GuessStartParaCount {
    local (@lPara) = @_;



    return ($lStart);

}   # S_GuessStartParaCount

#---------------------------------------------------------------------------
# Routine:      IsTextRow
# Description:  This routine will take a row of text and return 1 if the
#               row appears to contain legitmate text. This is to help
#               the paragraph analysis routine to try and filter out
#               spacer rows like "******" or "===========", or "poetry"
#               rows like:
#
#               "                              TITLE"
#
#  Input:       aAvgIndent - The average indent found for this body of text
#               aText - The text-row
#
# Returns:      0 - if the aText does not appear to be legitimate text
#               1 - if the aText IS legitimate text
#
# Notes:
#
#---------------------------------------------------------------------------
sub IsTextRow {
    local ($aAvgIndent, $aText) = @_;
    local ($lResult) = 0;
    local ($lRow, $lSize, $lIndentLimit);

    # A text row must have a minimum-number of alpha-characters to qualify.
    # This will help us filter out "------------" or "****" or "========"
    # seperator rows.

    # See how many alpha chars are in aText

    $lRow = uc($aText);
    $lRow =~ s/[^A-Z0-9]//g;  # Strip out anything not A-Z, 0-9
    if ( length ($lRow) < $gPA_MIN_CHAR_COUNT ) {
        return (0);
    }

    # So we have a bunch of text. If it is indented too-far, it could
    # be poetry (Title, Headers, etc.)

    # Decide how much indentation is too much

    $lIndentLimit = $gPA_POETRY_INDENT;
    if ( $aAvgIndent > 0 ) {
        $lIndentLimit = $aAvgIndent * $gPA_POETRY_INDENT_FACTOR;
    }

    if ( &GetIndentSize ($aText) > $lIndentLimit ) {
        return (0);
    }

    # Looks like a good text row
    $lResult = 1;

    return ($lResult);

}   # IsTextRow

#---------------------------------------------------------------------------
# Routine:      IsParagraphStart
# Description:  This routine will take a row of text and return 1 if it
#               appears like a legitimate start of paragraph text. This means
#               it must be a text-row (see the "IsTextRow" routine) and
#               the first character must be " or A-Z.
#
#  Input:       aAvgIndent - The average indent found for this body of text
#               aText - The text-row
#
# Returns:      0 - if the aText does not appear to be legitimate paragraph start
#               1 - if the aText IS legitimate paragraph start
#
#---------------------------------------------------------------------------
sub IsParagraphStart {
    local ($aAvgIndent, $aText) = @_;
    local ($lRow);

    # Call the IsTextRow routine to see if aText contains enough text
    # to look like a paragraph-start canidate, and is not indented too
    # far so it looks like header/poetry

    if ( &IsTextRow ($aAvgIndent, $aText) == 0 ) {
        # Nope. Not enough alpha characters or too much indents
        return (0);
    }

    # Need to check the first non-whitespace character. It should be A-Z
    # or a single or double quote

    if ( $aText =~ m/^\s*[A-Z\"\']/ ) {
        # Looks good.

        # FUTURE: We want to test that the end of the first word is NOT a
        # colen so we dont treat "Subject: ..." or "Report-Problems-To:"
        # types of rows as paragraph starts.

        # print "IPS: Row PASSES paragraph start test: " . substr ($aText, 0, 20) . "\n";
        return (1);
    }


    ## print "IPS: Row FAILS paragraph start test: " . substr ($aText, 0, 20) . "\n";
    return (0);

}   # IsParagraphStart

#---------------------------------------------------------------------------
# Routine:      GetIndentSize
# Description:  This routine will take a line of text and return the
#               count of white-space characters found at the beginging.
#
# Input:        aText - Line of text like "and then she said" or "    and then"
#
#---------------------------------------------------------------------------
sub GetIndentSize {
    local ($aText) = @_;
    local ($lSize) = 0;

    # See if there is any white-space at the begining of the text

    if ( $aText =~ m/^(\s+)/ ) {
        # Since we put the \s+ in parens, $1 holds a copy of the
        # white-space. Just return the length.

        return (length ($1));
    }

    return ($lSize);

}   # GetIndentSize

#---------------------------------------------------------------------------
# Routine:      S_AnalyzeIndent
# Description:  This routine will jump into the middle of the gText array
#               and scan forwards and backwards trying to spot the
#               typical indentation for the start of a paragraph. This
#               value is later used to try and locate text-paragraphs
#
# Input:        gText - uses the global array
#
# Returns:      nn - The average number of spaces of indentation that appears
#               typical of the gText body
#               $gAverageIndent - The global variable is set to nn - the
#                   average number of spaces of indentation.
#
#---------------------------------------------------------------------------
sub S_AnalyzeIndent {
    local ($lSize, $lMid, $lStart, $lEnd, $i, $lRow);
    local ($lIndentCount, $lIndentSpace, $lIndentAverage);

    # Find the row about 60% into the body of the gText array. This is
    # so we skip the header rows which can be 5-20 % of the entire body

    $lSize = $#gText;

    $lMid = 0.6 * $lSize;

    # Pick a start and end row about 20% to either side of this mid point

    $lStart = int ($lMid - (0.2 * $lSize));
    $lEnd   = int ($lMid + (0.2 * $lSize));

    $lIndentCount = 0;
    $lIndentSpace = 0;
    for ( $i = $lStart; $i <= $lEnd; $i++ ) {

        $lRow = $gText[$i];

        # Check this row to see if it starts with any white-space. If so,
        # count the size and add it to our variables. Skip this row
        # if it does not start with white-space

        $lSize = &GetIndentSize ($lRow);
        if ( $lSize > 0 ) {
            $lIndentSpace += $lSize;
            $lIndentCount++;
        }
    }

    # Now calculate the average

    $lIndentAverage = 0;
    if ( $lIndentCount > 0 ) {
        $lIndentAverage = int ($lIndentSpace / $lIndentCount);
    }

    ## For debugging

    # print "AI: From row $lStart to $lEnd the average indent is: $lIndentAverage\n";

    $gAverageIndent = $lIndentAverage;      # Set the global

    return ($lIndentAverage);


}   # S_AnalyzeIndent

#---------------------------------------------------------------------------
# Routine:      S_AnalyzeTextParagraphs
# Description:  This routine looks at an array of text strings
#               and analize which row-numbers are the start of each TEXT
#               paragraph. The starting row of each paragraph is
#               put into an array. The array is then returned.
#
# Input:        @gText - Array of text (The Global array)
#
# Returns:      @lPara - Array of row numbers coresponding to the start
#               of each paragraph in gText:
#                   $lPara[0] = 4  - Means the first paragraph starts at
#                                   $gText[4]
#                   $lPara[1] = 17 - Means that the second paragraph starts
#                                   at $gText[17].
#                                                                        -
# Note:         This routine attempts to find text/story paragraphs, not
#               header, poetry paragraphs for the entire article. The goal
#               is to identify paragraphs that we can re-format or re-word-
#               wrap.
#
#               Here is what we look for:
#
#               4 :
#               5 :
#               6 :Now is the time for all good men...
#
#                   Row 6 is the start of a paragraph because it comes after
#                   a blank line, and starts with less than 15 spaces. Text
#                   indented with 15 or more spaces is considered title/poetry
#
#               8 :    It was the best of
#               9 :times, it was the worst of times.
#               10:   "I am not having a good day."
#
#                   Row 8 is the start of a pargraph because it starts with
#                   2-14 spaces and starts with a capitol letter or ". Row
#                   10 is also a paragraph for the same reasons.
#
#                13:Chapter 1
#                14:"Help Me"
#                15:My cry for help elicted no response
#
#                   Row 13 is NOT a paragraph because it has less than 20
#                   alpha characters and no quotes.
#                   Row 14 is a paragraph because it contains quotes.
#                   Is row 15 a new paragraph or part of the previous???
#
#               20:
#
#
#
#
#---------------------------------------------------------------------------
sub S_AnalyzeTextParagraphs {
    local (@lPara) = ();
    local ($lLast);
    local ($lRow, $lPrevious, $lRowCount, $i);
    local ($lSubjectRow);
    local ($lAvgIndent);
    local ($lIsParaStart);

    $lLast = $#gText;       # Remember the last row of the array

    # Find the row that starts with "Subject:" This becomes our first paragraph
    $i = 0;
    while ( $i < $lLast ) {
        $lRow = $gText[$i];
        $lRow =~ s/ //g;
        if ( $lRow =~ m/^Subject\:/ ) {
            $lSubjectRow = $i;
            break;
        }
        $i++;
    }

    # print "Found Subject - ($gText[$lSubjectRow]) \n";

    # Search BACKWARDS to beginning or previous blank line
    $i = $lSubjectRow;
    # while ( ($i > 0) && (length ($gText[$i]) > 0) ) {
    while ( $i > 0 ) {
        $lRow = $gText[$i];
        $lRow =~ s/ //g;
        if ( length ($lRow) == 0 ) {
            # Found our first real paragraph
            $i++;
            push (@lPara, $i);
            last;       # Break out of the loop
        }
        $i--;
    }

    # Look at the rows in gText and decide what the average
    # indentation is. Store the value in gAverageIndent.

    $lAvgIndent = &S_AnalyzeIndent ();

    # Now run through the entire text array looking for paragraphs

    while ( $i < $lLast ) {
        $lPrevious = $gText[$i - 1];
        $lRow      = $gText[$i];

        $lIsParaStart = 0;      # Assume this is NOT the start of a pargraph

        # Test 1: previous row blank, current row looking like paragraph start

        if ( (length ($lPrevious) < 2) &&
             (&IsParagraphStart ($lAvgIndent, $lRow) == 1) ) {
            # Looks good
            $lIsParaStart = 1;
        }

        # Test 2: Previous row NOT indented, current row indented and
        # looking like the start of a paragraph.
        # This only works if we have an average indent.

        if ( $lAvgIndent > 0 ) {
            if ( (&GetIndentSize ($lPrevious) < $lAvgIndent)  &&
                 (&GetIndentSize ($lRow) == $lAvgIndent)      &&
                 (&IsParagraphStart ($lAvgIndent, $lRow) == 1)
            ) {
                $lIsParaStart = 1;
            }
        }


        # Did this row pass our tests?

        if ( $lIsParaStart > 0 ) {
            push (@lPara, $i);
        }

        $i++;
    }

    return (@lPara);

}   # S_AnalyzeTextParagraphs

#---------------------------------------------------------------------------
# Routine:      S_MergeGTextRows
# Description:  This routine will take a starting and ending row number
#               for the gText array and try to merge all the text into
#               a single row. If successful, the new row will be written to
#               gText in the start position, and all the other rows in
#               the range will be made blank.
#
# Input:        aStart - Starting row in gText
#               aEnd   - Ending row in gText
#
# Output:       @gText - The row at aStart will contain the entire paragraph
#                   of text from aStart to aEnd inclusively. The rows
#                   between aStart+1 and aEnd will be made blank.
#
#---------------------------------------------------------------------------
sub S_MergeGTextRows {
    local ($aStart, $aEnd) = @_;
    local ($lNewRow, $lRow);
    local ($i, $lFirstWord);

    # Not every paragraph should be merged to a single line
    # Do checks here to make sure we are not at the begining of
    # header or copyright text

    $lRow = $gText[$aStart];

    return if ($lRow =~ m/^\>/);
    return if ($lRow =~ m/Subject\:/);
    return if ($lRow =~ m/disclaimer/i);
    return if ($lRow =~ m/chapter/i);

    # Look for the first word to end with a : char
    $lFirstWord = $gText[$aStart];
    if ($lFirstWord =~ m/^(\w+)\: /) {
        $lFirstWord = $1;
        return;
    }

    # Design note: use lNewRow as the buffer. Put in the first
    # row, then decide how to append the next

    $lNewRow = $gText[$aStart];

    # Get rid of the leading whitespace

    $lNewRow =~ s/^\s*//;

    for ( $i = $aStart +1; $i <= $aEnd; $i++ ) {
        $lRow = $gText[$i];

        # Get rid of any leading white space

        $lRow =~ s/^\s*//;

        # Append

        # See if the end of NewRow has a "-" char. If so, dont padd with
        # a space

        if ( $lNewRow =~ m/\-$/ ) {
            $lNewRow .=  $lRow;
        } elsif ( $lNewRow =~ m/=$/) {
            # The row ends with "=" signs so we want to get
            # rid of the '=' and append the current row.
            $lNewRow =~ s/=$//;
            $lNewRow .= $lRow;
        } else {
            # Just append the next row with a space
            $lNewRow .= " " . $lRow;
        }
    }


    # If we succeeded, put lNewRow in the starting position and blank the
    # other rows

    # $gText[$aStart] = $gSTD_INDENT . $lMyWrap->wrap ($lNewRow);
    #local ($lMyWrap) = Text::Wrapper->new(columns => 70, body_start => '');
    #$gText[$aStart] = $lMyWrap->wrap ($gSTD_INDENT . $lNewRow);

    # Look for extra spaces and replace with singles
    $lNewRow =~ s/([a-z])  +([A-Za-z])/$1 $2/g;
    $lNewRow =~ s/([a-z])\s*\,\s*([a-zA-Z])/$1\, $2/g;
    $gText[$aStart] = $gSTD_INDENT . $lNewRow;



    for ( $i = $aStart + 1; $i <= $aEnd; $i++ ) {
        $gText[$i] = "";
    }

}       # S_MergeGTextRows

#---------------------------------------------------------------------------
# Routine:      S_UnWrapGText
# Description:  This routine will take the rows of text stored in the gText
#               array and un-wrap the paragraphs so they occupy exactly
#               one row each. Below is a before/after of this:
# BEFORE:        20:     It was the best of times,
#                21:it was the worst
#                22:of times.
#                23:    I was born a poor black child on
#                24:a dirt farm.
#
# AFTER:         20:    It was the best of times, it was the worst of times.
#                21:(blank)
#                22:(blank)
#                23 :    I was born a poor black child on a dirt farm.
#
#               So the row that starts the paragraph STILL starts the paragraph,
#               but the intermediate text is appended to one long row.
#
# Input:        @aPara - Array of ints that tell us which row in gText
#                   contains the start of each paragraph:
#                   $aPara[0] = 7  - Means the first paragraph is in gText[7]
#                   $aPara[1] = 9  - Means the second paragraph is in gText[9]
#                       ...
#               @gText - This global array contains all the text
#
# Output:       @gText - The rows of gText are un-wrapped
#---------------------------------------------------------------------------
sub S_UnWrapGText {
    local (@aPara) = @_;
    local ($i, $j, $lRow, $lStart, $lEnd, $lNext, $lNumParagraphs);
    local ($lgTextSize);

    $lNumParagraphs = $#aPara;
    $lgTextSize     = $#gText;

    # The first paragraph is the header block that we dont want to
    # un-wrap. So start with the second one.

    for ( $i = 1; $i < $lNumParagraphs; $i++ ) {

        # Get the starting and ending row numbers for
        # this paragraph.  The aPara array will give us this.

        $lStart = $aPara[$i];           # Starting row number in gText
        $lEnd = $aPara[$i + 1] - 1;     # Starting row for NEXT paragraph, minus 1

        # So we need to take the text from the lStart row through
        # $lEnd and make it one big row of text. All the rows that
        # were appended to lStart need to be made blank. Deal with
        # indendations, hyphens, broken text, etc.

        # Because this is such a complex process, pass the starting and
        # ending rows to a routine that will try and do it for us. If it
        # fails, it will simply return without affecting gText.

        S_MergeGTextRows ($lStart, $lEnd);

    }

    # Need to handle the last paragraph. We know the staring row, but we
    # need to find the ending row. Look for the first blank row after
    # the start of the last paragraph.

    $lStart = $aPara[$lNumParagraphs];
    $lEnd = $lStart;
    while ($lEnd < $lgTextSize && length ($gText[$lEnd]) > 1) {
        $lEnd++;
    }

    S_MergeGTextRows ($lStart, $lEnd - 1);

    ## For testing

}   # S_UnWrapGText

#---------------------------------------------------------------------------
# Routine:      S_FindTextStart
# Description:  This routine will take the array of text lines and
#               try to determine which row contains the first line of
#               story-text. Not disclaimers or header stuff
#
# Input:        @gText - Array of text
#
# Returns:      lStart - Array index of the first row of actual story
#
#---------------------------------------------------------------------------
sub S_FindTextStart {
    local ($lStart) = -1;
    local ($lWidth) = 40;       # How many chars of text to display
    local (@lPara) = ();
    local ($lRow, $lChoice);
    local ($lMsg);
    local ($lCount);
    local ($lUserStart, $lGuess1, $lGuess2, $lGuess3);

    # Call a routine that will look at the text file and return an array
    # of row-numbers that represent the starting row of each paragraph.

    @lPara = &S_AnalyzeTextParagraphs (@gText);

    &S_PrintParaStats (@lPara);

    # Ask the user which paragraph is the start of the text
    print "\tStart of Text: ";
    $lChoice = <STDIN>;
    chomp ($lChoice);

    # We have the paragraph number, now extract the row number

    $lRow = $lPara[$lChoice];
    $lUserChoice = $lRow;

    # print "\nText Start = $gText[$lRow]\n";


    ## Experimental: Try different routines to determine the
    # starting row of the text
    #&S_GuessStartParaCount (@lPara);


    return ($lUserChoice);

}   # S_FindTextStart

#---------------------------------------------------------------------------
# Routine:      S_CalcTextCRC
# Description:  This routine will take a file name, open the file
#               and attempt to calculate the "Text CRC" for the story.
#
# Input:        aFileName - Name of the input file
#
# Return:       lCRC - The 32 bit "Text CRC" as a upper-case Hex string
#
# Notes:        The "Text CRC" is calculated this way:
#               A) Take the first 256 chars of the story
#               B) Take the Last 256 chars of the story
#               C) Take the CRC of First+Last
#
#               The Chars are only A-Z, 0-9 with no puncuation,
#               white space, etc., and everything converted to upper case.
#
#---------------------------------------------------------------------------
sub S_CalcTextCRC {
    local ($aFileName) = @_;
    local ($lCRC) = -1;             # The return value
    local ($lRow, $lRowCount);
    local ($lLastHeader, $lPos, $lStartText);
    local ($lMyStr, $lFinished, $lLastRow);

    if (  ! (-e $aFileName) ) {
        print "CTC: Error - File ($aFileName) does not exist\n";
        return ($lCRC);
    }

    # Step 1: Read the entire file into an array

    print "CTC: Reading ($aFileName) into memory...\n";

    # Call a routine to read the text file into the global gText array

    &FillGTextArray ($aFileName);


    # Step 2: Find the row number of the start of the actual story

    $lRow = &S_FindTextStart ();


    # Step 3: Get the row numbers for the start of each paragraph. Then
    # take each paragraph and un-wrap it so each paragraph is
    # all on 1 line.

    local (@lPara) = &S_AnalyzeTextParagraphs ();

    ## Debugging
    asstr_para::AnalyzeText ($gText);



    &S_UnWrapGText (@lPara);


    return (-1);        ## for development

    # Take the starting row and start appending text. Make all the text
    # upper-case and strip out puncuation. Keep doing this until
    # we have about 256 chars in a start-string

    $lMyStr = "";
    $lFinished = 0;
    while ( $lFinished == 0 ) {
        $lMyStr .= uc ($gText[$lRow]);      # Make everything upper case
        $lMyStr =~ s/[^A-Z0-9]//g;          # Strip everything other than alphas

        # See if we have a big-enough string, or have run out of chars

        if ( length ($lMyStr) > $gCHAR_COUNT_CRC ) {
            $lFinished = 1;
        }
        if ( $lRow >= $lRowCount ) {
            $lFinished = 1;
        }

        $lRow++;
    }

    $lMyStr = substr ($lMyStr, 0, $gCHAR_COUNT_CRC);
    # print "TextStart (" . length ($lMyStr) . ") = ($lMyStr)\n";
    #$lCRC = sprintf ("%08x", crc32 ($lMyStr, -1));
    #$lCRC = uc ($lCRC);
    #print "Start CRC = $lCRC\n";

    return ($lCRC);

}   # S_CalcTextCRC

#---------------------------------------------------------------------------
# Routine:      S_AddCRCHeaders
# Description:  This routine will take a story file name and break-out
#               each article.
#
# Input:        aFileName - Name of the file to sort
#
#---------------------------------------------------------------------------
sub S_AddCRCHeaders {
    local ($aInFile) = @_;
	local (@lBreakIndex) = ();	# contains row-number | subject line pairs
	local (%lSubjectArray) = ();	# contains Subject | file name pairs
    local ($lFileCount) = 0;

    # See if the parent gave us a name, or do we prompt for one

    if ( $aInFile eq "" ) {
        $aInFile = &SelectTextFile ($gWORKING_DIR, 1);
    }

    # Make sure we dont have the temp file left over

    if (-e $gTEMP_FILE) {
        unlink ($gTEMP_FILE);
    }
    if ( ! (-e $aInFile)) {
        print "SSF: Error - Input file ($aInFile) does not exist\n";
    }


	# Call a routine to analyze the story file and return a array
	# that tells us the end-row of each story, and the "Subject:"
	# line for each one.

    print "ACH: Analyzing breaks in ($aInFile)...\n";
    @lBreakIndex = &S_GetSubjectBreaks ($aInFile);

	# Use the break index array to split the big file up into smaller
	# story files. It will return a Associative array with the
	# subject lines as the index and the file names as the members.
	# This will allow us to pull the smaller story files into a
	# single file, but sorted by Subject header

    print "ACH: Breaking ($aInFile) into smaller parts...\n";
    %lSubjectArray = &S_SplitSubjectBreaks ($aInFile, @lBreakIndex);


	# Our %lSubjectArray now looks like
	#     lSubjectArray["Subject: fubar"] = "t0000.tmp"
	#     lSubjectArray["Subject: this is mine"] = "t0001.tmp"
	#
	# Using the index, grab the file names in order and put them into
	# a new file

    local ($lOldFileName) = "_" . $aInFile;
    rename ($aInFile, $lOldFileName);
    open (OUTFILE, ">$aInFile") || die ("Cannot open $aInFile for output\n");

	foreach $lSubject (sort (keys(%lSubjectArray))) {
		$lFileName = $lSubjectArray{$lSubject};
		# print "Out: $lFileName - $lSubject\n";

		print OUTFILE "$gDIVIDER";


        ### NEW: Grab the temporary file and try to analize it's CRC
        # value

        if ( $lFileCount < 15 ) {
            &S_CalcTextCRC ($lFileName);
        }

		# Grab the story file and put it's lines into the output file
		open (INFILE, "$lFileName") || die ("Cannot open $lFileName for input!\n");
		while ( <INFILE> ) 	{
			print OUTFILE $_;
		}
		close (INFILE);
		# unlink (INFILE);	# Delete the temp file
        $lFileCount++;
	}

	close (OUTFILE);
	system "del *.tmp";
	print "Original file moved to : $lOldFileName\n";
    print "Sorted output written to : $aInFile\n";

}   # S_AddCRCHeaders



#---------------------------------------------------------------------------
# Routine:      S_UnwrapFile
# Description:  This routine will take a story file name and break-out
#               each article, then it will un-wrap the paragraphs
#
# Input:        aFileName - Name of the file to sort
#
#---------------------------------------------------------------------------
sub S_UnWrapFile {
    local ($aInFile) = @_;
    local ($lOutFile);          # aInFile = sto1-1.txt, lOutFile will be sto1-2.txt
	local (@lBreakIndex) = ();	# contains row-number | subject line pairs
	local (%lSubjectArray) = ();	# contains Subject | file name pairs
    local ($lFileCount) = 0;
    local (@lPara) = ();        # To hold paragraph numbers
    local ($i);

    # See if the parent gave us a name, or do we prompt for one

    if ( $aInFile eq "" ) {
        $aInFile = &SelectTextFile ($gWORKING_DIR, 1);
    }

    # Calculate the new outfile name
    # Hard code for now
    $lOutFile = &IncrimentFileName ($aInFile);
    print "UW:NewFile name = $lOutFile\n";
    if ( -e $lOutFile ) {
        unlink ($lOutFile);
    }

    # Make sure we dont have the temp file left over

    if (-e $gTEMP_FILE) {
        unlink ($gTEMP_FILE);
    }
    if ( ! (-e $aInFile)) {
        print "SSF: Error - Input file ($aInFile) does not exist\n";
    }


	# Call a routine to analyze the story file and return a array
	# that tells us the end-row of each story, and the "Subject:"
	# line for each one.

    print "UF: Analyzing breaks in ($aInFile)...\n";
    @lBreakIndex = &S_GetSubjectBreaks ($aInFile);

	# Use the break index array to split the big file up into smaller
	# story files. It will return a Associative array with the
	# subject lines as the index and the file names as the members.
	# This will allow us to pull the smaller story files into a
	# single file, but sorted by Subject header

    print "UF: Breaking ($aInFile) into smaller parts...\n";
    %lSubjectArray = &S_SplitSubjectBreaks ($aInFile, @lBreakIndex);


	# Our %lSubjectArray now looks like
	#     lSubjectArray["Subject: fubar"] = "t0000.tmp"
	#     lSubjectArray["Subject: this is mine"] = "t0001.tmp"
	#
	# Using the index, grab the file names in order and put them into
	# a new file

    open (OUTFILE, ">$lOutFile") || die ("Cannot open $lOutFile for output\n");

	foreach $lSubject (sort (keys(%lSubjectArray))) {
		$lFileName = $lSubjectArray{$lSubject};
		# print "Out: $lFileName - $lSubject\n";



        # Grab the temporary file and read it's rows into
        # the global array gText

        &FillGTextArray($lFileName);

        # Analize the paragraphs in gText

        @lPara = &S_AnalyzeTextParagraphs ();

        # Use the paragaph numbers to un-wrap the rows in gText

        &S_UnWrapGText (@lPara);

        # The un-wrapping left lots of blank rows in gText. Fix this

        &ScrubGTextCompress();

        # Write the un-wrapped gText array to the output file

		print OUTFILE "$gDIVIDER";

        for ( $i = 0; $i < $gGTextSize; $i++ ) {
            print OUTFILE "$gText[$i]\n";
        }

        $lFileCount++;
	}

	close (OUTFILE);
	system "del *.tmp";
    print "Original file     : $aInFile\n";
    print "Word-wrapped file : $lOutFile\n";

}   # S_UnwrapFile


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
	local ($aInFileName, @aBreakIndex) = @_;
	local (%lSubjectArray) = ();				# Our output
	local ($lRowCount, $lFileName, $lFileCount, $lEndRow);
	local ($lSubject, $lLine, $lIndex, $i);

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

        # Check for old-style "{--------}" Divider rows and strip them out.
        # Otherwise when we add them back in we will get multiples.
        if ($lLine =~ m/^\{\-+/) {
            $lLine = "";
        }

		print TXTFILE "$lLine";
		# print "$lLine";

		$lRowCount++;

		# See if we reached the last row before the next message
		if ( $lRowCount == $lEndRow ) {
			# Found the end. Close the file and open the next one.
			close (TXTFILE);

			# Get the next temp file name
			$lFileName = "t" . sprintf ("%04d", $lFileCount) . ".tmp";

			# Get the next ending row number
			($lEndRow, $lSubject) = split (/\|/,$lBreakIndex[$lFileCount]);

			# Track this file name with this subject line
			$lIndex = &S_CompressSubjectText($lSubject);

			# If we have 2 or more identical subject lines, one will
			# over-write the other. Work to create a unique
			# index string for the second, third,...

			while ( defined ($lSubjectArray{$lIndex} ) ) {
                # print "Error: Index ($lIndex) is already defined\n";
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
# S_CompressSubjectText
# This routine will remove all non alpha characters, spaces and upper-case
# the alphas so that this subject line will sort in correct order.
#-------------------------------------------------------------------------
sub S_CompressSubjectText {
	local ($aSubject) = @_;
	local ($lOrig) = $aSubject;

    $aSubject =~ s/Subject: //;
    $aSubject =~ s/Subject://;
    $aSubject = uc ($aSubject);

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
    $aSubject =~ s/\"//g;
    $aSubject =~ s/\'//g;
    $aSubject =~ s/THE //g;
    $aSubject =~ s/A //g;
    $aSubject =~ s/\(//g;
    $aSubject =~ s/ +//g;

    #print "Orig/Compressed = ($lOrig / $aSubject)\n";
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
                if ( $lSubjectCount < 10 ) {
                    # print "$lTemp\n";
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

#---------------------------------------------------------------------------
# Routine:      S_SortStoryFile
# Description:  This routine will take a story file name and sort the
#               articles within the file in alphabetical order.
#
# Input:        aFileName - Name of the file to sort
#
#---------------------------------------------------------------------------
sub S_SortStoryFile {
    local ($aInFile) = @_;
	local (@lBreakIndex) = ();	# contains row-number | subject line pairs
	local (%lSubjectArray) = ();	# contains Subject | file name pairs

    # See if the parent gave us a name, or do we prompt for one

    if ( $aInFile eq "" ) {
        $aInFile = &SelectTextFile ($gWORKING_DIR, 1);
    }

	print "Sorting : $aInFile\n";

    # Make sure we dont have the temp file left over

    if (-e $gTEMP_FILE) {
        unlink ($gTEMP_FILE);
    }
    if ( ! (-e $aInFile)) {
        print "SSF: Error - Input file ($aInFile) does not exist\n";
		return;
    }


	# Call a routine to analyze the story file and return a array
	# that tells us the end-row of each story, and the "Subject:"
	# line for each one.

    @lBreakIndex = &S_GetSubjectBreaks ($aInFile);

	# Use the break index array to split the big file up into smaller
	# story files. It will return a Associative array with the
	# subject lines as the index and the file names as the members.
	# This will allow us to pull the smaller story files into a
	# single file, but sorted by Subject header

    %lSubjectArray = &S_SplitSubjectBreaks ($aInFile, @lBreakIndex);


	# Our %lSubjectArray now looks like
	#     lSubjectArray["Subject: fubar"] = "t0000.tmp"
	#     lSubjectArray["Subject: this is mine"] = "t0001.tmp"
	#
	# Using the index, grab the file names in order and put them into
	# a new file

    local ($lOldFileName) = $aInFile . '.bak';
    rename ($aInFile, $lOldFileName);
    open (OUTFILE, ">$aInFile") || die ("Cannot open $aInFile for output\n");

	foreach $lSubject (sort (keys(%lSubjectArray))) {
		$lFileName = $lSubjectArray{$lSubject};
		# print "Out: $lFileName - $lSubject\n";

		print OUTFILE "$gDIVIDER";

		# Grab the story file and put it's lines into the output file
        # Use a routine to fill the global gText array from the file

        &FillGTextArray ($lFileName);

        # Remove common garbage & blank rows from gText

        &ScrubGText ();

        # Write the contents of the gText array to the open output file

        foreach (@gText) {
            print OUTFILE "$_\n";
        }

        #open (INFILE, "$lFileName") || die ("Cannot open $lFileName for input!\n");
        #while ( <INFILE> )  {
        #    print OUTFILE $_;
        #}
        #close (INFILE);

        # unlink ($lFileName);  # Delete the temp file
	}

	close (OUTFILE);
	system "del *.tmp";
	print "Original file moved to : $lOldFileName\n";
    print "Sorted output written to : $aInFile\n";

}   # S_SortStoryFile



#-------------------------------------------------------------------------
# S_akFile2
# This routine will take a story file and break each storie into a
# individual file.
# This looks for a blank-line ahead of each Subject: line
#-------------------------------------------------------------------------
sub S_BreakFile2 {
	local ($aInFileName) = @_;
	local (@lBreakIndex) = ();	# contains row-number | subject line pairs
	local (%lSubjectArray) = ();	# contains Subject | file name pairs
	local ($lSubject, $lLine, $lFileName, $lRowCount, $lEndRow);
	local ($lFileCount) = 0;

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

	local ($lOldFileName) = "_" . $aInFileName;
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

#---------------------------------------------------------------------------
# Routine:      IsHeader
# Description:  A lot of articles have a bunch of headers like:
#               X-Archive:
#               Subject:
#               This routine tries to identify these header rows
#
# Input:        aRow - A row from the text file
#
# Returns:      1 if the row is a header, 0 otherwise
#---------------------------------------------------------------------------
sub IsHeader {
    local ($aRow) = @_;
    local ($lReturn) = 0;   # default is Not a header
    local ($lFirstWord);
    local (@lTemp);

    # A header is usually a upper-case alpha character
    if ( $aRow =~ m/^[A-Z]/ ) {
        @lTemp = split (/ /, $aRow);
        $lFirstWord = $lTemp[0];

        # The header always ends with a ": " combo
        if ( $lFirstWord =~ m/\:$/ ) {
            # Sometimes we get UUENCODED rows that end with a comma
            if ( length ($lFirstWord) < 35 ) {
                print "$lFirstWord\n";
                $lReturn = 1;
            }
        }

    }


    return ($lReturn);
}   # IsHeader


#-------------------------------------------------------------------------
# Routine:      HandleAuthor
# Description:  Often, Subject lines start with the authors name like:
# 		Subject: (PJ)
# 		Subject: {Kellis}
# This routine will take a "Subject:" line, look for author names at
# the begining and move the text to the end of the line.
#-------------------------------------------------------------------------
sub HandleAuthor {
	local ($aLine) = @_;
	local ($lEndChar);
	local ($lAuthorName);
	local ($lTarget);
	local ($i, $j);


    local ($lOrigLine) = $aLine;

	# Look for Ann Douglas stories
	if ( $aLine =~ /Subject: AnnD/i ) {
		$aLine =~ s/Subject: AnnD/Subject: /gi;
		$aLine .= " {AnnD}";
	}

    # Strip "Kirsten's Collections"
	if ( $aLine =~ /Subject: Kristen's collection: /i ) {
		$aLine =~ s/Subject: Kristen's collection: /Subject: /gi;
	}

	# Author Names

	## New: Look for "by author" and convert it to {author}
    foreach $lAuthorName (@gAuthors) {
        if ( $aLine =~ /\bby $lAuthorName\b/i ) {

			# Remove the text from the subject line
            $aLine =~ s/\bby $lAuthorName\b//i;
			# Put the author at the end in curly braces
			$aLine .= " \{$lAuthorName\}";
            #print "Put ($lAuthorName) at the end\n";
		}
	}


	# Some Articles start like:
	#	Subject: [Lingus] aaaaaa
	#	Subject: [Black Demon] aaaaaa
	# We want to change this to:
	# 	Subject: aaaaa {Lingus}
	#	Subject: aaaaa {Black Demon]


    ## THIS NEEDS WORK
    #
	# Look for the word "Subject: " followed by "({["
    #if ( $aLine =~ /Subject: [\(\{\[]/ ) {
    #
    #    # The opening "(" is at char pos 9. Find the ending character
    #    $lEndChar = 0;
    #    if ( index ($aLine, "(") == 9 ) {
    #        $lEndChar = index ($aLine, ")");
    #    } elsif ( index ($aLine, "{") == 9 ) {
    #        $lEndChar = index ($aLine, "}");
    #    } elsif ( index ($aLine, "[") == 9 ) {
    #        $lEndChar = index ($aLine, "]");
    #    }
    #
    #    if ( $lEndChar > 9 ) {
    #        # Grab everything between () as the authors name
    #        $lAuthorName = substr ($aLine, 9, $lEndChar - 8);
    #
    #        # Remove the authors name from the begining
    #        $aLine = "Subject: " . substr ($aLine, $lEndChar + 1);
    #
    #        # Put the authors name at the end between  {} chars
    #        chop ($lAuthorName);    # Trim trailing ) char
    #        $aLine .= " {" . substr ($lAuthorName, 1) . "}";
    #    }
    #
    #
    #}


	# We may have left some extra spaces
	$aLine =~ s/  / /gi;

    ## For development
    #if ( $aLine ne $lOrigLine ) {
    #    print "Author Change: $lOrigLine\n";
    #    print "             : $aLine\n";
    #}

	return ($aLine);


}	# S_HandleAuthor

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
	local ($aInLine, $aTLA) = @_;

    $aInLine =~ s/ *\{$aTLA\} */ /gi;
    $aInLine =~ s/ *\[$aTLA\] */ /gi;
    $aInLine =~ s/ *\($aTLA\) */ /gi;
    $aInLine =~ s/ *\<$aTLA\> */ /gi;
    $aInLine =~ s/ *\*$aTLA\* */ /gi;

    # We might be searching for " Re: " but if we are not careful,
    # we also strip "Where:"
    $aInLine =~ s/ +$aTLA\. */ /gi;
    $aInLine =~ s/ +$aTLA\: */ /gi;
    $aInLine =~ s/ +$aTLA\! */ /gi;
    $aInLine =~ s/ +$aTLA *\- */ /gi;

    # We often get "Subject: New Story The final..." so we want to
    # strip the pattern: "Subject: TLA "
    $aInLine =~ s/^Subject: $aTLA /Subject: /gi;


	return ($aInLine);

}	# S_StripTLA

#---------------------------------------------------------------------------
# Routine:      ScrubSubjectLine
# Description:  This routine will take a newsgroup "Subject:" line and
#               clean it up.
#---------------------------------------------------------------------------
sub ScrubSubjectLine {
    local ($aLine) = @_;
    local ($lOutLine) = "";

    $lLine = $aLine;
    $lLine = &S_StripTLA ($lLine, "ASSC");
    $lLine = &S_StripTLA ($lLine, "ASSM");
    $lLine = &S_StripTLA ($lLine, "ASSD");
    $lLine = &S_StripTLA ($lLine, "ASS");
    $lLine = &S_StripTLA ($lLine, "FAQ");
    $lLine = &S_StripTLA ($lLine, "IPG");
    $lLine = &S_StripTLA ($lLine, "RE");
    $lLine = &S_StripTLA ($lLine, "RP");
    $lLine = &S_StripTLA ($lLine, "RETRY");
    $lLine = &S_StripTLA ($lLine, "REPOST");
    $lLine = &S_StripTLA ($lLine, "NEW\!");
    $lLine = &S_StripTLA ($lLine, "NEW");
    $lLine = &S_StripTLA ($lLine, "ASSM NEW");
    $lLine = &S_StripTLA ($lLine, "REV");
    $lLine = &S_StripTLA ($lLine, "REVISED");
    $lLine = &S_StripTLA ($lLine, "rp by req.");
    $lLine = &S_StripTLA ($lLine, "by request");
    $lLine = &S_StripTLA ($lLine, "NEW STORY");
    $lLine = &S_StripTLA ($lLine, "ASA STORY");
    $lLine = &S_StripTLA ($lLine, "STORY");
    $lLine = &S_StripTLA ($lLine, "SEX4FREE SITE");
    $lLine = &S_StripTLA ($lLine, "STORY4FREE SITE");
    $lLine = &S_StripTLA ($lLine, "SEXSTORY4FREE SITE");


    $lLine =~ s/Subject: +\-+ */Subject: /g;
    $lLine =~ s/Subject: new story +/Subject: /gi;
    $lLine =~ s/Subject: \.+/Subject: /g;

    $lLine =~ s/\s:\s/ /g;    # Remove "Subject: : "

    $lLine =~ s/ +/ /g;         # remove multiple spaces left over

    # For development/testing
    if ( $aLine ne $lLine ) {
        # Show old & new
        #print "$aLine\n$lLine\n\n";
        #print "$lLine\n";
    }

    return ($lLine);

}   # ScrubSubjectLine

#---------------------------------------------------------------------------
# Routine:      CountChars
# Description:  This routine takes a string, and a single character
#               and returns the number of times the character appears
#               in the string.
#---------------------------------------------------------------------------
sub CountChars {
    local ($aStr, $aChar) = @_;
    local ($lChar) = ord ($aChar);
    local ($lCount) = 0;

    # print "CC: Looking for ($aChar) or ($lChar) in ($aStr)\n";
    foreach (unpack ("C*", $aStr)) {
        #print "$_,";
        if ( $_ == $lChar ) {
            $lCount++;
        }
    }

    #print "\nFound $lCount\n";
    return ($lCount);

}   # CountChars

#---------------------------------------------------------------------------
# Routine:      ExtractKeywords
# Description:  A lot of "Subject:  " headers include keywords that are
#               not deliminated. This routine will try to find the more
#               common keywords and pull themout into a separate variable.
#
# Input:        aSubject - The text after "Subject: xxxxxxx"
#
# Returns:      lCodes - Any extracted codes like "MF, BD,mmF"
#               lTemp - The subject text with the codes removed
#
#---------------------------------------------------------------------------
sub ExtractKeywords {
    local ($aSubject) = @_;
    local ($lTemp, $lCodes);

    $lCodes = "";
    $lTemp = $aSubject;

    #if ( $lTemp =~ m/ m+|f+\//i ) {
    #    $lTemp =~ s/ ([m+|f+])+\// $1/gi;
    #    print "EK: $lTemp\n";
    #}

    return ($lCodes, $lTemp);


}   # ExtractKeywords

#---------------------------------------------------------------------------
# Routine:      ExtractChapters
# Description:  This routine will take a "Subject:..." string and try to
#               extract the chapter numbers from it. These are sometimes
#               in the form [1/2] or "Chapter 3 of 22". It will extract
#               the text and return it in the form "xx/yy"
#
# Input:        aSubject - The subject line with "Subject: " removed
#
# Returns:      lParts - String of the form "xx/yy"
#               lTemp - The original "Subject:..." line with the chapters
#                   text removed.
#
#---------------------------------------------------------------------------
sub ExtractChapters {
    local ($aSubject) = @_;
    local ($lTemp, $lParts, $lSection, $lTotal, $lPos);

    $lTemp = $aSubject;
    $lParts = "";


    # One of the easiest things to find is something like "[1/1]" ,
    # or [2/?]
    # but (1/1) is difficult because there could be multiple ()'s

    $lParts = "";

    if ( $lTemp =~ m/\[\d+\/\d+|\?+\]/ ) {

        # Found [n/n]
        $lTemp =~ m/(\[\d+.*\])/;
        $lParts = $1;           # Extract the [n/n] part
        $lPos = index ($lTemp, $lParts);
        $lParts =~ s/\[//g;     # Dont want the brackets
        $lParts =~ s/\]//g;

        # print "[$lParts] Orig: $lTemp\n";
        # Now try to remove the [n/n] from the original string
        $lTemp = substr ($lTemp, 0, $lPos) .
                 substr ($lTemp, $lPos + length ($lParts) + 2, 111);

        $lTemp =~ s/ +/ /g;     # May have left some spaces

    } elsif ($lTemp =~ m/\(\d+\/\d+\)/ ) {
        # We cannot use our normal extract routine because it cannot handle
        # (m/f) (2/3) in the subject line.
        $lTemp =~ m/(\(\d+\/\d+\))/;
        $lParts = $1;
        $lParts =~ s/\(//g;     # Dont want the parens
        $lParts =~ s/\)//g;

        # Now try to remove the (n/n) from the original string
        $lTemp =~ s/$lParts//;
        $lTemp =~ s/\(\)//;         # The () chars are sometimes left
    }

    ### If the parts are "1/1", this is the default. Clear our parts variable
    # so we can look for other clues as to the chapters.
    $lTemp =~ s/1\/1//g;
    if ( $lParts eq "1\/1" ) {
        $lParts = "";
    }

    # See if we caught [4/?] or there is a second set of numbers in brackets
    #if ( $lTemp =~ m/\/\?\]/ ) {
    #    print "($lParts) missed ($lTemp)\n";
    #}


    # Look for "Chapter nn of yy" or "Part yy of zz"
    if ( $lParts eq "" ) {
        $lTemp =~ s/Chapter (\d+) of (\d+)/$1 of $2/i;
        $lTemp =~ s/Part (\d+) of (\d+)/$1 of $2/i;
        $lTemp =~ s/Chapter One/Chapter 1/i;
        $lTemp =~ s/Chapter two/Chapter 2/i;
        $lTemp =~ s/Chapter three/Chapter 3/i;
        $lTemp =~ s/Chapter four/Chapter 4/i;
        $lTemp =~ s/Chapter five/Chapter 5/i;
        $lTemp =~ s/Chapter six/Chapter 6/i;
        $lTemp =~ s/Chapter seven/Chapter 7/i;
        $lTemp =~ s/Chapter eight/Chapter 8/i;
        $lTemp =~ s/Chapter nine/Chapter 9/i;

        # Convert "Part 1/2/3.. to "Chapter 1/2/3" so we can process it later

        $lTemp =~ s/Part (\d+)/Chapter $1/i;
        $lTemp =~ s/Part I /Chapter 1 /i;
        $lTemp =~ s/Part II /Chapter 2 /i;
        $lTemp =~ s/Part III /Chapter 3 /i;
        $lTemp =~ s/Part IV /Chapter 4 /i;
        $lTemp =~ s/Part V /Chapter 5 /i;
        $lTemp =~ s/Part VI /Chapter 6 /i;
        $lTemp =~ s/Part VII /Chapter 7 /i;
        $lTemp =~ s/Part VIII /Chapter 8 /i;
        $lTemp =~ s/Part IX /Chapter 9 /i;
        $lTemp =~ s/Part X /Chapter 10 /i;
    }

    # Look for "Ch 1" type of text
    $lTemp =~ s/Ch ?(\d)/Chapter $1/g;
    $lTemp =~ s/Chap ?(\d)/Chapter $1/g;
    $lTemp =~ s/Ch\.? ?(\d)/Chapter $1/g;
    $lTemp =~ s/pt\.? ?(\d)/Chapter $1/g;
    $lTemp =~ s/parts ?(\d)/Chapter $1/g;

    # Look for "Romance #4"
    $lTemp =~ s/\#(\d+)/Chapter $1/g;
    $lTemp =~ s/\# +(\d+)/Chapter $1/g;

    # Look for text "...4 of 20" if we dont already have the parts

    if ( $lParts eq "" ) {
        if ( $lTemp =~ m/(\d+ of \d+)/ ) {
            $lParts = $1;       # "3 of 5"

            $lParts =~ m/(\d+) of (\d+)/;      # Pull numbers into variables
            $lSection = $1;
            $lTotal = $2;

            # We have COPIED the "...4 of 20" text, but what if there is
            # text like "Chapter 4 of 20" or "Part 4 of 20" or some such.
            # We want to get rid of the "Chapter" text
            $lTemp =~ s/Chapter $lParts//i;
            $lTemp =~ s/Part $lParts//i;


            # Strip out the original "3 of 5" text
            $lTemp =~ s/$lParts//;

            # format the sections and total into nn/yy type of string

            $lParts = "$lSection/$lTotal";
        }
    }

    #

    # Look for "Chapter nn" type of text
    if ( $lParts eq "" ) {
        $lTemp =~ s/Chapter (\d)+//i;
        $lParts = $1;
        if ( $lParts ne "" ) {
            $lParts = sprintf ("%02d/??", $lParts);
        }
    }


    # Reformat: Look for "2/22" type of strings and make it "02/22"

    if ( $lParts ne "" ) {
        $lParts =~ m/(\d+)\/(\d+)/;
        $lSection = $1 * 1;
        $lTotal = $2 * 1;
        if ( $lTotal >= 100 ) {
            $lParts = sprintf ("%03d/%03d", $lSection, $lTotal);
        } elsif ( $lTotal >= 10 ) {
            $lParts = sprintf ("%02d/%02d", $lSection, $lTotal);
        }
    }




    return ($lParts, $lTemp);

}   # ExtractChapters

#---------------------------------------------------------------------------
# Routine:      PullSubsection
# Description:  This takes a "Subject: " string and tries to pull-out
#               sub-sections that are delimited by "()" chars, or ("")
#               chars. This only works if there is exactly 1 kind
#               of each delimiter
#
# Input:        aSubject - The text after "Subject: (xxx) {yyy} "zzz""
#               aOpen - The open-delimiter character (one of ({")
#               aClose - The closing delimiter char
#
# Returns:      lSection - The text between the delimiters
#               lRemains - The remainder of the aSubject text
#---------------------------------------------------------------------------
sub PullSubSection {
    local ($aSubject, $aOpen, $aClose) = @_;
    local ($lSection, $lRemains) = ("", $aSubject);
    local ($lLindex, $lRindex);

    local ($lFoundGoodMatch) = 0;

    # We could be looking for a pair of {} or [] chars,
    # but titles are usually in open/close pairs of " chars.
    # Count the number of each open and close character
    # and decide if it is safe to pull a sub-section

    $lLindex = &CountChars ($aSubject, "$aOpen");
    $lRindex = &CountChars ($aSubject, "$aClose");

    if ( $aOpen eq $aClose ) {
        # Then we want the counts to be exactly 2
        $lFoundGoodMatch = 1 if ($lLindex == 2);
    } else {
        # We have different open/close chars. So we can only do our
        # job if there is one of each
        $lFoundGoodMatch = 1 if ($lLindex == 1 && $lRindex == 1);
    }

    # Try to find the text between {} chars

    if ($lFoundGoodMatch == 1 ) {

        # Use brute-force sub-strings to grab the section.
        $lLindex = index ($aSubject, $aOpen);
        $lRindex = rindex ($aSubject, $aClose);

        if ( $lLindex < $lRindex ) {
            $lSection = substr ($aSubject, $lLindex + 1, $lRindex - $lLindex - 1);
            $lRemains = substr ($aSubject, 0, $lLindex) . substr ($aSubject, $lRindex + 1);
            $lRemains =~ s/ +/ /g;  # May have left some spaces
            $lRemains =~ s/ +$//g;  # Trim end spaces
            $lRemains =~ s/^ +//g;  # Trim leading spaces
        }
    }

    $lSection =~ s/ +$//g;  # Trim end spaces
    $lSection =~ s/^ +//g;  # Trim leading spaces

    return ($lSection, $lRemains);

}   # PullSubSection

#---------------------------------------------------------------------------
# Routine:      ParseSubjectLine
# Description:  This routine takes a "Subject: xxx" line and attempts to
#               pull apart the peices and re-format it
#               to:
#
#               Subject: "Title" [n/m] (codes) {Author}
#
# Input:        aSubject - The full subject line
# Returns:      lSubject - The re-formatted subject line
#
#---------------------------------------------------------------------------
sub ParseSubjectLine {
    local ($aSubject) = @_;
    local ($lSubject, $lTitle, $lAuthor, $lParts, $lCodes) = ("", "", "", "", "");
    local ($lSection, $lTotal);
    local ($lTemp) = $aSubject;
    local ($lPos);
    local ($lLOCAL_DEBUG) = 0;



    # The subject line could already be in our formatted form so look
    # for our sections

    $lTemp =~ s/^Subject: //;   # Get rid of this header

    # Get rid of nnnnn bytes
    $lTemp =~ s/\d+ bytes//g;

    # Design Note: As we find each section, remove it from the string.
    # Whatever is left over will fill in for the title.


    ## Parts section - This is complex so call a routine to do it for us.
    ($lParts, $lTemp) = &ExtractChapters ($lTemp);

    # Call a routine to look for common author names and put them
    # in {} chars

    $lTemp = &HandleAuthor ($lTemp);

    ## Author Section
    ($lAuthor, $lTemp) = &PullSubSection ($lTemp, "{", "}");
    if ( $lAuthor eq "" ) {
        # Check against a list of known authors. If found it will move
        # the author to the end of the string and bracket it with "{}" chars

        #$lTemp = &HandleAuthor ("Subject: $lTemp");
        #($lAuthor, $lTemp) = &PullSubSection ($lTemp, "{", "}");
    }


    ## Title Section
    ($lTitle, $lTemp) = &PullSubSection ($lTemp, "\"", "\"");
    if ( length ($lTitle) == 0 ) {
        # Try looking for single quotes
        ($lTitle, $lTemp) = &PullSubSection ($lTemp, "'", "'");
    }

    ## Story Codes Section
    ($lCodes, $lTemp) = &PullSubSection ($lTemp, "(", ")");

    # Check for people putting things like author in parenthesies
    if ( $lAuthor =~ m/\,/ ) {
        # Authors names done have commas. This is really the story codes
        if ( $lCodes eq "" ) {
            $lCodes = $lAuthor;
            $lAuthor = "";
        }
    }


    #########################
    ## Resolve missing fields
    #########################

    # Assume everything left is the title.
    if ( $lTitle eq "" ) {
        $lTitle = $lTemp;
        $lTemp = "";
        $lTitle =~ s/^\'//;
        $lTitle =~ s/\'$//;
        $lTitle =~ s/ +$//g;
        $lTitle =~ s/\"//g;
        $lTitle =~ s/\-+$//g;
        $lTitle =~ s/NND +//g;
        $lTitle =~ s/\-Story,\-//g;
        $lTitle =~ s/ +$//g;
        $lTitle =~ s/ +\,$//g;

        # See if the title ends with numbers - could be chapter/part numbers
        if ( $lParts eq "" && $lTitle =~ m/ \d+$/ ) {
            $lTitle =~ s/ (\d+)$//;
            $lParts = sprintf ("%02d/\?\?", $1);
        }
    }

    if ( $lCodes eq ""  ) {
        ($lCodes, $lTitle) = &ExtractKeywords ($lTitle);
    }

    # See if the left-over has a bunch of commas - could mean it's story codes
    if ( $lCodes eq ""  ) {
        # I think this is story codes. Check for commas or / chars like M/F
        if (&CountChars ($lTemp, ",") > 1 || &CountChars ($lTemp, "//") > 0) {
            $lCodes = $lTemp;
            $lTemp = "";
            $lCodes =~ s/\[\(|\{|\}|\)|\]|//g;
        }
    }



    if ( $lAuthor eq "" ) {
        # See if the left over text is something like "by tom jones"
        if ( $lTemp =~ m/^by /i ) {
            $lAuthor = $lTemp;
            $lTemp = "";
            $lAuthor =~ s/^by //;
        }
    }


    #print "Orig:       $aSubject\n";
    #print "        Title:       $lTitle\n";
    #print "        Parts:       $lParts\n";
    #print "        Author:      $lAuthor\n";
    #print "        Codes:       $lCodes\n";
    #print "        Left:        $lTemp\n\n";

    # Re assemble the subject line
    $lSubject = "Subject: \"$lTitle\"";
    if ( $lParts ne "" ) {
        $lSubject .= " [$lParts]";
    }
    if ( $lCodes ne "" ) {
        $lSubject .= " ($lCodes)";
    }
    if ( $lAuthor ne "" ) {
        $lSubject .= " {$lAuthor}";
    }
    if ( $lTemp ne "" ) {
        $lSubject .= " -$lTemp-";
    }

    # print "$aSubject\n$lSubject\n\n";

    return ($lSubject);

}   # ParseSubjectLine

#---------------------------------------------------------------------------
# Routine:      S_InitialCleanupFile
# Description:  This routine will take a xx.txt file and create a xx-1.txt
#               file. The new file will have:
#                   - Common Binary characters replaced/removed
#                   - Tabs turned into 4 spaces
#                   - Common "garbage" headers removed
#                   - Common "garbage" lines removed
#                   - Cleaned up "Subject:" header
#---------------------------------------------------------------------------
sub S_InitialCleanupFile {
    local ($aFile) = @_;
    local ($lOutFile);
    local ($lRow, $lBlankCount, $lNewSubject);

    # See if the parent gave us a name, or do we prompt for one

    if ( $aFile eq "" ) {
        $aFile = &SelectTextFile ($gWORKING_DIR, 0);
    }

    # Convert the input file name: storiesa.txt to an output file name
    # storiesa-1.txt

    $lOutFile = &IncrimentFileName ($aFile);
    # $lOutFile =~ s/$gFEXT/\-1$gFEXT/i;

    print "Initial Cleanup: Input/Output: ($aFile / $lOutFile)\n";

    if ( -e $lOutFile ) {
        unlink ($lOutFile);
    }

    open (INFILE, "$aFile")      || die ("ICF: Error - cannot open ($aFile) for input\n");
    open (OUTFILE, ">$lOutFile") || die ("ICF: Error - cannot open ($lOutFile) for output\n");

    $lBlankCount = 0;
    while ( <INFILE> ) {
        $lRow = $_;
        $lRow = &StripBinaryCharsFromRow ($lRow);   # This will chomp

        $lRow = &StripAsciiCharsFromRow ($lRow);

        # See if this row is a "Subject:" header
        if ( 1 and $lRow =~ m/^Subject\:/ ) {
            $lNewSubject = &ScrubSubjectLine ($lRow);

            # Call a routine that will try to put the Subject line in
            # a standard order
            $lNewSubject = &ParseSubjectLine ($lNewSubject);
            # $lNewSubject = &HandleAuthor($lNewSubject);

            $lRow = $lNewSubject;
        }


        # Check for old-style "{--------}" rows and strip them out
        if ($lRow =~ m/^\{\-+\}$/) {
            $lRow = "";
        }

        # Check for -- by itself on a line
        if ( $lRow =~ m/^\-\-$/ ) {
            $lRow = "";
        }

        # Remove blank lines. We dont want to print tons of blank
        # lines
        if ( length ($lRow) < 1) {
            $lBlankCount++;
        } else {
            $lBlankCount = 0;
        }

        if ( $lBlankCount < 2 ) {
            print OUTFILE "$lRow\n";
        }
    }

    close (OUTFILE);
    close (INFILE);

    print "New output file is: $lOutFile\n";

}   # S_InitialCleanupFile

#---------------------------------------------------------------------------
# Routine:      SelectTextFile
# Description:  This routine will look at a target directory and present
#               a list of *.txt files for the user. When the user makes
#               a selection, the full-path name for the text file
#               will be returned.
#
# Input:        aDir - Directory where the *.txt files should live
#               aMode - If 0, all .txt files will be shown, if 1,
#                   only xxx-1.txt files will be shown
#
# Returns:      empty string if user cancled or full-path name to a .txt
#               file.
#---------------------------------------------------------------------------
sub SelectTextFile {
    local ($aDir, $aMode) = @_;
    local ($lReturn) = "";          # blank is the default
    local (@lFileList);
    local ($lPattern, $lRow, $lCount, $lFileName, $lChoice);

    @lFileList = ();
    print "Looking for $aDir\\*$gFEXT ...\n";
    local (@lTempList) = glob ("$aDir\\*$gFEXT");

    # Decide if we are looking for *.txt or *-1.txt Put only the
    # matching files into lFileList
    foreach $lRow (@lTempList) {
        $lRow = lc ($lRow);
        if ( $aMode == 0 ) {
            if ( $lRow =~ m/\-\d/i ) {
                # skip
            } else {
                push (@lFileList, $lRow);
            }
        } else {
            # Mode 1/2/3
            if ( $lRow =~ m/\-\d/ ) {
                push (@lFileList, $lRow);
            }
        }
    }

    # Now print the menu of choices

    $lCount = $#lFileList;
    if ( $lCount > -1 ) {

        $lCount = 1;
        print "Please select a file by number:\n";
        foreach $lRow (@lFileList) {

            # Strip the file name from the end
            $lFileName = $lRow;
            $lFileName =~ s/^.*\\//;
            print "\t $lCount -  $lFileName\n";
            $lCount++;
        }

        print "Choice: ";
        $lChoice = <STDIN>;
        chomp ($lChoice);
        $lReturn = $lFileList[$lChoice - 1];
    } else {
        print "Error: There are no text files in ($aDir) to work with\n";
    }

    #print "Selection was: ($lReturn)\n";
    return ($lReturn);

}   # SelectTextFile

#---------------------------------------------------------------------------
# Routine:      StripAsciiCharsFromRow
# Description:  This routine looks for ascii chars to strip. This must be
#               done differently than for binary chars so we dont mess up
#               uuencoded blocks which might contain these chars by accident.
#               This routine first tests to make sure the row does not look
#               like: "Mxldslfjdlsalakjfldksajfla"
#---------------------------------------------------------------------------
sub StripAsciiCharsFromRow {
    local ($aRow) = @_;

    $lRow = $aRow;

    # Make sure this is not a uuencoded row
    if (length ($lRow) == $gUUENCODE_LINE_LENGTH &&
       ( $lRow =~ m/^M/)) {

        return ($lRow);

    }

    # Some editor puts in things like:
    #  &#8211; - ?? I think it's "-"
    #  &#8216; - opening single quote
    #  &#8217; - single quote
    #  &#8220; - opening double quote
    #  &#8221; - closing double quote
    #  &#8230; - ?? I think its ".."
    #
    # Handle this here

    $lRow =~ s/\&\#8211\;/\-/g;

    $lRow =~ s/\&\#8216\;/\`/g;
    $lRow =~ s/\&\#8217\;/\'/g;
                #
    $lRow =~ s/\&\#8220\;/\"/g;
    $lRow =~ s/\&\#8221\;/\"/g;

    $lRow =~ s/\&\#8230\;/\.\./g;

    $lRow =~ s/\=85/ \.\.\. /g;
    $lRow =~ s/\=91/\`/g;       # URL 91 - backquote
    $lRow =~ s/\=92/\'/g;       # URL 92 - forward quote
    $lRow =~ s/\=93/\"/g;
    $lRow =~ s/\=94/\"/g;
    $lRow =~ s/\=96/\-/g;       # URL 96 - dash
    $lRow =~ s/\=97/ \-\- /g;     # URL 97 - extended dash



    ## Now look for common divider chars like "======" or "....."
    $lRow =~ s/^\(\)//g;   # backslash chars at start
    $lRow =~ s/^\.+$//g;   # "....."
    $lRow =~ s/^\-+$//g;   # Whole row of "-----"
    $lRow =~ s/^0\~+$//g;
    $lRow =~ s/^\*+$//g;   # Whole row of "***********"
    $lRow =~ s/[\(\)]+//g; # Whole row of "()()()()"


    # There are a lot of rows like: -------------1A76
    $lRow =~ s/^\-+[0-9A-F]+$//g;

    return ($lRow);

}   # StripAsciiCharsFromRow

#---------------------------------------------------------------------------
# Routine:      StripBinaryCharsFromRow
#
#---------------------------------------------------------------------------
sub StripBinaryCharsFromRow {
    local ($aRow) = @_;
    local ($lRow) = $aRow;
    local ($lChar);

    chomp ($lRow);

    # replace any tabs with 4 spaces
    $lRow =~ s/\t/    /g;

    # replace form-feeds with newlines
    $lRow =~ s/\f/\n\n/g;


    $lRow =~ s/\x85//g;     # Hex 133 funny .... chars
    $lRow =~ s/\xA0/ /g;    # Hex 133 funny .... chars

    # Multi-character replacements

    $lChar = "\xE2\x2D\x20\x9C";
    if ($lRow =~ m/$lChar/) {
        print "\n\nFound Funny starting ($lChar)\n\n";
    }

    $lRow =~ s/\xE2\x80\x9C/\`/g;      # Hex 226 p 156
    $lRow =~ s/\xE2\x80\x9D/\'/g;      # Hex 226 p 157


    $lRow =~ s/\xE2\x80\x98/\"/g;     # Hex 226, 128, 152
    $lRow =~ s/\xE2\x80\x99/\'/g;     # Hex 226, 128, 153

    $lRow =~ s/\xE2\x80\x22\x20/\"/g;  # Hex 226 128 space

    $lRow =~ s/\xE2\x80\xB0//g;        # Hex 226 128 176


    $lRow =~ s/\xC2\xC1\\/\-/g;       # Hex 194, 193

    # Add in single-quotes
    $lRow =~ s/\x19/\'/g;   # Hex 025
    $lRow =~ s/\x92/\'/g;   # Hex 146
    $lRow =~ s/\x99/\'/g;   # Hex 153
    $lRow =~ s/\xB1/\`/g;   # Hex 177
    $lRow =~ s/\xB2/\'/g;   # Hex 178
    $lRow =~ s/\xB4/\'/g;   # Hex 180
    $lRow =~ s/\xB9/\'/g;   # Hex 185
    $lRow =~ s/\xBC/\'/g;   # Hex 188
    $lRow =~ s/\xBD/\'/g;   # Hex 189
    $lRow =~ s/\xE9/\'/g;   # Hex 233
    $lRow =~ s/\xED/\'/g;   # Hex 237

    # Double Quotes
    $lRow =~ s/\x81/\"/g;       # Hex 129
    $lRow =~ s/\x84/\"/g;       # Hex 132
    $lRow =~ s/\x93/\"/g;       # Hex 147
    $lRow =~ s/\x94/\"/g;       # Hex 148
    $lRow =~ s/\xB3/\"/g;       # Hex 179

    # Back-quotes
    $lRow =~ s/\x8C/\`/g;       # Hex 140
    $lRow =~ s/\x91/\`/g;       # Hex 145

    # Copyright symbol - Dash
    $lRow =~ s/\xA9/\-/g;       # Hex 169
    $lRow =~ s/\x96/\-/g;       # Hex 150
    $lRow =~ s/\xB7/\-/g;       # Hex 183
    $lRow =~ s/\x9F\x9F/\-/g;   # Hex 159 159
    $lRow =~ s/\xBE/\-/g;       # Hex 190

    # Funny way of `this'
    $lRow =~ s/\xF2/\`/g;       # Hex 242
    $lRow =~ s/\xF3/\'/g;       # Hex 243

    # Funny upside-down Exclemation point
    $lRow =~ s/\xAD /\!/g;      # Hex 173

    # Soft spaces
    $lRow =~ s/\x97+/ /g;       # Hex 151

    # elipses (...)
    $lRow =~ s/\x8B/\.\.\./g;   # Hex 139
    $lRow =~ s/\xC9/\.\.\./g;   # Hex 201

    # Funny accent of naive
    $lRow =~ s/\xEF/i/g;       # Hex 239
    $lRow =~ s/\xE7/c/g;       # Hex 231
    $lRow =~ s/\xE8/i/g;       # Hex 232

    # Carriage Returns
    $lRow =~ s/\x0A/\n/g;       # Hex 010


    # Things to just strip out
    $lRow =~ s/\x04//g;   # Hex 004
    $lRow =~ s/\x07//g;   # Hex 007 - Bell
    $lRow =~ s/\x0B//g;   # Hex 011 - VT
    $lRow =~ s/\x0E//g;   # Hex 014 - Music Note
    $lRow =~ s/\x1A//g;   # Hex 026 - CtrlZ *** This kills the input
    $lRow =~ s/\xA1//g;   # Hex 161
    $lRow =~ s/\xA2//g;   # Hex 162
    $lRow =~ s/\xA4//g;   # Hex 164
    $lRow =~ s/\xC2//g;   # Hex 194


    # Bullited lists
    $lRow =~ s/\x80/\- /g;   # Hex 128




    return ($lRow);

}   # StripBinaryCharsFromRow

#---------------------------------------------------------------------------
# Routine:      IncrimentFileName
# Description:  This routine will take a full-path file name like:
#                   c:\temp\sto3-1.txt and will return a incrimented
#               file name like c:\temp\sto3-2.txt
#
# Input:        aFileName - full-path string like: c:\temp\sto3.txt
#
# Returns:      lNewName - full-path string like: c:\temp\sto3-01.txt
#
#---------------------------------------------------------------------------
sub IncrimentFileName {
    local ($aFileName) = @_;
    local ($lOrigFile, $lNewName, $lCount);

    # Trim off the file name from the full path
    $lOrigFile = $aFileName;
    $lOrigFile =~ s/^.*\\//;        # lFile now is just a file name
    $lNewName = $lOrigFile;

    # We could have gotten sto3.txt or sto3-2.txt. See which
    if ($lNewName =~ m/\-(\d+)$gFEXT/) {
        # Got it
        $lCount = $1;
        $lCount++;
        $lNewName =~ s/\-\d+$gFEXT/\-$lCount$gFEXT/;
    } else {
        # Just add a "-1" before the extension
        $lNewName =~ s/$gFEXT$/\-1$gFEXT/;
    }

    # Put the new name in place of the old name on the original string

    $aFileName =~ s/$lOrigFile/$lNewName/;

    return ($aFileName);
}   # IncrimentFileName

#---------------------------------------------------------------------------
# Routine:      StripBinaryChars
# Description:  This routine will take a input file name and a output
#               file name. The input file will be opened and read char-by
#               char and binary characters will be replaced with ascii
#               text characters.
#
#---------------------------------------------------------------------------
sub StripBinaryChars {
    local ($aSrcFile, $aDestFile) = @_;
    local ($lChar, $lRow);
    local ($lRowCount) = 1;

    if ( -e $aDestFile ) {
        unlink ($aDestFile);
    }

    open (INFILE, "$aSrcFile") || die ("Error: cannot open ($aSrcFile) for input\n");
    open (OUTFILE, ">$aDestFile") || die ("Error: Cannot open ($aDestFile) for output\n");
    binmode OUTFILE;

    print "Reading from $aSrcFile to $aDestFile\n";

    while ( <INFILE> ) {
        $lRow = $_;
        $lRow = &StripBinaryCharsFromRow ($lRow);

        #foreach (unpack ("C*", $lRow)) {
        #    if ( $_ < 32 && $_ != 13 && $_ != 10 ) {
        #        print "($lRowCount) $lRow : $_\n";
        #    }
        #}


        foreach (unpack ("C*", $lRow)) {
            if ( $_ > 126 ) {
                print "($lRowCount) $lRow : $_\n";
            }
        }

        print OUTFILE "$lRow\n";
        $lRowCount++;
    }


    #while ( defined ($lChar = getc INFILE) ) {
    #
    #    if ( ord ($lChr) == 13 ) {
    #        $lRowCount++;
    #    }
    #
    #    # 13 - CR, 10 - LF
    #    if ( $lChar LT " "  && ord ($lChar) != 10 && ord ($lChar) != 13) {
    #        if ( ord ($lChar) == 12 ) {
    #            # Convert Form Feeds to 2 CR/LF combos
    #            print OUTFILE "\n\n";
    #        }
    #        print "Found smaller than space char, Row $lRowCount: " . ord ($lChar) . " - " . $lChar . "\n";
    #        print OUTFILE " ";
    #    } elsif ($lChar GT "~") {
    #        #print "Found Larger than tilda char: " . ord ($lChar) . "\n";
    #        print OUTFILE " ";
    #    } else {
    #        print OUTFILE "$lChar";
    #    }
    #
    #}

    close (OUTFILE);
    close (INFILE);

    local ($lSrcSize) = -s $aSrcFile;
    local ($lDestSize) = -s $aDestFile;

    print "Src File:  $lSrcSize\n";
    print "Dest File: $lDestSize\n";

}   # StripBinaryChars

#---------------------------------------------------------------------------
# Routine:      TestBinaryRead
# Description:  This routine will try to open a raw text file and
#               strip the word-processing and binary characters
#               from it.
#---------------------------------------------------------------------------
sub TestBinaryRead {
    local ($aDir) = @_;
    local ($lSrcFile, $lDestFile);
    local ($lRow);

    $lDestFile = "C:\\temp\\clean.out";
    &StripBinaryChars ($aDir, $lDestFile);
    return;

    #open (INFILE, "$aDir");
    #open (OUTFILE, ">$lDestFile");
    #binmode OUTFILE;

    #while ( <INFILE> ) {
    #    $lRow = $_;
    #    chomp ($lRow);
    #    print OUTFILE "$lRow\n";
    #}

    #close OUTFILE;
    #close INFILE;
    #return;

    # Ask the user which file to read
    $lSrcFile = &SelectTextFile ($gWORKING_DIR, 0);
    if ( length ($lSrcFile) > 1 ) {
        &StripBinaryChars ($lSrcFile, $lDestFile);
    }



}   # TestBinaryRead

#---------------------------------------------------------------------------
# Routine:      S_TestParaAnalysis
# Description:  This routine will take a text file, break it up into
#               individual articles and analyze the paragraphs
#---------------------------------------------------------------------------
sub S_TestParaAnalysis {
    local ($aInFile) = @_;
    local ($lOutFile);          # aInFile = sto1-1.txt, lOutFile will be sto1-2.txt
	local (@lBreakIndex) = ();	# contains row-number | subject line pairs
	local (%lSubjectArray) = ();	# contains Subject | file name pairs
    local ($lFileCount) = 0;
    local (@lPara) = ();        # To hold paragraph numbers
    local ($i);

    # See if the parent gave us a name, or do we prompt for one

    if ( $aInFile eq "" ) {
        $aInFile = &SelectTextFile ($gWORKING_DIR, 1);
    }

    # Calculate the new outfile name
    # Hard code for now
    $lOutFile = &IncrimentFileName ($aInFile);
    print "TPA:NewFile name = $lOutFile\n";
    if ( -e $lOutFile ) {
        unlink ($lOutFile);
    }

    # Make sure we dont have the temp file left over

    if (-e $gTEMP_FILE) {
        unlink ($gTEMP_FILE);
    }
    if ( ! (-e $aInFile)) {
        print "TPA: Error - Input file ($aInFile) does not exist\n";
    }


	# Call a routine to analyze the story file and return a array
	# that tells us the end-row of each story, and the "Subject:"
	# line for each one.

    print "TPA: Analyzing breaks in ($aInFile)...\n";
    @lBreakIndex = &S_GetSubjectBreaks ($aInFile);

	# Use the break index array to split the big file up into smaller
	# story files. It will return a Associative array with the
	# subject lines as the index and the file names as the members.
	# This will allow us to pull the smaller story files into a
	# single file, but sorted by Subject header

    print "TPA: Breaking ($aInFile) into smaller files...\n";
    %lSubjectArray = &S_SplitSubjectBreaks ($aInFile, @lBreakIndex);


	# Our %lSubjectArray now looks like
	#     lSubjectArray["Subject: fubar"] = "t0000.tmp"
	#     lSubjectArray["Subject: this is mine"] = "t0001.tmp"
	#
	# Using the index, grab the file names in order and put them into
	# a new file

    open (OUTFILE, ">$lOutFile") || die ("Cannot open $lOutFile for output\n");

	foreach $lSubject (sort (keys(%lSubjectArray))) {
		$lFileName = $lSubjectArray{$lSubject};
		# print "Out: $lFileName - $lSubject\n";



        # Grab the temporary file and read it's rows into
        # the global array gText

        &FillGTextArray($lFileName);

        # Analize the paragraphs in gText

        &AnalyzeText(@gText);

        # Write the un-wrapped gText array to the output file

		print OUTFILE "$gDIVIDER";

        for ( $i = 0; $i < $gGTextSize; $i++ ) {
            print OUTFILE "$gText[$i]\n";
        }

        $lFileCount++;
	}

	close (OUTFILE);
	system "del *.tmp";
    print "Original file     : $aInFile\n";
    print "Word-wrapped file : $lOutFile\n";



}   # S_TestParaAnalysis



#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
sub S_FixDirectoryText {
   my (%args) = @_;
   my $lRow;

   open (IN_FILE, $args{in_file}) or die ("$!");
   open (OUT_FILE, ">$args{out_file}") or die ("$!");

   while ( $lRow = <IN_FILE> ) {
      next if (index ($lRow, '.jpg') > -1 );
      next if (index ($lRow, '.JPG') > -1 );
      next if (index ($lRow, '.zip') > -1 );
      next if (index ($lRow, '.ZIP') > -1 );
      print OUT_FILE $lRow;
   }

   close (OUT_FILE) or die ("$!");
   close (IN_FILE) or die ("$!");
   print "Output file: $args{out_file}\n";

}

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
    print "        Text Utility 2 - Main Menu\n";
    print "--------------------------------------------\n";
    print "Please choose an option:\n";
    print "\t0 - Exit\n";
    print "\t1 - First Pass cleanup\n";
    print "\t2 - Sort by Subject: heading\n";
    print "\t3 - Add CRC Headers\n";
    print "\t4 - Unwrap Text\n";
    print "\t5 - \n";
    print "\t6 - \n";
    print "\t7 - Paragraph Analysis - Test\n";
    print "\t8 - Test Binary read\n";
    print "\t9 - Select text file\n";
	print "\t10 - Fix Kristin File\n";
	 print "\t11 - Clean Directory.txt\n";
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


        if ( $lChoice > -1 && $lChoice < 15 ) {
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

    #&S_InitialCleanupFile ("c:\\temp\\sub.txt");
    #exit (0);

    local ($lTemp) = $ARGV[0];
    if ( $lTemp ne "" ) {
        $lChoice = $lTemp;
    }

    while ( $lFinished != 1 ) {

        if ( $lChoice == -1 ) {
            $lChoice = &S_GetChoice();
            print "main: got choice ($lChoice)\n";
        }

        if ( $lChoice eq "0" ) {
            $lFinished = 1;
        } elsif ($lChoice eq "1") {
            #&S_InitialCleanupFile ("a.txt");
            &S_InitialCleanupFile ();
            $lFinished = 1;
        } elsif ($lChoice eq "2") {
            &S_SortStoryFile ($gWORKING_DIR . "\\2001c-c.txt");
            $lFinished = 1;
        } elsif ($lChoice eq "3") {
            &S_AddCRCHeaders ($gWORKING_DIR . "\\test-1$gFEXT");
            $lFinished = 1;
        } elsif ($lChoice eq "4") {
            &S_UnWrapFile ("");
            $lFinished = 1;
        } elsif ($lChoice eq "5") {
            $lFinished = 1;
        } elsif ($lChoice eq "6") {
            $lFinished = 1;
        } elsif ($lChoice eq "7") {
            &S_TestParaAnalysis ();
            $lFinished = 1;
        } elsif ($lChoice eq "8") {
            &TestBinaryRead ($gWORKING_DIR . "\\btest.txt");
            exit (0);
            $lFinished = 1;
        } elsif ($lChoice eq "9") {
            &SelectTextFile ($gWORKING_DIR, 0);
            &SelectTextFile ($gWORKING_DIR, 1);
            $lFinished = 1;
        } elsif ($lChoice eq "10") {
			&S_FixKristenFile ( path => "d:\\temp\\text_proc", file => "stories_raw009.txt" );
            $lFinished = 1;
        } elsif ($lChoice eq "11") {
            &S_FixDirectoryText( in_file => 'directory.txt', out_file => 'dir_clean.txt');
            $lFinished = 1;
        }
    }


    local ($lRunTime) = time - $^T;
    print "Run Time: " . &Sec2HMS ($lRunTime) . "\n";

}       # Main

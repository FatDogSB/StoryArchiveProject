# File: TU3.pl
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

	my %gGARBAGE_ROWS = (
		'<p><a name="_GoBack"></a>'			=> 0,
		'<p></p>'							=> 0,
		'<meta http-equiv="Content-Style-Type" content="text/css">'		=> 0,
		'<p><p class=rvps1>span></p></p>'	=> 0,
		'<p><p class=rvps2>span></p></p>'	=> 0,
		'<p><p class=rvps3>span></p></p>'	=> 0,
		'<p><p class=rvps4>span></p></p>'	=> 0,
		'</p>p class=rvps1>span></p>'		=> 0,
		'</p>p class=rvps2>span></p>'		=> 0,
		'</p>p class=rvps3>span></p>'		=> 0,
		'</p>p class=rvps4>span></p>'		=> 0,
		'<p>span class=rvts1>'				=> 0,
		'<p>span class=rvts2>'				=> 0,
		'<p>span class=rvts3>'				=> 0,
		'<p>span class=rvts4>'				=> 0,
		'<p>span class=rvts5>'				=> 0,
		'<p>span class=rvts6>'				=> 0,
		'<p>span class=rvts7>'				=> 0,
		'<p>span class=rvts8>'				=> 0,
		'<p>&amp;&amp;&amp;</p>'			=> 0,
		'<p></p>'							=> 0,
		'<p><p>span></p>'					=> 0,
		'<p><p>span></p></p>'				=> 0,
		'</p>p>span></p>'					=> 0,
		'</p>'								=> 0,
		'</pre>'							=> 0,
		'<pre>'								=> 0,
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
#---------------------------------------------------------------------------
sub S_CleanStoryBuffer {
	my (%args) = @_;
	my (@lTemp, $lRow);
	
	@lTemp = ();
	foreach $lRow ( split ("\n", $args{story}) ) {
	
		# Strip white space from end
		$lRow =~ s/\s+$//;
		
		next if ( exists $gGARBAGE_ROWS{$lRow});
		next if ( index ($lRow, '>span>') > -1);
		next if ( index ($lRow, '_GoBack') > -1);
		if ( index ($lRow, '<p><a name="_Toc') > -1) {
			$lRow = '<p>';
		}
		if ( index ($lRow, 'span class=r') > -1) {
			$lRow =~ s/span class[^>]*//;
		}

		if ( index ($lRow, ' <') > -1 ) {
			$lRow =~ s/\s+\</</g;
		}
		# Look for scene breaks like <p>============</p>
		if ( index ( $lRow, '<p>*') > -1 ) {
			$lRow = '<div class="scene_break">* * *</div>' if ( $lRow =~ m/\>[* ]*\</ );
		}
		if ( index ( $lRow, '<p>-') > -1 ) {
			$lRow = '<div class="scene_break">* * *</div>' if ( $lRow =~ m/\>[- ]*\</ );
		}
		if ( index ( $lRow, '<p>=') > -1 ) {
			$lRow = '<div class="scene_break">* * *</div>' if ( $lRow =~ m/\>[= ]*\</ );
		}
		# Look for space</p>
		if ( index ( $lRow, ' </p') > -1 ) {
			$lRow =~ s/\s+\<\/p/\<\/p/g;
		}

	



		$lRow = &StripBinaryCharsFromRow($lRow);
		if ( index ($lRow, '<p class') > -1 ) {
			$lRow =~ s/^\<p [^>]*/<p/;
			#print substr( $lRow, 0, 40) . "\n";
		}
		
		push (@lTemp, $lRow);
		
		#if ( index ($lRow, '<p><p>span></p>') > -1 ) {
		#	print "$lRow\n";
		#	<STDIN>;
		#}
		
	}
	#print "$args{story}\n";
	#<STDIN>;
	
	$args{story} = join ("\n", @lTemp);
	# Look for "<p class=rvps>..." constructs at the beginning
	
	
	$args{story} =~ s/$\<p [^>]*/<p/g;
	$args{story} =~ s/\&#8216;/\`/g;
	$args{story} =~ s/\&#8217;/\'/g;
	

	return ($args{story});
}	# S_CleanStoryBuffer

#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
sub S_InitialCleanupFile {
	my (%args) = @_;
	my ($lInFile, $lOutFile, $lInStory);
	my ($lBuffer, $lRow);
	
	# Validate arguments
	if ( ! -e $args{in_file} ) {
		print "Error: input file does not exist: $args{in_file}\n";
	}
	
	$lInFile = $args{in_file};
	$lOutFile = $args{out_file};
	open (IN_FILE, $lInFile) or die ("Error: Could not open file for input: $lInFile : $!\n");
	open (OUT_FILE, ">$lOutFile") or die ("Error: Could not open file for output: $lOutFile: $!\n");
	$lInStory = 0;
	while ( $lRow = <IN_FILE> ) {
		#chomp ($lRow);
		
		$lInStory = 1 if ( index ($lRow, '{-------') > -1 and $lInStory == 0 );
		$lBuffer .= $lRow;
		if ( index ($lRow, '{-------') > -1 and $lInStory == 1 ) {
			# Just found the end of the current story.
			$lInStory = 0;
			$lBuffer .= $lRow;
			$lBuffer = &S_CleanStoryBuffer ( story => $lBuffer );
			print OUT_FILE "$lBuffer\n\n";
			$lBuffer = "";			
		}
		
		
	}
	
	close (IN_FILE);
	close (OUT_FILE);
	
	
}	# S_InitialCleanupFile

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
    print "        Text Utility 3 - Main Menu\n";
    print "--------------------------------------------\n";
    print "Please choose an option:\n";
    print "\t0 - Exit\n";
    print "\t1 - First Pass cleanup\n";
    print "\t2 - \n";
    print "\t3 - \n";
    print "\t4 - \n";
    print "\t5 - \n";
    print "\t6 - \n";
    print "\t7 - \n";
    print "\t8 - \n";
    print "\t9 - \n";
	print "\t10 - \n";
	 print "\t11 - \n";
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
            &S_InitialCleanupFile ( in_file => 'bd06.txt', out_file => 'bd06a.txt');
            $lFinished = 1;
        } elsif ($lChoice eq "2") {
            $lFinished = 1;
        } elsif ($lChoice eq "3") {
            $lFinished = 1;
        } elsif ($lChoice eq "4") {
            $lFinished = 1;
        } elsif ($lChoice eq "5") {
            $lFinished = 1;
        } elsif ($lChoice eq "6") {
            $lFinished = 1;
        } elsif ($lChoice eq "7") {
            $lFinished = 1;
        } elsif ($lChoice eq "8") {
            $lFinished = 1;
        } elsif ($lChoice eq "9") {
            $lFinished = 1;
        } elsif ($lChoice eq "10") {
            $lFinished = 1;
        } elsif ($lChoice eq "11") {
            $lFinished = 1;
        }
    }


    local ($lRunTime) = time - $^T;
    print "Run Time: " . &Sec2HMS ($lRunTime) . "\n";

}       # Main

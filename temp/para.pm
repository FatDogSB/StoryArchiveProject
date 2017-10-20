#!/usr/bin/perl
package para;
#
# AUTHOR:	Bob McElfresh
# DATE:		2008-08-22
#
# MODULE_NAME: para.pm
#
use strict;
use warnings;
use diagnostics;
use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION     = '0.01';
@ISA         = qw(Exporter);
@EXPORT      = ();
@EXPORT_OK   = qw();
%EXPORT_TAGS = ( DEFAULT => [qw(&func1)],
                 Both    => [qw(&func1 &func2)]);


sub new
{
	my $class = shift;
	my %args  = @_;
	my @lText = ();
	my ($lRow, $lRowCount);

	#if (ref $arg  eq 'HASH')
	#{
	#  $val = $arg->{val} if defined $arg->{val};
	#}
	#else
	#{
	#  die "Missing argument hash";
	#}

	#print "new para: ($args{start}) - ($args{end})\n";

	# Make a copy of the text
	@lText = ();
	$lRowCount = 0;
	foreach $lRow (@{$args{text}}) {
		push (@lText, $lRow);
		$lRowCount++;
	}

	my $self = {
		mStart		=> $args{start},
		mEnd		=> $args{end},
	    mText		=> \@lText,
		mRowCount	=> $lRowCount,
		mType		=> 'text',
		mTag1		=> '<p>',
		mTag2		=> '</p>',
	};


	bless $self, $class;
	return $self;
}	# new

#-------------------------------------------------------------------------------------
# Routine:		print_text
# Description:  takes the array of text, slaps the opening and ending tags around it
#				and returns a scalar variable containing all the text.
#-------------------------------------------------------------------------------------

sub print_text 
{
	my $self = shift;
	my $lBuf = "";

	$lBuf = $self->{mTag1} . "\n";;
	foreach my $lRow (@{$self->{mText}}) {

		# Clean up the special characters that will mess up the xhtml

		$lRow =~ s/\&/and/g if ( index ($lRow, '&') > -1);

		$lBuf .= $lRow;
		#print "$lRow";
	}

	$lBuf .= "\n" . $self->{mTag2} . "\n";

	return ($lBuf);

}	# print_text

#----------------------------------------------------------------------------------------
# Routine:		analyze_class
# Description:	Routine that reads through the array of article rows and tries to determine
#				what tags belong around each paragraph.
#----------------------------------------------------------------------------------------
sub analyze_class
{
	my $self = shift;
	my ($lBuf, $lRow);
	my ($lInteractive) = 0;
	my $lQuoteCount = 0;

	# The files sometimes come with a few divisions already defined:
	#		ng_header     - Header for the newsgroup block
	#		s_disclaimer  - Disclaimer block
	#
	# We need to know if this article already has these and what the row numbers are

	# The rows in the array end in \n


	foreach $lRow (@{$self->{mText}}) {
		$lBuf .= $lRow;
	}

	# Test 1: ng_header

	if (index ($lBuf, 'Subject: ') > -1 and index ($lBuf, 'From: ') > -1) {


		# Make sure these are at the beginning of a row
		if ($lBuf =~ m/Subject:/ and $lBuf =~ m/From:/) {
			$self->{mType} = 'ng_header';
			$self->{mTag1} = '<div class="ng_header"><pre>';
			$self->{mTag2} = '</pre></div> <!-- ng_header -->';
			return;
		}
	}


}	# analyze_class

sub func1  
{ 
	my $this= shift;
	my $class= ref($this);
	my ($parm1, $parm2)= @_;
	return $parm1;
}

#============================================================================================

package uword;
#
# AUTHOR:	Bob McElfresh
# DATE:		2008-08-22
#
use strict;
use warnings;
use diagnostics;
use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION     = '0.01';
@ISA         = qw(Exporter);
@EXPORT      = ();
@EXPORT_OK   = qw();
%EXPORT_TAGS = ( DEFAULT => [qw(&func1)],
                 Both    => [qw(&func1 &func2)]);


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


my $TAG_NG_HEADER_1 = '<div class="ng_header"><pre>';
my $TAG_NG_HEADER_2 = '</pre></div> <!-- ng_header -->';


my $TAG_NG_DISCLAIMER_1 = '<div class="s_disclaimer"><pre>';
my $TAG_NG_DISCLAIMER_2 = '</pre></div> <!-- s_disclaimer -->';
my $TAG_PRE_DIV_END     = '</pre></div>';

my $TAG_NG_SBREAK_1 = '<div class="s_break">';
my $TAG_NG_SBREAK_2 = '</div> <!-- s_break -->';

my $SUBJECT_PREFIX  = 'Subject: ';


#------------------------------------------------------------------------------------------
# Routine:		uword->new()
# Description:
#
# Inputs:		text - array of text
#------------------------------------------------------------------------------------------
sub new 
{
	my $class = shift;
	my %args  = @_;
	my @lText = ();
	my $lBuf;
	my ($lRow, $lRowCount);

	#if (ref $arg  eq 'HASH')
	#{
	#  $val = $arg->{val} if defined $arg->{val};
	#}
	#else
	#{
	#  die "Missing argument hash";
	#}

	#print "new para: ($args{start}) - ($args{end})\n";

	# Make a copy of the text
	@lText = ();
	$lBuf = "";
	$lRowCount = 0;
	foreach $lRow (@{$args{text}}) {
		push (@lText, $lRow);			# Store as array
		$lBuf .= $lRow;					# Store as 1 text scalar variable
		$lRowCount++;
	}

	my $self = {
		mArray			=> \@lText,
		mBuff			=> $lBuf,
		mRowCount		=> $lRowCount,
		mNGHeaderStart	=> -1,		# Row number where '<div class="ng_header"> exists/belongs
		mNGHeaderEnd 	=> -1,
		mDiscStart		=> -1,		# Row number where '<div class="s_disclaimer"> exits/belongs
		mDiscEnd		=> -1,
		mBodyStart		=> -1,		# Row number where first paragraph of text begins
		mHeaderEnd		=> -1,
		mSubjectRow		=> -1,		# Row number of subject line
	};



	bless $self, $class;
	return $self;

}	#  uword->new


#------------------------------------------------------------------------------------------
# Routine:		d_print  (debug print)
# Description:	This routine will print the current text buffer to the screen as a
#				debugging tool
#------------------------------------------------------------------------------------------
sub d_print {
	my $self = shift;
	my ($lRow, $lRowNum, $lMsg, $lTag);

	$lRowNum = 0;

	print "ngHeader:    $self->{mNGHeaderStart} : $self->{mNGHeaderEnd}\n";
	print "Disclaimer:  $self->{mDiscStart} : $self->{mDiscEnd}\n";
	print "Body Start:  $self->{mBodyStart}\n\n";


	foreach $lRow ( @{$self->{mArray}}) {
		chomp ($lRow);

		$lTag = "";
		$lTag = "ngs" if ($lRowNum == $self->{mNGHeaderStart});
		$lTag = "nge" if ($lRowNum == $self->{mNGHeaderEnd});

		$lTag = "dis" if ($lRowNum == $self->{mDiscStart});
		$lTag = "die" if ($lRowNum == $self->{mDiscEnd});

		$lTag = "bod" if ($lRowNum == $self->{mBodyStart});


		# See if something exists in the tag hash for this row number

		if (exists ${$self->{mTag}}{$lRowNum}) {
			$lRow .= ${$self->{mTag}}{$lRowNum};
		}

		$lMsg = sprintf ("%4d : %45s\n", $lRowNum, substr ($lRow, 0, 44));
		$lMsg = sprintf ("%5s %4d : %-s\n", $lTag, $lRowNum, substr ($lRow, 0, 45));
		print $lMsg;

		$lRowNum++;
		last if ($lRowNum > 29);
	}


}	# d_print

#------------------------------------------------------------------------------------------
# Routine:		_isStoryLine
# Description:	Routine to take a row of text and determine if it looks like a line
#				of story text, or something else. This is usually determined by indent
#				level and number of chars
#
# Input:		aRow - Row of text to be analyzed
#
# Returns:		0 - aRow does NOT appear to be story txt
#				1 - aRow is a line of story text
#------------------------------------------------------------------------------------------
sub _isStoryLine {
	my ($aRow) = @_;
	my $lNoWhiteSpace;

	# More than 4 spaces of indentation implies NOT story text
	$lNoWhiteSpace = $aRow;
	$lNoWhiteSpace =~ s/\s//g;

	return (0) if (length ($lNoWhiteSpace) < 20);

	# Any row starting with "fubar: " is NOT story text
	return (0) if ($aRow =~ m/^\w+\:/);

	# Any row with an ampersand like an email is NOT story text:
	return (0) if ( index ($aRow, '@') > -1);


	# Must be text
	return (1);

}	# _isStoryLine

#------------------------------------------------------------------------------------------
# Routine:		ScanExistingTags
# Description:	This routine will look at the array of text lines and identify
#				tags that might already exist:
#					ng_header
#					s_disclaimer
#				The start & ending row number for these tags will be stored (if found) in
#					mNGHeadStart, mNGHeadEnd
#					mDiscStart,   mDiscEnd
#------------------------------------------------------------------------------------------
sub ScanExistingTags {
	my $self = shift;
	my ($lRowNum, $lRow, $lBodyStart);
	

	$lRowNum = 0;
	$lBodyStart = 0;
	foreach $lRow ( @{$self->{mArray}}) {

		
		# See if this row contains: '<div class="ng_header"><pre>'

		if ($self->{mNGHeaderStart} == -1) {
			if (index ($lRow, $TAG_NG_HEADER_1) > -1) {
				$self->{mNGHeaderStart} = $lRowNum;
			}
		}

		# Note: the end tag for several divisions look identical so make sure the end
		# of the ng_header tag comes after the start.
		if ($self->{mNGHeaderEnd} == -1 and $self->{mNGHeaderStart} > 0) {
			if (index ($lRow, $TAG_NG_HEADER_2) > -1  or index ($lRow, $TAG_PRE_DIV_END) == 0) {
				$self->{mNGHeaderEnd} = $lRowNum;
				$lBodyStart = $lRowNum +1;
			}
		}

		# See if this row contains: <div class="s_disclaimer"><pre>
		if ($self->{mDiscStart} == -1) {
			if (index ($lRow, $TAG_NG_DISCLAIMER_1) > -1) {
				$self->{mDiscStart} = $lRowNum;
				$lBodyStart = $lRowNum +1;
			}
		}
		if ($self->{mDiscEnd} == -1 and $self->{mDiscStart} > 0) {
			if (index ($lRow, $TAG_NG_DISCLAIMER_2) > -1 or index ($lRow, $TAG_PRE_DIV_END) == 0) {
				$self->{mDiscEnd} = $lRowNum;
				$lBodyStart = $lRowNum +1;
			}
		}

		# See if the current row starts with "Subject:"
		if (index ($lRow, $SUBJECT_PREFIX) == 0) {
			$self->{mSubjectRow} = $lRowNum;	
		}


		# Break out of the loop if we have found all 4 tags

		if ($self->{mNGHeaderStart} > -1 and $self->{mNGHeaderEnd} > -1 and
			$self->{mDiscStart} > -1 and $self->{mNGHeaderEnd} > -1) {

		}

		$lRowNum++;
	}

	# Look for the start of the body text. We already set "$lBodyStart" above to skip past
	# the header portions (if they exist)

	$lRowNum = 0;
	foreach $lRow ( @{$self->{mArray}}) {
		if ($lRowNum < $lBodyStart) {
			$lRowNum++;
			next;
		}

		# See if this row looks like:
		# "Now is the time for all good men"
		#  or
		# The bad dog
		if ( &_isStoryLine ($lRow) == 1) {
			$lBodyStart = $lRowNum;
			last;
		}



		$lRowNum++;
	}

	$self->{mBodyStart} = $lBodyStart;


}	# ScanExistingTags

#------------------------------------------------------------------------------------------
# Routine:		tag_ngheader
# Description:	This routine will take the text in the current array and 
#				put div newsgroup headers around the newsgroup header rows:
#					Subject:  bla
#------------------------------------------------------------------------------------------
sub tag_ngheader {
	my $self = shift;
	my ($lRowNum, $lStart, $lCenter, $lEnd, $lRow);


	# Just return if we already know where the ng headers are
	return if ($self->{mNGHeaderStart} > -1);

	# Run through the text looking for "^Subject:". Track the empty row above and below this block

	($lStart, $lCenter, $lEnd) = (0,0,0);

	$lRowNum = 0;
	foreach $lRow ( @{$self->{mArray}}) {
		
		# Track empty row above the block if we have not found the ng block

		if ($lCenter == 0 and length ($lRow) == 1) {
			$lStart = $lRowNum;
		}

		# Find the "Subject:" at the beginning of the row.

		$lCenter = $lRowNum if (index ($lRow, 'Subject:') == 0);

		if ($lCenter > 0 and length ($lRow) == 1) {
			$lEnd = $lRowNum;
			last;
		}


		$lRowNum++;
	}

	# Now we should have 3 variables filled in:
	#	$lStart = rownumber for blank row ABOVE newsgroup header block
	#	$lEnd   = rownumber for blank row BELOW newsgroup header block

	# Short Cut: What if the text block already looks like this:
	#	7 :						($lStart is 7)
	#   8 : <div...
	#   9 : Subject:...			($lCenter is 9)
	#  10 : From: ...
	#  11 : </div...
	#  12 :						($lEnd is 12)
	#

	# See if the line after start begins "<..."

	$lRow = ${$self->{mArray}}[$lStart + 1];
	if (index ( $lRow, '<') == 1) {

		# See if the line above END also starts with "<"
		$lRow = ${$self->{mArray}}[$lEnd - 1];
		if (index ( $lRow, '<') == 1) {
			# Newsgroup header block is already marked
			return;
		}
	}

	# Put the tags in the text array

	${$self->{mArray}}[$lStart] =  $TAG_NG_HEADER_1;
	${$self->{mArray}}[$lEnd]   =  $TAG_NG_HEADER_2;


	# Document what rows the tags are on so other routines can skip over them

	$self->{mNGHeaderStart} = $lStart;
	$self->{mNGHeaderEnd}   = $lEnd;



}	# tag_ngheader


#------------------------------------------------------------------------------------------
# Routine:		tag_sbreak
# Description:	This routine will search through the array of text and find section or
#				chapter breaks and wrap tags around the text
#					Chapter 7    becomes
#					<div class="s_break">Chapter 7</div>
#
#					my $TAG_NG_SBREAK_1 = '<div class="s_break">';
#					my $TAG_NG_SBREAK_2 = '</div> <!-- s_break -->';
#
#------------------------------------------------------------------------------------------
sub tag_sbreak {
	my $self = shift;
	my ($lRow, $lRowNum, $lMsg);
	my (@lBreakArray);

	$lRowNum = 0;
	@lBreakArray = ();

	# Run through the text looking for obvious things like "Chapter" and "Part".
	# Put the row numbers if any are found in an array like this:
	#	$lBreakArray[0] = "17|17"
	#   $lBreakArray[1] = "45|45"
	#
	# A later routine will scan above and below lines 17 and 45 to see if the chapter
	# breaks should really be more than 1 row

	foreach $lRow ( @{$self->{mArray}}) {

		# Skip past the ng header.

		if ($self->{mHeaderEnd} > 1 and $lRowNum < $self->{mHeaderEnd}) {
			$lRowNum++;
			next;
		}

		if ($lRow =~ m/^\s*chapter/i) {
			push (@lBreakArray, "$lRowNum|$lRowNum");
			#print "sbreak: $lRowNum : $lRow\n";
		}

		# Look for dash chars or '****' chars
		if ($lRow =~ m/^\s*[\=\-\*]{3,}$/) {
			push (@lBreakArray, "$lRowNum|$lRowNum");
			#print "sbreak: $lRowNum : $lRow\n";
		}

		$lRowNum++;
	}

	# Go through the array and look at previous and next lines for stuff like this:
	#				The terror
	#              
	#                by bob
	# 
	#                Chapter 7
	# 
	#                by steve

	my ($lBreak, $lStart, $lEnd, $lIndex, $lDone);
	$lIndex = 0;
	foreach $lBreak (@lBreakArray) {
		($lStart, $lEnd) = split (/\|/, $lBreak);			# Get the start and end row numbers


		$lRow = ${$self->{mArray}}[$lStart];

		# Look for indents
		if ($lRow =~ m/^\s+/) {
			print "\nIndented Section break at $lStart : $lEnd.  Looking around:\n";

			
			# Go backwards until we find the first un-indented line

			$lDone = 0;
			while ( $lDone == 0) {
				$lStart--;
				last if ($lStart < 2);
				$lRow = ${$self->{mArray}}[$lStart];
				#print "B $lStart : " . substr ($lRow, 0, 40) . "\n";
				next if (length ($lRow) == 1);			# Blank line
				next if ( $lRow =~ m/^\s{5,}/);			# Indent

				$lDone = 1;
			}
			$lStart++;

			while (length (${$self->{mArray}}[$lStart]) < 2) {
				$lStart++;
			}
			$lStart--;
			
			# Go forwards
			$lDone = 0;
			while ( $lDone == 0) {
				$lEnd++;
				last if ($lEnd >= $self->{mRowCount});
				$lRow = ${$self->{mArray}}[$lEnd];
				next if (length ($lRow) == 1);			# Blank line
				next if ( $lRow =~ m/^\s{5,}/);			# Indent

				$lDone = 1;
			}
			$lEnd--;		
			while (length (${$self->{mArray}}[$lEnd]) < 2) {
				$lEnd--;
			}
			$lEnd++;


			## DEBUG PRINT
			my $i;
			print "sbreak between $lStart - $lEnd\n";

			for ($i = $lStart - 3; $i < $lEnd + 3; $i++) {


				if ($i == $lStart) {
					print sprintf ("%3d : sbreak begin\n", $i);
					next;
				}

				if ($i == $lEnd) {
					print sprintf ("%3d : sbreak end\n", $i);
					next;
				}

				$lRow = ${$self->{mArray}}[$i];
				$lRow = substr ($lRow, 0, 45);
				print sprintf ("%3d : %s\n", $i, $lRow);
			}
			print "Press any key...";
			<STDIN>;


		}



		$lIndex++;
	}

}	# tag_sbreak

#------------------------------------------------------------------------------------------
# Routine:		findBodyStart
# Description:	The tagNGHeader() routine tried to set mBodyStart, but there could be 
#				a "<div class="s_title" ... </div> pair of tags we want to skip around.
#				This routine bumps mBodyStart to the text paragraph past this.
#
#------------------------------------------------------------------------------------------
sub findBodyStart {
	my $self = shift;
	my ($lRowNum, $lRow);
	my ($lBodyStart, $lInBlock);

	$lInBlock = 0;
	$lBodyStart = $self->{mBodyStart};
	for ($lRowNum = $lBodyStart; $lRowNum < $self->{mRowCount}; $lRowNum++) {
		$lRow = ${$self->{mArray}}[$lRowNum];

		# See if we hit a title block (which could have paragraphs)

		if (index ($lRow, '<div class="s_title"') > -1) {
			$lInBlock = 1;		# Set flag
		}

		# See if we hit a closing div tag for the s_title block
		
		if ($lInBlock and index ($lRow, '</div>') > -1) {
			$lBodyStart = $lRowNum + 1;
			$lInBlock = 0;
		}
	}

	# See if our local body start number changed from the original. If so, we have to hunt
	# forward for the start of the paragraph

	if ($lBodyStart > $self->{mBodyStart}) {
		for ($lRowNum = $lBodyStart; $lRowNum < $self->{mRowCount}; $lRowNum++) {
			$lRow = ${$self->{mArray}}[$lRowNum];

			if ( &_isStoryLine ($lRow) == 1) {
				$self->{mBodyStart} = $lRowNum;
				return;
			}

		}

	}

}	# findBodyStart

#------------------------------------------------------------------------------------------
# Routine:		findSubjectTitle
# Description:	This routine will look at the "Subject: ..." line to try and determine 
#				the title of the current article.
#
#------------------------------------------------------------------------------------------
sub findSubjectTitle {
	my $self = shift;
	my ($lTitle) = "";
	my ($lRowNum, $lRow);
	
	# Find the subject row.
	$lRowNum = $self->{mSubjectRow};
	if ($lRowNum > -1) {
		$lRow = ${$self->{mArray}}[$lRowNum];

		# See if the title is in double quotes
		if ($lRow =~ m/^Subject: \"([^\"]*)/) {
			$lTitle = $1;
			#print "Sub:   " . substr ($lRow, 0, 40) . "\n";
			#print "Title: $lTitle\n";
			return ($lTitle);
		}

		# Many times the title is not double-quoted so take all the text before any brackets or parens

		if ($lRow =~ m/^Subject: ([^\(\[\{]*)/) {
			$lTitle = $1;
			#print "Sub:   " . substr ($lRow, 0, 40) . "\n";
			#print "Title: $lTitle\n";
			return ($lTitle);
		}
	}

	if ($lTitle eq "") {
		print "Warning: Could not extract title from subject line:\n\t$lRow\n\n";
	}
	return ($lTitle);

}	# findSubjectTitle

#------------------------------------------------------------------------------------------
# Routine:		writeFile
# Description:	This routine will write the text array to the specified output file
#
# Input:		file - Full path to the file name to create
#------------------------------------------------------------------------------------------
sub writeFile {
	my $self = shift;
	my %args  = @_;
	my ($lRowNum, $lRow, $lTitle);
	my ($lPrevLen, $lLen, $lNextLen);
	my ($lInParagraph);


	if ( ! exists $args{file}) {
		die ("Error: writeFile() routine requires a file => argument\n");
		return;
	}

	if ( -e $args{file} ) {
		unlink ($args{file}) or die ("Error: Cannot unlink file: $args{file} : $!\n");
	}

	$self->findBodyStart();
	$lTitle = $self->findSubjectTitle();


	open (OUT_FILE, ">$args{file}") or die ("Error: Cannot open file for output: $args{file} : $!\n");

	# Print the doctype statement
	print OUT_FILE $gDOCTYPE_HTML;

	# Print the section that points to 'base.css'
	my $lTemp = $gHEAD_TITLE_CSS;		# Contains generic title
	$lTemp =~ s/fill_me/$lTitle/;
	print OUT_FILE $lTemp;


	$lRowNum = 0;
	$lPrevLen = 1;
	$lLen = 1;
	$lInParagraph = 0;

	foreach $lRow ( @{$self->{mArray}}) {


		# Looking for body text past the header stuff
		if ($lRowNum >= $self->{mBodyStart}) {
			# Make sure we are not already in a paragraph
			if ($lInParagraph == 0) {
				# See if we had a blank row before
				if ($lPrevLen < 2 and length ($lRow) > 5) {
					# Make sure this is not the start of some tag
					if (index ($lRow, '<') == -1) {
						# About to print the start of a new text paragraph
						$lInParagraph = 1;
						print OUT_FILE "<p>\n";
					}
				}
			}
		}


		print OUT_FILE "$lRow";
	
		# See if we need a closing paragraph tag. This is signaled by the next row being
		# very short

		$lNextLen = 1;
		if (defined ${$self->{mArray}}[$lRowNum + 1]) {
			$lNextLen = length (${$self->{mArray}}[$lRowNum + 1]);
		}
		if ($lInParagraph and $lNextLen < 2) {
			print OUT_FILE "</p>\n";
			$lInParagraph = 0;
		}

		$lPrevLen = length ($lRow);
		$lRowNum++;
	}

	# Print the closing </body></html> tags
	print OUT_FILE $gBODY_HTML;

	close (OUT_FILE);

}	# writeFile
1;
use Class::Struct;

#==========================================================================
# Module Name:      asstr_para
# Description:      This package contains structures and functions to analize
#                   paragraphs.
#                   A message contains paragraphs, blocks of text seperated
#                   by blank lines. But many messages look like continous
#                   blocks of text with indents to break the paragraphs
#                   up.
#                   A Message actually contains several types of paragraphs:
#                       M - Message Header: This block of text is the Date:
#                           Subject:/... at the top of every message
#                       D - Disclaimer/Copyright block
#                       T - Title block: This could be the title/chapter
#                           section; often centered or even right-justified
#                       B - Body: This is the actual message text
#                       F - Footer: this is similar to the Disclaimer section
#                           but could also be spam/send feedback to/etc.
#                           Its basically all the text after the Body
#                       U - Unknown: in case we cannot determin the type
#
#                   The goal is to analyze an array of text and define all
#                   the parts so a later routine can re-format the body
#                   without touching the other parts.
#                   It is also desired to identify the first and last Body
#                   paragraphs so a CRC value can be derived
#
#==========================================================================

# package asstr_para;

###############################
## CONSTANTS/DEFINITION SECTION
###############################

# These are the various codes for the paragraph.type field

$gHEADER_TYPE       = 'M';
$gDISCLAIMER_TYPE   = 'D';
$gTITLE_TYPE        = 'T';
$gBODY_TYPE         = 'B';
$gFOOTER_TYPE       = 'F';
$gUNKNOWN_TYPE      = 'U';


# This is the main structure for a paragraph analysis. One structure
# points to a row in the text array. It includes the type of paragraph,
# the starting row and the ending row.

struct ( paragraph =>
    {
        type  => '$',       # Type code like M/D/T/B/F
        start => '$',       # Starting row of the paragraph
        end   => '$'        # Ending row of the paragraph
    }
);


###########################
## GLOBAL VARIABLES SECTION
###########################

# This is the main array of PARAGRAPH structures. It starts
# out blank and gets filled when an array of text gets sent
# to the AnalyzeText routine. The other variables are
# convient bookkeeping values that are filled in.

@gPArray = ();              # The global array
$gPArraySize = -1;          # The size of gPArraySize
$gPArraySubject = "";       # The contents of the "Subject: xxx" row.

# This is a local copy of the text. The source text is copied here and
# all the routines access THIS copy so we dont have to worry about
# passing around arrays or array references.

@gRawText = ();
$gRawTextSize = -1;
$gRawAverageIndent = -1;

#--------------------------------------------------------------------------
# Routine:      S_InitPArray
# Description:  This routine will zero-out the gPArray variable and all
#               the bookkeeping variables to an initial/empty state.
#
# Input:        (none)
# Returns:      @gPArray - set to empty
#               $gPArraySize - set to -1 (uninitalized)
#               $gPArraySubject - set to -1 (uninitialized)
#--------------------------------------------------------------------------
sub S_InitPArray {

    @gPArray = ();
    $gPArraySize = -1;
    $gPArraySubject = "";
    $gRawAverageIndent = -1;

}   # S_InitPArray

#--------------------------------------------------------------------------
# Routine:      S_FindParagraphStartSimple
# Description:  This routine takes an index into the gRawText array and
#               searches backwards from this row to find the start of
#               the paragraph. This will be the row number after the
#               blank line, or 0 if the first row of gRawText is part
#               of this paragraph.
#
#               Note: Right now the simple routine is to look backwards
#               for a blank line, and return the row number +1 of the
#               blank line.  Later, this might get more suposticated.
#
# Input:        aMid - Row number in the middle of a block of text
#               in gRawText
#
# Returns:      The row number for the start of the enclosing block of text
#
#--------------------------------------------------------------------------
sub S_FindParagraphStartSimple {
    local ($aMid) = @_;
    local ($i);

    $i = $aMid;

    while ( $i >= 0 ) {
        if ( $gRawText[$i] eq "" ) {
            return ($i + 1);
        }
        $i--;
    }

    # If we got here, every row before aMid has text, including the zeroith
    # row. so just return 0

    return (0);

}   # S_FindParagraphStartSimple


#--------------------------------------------------------------------------
# Routine:      S_FindParagraphEndSimple
# Description:  This routine takes an index into the gRawText array and
#               searches forwards from this row to find the end of
#               the paragraph. This will be the row number before the
#               next blank line, or $gRawTextSize if the array ends with
#               no blank lines and we are in the middle of the last paragraph.
#
# Input:        aMid - Row number in the middle of a block of text
#               in gRawText
#
# Returns:      The row number for the last row of the paragraph.
#
#--------------------------------------------------------------------------
sub S_FindParagraphEndSimple {
    local ($aMid) = @_;
    local ($i);

    $i = $aMid;

    while ( $i <= $gRawTextSize ) {
        if ( $gRawText[$i] eq "" ) {
            return ($i - 1);        # Return the last row containing text
        }
        $i++;
    }

    # If we got here, every row including the last has text.
    # So just return the index of the last row

    return ($gRawTextSize);

}   # S_FindParagraphEndSimple

#--------------------------------------------------------------------------
# Routine:      S_FindSubjectRow
# Description:  This routine will look through the gRawText array for
#               the first row that starts with "Subject: xxx". The "xxx"
#               portion of the row will be copied to the gPArraySubject
#               variable.
#               Then the routine will look back and find the starting row
#               for the paragraph block that contains the "Subject:" row
#               and add a Paragraph entry into @gPArray for it.
#
# Input:        @gRawText
# Output:       Creates a Paragraph ( type => 'M', start => nn, end => yy)
#               structure and pushes it onto @gRawText
#               $gPArraySubject - Fills this with all the text after
#                   the "Subject: " header. Usefull for log messages
#
# Returns:      0 - Success, 1 - Failure/cannot find a row staring with
#                   "Subject: ".
#--------------------------------------------------------------------------
sub S_FindSubjectRow {
    local ($i, $lRow, $lSubjectRow);
    local ($lParagraph);


    for ( $i = 0; $i < $gRawTextSize; $i++ ) {
        if ( $gRawText[$i] =~ m/^Subject: / ) {
            # Found the Subject: heading
            $gPArraySubject = $gRawText[$i];
            $gPArraySubject =~ s/^Subject\: (.*)/$1/;
            # print "FSR: found subject: $gPArraySubject\n";
            $lSubjectRow = $i;
            break;
        }
    }

    # Did we find a "Subject: " header

    if ( $gPArraySubject eq "" ) {
        # No. Return an error
        return (0);
    }

    # Go ahead and create our Paragraph record

    $lParagraph = new paragraph;
    $lParagraph->type ($gHEADER_TYPE);      # M for Message header


    # We know what row the "Subject: " line is. Now search backward
    # to find the start of this block of text

    $i = &S_FindParagraphStartSimple ($lSubjectRow);
    $lParagraph->start ($i);

    # Search forward from the Subject: row for the first blank line and
    # return the last row of text for this paragraph

    $i = &S_FindParagraphEndSimple ($lSubjectRow);
    $lParagraph->end ($i);

    push (@gPArray, $lParagraph);

    return (1);

}   # S_FindSubjectRow

#---------------------------------------------------------------------------
# Routine:      S_GetIndentSize
# Description:  This routine will take a line of text and return the
#               count of white-space characters found at the beginging.
#
# Input:        aText - Line of text like "and then she said" or "    and then"
#
#---------------------------------------------------------------------------
sub S_GetIndentSize {
    local ($aText) = @_;
    local ($lSize) = 0;

    # See if there is any white-space at the begining of the text

    if ( $aText =~ m/^(\s+)/ ) {
        # Since we put the \s+ in parens, $1 holds a copy of the
        # white-space. Just return the length.
        $lSize = length ($i);
    }

    return ($lSize);

}   # S_GetIndentSize


#---------------------------------------------------------------------------
# Routine:      S_AnalyzeIndent
# Description:  This routine will jump into the middle of the gText array
#               and scan forwards and backwards trying to spot the
#               typical indentation for the start of a paragraph. This
#               value is later used to try and locate text-paragraphs
#
# Input:        gRawText - uses the global array
#
# Returns:      nn - The average number of spaces of indentation that appears
#               typical of the gText body
#               $gRawAverageIndent - The global variable is set to nn - the
#                   average number of spaces of indentation.
#
#---------------------------------------------------------------------------
sub S_AnalyzeIndent {
    local ($lSize, $lMid, $lStart, $lEnd, $i, $lRow);
    local ($lIndentCount, $lIndentSpace, $lIndentAverage);

    # Find the row about 60% into the body of the gText array. This is
    # so we skip the header rows which can be 5-20 % of the entire body

    $lMid = 0.6 * $gRawTextSize;

    # Pick a start and end row about 30% to either side of this mid point

    $lStart = int ($lMid - (0.3 * $gRawTextSize));
    $lEnd   = int ($lMid + (0.3 * $gRawTextSize));

    $lIndentCount = 0;
    $lIndentSpace = 0;
    for ( $i = $lStart; $i <= $lEnd; $i++ ) {

        $lRow = $gRawText[$i];

        # Check this row to see if it starts with any white-space. If so,
        # count the size and add it to our variables. Skip this row
        # if it does not start with white-space

        $lSize = &S_GetIndentSize ($lRow);
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

    print "AI: From row $lStart to $lEnd the average indent is: $lIndentAverage\n";

    $gRawAverageIndent = $lIndentAverage;      # Set the global

    return ($lIndentAverage);


}   # S_AnalyzeIndent

#--------------------------------------------------------------------------
# Routine:      AnalyzeText
# Description:  This routine is the main starting point for paragraph
#               analysis. It will take an array of text-rows and decide
#               which rows are starting rows for a paragraph, what type
#               of paragraph it is (header, disclaimer, body, etc.)
#
# Input:        @aText - Array of text rows
#
# Returns:      1 - Successfull analysis
#               0 - Failure for some reason
#
#--------------------------------------------------------------------------
sub AnalyzeText     #10/31/01 2:27:PM
{
    @gRawText = @_;
    $gRawTextSize = $#gRawText;     # Store the number of rows in gRawText

    # Init the internal variables

    &S_InitPArray();

    print "\n--------------------------------------------------\n";

    # The simple first thing to look for is the "Subject: " row.
    # This will find the "M - Message Header" paragraph and fill
    # out the gPArraySubject variable.

    &S_FindSubjectRow ();

    # Now we need to go through the rest of the rows and try and identify
    # the paragraphs. But there are lots of different ways text can
    # be formatted.
    # One thing to look for is indents. If we see that most of the text
    # in the middle of the message is indented 4 spaces, then
    # we can guess that text more than about... 8 spaces could be
    # titles/headers/page numbers.  If we see that there are NO indents,
    # then we know to look for other things.

    # Call a routine that will look through the middle of the @gRawText
    # array and determine the average indent count (if any). The value
    # will be stored in gRawAverageSize

    &S_AnalyzeIndent();





    ## For debugging
    local ($i, $lPara);

    foreach $lPara (@gPArray) {
        # Look for the header block
        if ( $lPara->type eq $gHEADER_TYPE ) {
            for ( $i = $lPara->start; $i <= $lPara->end; $i++ ) {
                print "H \|" . substr ($gRawText[$i], 0, 50) . "\n";
            }
        }
    }


}   # AnalyzeText


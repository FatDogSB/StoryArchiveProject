#-------------------------------------------------------------------------
# S_AlphatizeTextFile
# This routine will take a story file and break each story into a
# individual file. Then the individual files will be written to
# files like "A00.txt", "B00.txt", etc.
#-------------------------------------------------------------------------
sub S_AlphatizeTextFile {

    local ($aInFileName, $aDestDir) = @_;
	local (@lBreakIndex) = ();	# contains row-number | subject line pairs
	local (%lSubjectArray) = ();	# contains Subject | file name pairs
	local ($lSubject, $lLine, $lFileName, $lRowCount, $lEndRow);
	local ($lFileCount) = 0;
    local ($lTemp);

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
         $lTemp = "";
#        $lTemp = $lSubject;     # "Subject: "The ..."
#        $lTemp = substr ($lTemp, 9);
#        $lTemp = s/\d//g;
#        $lTemp = s/\"//g;
#        $lTemp = s/ //g;
#        $lTemp = $aDestDir . "\" . substr ($lTemp, 0, 1) . "00.txt";


        print "Out: $lTemp - $lSubject\n";

        #print OUTFILE "$gDIVIDER";

		# Grab the story file and put it's lines into the output file
        #open (INFILE, "$lFileName") || die ("Cannot open $lFileName for input!\n");
        #while ( <INFILE> )  {
        #    print OUTFILE $_;
        #}
        #close (INFILE);
		# unlink (INFILE);	# Delete the temp file
	}

    #close (OUTFILE);
    #system "del *.tmp";
    #print "Original file moved to : $lOldFileName\n";
    #print "Sorted output written to : $aInFileName\n";

} # S_AlphatizeTextFile

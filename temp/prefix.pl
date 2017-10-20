#!/usr/bin/perl

print "Hello, World...\n";

print "File Spec:\t $ARGV[0]\n";
print "Prefix:\t$ARGV[1]\n";

# See if the user gave us 2 arguments -> a prefix or 1 argument -> a cleanup/rename

print "Param Count = $#ARGV\n";
if ( ! exists $ARGV[1]) {
	&CleanupFileNames ($ARGV[0]);
} else {
	&PrefixFiles ($ARGV[0], $ARGV[1]);
}

#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
sub CleanupFileNames {
	my ($aFilePattern) = @_;
	my ($lFile, $lNewName);
	my (@lFileList) = glob ($aFilePattern);

	foreach $lFile (@lFileList) {
		$lNewName = &S_NormalizeFileName($lFile);
		print "Normalizing file ($lFile) to ($lNewName) \n";
		rename ($lFile, $lNewName);
	}

}	# CleanupFileNames

#-----------------------------------------------------------------------------------------------------------------------
# Routine:		S_NormalizeFileName
# Description:	This routine will take a file name with spaces or other problems and return a cleaned-up version of the
#				name.
#-----------------------------------------------------------------------------------------------------------------------
sub S_NormalizeFileName {
	my ($aFile) = @_;
	my (@aWordArray, $lNewName);

	# See if the file name contains spaces. If so, remove them, but first make the chars upper case in place
	# of the spaces.

	$lNewName = ucfirst($aFile);
	$lNewName =~ s/ (\w)/\u$1/g;


	return ($lNewName);
}	# S_NormalizeFileName

#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
sub PrefixFiles {
my ($aFileSpec, $aPrefix) = @_;
my ($lNewName);

	$aPrefix = uc $aPrefix;

	if (length ($aPrefix) < 2 || length ($aPrefix) > 10) {
		print "Prefix ($aPrefix) does not appear valid\n";
		exit;
	}

	my (@lFileList) = glob ($aFileSpec);
	my ($lFile);
	foreach $lFile (@lFileList) {
		$lNewName = "$aPrefix-$lFile";
		# Look for and get rid of spaces
		$lNewName =~ s/ //g;

		if (-e $lNewName) {
			print "Error: Cannot prefix $lFile because $lNewName already exist\n";
		} else {
			print "Renaming $lFile to $lNewName\n";
			rename ($lFile, $lNewName);
		}
	}
}	# PrefixFiles
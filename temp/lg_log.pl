#!/bin/perl

use strict;
use warnings;
use Getopt::Long qw(GetOptions);

my $FILE_PATH_DEFAULT 		= "C:\\Windows\\";
my $FILE_SIZE_DEFAULT 		= 60;				# This is 60 Kilobytes
my $FILE_PATTERN_DEFAULT    = "*.log";

# Doing the quick and dirty version

&main();

#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
sub main {
	# Should check for command-line arguments that would change the path, the
	# size or the pattern. but we only have 15 minutes
	my ($lFile, $lSize);
	my ($lPath, $lPattern, $lFinalPath);
	my ($lCount, $lOversizeCount);

	
	
	
	$lPattern = $FILE_PATTERN_DEFAULT;
	$lPath = $FILE_PATH_DEFAULT;
	$lFinalPath = $FILE_PATH_DEFAULT . "\\" . $FILE_PATTERN_DEFAULT;		# Should be C:\Windows\*.log
	$lSize = $FILE_SIZE_DEFAULT;
	
	# Check for command-line arguments like this:
	# ./lg_log.pl --size 60 --pattern *.log --path c:\windows
	GetOptions (
		"size=i"	=> \$lSize,
		"pattern=s"	=> \$lPattern,
		"path=s"	=> \$lPath,
	);
	
	# Sanity check the arguments
	if ( -e $lPath ) {
		if ( length ($lPattern) > 1 ) {
			if ( $lSize > 0 && $lSize < 5000 ) {
				$lFinalPath = $lPath . "\\" . $lPattern;
			} else {
				die ("Argument Error: The size value is in Killobytes and appears wrong: $lSize\n");
			}
		} else {
			die ("Argument Error: the Pattern string appears too small: $lPattern");
		}
	} else {
		die("Argument error: Path appears to not exist or we do not have access to it: $lPath\n");
	}
	
	# The size value could be 20 meaning 20 kilobytes
	$lSize = $lSize * 1024;
	foreach $lFile (sort glob ($lFinalPath) ) {
		#print "$lFile\n";
		$lCount++;
		if ( -s $lFile >= $lSize ) {
			print "$lFile\n";
			$lOversizeCount++;
		}
	}
}

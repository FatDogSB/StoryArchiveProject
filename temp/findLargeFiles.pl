#!/bin/perl

use strict;
use warnings;
use Getopt::Long qw(GetOptions);
use CWD qw(cwd getcwd);

my $FILE_PATH_DEFAULT 		= "d:\\upgrades\\";
my $FILE_SIZE_DEFAULT 		= 1024 * 1024 * 50;
my $FILE_PATTERN_DEFAULT	= "*.*";
my $gExitCode 				= 0;
my $gVerbose				= 0;

main();
exit ($gExitCode);

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
sub findLargeFiles {
	my (%args) = @_;	

	
}	# findLargeFiles


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
sub main {
	my ($lFilePathBase, $lFileSize, $lFilePattern);
	my ($lErrorCount, $lErrorMessage);
	
	$lFilePathBase 	= $FILE_PATH_DEFAULT;
	$lFileSize		= $FILE_SIZE_DEFAULT;
	$lFilePattern	= $FILE_PATTERN_DEFAULT;
	
	GetOptions (
		'path=s'		=> \$lFilePathBase,
		'size=i'		=> \$lFileSize,
		'pattern=s'		=> \$lFilePattern,
		'verbose=i'		=> \$gVerbose,
	);
	
	
	if ( $gVerbose > 0 ) {
		print sprintf ("%20s = %s\n", "Path", $lFilePathBase);
		print sprintf ("%20s = %s\n", "Size", $lFileSize);
		print sprintf ("%20s = %s\n", "Pattern", $lFilePattern);
		
	}
	
	# Error check the arguments
	$lErrorCount = 0;
	$lErrorMessage = "";
	
	if ( length ($lFilePathBase) < 2 ) {
		$lErrorCount++;
		$lErrorMessage .= "Argument Error: Path string appears too small: $lFilePathBase\n";
	}
	
	if ( ! -e $lFilePathBase ) {
		$lErrorCount++;
		$lErrorMessage .= "Argument Error: Path does not exist: $lFilePathBase\n";
	}
	
	if ( $lErrorCount == 0 && ( ! -r $lFilePathBase ) ) {
		$lErrorCount++;
		$lErrorMessage .= "Argument Error: Path cannot be read by this process: $lFilePathBase\n";
	}
	
	if ( $lFileSize < 0 || $lFileSize > 1024 * 1024 * 1024 ) {
		$lErrorCount++;
		$lErrorMessage = "Argument Error: File size appears wrong: $lFileSize\n";
	}
	
	if ( $lErrorCount > 0 ) {
		print $lErrorMessage;
		#die ("Aborting due to too many errors\n");
		$gExitCode = 1;
		
	}
	
	&findLargeFiles(path => $lFilePathBase, size => $lFileSize, pattern => $lFilePattern, recurse => 0);
	
}	# main
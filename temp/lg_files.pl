#!/bin/perl

use strict;
use warnings;

use Getopt::Long qw(GetOptions);

# This will be the default return code of the process.

my $gExitCode = 0;

# These are default paths and values that can be over-written by command line arguments
my $BASE_PATH_DEFAULT 		= 'C:\\upgrades';
my $FILE_SIZE_DEFAULT 		= 1024 * 425;
my $FILE_PATTERN_DEFAULT	= '*.*';

my $gBasePath;
my $gFileSize;
my $gFilePattern;
my $gDebug = 0;

main();
exit ($gExitCode);

#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------

sub findLargeFiles {
	my (%args) = @_;
	my ($lFileName, $lFileSize, $lCountTotal, $lCountLarge);
	
	chdir ($args{path}) or die ("Error: Could not chdir to path: $args{path}\n");
	print "Looking for files $args{pattern} in folder: $args{path}...\n";

	foreach $lFileName ( sort glob ($args{pattern}) ) {
		$lCountTotal++;
		$lFileSize = -s $lFileName;
		if ( $lFileSize > $args{size} ) {
			print sprintf ("%90s = %15d\n", $lFileName, $lFileSize);
			$lCountLarge++;
		}
	}
	
}	# findLargeFiles

#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
sub main {

	# lg_files --path c:\fubar  --size 425000
	
	# Set default values
	$gBasePath = $BASE_PATH_DEFAULT;
	$gFileSize = $FILE_SIZE_DEFAULT;
	$gFilePattern = $FILE_PATTERN_DEFAULT;
	
	# See if the user over-rode the command line arguments
	&GetOptions(
		'path=s'	=> \$gBasePath,
		'size=i'	=> \$gFileSize,
		'pattern=s'	=> \$gFilePattern,
		'debug|d'	=> \$gDebug,		
	);
	
	print "Hello World\n";
	
	if (1) {
		print "Path: $gBasePath\n";
		print "Size: $gFileSize\n";
		print "Pattern: $gFilePattern\n";
		print "Debug: $gDebug\n";
	}
	
	# Sanity check the options
	if ( $gFileSize < 10 or $gFileSize > 1024 * 1024 * 10) {
		print "Argument Error: file size must be between 10 and 10 gig: $gFileSize is wrong\n";
		$gExitCode++;
	}
	
	if ( ! -e $gBasePath ) {
		print "Argument Error: base path does not exist: $gBasePath\n";
		$gExitCode++;
	}
	
	if ( ! -r $gBasePath ) {
		print "Argument Error: base path cannot be read: $gBasePath\n";
		$gExitCode++;
	}
	
	if ( $gExitCode > 0 ) {
		print "Run aborting due to too many errors\n";
		die ($gExitCode);
	}
	
	&findLargeFiles(path => $gBasePath, size => $gFileSize, pattern => $gFilePattern);
	
}
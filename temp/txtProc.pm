#!/usr/bin/perl
package txtProc;
#
# AUTHOR:	Bob McElfresh
# DATE:		2008-08-22
#
# MODULE_NAME: neatoUtil - Utility package for Stories On Line
#
use strict;
use warnings;
use diagnostics;
use Exporter;
use Carp;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use Data::Dumper;
require LWP::UserAgent;
use WWW::Mechanize;


$VERSION     = '0.01';
@ISA         = qw(Exporter);
@EXPORT      = ();
@EXPORT_OK   = qw(new getAuthors);
%EXPORT_TAGS = ( DEFAULT => [qw(&func1)],
                 Both    => [qw(&func1 &func2)]);

my %gIndexHash = ();

my %gFileHash = ();
my %gCatalogHash = ();
my %gRawFileHash = ();
my %gTitleHash = ();

#-------------------------------------------------------------------------
# Routine:		new
#
#-------------------------------------------------------------------------
sub new
{
	my $class = shift;
	my %args  = @_;
	my @lText = ();
	my ($lRow, $lRowCount);

	# Calculate the name of an index file that contains STATUS, URL so we
	# can scan over mulitple days but remember where we left off
	my $lIndexFile = "bl_index.txt";
	
	my $lMech = WWW::Mechanize->new(
		agent 		=> 'Mozilla/5.0',
		cookie_jar 	=> {}
	);
	$lMech->agent_alias( 'Windows IE 6' );
	
	# Hard code a base url so later routines can read the relative links to attach
	#  '/stories/story.php?storyid=1234'
	$args{base_url} = 'http://neatopotato.net/xnovel/browse_series';
	$args{index_file} = 'neato_index.txt' if ( ! exists $args{index_file} );
	
	my $self = {
		mBaseURL 	=> $args{base_url},
		mIndexFile	=> $args{index_file},
		mWWW		=> $lMech,
	};


	bless $self, $class;
	return $self;
	
}	# new


#-------------------------------------------------------------------------
# Routine:		genCatalogFile
# Description:	This routine will take the name of a .txt file, it will scan
#				it for Subject: "title" {author}  and create a .cat file
#				that contains title|author|file name
#
# Inputs:		input_dir = path to where the files are
#				input_file = name of 1 .txt file to scan
#-------------------------------------------------------------------------
sub genCatalogFile {
	my ($self) = shift;
	my (%args) = @_;
	my ($lOutputFile, $lRow, $lTitle, $lAuthor, %lDataHash, $lKey, $lCount);
	
	
	$lOutputFile = $args{input_file};
	$lOutputFile =~ s/\.txt/.cat/;
	
	if (-e $lOutputFile) {
		print "Catalog file pre-exists: $lOutputFile\n";
		return;
	}
	
	print "Scanning file: $args{input_file}\n";
	
	open (INPUT_FILE, $args{input_file}) or confess ("Error: Could not open file for input: $args{input_file} : $!\n");
	while ($lRow = <INPUT_FILE>) {
		next unless ( index ($lRow, "Subject:") > -1);
		chomp ($lRow);
		
		# Extract the title between double quotes
		($lTitle, $lAuthor) = ("", "");
		
		if ( $lRow =~ m/\"([^"]*)/ ) {
			$lTitle = $1;
		}
		
		if ( $lRow =~ m/\{([^}]*)/ ) {
			$lAuthor = $1;
		}
		
		$lKey = "$lAuthor|$lTitle";
		$lDataHash{$lKey} = 1;
	}
	close (INPUT_FILE);
	
	$lCount = scalar ( keys %lDataHash );
	print "Total author - title pairs in file: $lCount\n";
	
	# Create file of: file_name | Author | Title
	open (OUT_FILE, ">$lOutputFile") or confess ("Error: could not open file for output: $lOutputFile : $!\n");
	foreach $lKey ( sort keys %lDataHash ) {
		print OUT_FILE "$args{input_file}|$lKey\n";
	}
	close (OUT_FILE) or confess ("Error: Could not close output file: $lOutputFile : $!\n");
	
	print "Output file created: $lOutputFile\n";
	
}	# genCatalogFile

#-------------------------------------------------------------------------
#-------------------------------------------------------------------------
sub genAllCatalogFiles {
	my ($self) = shift;
	my (%args) = @_;

	print "Scanning input dir: $args{input_dir}\n";
	
	if ( ! -d $args{input_dir} ) {
		confess ("Argument Error: input dir does not exist: $args{input_dir}\n");
	}
	
	chdir ($args{input_dir}) or confess ("Error: Could not chdir to input dir: $args{input_dir} : $!\n");
	
	# Scan for all the .txt files
	my @lFileArray = sort glob ("*.txt");
	foreach my $lFile (@lFileArray) {
		# print "\tFile: $lFile\n";	
		$self->genCatalogFile (input_dir => $args{input_dir}, input_file => $lFile);
		
	}
	
}	# genAllCatalogFiles


#-------------------------------------------------------------------------
#-------------------------------------------------------------------------
sub readCatalogFiles {
	my ($self) = shift;
	my (%args) = @_;
	my ($lFile, $lRow, $lInputFile, $lAuthor, $lTitle, $lKey);
	
	print "Reading Catalog input dir: $args{input_dir}\n";
	
	if ( ! -d $args{input_dir} ) {
		confess ("Argument Error: input dir does not exist: $args{input_dir}\n");
	}
	
	chdir ($args{input_dir}) or confess ("Error: Could not chdir to input dir: $args{input_dir} : $!\n");

	foreach $lFile ( sort glob ("*.cat") ) {
		open (INPUT_FILE, $lFile) or confess ("Error: Could not open file for input: $lFile : $!\n");
		while ( $lRow = <INPUT_FILE>) {
			chomp ($lRow);
			($lInputFile, $lAuthor, $lTitle) = split (/\|/, $lRow);
			$lKey = "$lTitle|$lAuthor";
			$lKey = uc ($lTitle);
			$gCatalogHash{$lKey} = $lInputFile;
			$gRawFileHash{$lInputFile} = 0;
		}
		close (INPUT_FILE);
	}
	
}


#-------------------------------------------------------------------------
#-------------------------------------------------------------------------
sub S_ExtractTitle {
	my ($aSubjectRow) = @_;
	my ($lPos);
	
	if ( 0 ) {
		# Remove (#/#)
		$aSubjectRow =~ s/\(\d+\/\d+\)//g;
		$aSubjectRow =~ s/\[\d+\/\d+\]//g;
		
		# Remove anything between curliy braces
		$aSubjectRow =~ s/\{[^}]*\}//g;
		$aSubjectRow =~ s/\([^)]*\)//g;
		$aSubjectRow =~ s/\[[^]]*\]//g;
		
		$aSubjectRow =~ s/Pt\.\(\d+\/\d+\)//g;
	}

	$lPos = index ($aSubjectRow, '{');
	if ( $lPos > -1 ) {
		$aSubjectRow = substr($aSubjectRow, 0, $lPos);
	}
	$lPos = index ($aSubjectRow, '[');
	if ( $lPos > -1 ) {
		$aSubjectRow = substr($aSubjectRow, 0, $lPos);
	}
	$lPos = index ($aSubjectRow, '(');
	if ( $lPos > -1 ) {
		$aSubjectRow = substr($aSubjectRow, 0, $lPos);
	}
	$lPos = index ($aSubjectRow, ',');
	if ( $lPos > -1 ) {
		$aSubjectRow = substr($aSubjectRow, 0, $lPos);
	}
	$lPos = index ($aSubjectRow, '.');
	if ( $lPos > -1 ) {
		$aSubjectRow = substr($aSubjectRow, 0, $lPos);
	}
	$lPos = index ($aSubjectRow, '-');
	if ( $lPos > -1 ) {
		$aSubjectRow = substr($aSubjectRow, 0, $lPos);
	}
	
	$aSubjectRow =~ s/Ch *\d+//gi;
	$aSubjectRow =~ s/Chapter *\d+//gi;
	
	# Clean up multiple spaces
	$aSubjectRow =~ s/\s+/ /g;

	$aSubjectRow =~ s/Subject: //;
	$aSubjectRow =~ s/\"//g;
	
	return ($aSubjectRow);
}	# S_ExtractTitle

#-------------------------------------------------------------------------
#-------------------------------------------------------------------------
sub readRawFile {
	my ($self) = shift;
	my (%args) = @_;
	my ($lRawFile, $lRow, $lTitle, $lAuthor, $lKey);
	
	# Take this .txt file and find all the Subject: headers so we can try to see
	# if a processed file exists with most of the stories.
	
	%gTitleHash = ();
	$lRawFile = $args{raw_file};
	if ( ! -e $lRawFile ) {
		print "Error: Raw file does not exist: $lRawFile\n";
		return;
	}
	
	print "Reading raw file: $lRawFile\n";
	
	open (RAW_FILE, $lRawFile) or confess ("Error: could not open raw file for input: $lRawFile : $!\n");
	while ( $lRow = <RAW_FILE> ) {
		next unless ( index ($lRow, 'Subject:') > -1 );
		next unless ( $lRow =~ m/^Subject/ );
		chomp ($lRow);
		$lTitle = &S_ExtractTitle ($lRow);
		$lKey = uc ($lTitle);
		$gTitleHash{$lKey} = "";
	}
	close (RAW_FILE);

	foreach $lKey ( sort keys %gTitleHash ) {
		#print "$lKey\n";
	}
	
	
}	# readRawFile

#-------------------------------------------------------------------------
# Routine:		findTitles
# Description:	This routine will run through the titles in %gTitleHash
#				to find matches in %gCatalogHash. If found the count for
#				the input file name is bumpped.  At the end the input file
#				with the max count is the winner
#-------------------------------------------------------------------------
sub findTitles {
	my ($self) = shift;
	my (%args) = @_;
	my ($lTitle, $lInputFile, $lMaxCount);
	
	$lMaxCount = 0;
	foreach $lTitle ( sort keys %gTitleHash ) {
		if ( exists $gCatalogHash{$lTitle} ) {
			$lInputFile = $gCatalogHash{$lTitle};
			$gRawFileHash{$lInputFile}++;
			# print "Found $lInputFile : $lTitle\n";
			$lMaxCount = $gRawFileHash{$lInputFile} if ( $gRawFileHash{$lInputFile} > $lMaxCount );
		}
	}
	
	foreach $lInputFile ( sort keys %gRawFileHash ) {
		if ( $gRawFileHash{$lInputFile} == $lMaxCount ) {
			print "Raw file $args{raw_file} has $lMaxCount matches in $lInputFile\n";
		}
	}
	
	
}	# findTitles


#-------------------------------------------------------------------------
#
#
# Inputs:		input_dir - name
#-------------------------------------------------------------------------
sub validateRawFile {
	my ($self) = shift;
	my (%args) = @_;
	my ($lFile, @lFileArray);
	
	# Read in the .cat files into %gCatalogHash{title} = input file
	# It also reads the file names into %gRawFileHash{file name} = 0;
	
	$self->readCatalogFiles( input_dir => 'D:\temp\text_proc\ASSTR\03-Tag' );
	
	# Go to the raw dir
	chdir ($args{raw_dir}) or confess ("Error: Could not chdir to input dir: $args{raw_dir} : $!\n");

	# Loop through the .txt files
	
	#push (@lFileArray, "2001A.TXT");
	#push (@lFileArray, "2001A-D.TXT");
	#push (@lFileArray, "2001b-a.txt");
	push (@lFileArray, "2001B.txt");
	
	foreach $lFile ( @lFileArray ) {
		
		# Read the titles into %gTitleHash
		$self->readRawFile ( raw_file => $lFile );
		
		# Call a routine that will take all the titles in %gTitleHash and look for the titles
		# in %gCatalogHash. If found - the input file count is bumpped in %gTitleHash.  In the end,
		# the input file with max count is the winner.
		
		$self->findTitles(raw_file => $lFile);
	}
	
}	# validateRawFile



1;

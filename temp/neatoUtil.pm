#!/usr/bin/perl
package neatoUtil;
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
#-------------------------------------------------------------------------
sub readDir {
	my $self = shift;
	my (%args) = @_;
	
	my (@lFileList, $lFile, @lDirList, $lPath, $lDir);

	print "Scanning dir: $args{path}...\n";
	$lPath = $args{path};
	chdir ( $args{path} ) or die ("Error: Could not chdir to folder: $args{path} : $!\n");
	
	@lFileList = glob ('*');
	foreach $lFile (@lFileList) {
		if ( -d $lFile ) {
			push (@lDirList, $lPath . '\\' . $lFile);
		} else {
			if ( exists $gFileHash{$lFile} ) {
				print "Found duplicate file name: $lFile\n";
			} else {
				$gFileHash{$lFile} = $lPath;
			}
			#print sprintf ("Dir: %20s : %s\n", $lPath, $lFile);
		}
	}

	foreach $lDir ( sort @lDirList ) {
		$self->readDir( path => $lDir );
	}
	
}	# readDir

#-------------------------------------------------------------------------
# Routine:		readLocalFiles
# Description:	This routine will scan sub dirs to read all the neatopotato story files
#				that we have already collected. This will allow us to spot new or
#				different files we have not downloaded yet.
#
# Inputs:		path - string like 'N:\\1Backup\\xNovels' which contain the previously
#				downloaded files.
#
# Outputs:		%gFileHash - hash to old our local file names
#-------------------------------------------------------------------------
sub readLocalFiles {
	my $self = shift;
	my (%args) = @_;
	
	my (@lFileList, $lFile, @lDirList);
	
	# Call a recursive routine to read the files
	$self->readDir ( path => $args{path} );

	# Do a report:
	my $lCount = scalar ( keys %gFileHash );
	print "Total local files: $lCount\n";
	
}	# readLocalFiles


#-------------------------------------------------------------------------
#-------------------------------------------------------------------------
sub calcFileName {
	my ($aURL) = @_;
	my ($lPos1, $lFileName);
	
	$lPos1 = rindex($aURL, '/');
	$lFileName = substr ($aURL, $lPos1+1, 999);
	$lFileName =~ s/\+/ /g;
	$lFileName =~ s/\%28/\(/g;
	$lFileName =~ s/\%29/\)/g;
	$lFileName =~ s/\%26/\&/g;
	$lFileName =~ s/\%21/\!/g;
	$lFileName =~ s/\%2C/\,/g;

	
	return ($lFileName);

}	# caldFileName

#-------------------------------------------------------------------------
# Routine:		scanPotatoLinks
# Description:	This routine will go to an index page on the neatopotato site
#				scan all the links, dive into them and scan those links.
#				The goal is to get to the .zip file under each book to compare
#				them to the local file list in gFileHash
#
# Inputs:		url - string like
#-------------------------------------------------------------------------
sub scanPotatoLinks {
	my $self = shift;
	my (%args) = @_;
	my $lMech = $self->{mWWW};
	my (@lURLArray, $lFolderURL, @lLinks, $lLink, @lBookURL);
		my @lNeedURL;
		my %lNeedHash;
	
	if ( 0 ) {
		print "Reading URL: $args{url} ...\n";
		$lMech->get($args{url});
		my $lTemp = $lMech->content();
		#print "$lTemp\n";
		my @lBody = split ("\n", $lTemp);
		foreach my $lRow ( @lBody ) {
			next unless (index ($lRow, 'xnovel/category') > -1 );
			print "$lRow\n";
		}
	}

	# Get all the links to the "greenleaf-classics", "beeline-books" folders
	if (1) {
		print "Reading url $args{url}...\n";
		$lMech->get($args{url});
		#my @lLinks = $lMech->find_all_links ( text_regex => qr/category/ );
		@lLinks = $lMech->find_all_links (  );
		foreach $lLink ( @lLinks ) {
			if ( index ($lLink->url(), 'category' ) > -1 ) {
				#print $lLink->url() . "\n";
				push (@lURLArray, $lLink->url()) if ( scalar (@lURLArray) < 9000 );
			}
		}
		
		# Now each URL points to 1 or more book files
		foreach $lFolderURL ( @lURLArray ) {
			print "\tFolder: $lFolderURL\n";
			$lMech->get($lFolderURL);
			#@lLinks = $lMech->find_all_links ( tag_regex => qr/a rel/ );
			@lLinks = $lMech->find_all_links (  );
			foreach $lLink ( @lLinks ) {
				
				my $lRef = $lLink->attrs();
				if (exists $$lRef{rel}) {
					if ($$lRef{rel} eq 'bookmark' ) {
						#print "\t\t" . $lLink->url() . "\n";
						push (@lBookURL, $lLink->url());
					}
				}
			}
			
		}
		
		# Test print
		foreach $lLink ( @lBookURL ) {
			print "\t\t$lLink\n";
			$lMech->get($lLink);
			@lLinks = $lMech->find_all_links (  );
			foreach $lLink ( @lLinks ) {
				next unless ( index ($lLink->url(), 'file_download') > -1 );
				next unless ( index ($lLink->url(), '.zip') > -1 );
				my $lFileName = &calcFileName ( $lLink->url() );
				if ( exists $gFileHash{$lFileName} and (! exists $lNeedHash{$lFileName}) ) {
					#print "\tHave: $lFileName\n";
				} else {
					#print "\tNeed: $lFileName\n";
					$lNeedHash{$lFileName} = $lLink->url();
				}
				#print "\t\t\t" . $lLink->url() . "\n";
			}
			
		}
		
		my $lCount = 1;
		foreach $lLink (sort keys %lNeedHash) {
			print sprintf ("%3d : %s\n", $lCount++, $lLink);
		}
		
	}
	
	
	
}	# scanPotatoLinks



#-------------------------------------------------------------------------
# Routine:		genIndexFile
# Descripton:	Will read the main page of the web site and extract all
#				the story links and create an index file that
#				consists of: URL <tab> Status <tab> Text>
#
#-------------------------------------------------------------------------
sub genIndexFile {
	my $self = shift;
	my (%args) = @_;
	my ($lMech, @lLinkArray,  $lLink, $lKey, $lURL);
	my (%lLinkHash, $lLinkCountRaw, $lLinkCountFinal, %lIgnoreURL);
	
	$lURL = $args{base_url};
	print "genIndexFile() starting: $lURL\n";
	
	print "Scanning baseURL: $lURL\n";
	$self->{mWWW}->get ( $lURL );
	
	# Setup a hash of url's to ignore because have seen it
	# in a previous file
	
	foreach my $lIndexFile ( sort glob ("bl_index*.txt") ) {
		open (INDEX_FILE, $lIndexFile) or die ("Error: Could not open file for input: $lIndexFile : $!\n");
		my ($lRow, $lIndexURL);
		while ($lRow = <INDEX_FILE>) {
			chomp ($lRow);
			my (@lTemp) = split ("\t", $lRow);
			$lIgnoreURL{$lTemp[0]} = 1;
		}
		close (INDEX_FILE);
	}
	
	#print $self->{mWWW}->content();
	
	# This routine will find all the links on a page.
	
	@lLinkArray = @{$self->{mWWW}->find_all_links()};

	
	# The find_all_links returns an array of link objects:
	#    my $link = WWW::Mechanize::Link->new( {
        #   url  => $url,
        #   text => $text,
        #  name => $name,
        #  tag  => $tag,
        #  base => $base,
        #  attr => $attr_href,
        # } )	;
	
    open (OUT_FILE, ">bdl_list.dat") or confess ("Error: Could not open file for output\n");
	foreach $lLink ( @lLinkArray ) {
		
		# Ignore links to author pages or review pages
		next if ( index ($lLink->url(), 'author.php') > -1 );
		next if ( index ($lLink->url(), 'review.php') > -1 );
		
		next unless ( index ($lLink->url(), 'story.php') > -1 );
		next if ( $lLink->text() eq '');
		
		$lKey = $lLink->url();
		$lLinkHash{$lKey}{url} = $lLink->url();
		$lLinkHash{$lKey}{text} = $lLink->text();
		$lLinkHash{$lKey}{status} = 0;

		$lLinkCountRaw++;
		
		next if (exists $lIgnoreURL{$lKey});
		
		print OUT_FILE sprintf ("%04d : %s\n", $lLinkCountRaw, $lLink->text());
		
		#print sprintf ("\tLink: %-40s : %-40s\n", substr($lLink->text(), 0, 40), substr ($lLink->tag(), 0, 40) );
	}
	close (OUT_FILE);
	
	# We want to mark the first 315 stories from the array as being processed so we pick up
	# from where we left off
	$lLinkCountRaw = 0;
	foreach $lLink ( @lLinkArray ) {
		$lLinkCountRaw++;
		
		if ( $lLinkCountRaw < 30000 ) {
			$lLinkHash{$lLink->url()}{status} = 1;
		}
	}

	
	
	$lLinkCountFinal = scalar ( keys %lLinkHash );
	
	print "Link Count Raw:    $lLinkCountRaw\n";
	print "Link Count Final:  $lLinkCountFinal\n";
	
	# Write a file with URL<tab>Status<tab>Text for later use
	open (OUT_FILE, ">$self->{mIndexFile}") or confess ("Error: Could not open index file for output: $self->{mIndexFile} : $!\n");
	foreach $lKey ( sort keys %lLinkHash ) {
		#print "index key: $lKey: $lLinkHash{$lKey}{url}\n";
		#next unless ( index ($lLinkHash{$lKey}{url}, 'stories/story') > -1 );
		next unless ( index ($lLinkHash{$lKey}{url}, 'story.php') > -1 );
		
		print OUT_FILE "$lLinkHash{$lKey}{url}\t$lLinkHash{$lKey}{status}\t$lLinkHash{$lKey}{text}\n";
	}
	
	
	close (OUT_FILE) or confess ("Error: Could not close index file: $self->{mIndexFile} : $!\n");
	
	print "Index File Created: $self->{mIndexFile}\n";
	
}	# genIndexFile

#-------------------------------------------------------------------------
# Routine:		readIndexFile
# Descripton:	Will read the main page of the web site and extract all
#				the story links and create an index file that
#				consists of: URL <tab> Status <tab> <Text>
#
#-------------------------------------------------------------------------
sub readIndexFile {
	my $self = shift;
	my (%args) = @_;
	my ($lRow, $lURL, $lStatus, $lText, $lKey, $lCount, $lStoryNum);

	if ( ! -e $self->{mIndexFile} ) {
		print "Error: Index file does not appear to exist: $self->{mIndexFile}\n";
		return;
	}

	print "Reading Index file $self->{mIndexFile}...\n";
	%gIndexHash = ();	
	$lCount = 0;
	open (IN_FILE, $self->{mIndexFile}) or confess ("Error: Could not open input file: $self->{mIndexFile}\n");
	while ( $lRow = <IN_FILE> ) {
		$lCount++;
		chomp ($lRow);
		($lURL, $lStatus, $lText) = split ("\t", $lRow);
		
		# The url string looks like: /stories/story.php?storyid=8220
		# Decode the story id
		$lStoryNum = -1;
		if ( $lURL =~ m/storyid\=(\d+)/ ) {
			$lStoryNum = $1;
		}
		
		$lKey = $lURL;
		$gIndexHash{$lKey}{url}    = $lURL;
		$gIndexHash{$lKey}{text}   = $lText;
		$gIndexHash{$lKey}{status} = $lStatus;
		$gIndexHash{$lKey}{storyid} = $lStoryNum;
	}
	
	close (IN_FILE);
	
	print "Index file read. Total rows: $lCount\n";
	
}	# readIndexFile




1;

#!/usr/bin/perl
package solUtil;
#
# AUTHOR:	Bob McElfresh
# DATE:		2008-08-22
#
# MODULE_NAME: solUtil - Utility package for Stories On Line
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
	$args{base_url} = 'http://www.bdsmlibrary.com/stories/';
	$args{base_url} = 'http://www.bdsmlibrary.com';
	$args{index_file} = 'bl_index.txt' if ( ! exists $args{index_file} );
	
	my $self = {
		mBaseURL 	=> $args{base_url},
		mIndexFile	=> $args{index_file},
		mWWW		=> $lMech,
	};


	bless $self, $class;
	return $self;
}	# new


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


#-------------------------------------------------------------------------
# Routine:		extractStoryRows
# Description:	This routine will take the entire, raw HTML content
# 				of a story page and extract the actual story rows
#-------------------------------------------------------------------------
sub extractStoryRows {
	my ($aBuffer) = @_;
	my (@lLines, $lRow, @lStory, $lPos);
	my ($lSynopsis, $lFoundBody);
	
	$lSynopsis = "";
	$lFoundBody = 0;
	
	# Convert the entire buffer to an array so we can process line by line
	@lLines = split ("\n", $aBuffer);
	
	push (@lStory, "");	# For the title
	push (@lStory, "");		# For the Synopsis
	push (@lStory, "");

	# Go through the buffer and find the rows that start with <p>
	foreach $lRow ( @lLines ) {
			
		# Skip all rows until we find "<body>". Then stop when we find "</body>"
		if ( index ($lRow, '<body>') == 0 ) {
			$lFoundBody = 1;
		}
		if ( index ($lRow, '</body>') == 0 ) {
			$lFoundBody = 0;
		}

		$lFoundBody = 0 if ( index ($lRow, '<style') == 0);
		$lFoundBody = 1 if ( index ($lRow, '</style') > 0);
		
		next unless ( $lFoundBody == 1 );
			
		# See if we can find the Synopsis
		
		if ( index ($lRow, 'Synopsis:') == 0 ) {
			$lPos = rindex ($lRow, '<');
			$lSynopsis = substr ($lRow, 0, $lPos -1 );
		}
	
		#if ( index ( $lRow, '<p>') == 0) {
		#	push ( @lStory, $lRow);
		#}
		
		# Do some common cleanup tasks
		
		next if ( index ($lRow, '<p><br></p>') > -1);
		next if ( index ($lRow, '--></style>') > -1);
		next if ( index ($lRow, '</head>') > -1);
		next if ( index ($lRow, '<body>') > -1);
		next if ( index ($lRow, '<html><head>') > -1);
		next if ( index ($lRow, '<meta http-equiv>') > -1);
		next if ($lRow eq '<br>');
		
		if ( index ($lRow, '<br>') > -1 ) {
			# Sometimes we see <br>texttext\n and sometimes <br>x x x xTo the dismay of the family..."
			# where x x x are funny graphics characters
			# Try to get rid of the graphic characters first
			$lRow =~ s/\<br\>[^a-zA-Z0-9'"]+//;
			
			$lRow = '<p>' . $lRow . '</p>';
		}
		
		
		
		if ( index ( $lRow, '&nbsp;') > -1 ) {
			$lRow =~ s/ \&nbsp\;//g;
			$lRow =~ s/\&nbsp\;//g;
		}
		$lRow =~ s/\> +/\>/ if ( index ($lRow, '> ') > -1 );
		$lRow =~ s/\<span class\=[^>]*\>//g if ( index ($lRow, '<span class') > -1 );
		$lRow =~ s/\<\/span\>//g if ( index ($lRow, '</span>') > -1 );
		
		if ( $lRow =~ m/Chapter (\d+)/i ) {
			$lRow =~ s/\<p\>/\<h3 class\="chapter"\>/;
			$lRow =~ s/\<\/p\>/\<\/h3\>/;
		}
		
		if ( $lRow =~ m/Part (\d+)/i ) {
			$lRow =~ s/\<p\>/\<h3 class\="chapter"\>/;
			$lRow =~ s/\<\/p\>/\<\/h3\>/;
		}

		push (@lStory, $lRow);
			
	}
	
	$lStory[1] = $lSynopsis;
	
	return (@lStory);
	
}	# extractStoryRows

#-------------------------------------------------------------------------
# Routine:		extractGTLTData
# Descripton:	This routine will take a long string that contains ">something here<"
#				and returns the text betwent the > and < characters
#
# Inputs:		aStr - the string with data between >< chars
#
# Returns:		string between the >< chars or ""
#-------------------------------------------------------------------------
sub extractGTLTData {
	my ($aStr) = @_;
	my ($lPos1, $lPos2, $lReturn);
	
	$lReturn = "";
	
	$lPos2 = rindex ( $aStr, '<' );
	$lPos1 = rindex ( $aStr, '>', $lPos2 );
	
	if ( $lPos2 > -1 and $lPos1 > -1 ) {
		$lReturn = substr ($aStr, $lPos1 + 1, $lPos2 - $lPos1 -1);
	}
	
	return ($lReturn);
}	# extractGTLTData

#-------------------------------------------------------------------------
# Routine:		outputStory
# Description:
#
# Inputs:	title - title of story
#			author - 
#			chapter - total number of chapters
#			body - Reference to array of paragraphs
#-------------------------------------------------------------------------
sub outputStory {
	my (%args) = @_;
	my ($lSubjectLine);
	my ($lParts, $lRow);
	
	$args{chapter} = 1 if ( ! exists $args{chapter} ) ;
	
	print STORY_FILE "\n\n{-------------------------------------------------------------------}\n\n";
	
	$lSubjectLine = 'Subject: "' . $args{title} . '" ';
	
	if ( $args{chapter} > 10 ) {
		$lParts = "[01-$args{chapter}/$args{chapter}] ";
	} else {
		$lParts = "[1-$args{chapter}/$args{chapter}] ";
	}
	
	$lSubjectLine .= $lParts;
	
	if ( length ( $args{author} ) > 1 ) {
		$lSubjectLine .= "\{$args{author}\} ";
	}

	print STORY_FILE "$lSubjectLine\n\n";
	
	# Now for the paragraphs
	foreach $lRow ( @{$args{body}} ) {
		print STORY_FILE "$lRow\n";
	}
	
	print STORY_FILE "\n\n\n";
}	# outputStory

#-------------------------------------------------------------------------
# Routine:		crawlStory
# Description:	This routine will take a key which will allow this routine to
#				extract the URL and text. Then it will parse the title
#				page for the title, author and codes. Then the story
#				body will be collected.
#-------------------------------------------------------------------------
sub crawlStory {
	my $self = shift;
	my (%args) = @_;
	my ($lURL, $lTitle, $lAuthor, $lCodes, $lKey, $lWholeStoryLink, $lStoryId);
	my ($lMech, $lPos, $lBody, $lRow, $lPos1, $lPos2, $lTotalChapters);
	
	$lKey = $args{key};
	$lTitle = $gIndexHash{$lKey}{text};
	$lAuthor = "";
	$lCodes = "";
	$lTotalChapters = 0;
	
	# STEP 1: Index page
	# This page gives us the title, author, links to the entire story or links to just the
	# chapters.
	
	# We have to add the base URL to the URL from our hash
	#$lKey = $args{key};
	$lURL = $self->{mBaseURL} . $gIndexHash{$lKey}{url};
	
	print "URL 2: $lURL\n";
	

	$lMech = WWW::Mechanize->new(
		agent 		=> 'Mozilla/5.0',
		cookie_jar 	=> {}
	);
	$lMech->agent_alias( 'Windows IE 6' );

	#$lMech->get($self->{mBaseURL});	
	#$lMech->follow_link ( url => $gIndexHash{$lKey}{url} );
	
	# Get index page like: http://www.bdsmlibrary.com/stories/story.php?storyid=1337
	print "Index Page: $lURL\n";
	$lMech->get($lURL);
	
	$lBody = $lMech->content();
	
	my @lTemp = split ("\n", $lBody);
	print "Index page Rows found: " . scalar(@lTemp) . "\n";

	
	my $i;
	# Find the Title of the story
	foreach $lRow ( @lTemp ) {
			
		# Look for the title	
		if ( index ($lRow, '<title>') > -1) {
			$lTitle = &extractGTLTData($lRow);
			# String should look like: ..Story: The Fifth
			my ($a, $b) = split (/:/, $lTitle);
			$b =~ s/^\s+//;
			$lTitle = $b;
			print "Title: $lTitle\n";
		}
		
		# Look for the Author
		if ( index ($lRow, 'author.php?authorid=') > -1) {
			if ( $lRow =~ m/authorid=(\d+)/) {
				$lAuthor = &extractGTLTData($lRow);
				$lAuthor =~ s/^\s+//;
				print "Author: $lAuthor\n";					
			}
		}
	
		# Look for the story codes
		#if ( index ($lRow, '>Story Codes<') > -1) {
		#	print "Story Codes: $lRow\n";
		#}
		
		# Look for the whole-story link
		if ( index ($lRow, '/stories/wholestory.php?storyid=') > -1 ) {
			$lRow =~ m/storyid=(\d+)/;
			$lStoryId = $1;
			print "Story id: $lStoryId\n";
		}
		
		# Count the chapters
		if ( index ($lRow, '>Chapter ') > -1 ) {
			$lRow =~ m/Chapter (\d+)/;
			$lTotalChapters = $1;
			#print "Chapter: $lTotalChapters\n";
		}
	}
	
	# If we get here and have a story id, use this to follow the link to the wholestory
	# page
	
	if ( $lStoryId > 0 ) {
		print "Found story id in page: $lStoryId\n";
	}
	
	if ($lStoryId > 0) {
		my $lWSURL = "/stories/wholestory.php?storyid=$lStoryId";
		print "Attempting to follow whole story link: $lWSURL\n";
		$lMech->follow_link( url => $lWSURL );
		if ( $lMech->success() ) {
			print "\tSUCCESS. Whole story link found\n";
			$lBody = $lMech->content();
			#$lBody = $lMech->text();
			my @lPara = &extractStoryRows ( $lBody );
			&outputStory (title => $lTitle, author => $lAuthor, chapters => $lTotalChapters, body => \@lPara);
		} else {
			print "Error: Attempt to follow whole story link failed: url = $lWSURL\n";
		}
	} else {
		print "Error: Could not find wholestory link\n";
	}
	
	
}	# crawlStory

#-------------------------------------------------------------------------
# Routine:		crawlStory2
# Description:	This routine will take a key which will allow this routine to
#				extract the URL and text. Then it will parse the title
#				page for the title, author and codes. Then the story
#				body will be collected.
#-------------------------------------------------------------------------
sub crawlStory2 {
	my $self = shift;
	my (%args) = @_;
	my ($lURL, $lTitle, $lAuthor, $lCodes, $lKey, $lWholeStoryLink, $lStoryId);
	my ($lMech, $lPos, $lBody, $lRow, $lPos1, $lPos2, $lTotalChapters);
	
	$lTitle = "";
	$lAuthor = "";
	$lCodes = "";
	$lTotalChapters = 0;
	$lKey = $args{key};
	
	# We have to add the base URL to the URL from our hash
	#$lKey = $args{key};
	$lURL = $self->{mBaseURL} . $gIndexHash{$lKey}{url};
	
	print "URL: $lURL\n";
	
	$lMech = WWW::Mechanize->new(
		agent 		=> 'Mozilla/5.0',
		cookie_jar 	=> {}
	);
	$lMech->agent_alias( 'Windows IE 6' );

	#$lMech->get($self->{mBaseURL});
	
	#$lMech->follow_link ( url => $gIndexHash{$lKey}{url} );
	
	
	#$lBody = $lMech->content();
	
	$lStoryId = 0;
	if ( $gIndexHash{$lKey}{url} =~ m/storyid=(\d+)/ ) {
		$lStoryId = $1;
	}
	# If we get here and have a story id, use this to follow the link to the wholestory
	# page
	if ($lStoryId > 0) {
		my $lWSURL = "http://www.bdsmlibrary.com/stories/wholestory.php?storyid=$lStoryId";
		print "Attempting to follow whole story link: $lWSURL\n";
		$lMech->get( $lWSURL );
		if ( $lMech->success() ) {
			print "\tSUCCESS. Whole story link found\n";
			$lBody = $lMech->content();
			#$lBody = $lMech->text();
			my @lPara = &extractStoryRows ( $lBody );
			&outputStory (title => $lTitle, author => $lAuthor, chapters => $lTotalChapters, body => \@lPara);
		} else {
			print "Error: Attempt to follow whole story link failed: url = $lWSURL\n";
		}
	} else {
		print "Error: Could not find wholestory link\n";
	}
	
	
}	# crawlStory2

#-------------------------------------------------------------------------
# Routine:		readIndexFile
# Descripton:	Will read the main page of the web site and extract all
#				the story links and create an index file that
#				consists of: URL <tab> Status <tab> <Text>
#
#-------------------------------------------------------------------------
sub scanStories {
	my $self = shift;
	my (%args) = @_;
	my ($lKey, $lURL, $lText, $lStatus, $lCount);
	my ($lOutputFile);
	
	if ( exists $args{output_file} ) {
		$lOutputFile = $args{output_file};
	} else {		
		$lOutputFile = 'bdsmlib05.txt';
	}
	
	print "Scanning for stories...\n";
	open (STORY_FILE, ">$lOutputFile") or confess ("Error: Could not open file for output: $lOutputFile : $!\n");
	
	foreach $lKey ( sort keys %gIndexHash ) {
		#next unless ( index ($gIndexHash{$lKey}{url}, 'storyid=9728' ) > -1 );
		#next unless ($gIndexHash{$lKey}{status} == 0);
		
		# We need to assemble the real url for the whole story
		
		$lURL = $lKey;
		#print "URL:    $lURL\n";
		#print "Text:   $gIndexHash{$lKey}{text}\n";
		
		
		$self->crawlStory( key => $lKey );
		$gIndexHash{$lKey}{status} = 1;
		$lCount++;
		
		last if ($lCount > 5000);
		
	}
	close (STORY_FILE) or confess ("Error: Could not close output file: $lOutputFile : $!\n");
			
	print "Output file created: $lOutputFile\n";
	
	
}	# scanStories


1;

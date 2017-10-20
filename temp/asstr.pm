#!/usr/bin/perl
package asstr;
#
# AUTHOR:	Bob McElfresh
# DATE:		2008-08-22
#
# MODULE_NAME: asstr.pm
#
use strict;
use warnings;
use diagnostics;
#use carp;
use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use Data::Dumper;
require LWP::UserAgent;

$VERSION     = '0.01';
@ISA         = qw(Exporter);
@EXPORT      = ();
@EXPORT_OK   = qw(new getAuthors);
%EXPORT_TAGS = ( DEFAULT => [qw(&func1)],
                 Both    => [qw(&func1 &func2)]);


my $AUTHORS_BASE_URL = 'http://www.asstr.org/files/Authors/';
my $WORKING_DIR      = '\\temp\\text_proc\\ASSTR\\NEW\\';
my $WORKING_DIR_MODERATED = '\\temp\\asstr\\';

my %BAD_ROWS_5 = (
    '<!--A' => 1,
    '<meta' => 1,
    '<SCRI' => 1,
    '<SCRI' => 1,
    '<SCRI' => 1,
    '<!--'  => 1,
    'runSc' => 1,
    '//-->' => 1,
    '</SCR' => 1,
    '<pre>' => 1,
    '<br><' => 1,
    '<font' => 1,
    '</fon' => 1,
);

# This hash will hold the URL for the pages that hold the most recent 8 days of stories.
my %RECENT_HASH = (
	1	=> {url => 'http://www.asstr.org/newfiles1.html', ymd => '', fetch => 0, index_file => ''},
	2	=> {url => 'http://www.asstr.org/newfiles2.html', ymd => '', fetch => 0, index_file => ''},
	3	=> {url => 'http://www.asstr.org/newfiles3.html', ymd => '', fetch => 0, index_file => ''},
	4	=> {url => 'http://www.asstr.org/newfiles4.html', ymd => '', fetch => 0, index_file => ''},
	5	=> {url => 'http://www.asstr.org/newfiles5.html', ymd => '', fetch => 0, index_file => ''},
	6	=> {url => 'http://www.asstr.org/newfiles6.html', ymd => '', fetch => 0, index_file => ''},
	7	=> {url => 'http://www.asstr.org/newfiles7.html', ymd => '', fetch => 0, index_file => ''},
	8	=> {url => 'http://www.asstr.org/newfiles8.html', ymd => '', fetch => 0, index_file => ''},
);


#-------------------------------------------------------------------------
#
#-------------------------------------------------------------------------
sub new
{
	my $class = shift;
	my %args  = @_;
	my @lText = ();
	my ($lRow, $lRowCount);

    $args{letter} = 'A' if ( ! exists $args{letter} );

	my $self = {
		mAuthorLetter		=> $args{letter},
	};


	bless $self, $class;
	return $self;
}	# new

#-------------------------------------------------------------------------
# Routine:		RFgetYMD
# Description:	This routine will take a "Recently uploaded" content from ASSTR and
# 				tease out 2 pieces of data:
#					YYYYMMDD - the date from the page that says these files were uploaded on this date
#					Array of story links
#				Asstr keeps 8 pages of recent uploads. After each day - they rotate so the stories
#				that were on recent page4 move to page5 then page6, then off the end. This makes
#				it hard to keep up.  So this routine finds the YYYYMMDD at the top of the page and 
#				returns it as a key. Since we have the content - this routine also teases out the
#				story links.
#
#
#-------------------------------------------------------------------------
sub RFgetYMD {
	my(%args) = @_;
	my (@lLines, $lRow, $lYMD, @lLinks);
	
	# Break the page up into rows:
	$lYMD = "";
	@lLines = split ("\n", $args{content});
	foreach $lRow ( @lLines ) {
		if ( index ($lRow, 'Files added last') > -1) {
			print "Looking for date: $lRow\n";
			$lRow =~ m/(\d\d\d\d\-\d\d\-\d\d)/;
			$lYMD = $1;
			$lYMD =~ s/\-//g;	
		}
	}
	return ($lYMD);
}	# RFgetYMD

#-------------------------------------------------------------------------
# Routine:		RFCalcFileName
# Description:	This routine will take a type and a YYYYMMDD string and return 
#				a different file name based on type. For example:
#					link_file = 'asstr_url_YYYYMMDD.dat'
#					story_file = 'asstr_story_YYYYMMDD.txt'
#-------------------------------------------------------------------------
sub RFCalcFileName {
	my (%args) = @_;
	my $lFileName = "";
	
	if ( $args{type} eq 'index_file' ) {
		$lFileName = sprintf ("asstr_url_%s.dat", $args{ymd});
	}
	if ( $args{type} eq 'story_file' ) {
		$lFileName = sprintf ("asstr_story_%s.txt", $args{ymd});
	}

	return ($lFileName);
}	# RFCalcFileName

#-------------------------------------------------------------------------
# Routine:		S_FetchStory
# Description:	This routine will take a URL and try and extract the contents
# 				of the web page to a text buffer.
#
#-------------------------------------------------------------------------
sub S_FetchStory {
	my (%args) = @_;
	my ($lUA, $lURL, $lContent, $lResponse);
	
	$lContent = "";

	$lUA = LWP::UserAgent->new;
	$lUA->timeout(10);
	$lUA->env_proxy();
	$lUA->agent('Mozilla/5.0');

	print "Fetching web page: $args{url}";
	$lResponse = $lUA->get($args{url});
	if ( $lResponse->is_success ) {
		$lContent = $lResponse->decoded_content();
	} else {
		print "Error: Page failed to load: $args{url}\n";
	}

	return ( $lContent );
}	# S_FetchStory


#-------------------------------------------------------------------------
# Routine:		S_ParseStory
# Description:	This routine will take a web page content, try and tease out the
#				Title, Author, Part, Keycodes and body, then return.
#
#-------------------------------------------------------------------------
sub S_ParseStory {
	my (%args) = @_;
	my ($lTitle, $lSubTitle, $lPart, $lAuthor, $lCodes, $lBody) = ("", "", "", "", "");
	my (@lLines, $lRow, $lStoryStart, $lStoryEnd, $lPos1, $lPos2, $lRowNum);

	print "Parse Story starting...\n";
	# Put the rows into an array
	@lLines = split ("\n", $args{content});
	
	$lStoryStart = 0;
	$lStoryEnd  = scalar (@lLines);
	$lRowNum = 0;
	
	foreach $lRow ( @lLines ) {
	
		# Search for Title
		if ( index ($lRow, '<p class="title"') > -1 ) {
			# <p class="title"    >Meadows
			$lPos1 = rindex ($lRow, '>') + 1;
			$lTitle = substr ($lRow, $lPos1, 100);
		}
		if ( index ($lRow, 'Title:') == 0 ) {
			$lPos1 = index ($lRow, ':') + 1;
			$lTitle = substr ( $lRow, $lPos1, 100);
		}
		
		# Search for Subtitle
		if ( index ($lRow, '<p class="subtitle"') > -1 ) {
			$lPos1 = rindex ($lRow, '>') + 1;
			$lSubTitle = substr ($lRow, $lPos1, 100);
		}

		# Search for Author
		if ( index ($lRow, '<p class="author"') > -1 ) {
			$lPos1 = rindex ($lRow, '>') + 1;
			$lAuthor = substr ($lRow, $lPos1, 100);
		}
		if ( index ($lRow, 'Author:') > -1 ) {
			$lPos1 = rindex ($lRow, ':') + 1;
			$lAuthor = substr ($lRow, $lPos1, 100);
		}

		
		# Look for Chapter or Part
		if ( index ($lRow, '<p class="chapter"') > -1 ) {
			$lPos1 = rindex ($lRow, '>') + 1;
			$lPart = substr ($lRow, $lPos1, 100);
		}
		if ( index ($lRow, 'Part:') > -1 ) {
			if ( $lRow =~ m/(\d+) of (\d+)/ ) {
				$lPart = sprintf ("%02d", $1) . '/' . sprintf ("%02d", $2);
			}
		}
	
		# Search for codes
		if ( index ($lRow, '<p class="codes"') > -1 ) {
			$lPos1 = rindex ($lRow, '>') + 1;
			$lCodes = substr ($lRow, $lPos1, 100);
		}
		if ( index ($lRow, 'Keywords:') > -1 ) {
			$lPos1 = rindex ($lRow, ':') + 1;
			$lAuthor = substr ($lRow, $lPos1, 100);
		}

		# See if we find a row that skips the header
		
		$lStoryStart = $lRowNum if ( index ($lRow, '<span class="chaptertitle">') > -1);
		$lStoryStart = $lRowNum if ( index ($lRow, '</font>') > -1 && $lRowNum < 30);
		$lStoryStart = $lRowNum if ( index ($lRow, 'this.previousTop = currentTop;') > -1 && $lRowNum < 100 );
		
		$lStoryEnd = $lRowNum if ( index ($lRow , '<p class="nextchapter">') > -1 && $lRowNum > 100);
		$lStoryEnd = $lRowNum if ( index ($lRow, 'To be continued' ) > -1 && $lRowNum > 100 );
		$lStoryEnd = $lRowNum if ( index ($lRow, '!-- end content -->') > -1 );
		$lStoryEnd = $lRowNum if ( index ($lRow, '<a name="Leave_a_comment">') > -1 );
		
		$lRowNum++;
	}
	
	$lTitle    =~ s/^\s+//;
	$lSubTitle =~ s/^\s+//;
	$lPart     =~ s/^\s+//;
	$lAuthor   =~ s/^\s+//;
	$lCodes    =~ s/^\s+//;
	
	my $lSubject = '"' . $lTitle . '" [' . $lPart .'] {' . $lAuthor . '} (' . $lCodes . ')';
	#print "$lSubject\n";
	print "Title:     [$lTitle]\n";
	print "SubTitle:  [$lSubTitle]\n";
	print "Part:      [$lPart]\n";
	print "Author:    [$lAuthor]\n";
	print "Codes:     [$lCodes]\n";
	
	
}	# S_ParseStory


#-------------------------------------------------------------------------
#-------------------------------------------------------------------------
sub DeDupIndexFiles {
	my ($lPattern, $lIndexFile, $lYMD, $lStoryFile, @lIndexArray, $lRow);
	my %lHash;

	# Find the missing .txt files.
	$lPattern = "asstr_url_*.dat";
	foreach $lIndexFile ( sort glob ($lPattern) ) {
	
		if ( $lIndexFile =~ m/(\d\d\d\d\d\d\d\d)/ ) {
			$lYMD = $1;
			$lStoryFile = &RFCalcFileName (type => 'story_file', ymd => $lYMD);
			if ( ! -e $lStoryFile ) {
				push (@lIndexArray, $lStoryFile);
			}
		}
	}

	foreach $lIndexFile ( @lIndexArray ) {
		print "DupChecking File: $lIndexFile\n";
		open (IN_FILE, $lIndexFile);
		while ( $lRow = <IN_FILE> ) {
			chomp ($lRow);
			if ( exists $lHash{$lRow} ) {
				print "Dup: $lRow\n";
			} else {
				$lHash{$lRow}++;
			}
		}
		close (IN_FILE);
	}

}	# DeDupIndexFiles

#-------------------------------------------------------------------------
#-------------------------------------------------------------------------
sub TestParse {
	my (@lIndexArray, $lFile, $lContent, $lRow);
	
	push (@lIndexArray, 'file1.url');
	push (@lIndexArray, 'file2.url');

	foreach $lFile ( @lIndexArray ) {
		$lContent = "";
		open (IN_FILE, $lFile);
		while ( $lRow = <IN_FILE> ) {
			$lContent .= $lRow;
		}
		close (IN_FILE);
		
		my @lTemp = &S_ParseStory ( content => $lContent );
	}
};	
#-------------------------------------------------------------------------
# Routine:		RFCollectRecent
# Description:	This routine will look for index files with names like 
#				asstr_url_YYYYMMDD.dat and see if there is a matching .txt
#				file. If not, this routine will open the .dat file, pull the
#				URL's and try to collect the text stories in the URL.
#-------------------------------------------------------------------------
sub RFCollectRecent {
	my $self = shift;
	my ($lPattern, @lIndexArray, $lYMD, $lIndexFile, $lStoryFile, $lURL, $lContent, $lTempFile);
	
	&TestParse();
	return;
	
	# Find the missing .txt files.
	$lPattern = "asstr_url_*.dat";
	foreach $lIndexFile ( sort glob ($lPattern) ) {
		print "Index File: $lIndexFile\n";
		if ( $lIndexFile =~ m/(\d\d\d\d\d\d\d\d)/ ) {
			$lYMD = $1;
			print "ymd = $lYMD\n";
			$lStoryFile = &RFCalcFileName (type => 'story_file', ymd => $lYMD);
			
			if ( ! -e $lStoryFile ) {
				push (@lIndexArray, $lStoryFile);
				print "Story file missing: $lStoryFile\n";
			}
		}
	}

	# Now go through the array and create the .txt file
	foreach $lIndexFile ( sort @lIndexArray ) {
		if ( $lIndexFile =~ m/(\d\d\d\d\d\d\d\d)/ ) {
			$lYMD = $1;
			$lStoryFile = &RFCalcFileName (type => 'story_file', ymd => $lYMD);
			
			# ...
			# Call a routine that will go to the web page, download the contents, scan for title, part, codes & author name & text.
			$lURL = 'http://www.asstr.org/~GeorgiePorgie/meadow07.htm';
			
			$lContent = &S_FetchStory( url => $lURL );
			$lTempFile = 'file1.url';
			open ( TEMP_FILE, ">$lTempFile" );
			print TEMP_FILE "$lContent\n";
			close (TEMP_FILE);

			$lURL = 'http://www.asstr.org/files/Authors/willy_tamarack/chronicles/Tamarack25.txt';
			$lContent = &S_FetchStory( url => $lURL );
			
			$lTempFile = "file2.url";
			open ( TEMP_FILE, ">$lTempFile" );
			print TEMP_FILE "$lContent\n";
			close (TEMP_FILE);

			die ("Exiting for testing\n");
		}

	}
	
}	# RFCollectRecent

#-------------------------------------------------------------------------
# 	Routine:		RFFindRecent
#	Description:	This routine will look at the most recent 8 days of uploads to ASSTR
#					and write the links to asstr_url_YYYYMMDD.dat.
#
#-------------------------------------------------------------------------
sub RFFindRecent {
	my $self = shift;
	my ($lUA, $lKey, $lURL, $lYMD, $lIndexFile, $lResponse, $lPageContent, $lStoryURL);
	
	
	print "FindRecent starting...";

	$lUA = LWP::UserAgent->new;
    $lUA->timeout(100);
	$lUA->env_proxy();
	$lUA->agent('Mozilla/5.0');
	
	my $lMech = WWW::Mechanize->new(
		agent 		=> 'Mozilla/5.0',
		cookie_jar 	=> {}
	);
	$lMech->agent_alias( 'Windows IE 6' );
	
	
	foreach $lKey ( sort keys %RECENT_HASH ) {
		print "Scanning url: $RECENT_HASH{$lKey}{url}\n";
		$lResponse = $lUA->get ($RECENT_HASH{$lKey}{url});
		$lMech->get ($RECENT_HASH{$lKey}{url});
		
		if ( $lResponse->is_success ) {
			print "\tScanning for YMD...\n";
			$lPageContent = $lResponse->decoded_content();
			# Call a routine that will extract the YYYY-MM-DD text saying these files were uploaded on this date
			$lYMD = &RFgetYMD ( content => $lPageContent );
			print "YMD = $lYMD\n";
			# Calculate the name of the index file we might or might not have created in the past.
			$lIndexFile = &RFCalcFileName ( type => 'index_file', ymd => $lYMD );
			print "Index file: $lIndexFile\n";
			#unlink ($lIndexFile);
			if ( ! -e $lIndexFile ) {
				# Create the index file and put all the story url's in the index.
				print "\tCreating index file: $lIndexFile...\n";
				open (INDEX_FILE, ">$lIndexFile") or die ("Error: cannot open file for output: $lIndexFile : $!\n");
				
				my $lArrayRef = $lMech->find_all_links( url_regex => qr/www\.asstr\.org/ );
				my @lLinkArray = @{$lArrayRef};
				foreach my $lMLink ( sort @lLinkArray ) {
					$lStoryURL = $lMLink->url_abs();
					next if ( index ($lStoryURL, '/archives.htm') > -1 );
					next if ( index ($lStoryURL, '/authpage.htm') > -1 );
					next if ( index ($lStoryURL, 'org/authors.htm') > -1 );
					next if ( index ($lStoryURL, '/copyright') > -1 );
					next if ( index ($lStoryURL, '/counts.htm') > -1 );
					next if ( index ($lStoryURL, '/donate') > -1 );
					next if ( index ($lStoryURL, '/donations') > -1 );
					next if ( index ($lStoryURL, '/faq') > -1 );
					next if ( index ($lStoryURL, '/gay') > -1 );
					next if ( index ($lStoryURL, '/header.htm') > -1 );
					next if ( index ($lStoryURL, 'Histoires_Fr') > -1);
					next if ( index ($lStoryURL, '/home.htm') > -1 );
					next if ( index ($lStoryURL, '/index.htm') > -1 );
					next if ( index ($lStoryURL, '/links.htm') > -1 );
					next if ( index ($lStoryURL, '/main.htm') > -1 );
					next if ( index ($lStoryURL, '/new.htm') > -1 );
					next if ( index ($lStoryURL, '/nifty') > -1 );
					next if ( index ($lStoryURL, '/stories.htm') > -1 );
					next if ( index ($lStoryURL, '/support') > -1 );
					next if ( index ($lStoryURL, '/terms') > -1 );
					next if ( index ($lStoryURL, '/updates.htm') > -1 );
					next if ( index ($lStoryURL, '/rss') > -1 );
					next if ( index ($lStoryURL, '.css') > -1 );
					next if ( index ($lStoryURL, '.docx') > -1 );
					next if ( index ($lStoryURL, '.pdf') > -1 );
					next if ( index ($lStoryURL, '.rtf') > -1 );
					
					print INDEX_FILE $lMLink->url_abs() . "\n";
					print $lMLink->url_abs() . "\n";
				}
				close (INDEX_FILE) or die ("Error: could not close output file: $lIndexFile : $!\n");
				print "Index file created: $lIndexFile\n\n"

			}
			
			
		} else {
			print "Error: Could not get response from url: $RECENT_HASH{$lKey}{url}\n"
		}
		
	}
	
}	# RFFindRecent

#-------------------------------------------------------------------------
# Routine:        getModeratedStories
# Description:	This routine will take a year argument, find the matching
#               stories_YYYY.url file and attempt to read the stories ----
#               and write pages to stories_YYYY.txt
# Input:		year - year to scan
#               max_files - max stories to read
#--------------------------------------------------------------------------
sub getModeratedStories {
	my (%args) = @_;
	my ($lURLFile, $lStoriesFile, $lBaseURL, $lTempFile);
	my (%lURLHash, $lRow, $lURL, $lDone, $lPendingCount, $lDoneCount);
	my ($lAttempt, $lUA, $lResponse);

	chdir ($WORKING_DIR_MODERATED) or die ("Error: Could not chdir to working dir: $WORKING_DIR_MODERATED : $!");
	$lBaseURL = sprintf ("http://www.asstr.org/files/Collections/Alt.Sex.Stories.Moderated/Year%04d/", $args{year});

	$lURLFile = sprintf ("stories_%04d.url", $args{year});
	$lStoriesFile = sprintf ("stories_%04d.txt", $args{year});

	if ( ! -e $lURLFile ) {
		print "Error: Expected URL file does not exist: $lURLFile\n";
		return;
	}

	# Read the stories_YYYY.url file into our hash so we know what
	# has been collected or not

	$lPendingCount = 0;
	open (URL_FILE, $lURLFile) or die ("Error reading url file: $lURLFile : $!\n");
	while ( $lRow = <URL_FILE> ) {
		chomp ($lRow);
		($lURL, $lDone) = split (/\|/, $lRow);
		$lURLHash{$lURL} = $lDone;
		$lPendingCount++ if ( $lDone == 0 );
	}
	close (URL_FILE);

	print "Reading Moderated stories for $args{year} - $lPendingCount files pending\n";

	$lUA = LWP::UserAgent->new;
    $lUA->timeout(100);

	$lTempFile = 'stories.tmp';

	open (TEMP_FILE, ">$lTempFile") or die ("Error: Could not open file for output: $lTempFile : $!\n");
	$lDoneCount = 0;
	foreach $lURL ( sort keys %lURLHash ) {
		next if ( $lURLHash{$lURL} != 0);

    	for ($lAttempt = 1; $lAttempt < 4; $lAttempt++ ) {
    	    $lResponse = $lUA->get( $lURL );
    	    if ( $lResponse->is_success() ) {
    	        last;
    	    } else {
    	        print "Error: Attempt $lAttempt failed. Could not get index page\n" . $lResponse->status_line ."\n";
    	        sleep (3);
    	    }
    	}

    	if ( ! $lResponse->is_success ) {
			next;
		}

		print TEMP_FILE "\n{------------------------------------------------------}\n\n";
		print TEMP_FILE $lResponse->content();
		print TEMP_FILE "\n";

		$lURLHash{$lURL} = 1;
		$lDoneCount++;
		print "\t$lDoneCount retrieved\n" if ($lDoneCount % 10 == 0);

		last if ($lDoneCount >= $args{max_files});

	}
	close (TEMP_FILE) or die ("Error: Could not close tmp file: $lTempFile : $!\n");

	# Append the temp file to the stories file
	open (TEMP_FILE, $lTempFile) or die ("Error opening file: $lTempFile : $!\n");
	open (OUT_FILE, ">>$lStoriesFile") or die ("Error opening stories file: $lStoriesFile : $!\n");
	while ( $lRow = <TEMP_FILE> ) {
		print OUT_FILE $lRow;
	}
	close (OUT_FILE) or die ("Error closing stories file: $lStoriesFile : $!\n");
	close (TEMP_FILE);
	unlink ($lTempFile);

	# Write the updated hash back to the url file

	print "Rewriting URL file: $lURLFile\n";
	open (TEMP_FILE, ">url.tmp") or die ("Error opening temp url file: $!\n");
	foreach $lURL ( sort keys %lURLHash ) {
		print TEMP_FILE $lURL . "|$lURLHash{$lURL}\n";
	}
	close (TEMP_FILE) or die ("Error closing temp url file: $!\n");
	unlink ($lURLFile);
	rename ("url.tmp", $lURLFile) or die ("Error renaming url.tmp to $lURLFile\n");


}	# getModeratedStories

#-------------------------------------------------------------------------
#   Routine:        getModeratedLinks
# Description:	This routine takes a YEAR argument, then it will scan the
#		asstr moderated page for that year, dive into the week
#		1,2,... pages and return an array of URL's for the s
#		stories.
#-------------------------------------------------------------------------
sub getModeratedLinks {
    my (%args) = @_;
	my ($lBaseURL, $lTempFile, $lYearFile);
	my ($lUA, $lAttempt, $lResponse);
	my ($lBuffer, $lRow, $lURL, %lURLHash, $lFile);
	my ($lFileCount);

	%lURLHash = ();
	$lFileCount = 0;

	chdir ($WORKING_DIR_MODERATED) or die ("Error: Could not chdir to working dir: $WORKING_DIR_MODERATED : $!");
	$lBaseURL = sprintf ("http://www.asstr.org/files/Collections/Alt.Sex.Stories.Moderated/Year%04d/", $args{year});

	$lYearFile = sprintf ("stories_%04d.url", $args{year});
	if ( -e $lYearFile ) {
		print "Year $args{year} already processed.\n";
		return;
	}

	# Try getting the base page
    $lUA = LWP::UserAgent->new;
    $lUA->timeout(100);

    for ($lAttempt = 1; $lAttempt < 4; $lAttempt++ ) {
        $lResponse = $lUA->get( $lBaseURL );
        if ( $lResponse->is_success ) {
            print "\tModerated Index page Attempt $lAttempt\n";
            last;
        } else {
            print "Error: Attempt $lAttempt failed. Could not get index page\n" . $lResponse->status_line ."\n";
            sleep (3);
        }
    }

	if ( ! $lResponse->is_success() ) {
		print "Error: Could not retrieve the index page\n";
		print "  $lBaseURL";
		return;
	}

	print "Index page for year $args{year} retrieved.\n";
    foreach $lRow ( split ("\n", $lResponse->content()) ) {
		#next unless ( index ($lRow, '.txt') > -1);
		next if ( index ($lRow, '0.7K') > -1);	# Ignore empty stories

		# Look for rows like this:
		# <tr><td class="n"><a href="1002.txt">1002.txt</a></td><td class="m
		if ( $lRow =~ m/a href="(\d+\.txt)/ ) {
			$lFile = $1;
			#print "Found: $lFile\n";
			$lFileCount++;

			$lURLHash{$lBaseURL . '/' . $lFile} = 0;
			#if ( $lFileCount % 15 == 0 ) {
			#	print "Enter to continue..."; <STDIN>;
			#}
		} elsif ($lRow =~ m/href="([^"]*)/) {
			$lFile = $1;
			#print "Found: $lFile\n";
			$lFileCount++;
			$lURLHash{$lBaseURL . '/' . $lFile} = 0;
		} else {
			#print "nf: " . substr ($lRow, 0, 60) . "\n";
		}

	}

	if ( $lFileCount < 3 ) {
		print "No matching URLS found for $args{year}\n";
		return;
	}
	# Write the urls to a file followed by |0 to indicate the not-collected status



	$lTempFile = "url.tmp";
	open (TEMP_FILE, ">$lTempFile") or die ("Could not open output file: $lTempFile : $!\n");
	foreach $lFile ( sort keys %lURLHash ) {
		print TEMP_FILE $lFile . "|0\n";
	}
	close (TEMP_FILE) or die ("$!\n");
	rename ($lTempFile, $lYearFile) or die ("Error during rename: $!\n");

	print "Year index file created: $lYearFile - $lFileCount links\n";

} # getModeratedLinks


#-------------------------------------------------------------------------
#   Routine:        cleanAuthorFiles
#   Description:    This routine will take all the new author files
#                   found in \temp\text_proc\ASSTR\new
#                   and attempt to do some cleanup on them
#-------------------------------------------------------------------------
sub cleanAuthorFiles {
    my ($lFile, $lTempFile, $lPattern);
    my ($lRow);

    chdir ($WORKING_DIR) or die ("Error: Could not cd to working dir: $WORKING_DIR : $!\n");

    $lTempFile = 'clean.tmp';
    unlink ( $lTempFile ) if ( -e $lTempFile );

    $lPattern = "*.txt";
    $lPattern =
    print "Clean Authors Files starting:\n";
    foreach $lFile ( sort glob ("*.txt") ) {
        next if ( -s $lFile < 10);
        print "\t$lFile\n";

        open (IN_FILE, $lFile) or die ("Error: Could not open file for input: $lFile : $!\n");
        open (TEMP_FILE, ">$lTempFile") or die ("Error: Could not open file for output : $lFile : $!\n");
        while ($lRow = <IN_FILE>) {
            chomp ($lRow);

            # Check the first 5 characters to see if the row should be skipped

            if ( exists $BAD_ROWS_5{substr ($lRow, 0, 5)} ) {
                #print "Skipping: $lRow\n";
                next;
            }

            # HTML Removal
            $lRow =~ s/\<p\>//g if ( index ($lRow, '<p>') > -1);
            $lRow =~ s/\<\/a\>//g if ( index ($lRow, '</a>') > -1);
            #$lRow =~ s/\<\b\>//g if ( index ($lRow, '<b>') > -1);
            #$lRow =~ s/\<\/b\>//g if ( index ($lRow, '</b>') > -1);
            #$lRow =~ s/\<\/p\>//g if ( index ($lRow, '</p>') > -1);
            #$lRow =~ s/\<\p\>//g if ( index ($lRow, '<p>') > -1);
            #$lRow =~ s/\<\br\>//g if ( index ($lRow, '<br>') > -1);
            #$lRow =~ s/\<\/font\>//g if ( index ($lRow, '</font>') > -1);
            #$lRow =~ s/\&nbsp;//g if ( index ($lRow, '&nbsp;'') > -1);


            print TEMP_FILE "$lRow\n";
        }

        close (TEMP_FILE) or die ("Error: Could not close output file: $lTempFile : $!\n");
        close (IN_FILE);

        print "Temp file: $lTempFile created\n";
        <STDIN>;


    }

}   # cleanAuthorFiles

#-------------------------------------------------------------------------
# Routine:      authorFileList
# Description:  This routine will take a authors base url like:
#                   http://www.asstr.org/files/Authors/MarieLeClare/
#               and dive into this directory and return a full URL
#               of interesting file in this directory and sub-directories
# Inputs:   verbose - Controls priting of final list
#           base_url - string like: http://www.asstr.org/files/Authors/MarieLeClare/
#           author   - author name like: MarieLeClare for log messages
#-------------------------------------------------------------------------
sub authorFileList {
    my (%args) = @_;
    my ($lUA, $lResponse, $lText, $lCount, $lRow, $lFile, $lLCFile);
    my (@lFileArray, $lURL, $lAttemptCount);

    $args{verbose} = 0 if ( ! exists $args{verbose} );
    $lCount = 0;
    $lUA = LWP::UserAgent->new;
    $lUA->timeout(100);

    @lFileArray = ();

    $lURL = $args{base_url};
    #print "aFL: Getting url: $lURL\n";

    $lAttemptCount = 1;

    for ($lAttemptCount = 1; $lAttemptCount < 5; $lAttemptCount++) {
        if ( $lAttemptCount > 1 ) {
            print "\tFile List Attempt $lAttemptCount : $lURL\n";
        }
        $lResponse = $lUA->get($lURL);
        if ( $lResponse->is_success() ) {
            last;
        }
    }

    if ( ! $lResponse->is_success() ) {
        my $lErrorMsg = "aFL: Error: Could not get authors file list in $lAttemptCount attempts";
        return (@lFileArray);
    }

    # Process the results by looking for links.

    foreach $lRow ( split ("\n", $lResponse->content()) ) {
        # Look for a href and grab everything between 2 double-quote chars
        if ( $lRow =~ m/\<a href="([^"]*)/ ) {
            $lFile = $1;
            $lLCFile = lc ($1);

            # Filter out obvious files and directories

            next if ( index ($lLCFile, 'c=n') > -1);
            next if ( index ($lLCFile, '../') > -1);        # Parent directory
            next if ( index ($lLCFile, 'parent') == 0);     # Parent_directory
            next if ( index ($lLCFile, 'please_read') > -1);
            next if ( index ($lLCFile, 'www') > -1);         # www link
            next if ( index ($lLCFile, '.jpg') > -1);        # binary file
            next if ( index ($lLCFile, '.gif') > -1);        # binary file
            next if ( index ($lLCFile, '.rm') > -1);        # binary file

            # See if this row represents a new directory because it ends with a /
            if ( $lFile =~ m!/$! ) {
                # Recursive Call
                push (@lFileArray, &authorFileList (author => $args{author}, base_url => $args{base_url} . '/' . $lFile, verbose => 0) );
                next;
            }

            push (@lFileArray, $args{base_url} . '/' . $lFile);
        }
    }

    if ( $args{verbose} > 0 ) {
        my $lCount = 0;
        print "Files found for author: $args{author}\n";
        foreach $lRow (@lFileArray) {
            print "\t$lRow\n";
            $lCount++;

        }
    }

    return ( @lFileArray );

}   # authorFileList

#-------------------------------------------------------------------------
# Routine:      fetchAuthorsTextFiles
# Description:  This routine will take an authors name, then scan his
#               directory in ASSTR and find .txt files under his directory.
#               Then it will copy the contents into a single .txt
#               file for later processing.
#
#-------------------------------------------------------------------------
sub fetchAuthorsTextFiles {
    my (%args) = @_;
    my ($lUA, $lResponse, $lText, $lCount);
    my (@lFileArray, $lURL, $lFileURL, $lRow, $lFile, $lTempFile);
    my ($lAttempt);

    $args{verbose} = 0 if ( ! exists $args{verbose} );


    chdir ($WORKING_DIR) or die ("Error: Could not cd to working dir: $WORKING_DIR : $!\n");

    # See if we already collected this authors stories
    my $lNewFile = $args{author} . '.txt';

    if ( $args{force_get} == 0 ) {
        if ( -e $lNewFile ) {
            print "Already collected: $args{author}\n";
            return;
        }
    }
    return if ( $args{author} =~ m/PLEASE_READ/ );


    $lTempFile = 'aut.tmp';
    open (OUT_FILE, ">$lTempFile") or die ("Error: Could not open file for output: $lTempFile : $!\n");

    print "Fetching Text files for author: $args{author}\n";

    # Scan the authors directory and find .txt files. Put the names
    # into our file arrray

    my @lTempArray = &authorFileList ( %args );

    # The array contains all files, filter down to text based files

    foreach $lFile ( @lTempArray ) {

        #next if ( ! defined $lFile );       # In case helper routine had an error

        # Make a lower case version of the file names
        my $lLCFile = lc ($lFile);

        next if ( index ($lLCFile, '.pdf') > -1);
        next if ( index ($lLCFile, '.rtf') > -1);
        next if ( index ($lLCFile, '.doc') > -1);
        next if ( index ($lLCFile, '.jpg') > -1);
        next if ( index ($lLCFile, '.gif') > -1);
        next if ( index ($lLCFile, '.rm') > -1);
        next if ( index ($lLCFile, 'www/') > -1);
        next if ( index ($lLCFile, 'c=n') > -1);
        next if ( index ($lLCFile, 'please_read') > -1);
        next if ( index ($lLCFile, 'parent') == 0); # Parent_directory

        push (@lFileArray, $lFile);
    }

    # Fetch the individual text files

    $lUA = LWP::UserAgent->new;
    $lUA->timeout(100);

    foreach $lFile ( @lFileArray ) {
        print "\t\t$lFile\n";

        for ($lAttempt = 0; $lAttempt < 3; $lAttempt++ ) {
            $lResponse = $lUA->get( $lFile );
            if ( $lResponse->is_success ) {
                print "\tFile Retrieved Attempt $lAttempt: $lFile\n";
                last;
            } else {
                print "Error: Attempt $lAttempt failed. Could not get text file:\n\t$lFile\n\t" . $lResponse->status_line ."\n";
                sleep (3);
            }
        }

        if ($lAttempt > 2) {
            next;
        }

        print OUT_FILE "\n{------------------------------------------------------------------------}\n\n";
        my $lCleanName = $lFile;
        $lCleanName =~ s/\%20/ /g;
        $lCleanName =~ s/\.txt//;
        print OUT_FILE 'Subject: "' . $lCleanName . '" [1/1] () {' . $args{author} . '}' . "\n\n";

        print OUT_FILE $lResponse->content();
        print OUT_FILE "\n\n";

        sleep (1);

    }


    close (OUT_FILE) or die ("Error: Could not close output file: $lTempFile : $!\n");

    rename ($lTempFile, $lNewFile);

    #print "Author file created: $lNewFile\n";

}   # fetchAuthorsTextFiles

#-------------------------------------------------------------------------
#   Routine:        getAuthors
#   Description:    This routine will take a letter argument, then scan
#                   the ASSTR authors page for authors whos name begin
#                   with the same letter.
#-------------------------------------------------------------------------
sub getAuthors {
	my (%args)  = @_;
    my ($lUA, $lResponse, $lText);
    my ($lRow, %lAuthorsHash, $lAuthorDir, $lCount);
    my ($lFirstLetter_LC, $lFirstLetter_UC);
	#my (%self) = @_;

    print "getAuthors starting\n";

    $lFirstLetter_LC = lc ($args{letter});
    $lFirstLetter_UC = uc ($args{letter});


    $lCount = 0;
    $lUA = LWP::UserAgent->new;
    $lUA->timeout(100);

    print "Fetching ASSTR Authors main page...\n";
    $lResponse = $lUA->get($AUTHORS_BASE_URL);

    if ( $lResponse->is_success) {
        print "Authors page retrieved\n";
    } else {
        die ("Error: Could not access ASSTR main Author : \n\t $AUTHORS_BASE_URL\n\t " . $lResponse->status_line() . "\n");
    }

    # The response contains text like this:
    #  <a href="Anil_Mahadev/">Anil_Mahadev/</a>                     02-Dec-2004 14:14    -
    #  <a href="Animal/">Animal/</a>                           04-Sep-2004 18:07    -
    #  <a href="Anime_Lover/">Anime_Lover/</a>                      25-Nov-2009 16:47    -
    #  <a href="Ann_Douglas/">Ann_Douglas/</a>                      28-May-2010 06:45    -

    foreach $lRow ( split ("\n", $lResponse->content()) ) {
        if ( $lRow =~ m/\<a href=\"([^\/]*)/ ) {
            $lAuthorDir = $1;

            # See if this is one of our target authors

            if ( index ($lAuthorDir, $lFirstLetter_LC) == 0 or index ($lAuthorDir, $lFirstLetter_UC) == 0) {

                $lAuthorsHash{$lAuthorDir} = 0;
                print "\t$lAuthorDir\n" if ($lCount < 20);
                $lCount++;
            }

        }
    }


    foreach $lAuthorDir ( sort keys %lAuthorsHash ) {

        #next unless ( $lAuthorDir eq 'CDE' or $lAuthorDir eq 'CH_Makoto');

        # Call a routine that will extract the text files

        next if ( $lAuthorDir eq 'Authentic' );
        next if ( $lAuthorDir eq 'PLEASE_READ' );

        &fetchAuthorsTextFiles (
            author      => $lAuthorDir,                    # Defines name of author file
            base_url    => $AUTHORS_BASE_URL . $lAuthorDir,
            force_get   => 0                               # Controls skipping already selected authors
        );
    }


}   # getAuthors




1;

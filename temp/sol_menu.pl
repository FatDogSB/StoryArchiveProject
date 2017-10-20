
#!/home/aruba/bin/gnu/isqlperl
# use Test::Harness;
# use DB_File;
# use strict 'untie';
# Initial revision
#
#

use solUtil;
use LWP::UserAgent;
use WWW::Mechanize;
use File::Basename;
use asstr;

my $gBASE_DIR='d:\\temp\\1\\';
my $gBuffer = "";

my %gLE_URLS = ();

# This started at update.php?id=60

my $gBLBaseURL = 'http://www.bdsmlibrary.com/stories';
$gBLBaseURL    = 'http://www.bdsmlibrary.com/stories/author.php?authorid=867';
my $gBLIndexFile                                        = 'bl_index09.txt';
my $gBLOutputFile                                       = 'bd09.txt';


&main ();
exit (0);


#-------------------------------------------------------------------------
# Routine:		S_ScanDirs
#-------------------------------------------------------------------------
sub findFiles {
	my (%args) = @_;
	my ($lBaseDir);
	my ($lDirName, $lFile, $lFullPath, $lCmd, $lNewName);
	
	$lBaseDir = $args{dir};
	chdir ($lBaseDir) or die ("Error: Could not chdir to : $lBaseDir : $!\n");
	
	# Now we should see a bunch of sub-dirs like 
	# 2009-10-17 Lodge Fun
	print "Looking in $lBaseDir\n";
	foreach $lDirName ( sort glob "*" ) {
		next unless ( -d $lDirName );
		print "\t\t$lDirName\n";
		next unless ( $lDirName =~ m/\d\d\d\d\-\d\d\-\d\d/ );
		
		# Use this dir name as the file name
		$lNewName = "EliteSpanking-" . $lDirName . ".mp4";
		print "New name: $lDirName\n";
		
		chdir ($lDirName);
		$lFullPath = $lBaseDir . '\\' . $lDirName;
		
		foreach $lFile ( glob ("*.mp4") ) {
			$lCmd = "copy \"$lFullPath\\$lFile\"                  \"$gBASE_DIR${lNewName}\"";
			$gBuffer .= $lCmd . "\n";
		
		}
		
		chdir ("..");
	}
	
}	# findFiles

#-------------------------------------------------------------------------
# Routine:		S_ScanDirs
#-------------------------------------------------------------------------
sub S_ScanDirs {
	my (@lDirList, $lDir);
	
	print "BaseDir: $gBASE_DIR\n";
	chdir ($gBASE_DIR) or die ("Error: Could not chdir to base dir: $gBASE_DIR : $!\n");
	foreach $lDir ( sort glob "*CD*") {
		print "Found dir: $lDir\n";
		push (@lDirList, $lDir);
		
		&findFiles( dir => $gBASE_DIR . $lDir );
	}
	
	# Create output batch file
	my $lBatchFileName = $gBASE_DIR . "ep_copy.bat";
	open (BATCH_FILE, ">$lBatchFileName");
	print BATCH_FILE $gBuffer . "\n";
	close (BATCH_FILE);
	
	print "Batch file created: $lBatchFileName\n";
	
}	# S_ScanDirs

#-------------------------------------------------------------------------
#-------------------------------------------------------------------------
sub S_ScanLE {

}	# S_ScanLE

#-------------------------------------------------------------------------
#-------------------------------------------------------------------------
sub S_ScanSOL {
	my ($lUA, $lURL, @lURLArray, $lResponse);
	
	push (@lURLArray, 'http://storiesonline.net/s/56730:77452');
	push (@lURLArray, 'http://storiesonline.net/s/56730:77452;1');
	push (@lURLArray, 'http://storiesonline.net/s/56730:77452;2');
	push (@lURLArray, 'http://storiesonline.net/s/56730:77472');		# Chapter 2

	$lURL = "http://storiesonline.net/s/56730:77452";
	
	my $lMech = WWW::Mechanize->new(
		agent 		=> 'Mozilla/5.0',
		cookie_jar 	=> {}
	);
	$lMech->agent_alias( 'Windows IE 6' );
	
	my $lURLLogin = 'http://storiesonline.net/login.php?';
	$lMech->get ($lURLLogin);
	$lMech->submit_form (
		form_number => 1,
		fields		=> {
			theusername	=> 'FatDog69',
			thepassword => 'bm1492!',
		},
		button		=> 'Login',
		
	);
	
	return;
	
	$lUA = LWP::UserAgent->new;
	$lUA->timeout(10);
	$lUA->env_proxy();
	$lUA->agent('Mozilla/5.0');
	
	$lResponse = $lUA->get($lURL);
	
	if ( $lResponse->is_success ) {
		print "Got url: $lURL\n";
		my $lTemp = $lResponse->decoded_content();
		print "$lTemp\n";
	} else {
		die $lResponse->status_line;
	}
}	# S_ScanSOL

#-------------------------------------------------------------------------
# Routine:		S_GenerateIndexFile
# Description:		This routine will create a instance, then try to read the 
#				index page and write the results (status, Title, URL) to
#				a data file.
#-------------------------------------------------------------------------
sub S_GenerateIndexFile {
	my (%args) = @_;
	my ($lUtilObj);
	my ($lURL);
	
	$lURL = 'http://www.bdsmlibrary.com/stories/update.php?id=60';
	$lURL = 'http://www.bdsmlibrary.com/stories/update.php?id=50';

	$lURL = 'http://www.bdsmlibrary.com/stories/author.php?authorid=867';
	$lURL = 'http://www.bdsmlibrary.com/stories';
	
	$gBLIndexFile = $args{index_file};
	
	# See if index file exists. We want to keep the old one for deduping
	if ( -e $gBLIndexFile ) {
		print "Error: Index file already exists: $gBLIndexFile\n";
		return;
	}
	
	$lUtilObj = solUtil->new(base_url => $lURL, index_file => $gBLIndexFile);
	$lUtilObj->genIndexFile(base_url => $lURL);
	
}	# S_GenerateIndexFile

#-------------------------------------------------------------------------
# Routine:		S_ImportLibrary
# Description:	This routine will read the index file, then start scanning
#				the URL's that have not been processed. The text will be
#				written to the objects "storyFile".
#
# Inputs:		index_file - name of file with unique URLS
#-------------------------------------------------------------------------
sub S_ImportLibrary {
	my (%args) = @_;
	my ($lUtilObj);
	
	my $lURL = 'http://www.bdsmlibrary.com/stories/update.php?id=60';
	$lURL = 'http://www.bdsmlibrary.com/stories/update.php?id=51';
		$lURL = 'http://www.bdsmlibrary.com/stories';
	$gBLIndexFile = $args{index_file};
	$lUtilObj = solUtil->new(base_url => $gBLBaseURL, index_file => $gBLIndexFile);
	$lUtilObj->readIndexFile();
	$lUtilObj->scanStories(output_file => $gBLOutputFile);
	
}	# S_ImportLibrary

#-------------------------------------------------------------------------
# Routine:		S_BDSMLDedup
# Description:	This routine will take a new_file index file and a prev_file index file
#				and scan new_file and remove all duplicates we may have already collected
#
# Inputs:		new_file - recent index file like bdsml_20150814
# 				prev_file - a previous file 
#-------------------------------------------------------------------------
sub S_BDSMLDedup {
	my (%args) = @_;
	my (%lHash, $lTempFile, $lRow);
	my ($lURL, $lStatus, $lText);
	my ($lNewCount, $lUniqueCount) = (0,0);
	
	# Error check the arguments
	if ( ! -e $args{new_file} ) {
		die ("Error: new_file does not exist: $args{new_file}\n");
	}
	
	if ( ! -e $args{prev_file} ) {
		die ("Error: prev_file does not exist: $args{prev_file}\n");
	}
	
	print "Reading previous index file for URL's : $args{prev_file}\n";
	# First read in the links in the previous file
	open (IN_FILE, $args{prev_file}) or die ("Error: Cannot open file for input: $args{prev_file} : $!\n");
	while ( $lRow = <IN_FILE> ) {
		chomp ($lRow);
		($lURL, $lStatus, $lText) = split ("\t", $lRow);
	 	$lHash{$lURL} = 1;
	}

	$lTempFile = $args{new_file};
	$lTempFile =~ s/\./_dedup\./;
	
	open (OUT_FILE, ">$lTempFile") or die ("Error: Could not open temp file for output: $lTempFile : $!\n");
	
	open (IN_FILE, $args{new_file}) or die ("Error: Could not open file for input: $args{new_file} : $!");
	while ( $lRow = <IN_FILE> ) {
		chomp ($lRow);
		$lNewCount++;
		($lURL, $lStatus, $lText) = split ("\t", $lRow);
		
		next if ( exists $lHash{$lURL} );
		
		print OUT_FILE "$lRow\n";
		$lUniqueCount++;
	}
	
	close (IN_FILE);
	close (OUT_FILE) or die ("Error: Could not close temp file for output: $lTempFile : $!\n");
	
	print "Total URL's in new file:   $lNewCount\n";
	print "Unique URL's in new file:  $lUniqueCount\n";
	
	print "Output file with unique URLs created: $lTempFile\n";
	
}	# S_BDSMLDedup

#-------------------------------------------------------------------------
# Routine:		
# Description:
#
# Inputs:		input_file - name of source file to open
#				file_prefix - prefix for output file 1,2,3...
#				size - what size to cut off for each output file
#-------------------------------------------------------------------------
sub S_BreakBigFile {
	my (%args) = @_;
	my ($i, $lRow, $lOutputFile, $lSize);
	my ($lBuffer);
	
	$i = 0;
	$lSize = 0;
	
	if ( ! -e $args{input_file} ) {
		print "Error: Input file not found: $args{input_file}\n";
		return;
	}
	
	$i = 1;
	open (IN_FILE, $args{input_file} ) or die ("Error: Could not open file for input: $args{input_file} : $!\n");
	while ( $lRow = <IN_FILE> ) {
		if ( index ( $lRow, '-----------------' ) == 0 ) {
			$lRow = '{' . $lRow;
			
			# See if our buffer size is big enought to write out
			
			if ( $lSize > 1024 * 1024 * $args{size} ) {
				# Calc new output file name
				$lOutputFile = sprintf ("%s%03d.txt", $args{file_prefix}, $i);
				print "Output File: $lOutputFile size = $lSize\n";
				
			
				# Write buffer to file
				
				open (OUT_FILE, ">$lOutputFile") or die ("Error: Could not open file for output: $lOutputFile : $!\n");
				print OUT_FILE $lBuffer;
				close (OUT_FILE);
				
				$i++;
				$lBuffer = "";
				$lSize = 0;
			}
			
		}
		
		if (index ($lRow, '&nbsp;') > -1 ) {
			$lRow =~ s/\&nbsp;/ /g;
		}
		
		# Remove some common crap
		$lRow =~ s/\<p class=rvps\d+\>/\<p\>/g if ( index ($lRow, '<p class') == 0 );
		
		$lRow =~ s/\<span class=rvts\d+\>//g if ( index ($lRow, '</span>') > -1 );
		$lRow =~ s/\<\/span\>//g if ( index ($lRow, '</span>') > -1 );

		#$lRow =~ s/\&#8211;/\-/g if ( index ($lRow, '&#8211') > -1 );		
		#$lRow =~ s/\&#8212;/\-/g if ( index ($lRow, '&#8212') > -1 );		
		
		$lRow =~ s/\&#8216;/'/g if ( index ($lRow, '&#8216') > -1 );		
		$lRow =~ s/\&#8217;/'/g if ( index ($lRow, '&#8217') > -1 );
		
		$lRow =~ s/\&#8220;/"/g if ( index ($lRow, '&#8220') > -1 );
		$lRow =~ s/\&#8221;/"/g if ( index ($lRow, '&#8221') > -1 );
		
		$lRow =~ s/\>\s+/\>/g if ( index ($lRow, '> ') > -1 );
		
		$lBuffer .= $lRow;
		$lSize += length ($lRow);
	}
	close (IN_FILE);
	
}	# S_BreakBigFile

#-------------------------------------------------------------------------
#-------------------------------------------------------------------------
sub fetchHREF {
	my ($aStr) = @_;
	my ($lPos1, $lPos2, $lURL, $lTemp);
	
	$lPos1 = rindex ( $aStr, "href=");
	$lTemp = substr ($aStr, $lPos1, 99);
	$lPos1 = index ( $lTemp , '"http') + 1;
	$lPos2 = index ( $lTemp, '"', $lPos1 + 1);
	$lURL = substr ($lTemp, $lPos1, $lPos2 - $lPos1 );
	
	$lURL = "" if ( index ($lURL, 'shop.liter') > -1);
	$lURL = "" if ( index ($lURL, 'vipcams.liter') > -1);
	$lURL = "" if ( index ($lURL, 'memberpage.php') > -1);
	$lURL = "" if ( index ($lURL, 'literoticavod') > -1);
	$lURL = "" if ( index ($lURL, 'support') > -1);
	$lURL = "" if ( index ($lURL, 'href=') > -1);
	
	#print "URL = $lURL\n";
	
	return ($lURL);
}	# fetchHREF

#-------------------------------------------------------------------------
# Routine:		S_FetchLENextLink
# Description:	Will scan a row from the bottom of a Literotica story page for a link
#				that comes just before ">Next". Returns the URL or just ""
#-------------------------------------------------------------------------
sub S_FetchLENextLink {
	my ($aRow) = @_;
	my ($lPos2, $lPos1, $lNextURL);
	my ($lRow);

	$lNextURL = "";	
	# aRow looks like: ...  Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">Next
	$lPos2 = index ($aRow, '">Next');
	if (  $lPos2 > -1 ) {
		my $lTemp = substr ($aRow, 0, $lPos2);		# Trim stuff off the right
		$lPos1 = rindex ($lTemp, 'href="');
		if ($lPos1 > -1) {
			$lNextURL = substr($lTemp, $lPos1 + 6, $lPos2);
			print "FLENL: $lNextURL \n";
		}
	}

	return ($lNextURL);
}	# S_FetchLENextLink

my $gTitle = "";
#-------------------------------------------------------------------------
#-------------------------------------------------------------------------
sub S_FetchLEStory {
	my ($aURL) = @_;
	my ($lUA, $lResponse, $lContent, $lRow, $lPos, $lBuffer, $lSecondPageURL, $lTitle, $lAttempt);
	my %lURLHash = ();
	
	# Some of the stories contain forward and backward links so check this URL
	# to make sure we have NOT already scanned it
	
	return ("") if ( exists $gLE_URLS{$aURL} );
	$lBuffer = "\n";
	
	$lUA = LWP::UserAgent->new;
	$lUA->timeout(10);
	$lUA->env_proxy();
	$lUA->agent('Mozilla/5.0');

	$gTitle = "";
	
	# Sometimes we get "Sorry, can't assemble the page" messages
	$lAttempt = 0;
	while ($lAttempt < 8) {
	
		$lResponse = $lUA->get($aURL);
		$lAttempt++;
		if ( $lResponse->is_success ) {
			$lContent = $lResponse->decoded_content();
			if ( index ($lContent, "Sorry, can't assemble the page") > -1 ) {
				print "Attempt $lAttempt error:    $aURL\n";
				sleep (6);
			} else {
				# Good response
				if ( $lAttempt > 1 ) {
					print "Attempt $lAttempt success: $aURL\n";
				}
				$lAttempt = 99;
			}
		}
	}
	
	if ( $lResponse->is_success ) {
	
		$gLE_URLS{$aURL} = 1;
		
		# Have to remove the "?page=n" if it exists in the url: href="http://www.literotica.com/s/it-started-with-a-slip-of-the-hand?page=3">
		$aURL =~ s/\?page=\d+//;
		$lContent = $lResponse->decoded_content();
		foreach $lRow ( split ("\n", $lContent) ) {
			chomp($lRow);
			
			# See if we can find a title: <title>Absence of Thought - First Time - Literotica.com</title>
			if ( index ($lRow, '<title>') > -1) {
				$lRow =~ m/\<title\>([^<]*)/;
				$lTitle = $1;
				$lTitle =~ s/ \- Literotica\.com$//;
				$gTitle = $lTitle if ( length ($lTitle) > 5);
			}
			
			# Text rows always end with "<br  />"
			next if ( index ($lRow, '/sc/js/page-submission') > -1 );
			next if ( index ($lRow, 'onmouseover') > -1 );
			
			# Text lines end with either "<br  />" or at the very end with </p>
			$lPos = index ($lRow, '<br  />');
			$lPos = index ($lRow, '</p') if ($lPos == -1 and index ($lRow, 'report-problem-story') > -1);
			if ($lPos > 2) {
				$lRow = substr ($lRow, 0, $lPos);
				$lRow =~ s/ +$//;						# Trim spaces from the end
				$lRow =~ s/^[- ]$/\* \* \*/;			# Replace "---" and "- - - " with "* * *"
				$lBuffer .= "<p>$lRow</p>\n";
				#print substr ($lRow, 0, 65) . "\n";
			}
			
			# Sometimes the pages goes onto a page=2 or page=3.... so look for this
			# href="http://www.literotica.com/s/it-started-with-a-slip-of-the-hand?page=3">Next
			# We have to be careful about links to the Previous chapter or we will ping-pong
			
			$lSecondPageURL = index ($lRow, $aURL . '?page=');
			if ( $lSecondPageURL > -1 and index ($lRow, '>Next') > -1) {
				$lSecondPageURL = &S_FetchLENextLink( $lRow );
				if ( $lSecondPageURL ne "" ) {
					print "Second Page URL: $lSecondPageURL\n";
					$lBuffer .= &S_FetchLEStory($lSecondPageURL);
					# I think we can stop scanning the parent page now
					last;
				}
			}
		}
	}
	
	print "Buffer Title: $lTitle\n";
	return ($lBuffer);
	
}	# S_FetchLEStory

#-------------------------------------------------------------------------
# Routine:		S_ExtractLEHref
# Description:	This routine will take the entire contents of a web page and extract all
#				the href= links. Then it will make sure the link contains "...come/s/"
#				to indicate a story, and add the URL to a return array.
#
# Inputs:		Decoded contents of a LE Authors submission web page
# Returns:		Array of URL's that point to the various stories
# perl -n -e 'chomp;s/.*?(?:(?i)href)="([^"]+)".*?(?:$|(?=(?i)href))/$1\n/xg 
#-------------------------------------------------------------------------
sub S_ExtractLEHref {
	my ($aContent) = @_;
	my ($lRow, $lCount, $lPos);
	my (@lResults);

	$lCount = 0;
	foreach $lRow ( split ("\n", $aContent) ) {
		$lRow =~ s/.*?(?:(?i)href)="([^"]+)".*?(?:$|(?=(?i)href))/$1\n/xg;
		foreach my $lURL ( split ("\n", $lRow)) {
			# The Stories are all under the ..com/s/ directory
			# http://www.literotica.com/s/the-darkest-knight
			$lPos = index ($lURL, 'literotica.com/s/'); 
			if ( $lPos > -1  and $lPos < 16 ) {
				push (@lResults, $lURL);
				$lCount++;
			}
		}
	}
	
	
	return (@lResults);
	
}	# S_ExtractHLEHref
#-------------------------------------------------------------------------
# Routine:		S_FetchLEAuthor
# Descripiton:	Will take a file name and a author URL for Literotica and it
#				will attempt to scrape the authors pages for stories
#-------------------------------------------------------------------------
sub S_FetchLEAuthor {
	my (%args) = @_;
	my ($lUA, $lResponse, $lContent, $lRow, $lURL, $lPos, $lPos2, $lCount);
	my %lURLHash = ();
	my @lURLArray = ();
	
	# Make sure we do not already have this output file
	if ( -e $args{file} ) {
		print "Warning: Output file already exists: $args{file}\n";
		return;
	}

	$lUA = LWP::UserAgent->new;
	$lUA->timeout(10);
	$lUA->env_proxy();
	$lUA->agent('Mozilla/5.0');
	
	$lResponse = $lUA->get($args{author_url});
	if ( $lResponse->is_success ) {
		print "Got Authors page...\n";
		$lContent = $lResponse->decoded_content();
		
		# Loop through all the rows and extract the URL's that point to the stories
		# or sub-chapters.
		
		@lURLArray = &S_ExtractLEHref( $lContent );
	}

	if ( 0 ) {
		foreach $lURL ( @lURLArray ) {
			print "\t$lURL\n";
		}
		return;
	}
	
	$lCount = 0;
	open (OUT_FILE, ">>$args{file}") or die ("Error: Could not open file for output: $args{file} : $!\n");
	foreach $lURL ( @lURLArray ) {
		my $lText = &S_FetchLEStory ( $lURL );
		print OUT_FILE "{------------------------------------------------------------\n\n";
		print OUT_FILE 'Subject: "' . $gTitle . '" [1/1] {' . $args{author_name} . '} ()' . "\n\n";
		print OUT_FILE "URL: $lURL\n\n";
		print "\t$lURL\n";
		print OUT_FILE "$lText\n\n";
		
		last if ($lCount > 1000);
	}
	
	print OUT_FILE "\n\n{------------------------------------------------------------\n\n";
	
	close (OUT_FILE) or die ("Error: Could not close output file: $args{file} : $!\n");
	
	print "Output file created: $args{file}\n";
	
}	# S_FetchLEAuthor

#-------------------------------------------------------------------------
#-------------------------------------------------------------------------
sub S_LinkExperiment {
	my ($lPos2, $lPos1, $lNextURL);
	my ($lRow);
	print "Link Experiment starting\n";

	$lRow = 'href="http://www.literotica.com/stories/memberpage.php?uid=923141&amp;page=submissions">alwayswantedto</a></span><span class="b-story-copy">©</span>  <span class="b-story-stats">72 comments<span class="sep">/</span>  234608 views<span class="sep">/</span>  60 favorites</span></div><div class="b-sidebar"><div class="b-box"><div class="b-box-header"><h3>Share the love</h3></div><div class="b-box-body"><div class="b-s-share-love"><script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script><div id="gplus"><div class="g-plusone" data-size="medium"></div></div><div id="tw-share"><a href="http://twitter.com/share" class="twitter-share-button" data-count="none" data-text="Crosswords Ch. 01" data-url="http://www.literotica.com/s/crosswords-ch-01">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script></div><div class="secline"><div id="add-this"><a href="http://www.addthis.com/bookmark.php?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/share.gif" width="16" height="16" alt="Share"  /></a></div><div id="add-email"><a href="http://api.addthis.com/oexchange/0.8/forward/email/offer?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/email.gif" width="56" height="18" alt="Email"  /></a></div></div></div></div></div><div class="b-box"><div class="b-box-header"><h3>Report a Bug</h3></div><div class="b-box-body"><a href="/stories/quest/bugs.php?id=3&amp;url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01"><strong>Submit bug report</strong></a></div></div></div><div id="sbar-l-wrp"><div class="b-pager"><a class="b-pager-prev" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/stories/memberpage.php?uid=923141&amp;page=submissions">alwayswantedto</a></span><span class="b-story-copy">©</span>  <span class="b-story-stats">72 comments<span class="sep">/</span>  234608 views<span class="sep">/</span>  60 favorites</span></div><div class="b-sidebar"><div class="b-box"><div class="b-box-header"><h3>Share the love</h3></div><div class="b-box-body"><div class="b-s-share-love"><script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script><div id="gplus"><div class="g-plusone" data-size="medium"></div></div><div id="tw-share"><a href="http://twitter.com/share" class="twitter-share-button" data-count="none" data-text="Crosswords Ch. 01" data-url="http://www.literotica.com/s/crosswords-ch-01">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script></div><div class="secline"><div id="add-this"><a href="http://www.addthis.com/bookmark.php?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/share.gif" width="16" height="16" alt="Share"  /></a></div><div id="add-email"><a href="http://api.addthis.com/oexchange/0.8/forward/email/offer?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/email.gif" width="56" height="18" alt="Email"  /></a></div></div></div></div></div><div class="b-box"><div class="b-box-header"><h3>Report a Bug</h3></div><div class="b-box-body"><a href="/stories/quest/bugs.php?id=3&amp;url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01"><strong>Submit bug report</strong></a></div></div></div><div id="sbar-l-wrp"><div class="b-pager"><a class="b-pager-prev" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">Previous</a><a class="b-pager-next" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">Next</a><div class="b-pager-pages"><span class="b-pager-caption-t r-d45"><!-- x -->7 Pages:</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01">1</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">2</a><span class="b-pager-active">3</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">4</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=5">5</a><form action="http://www.literotica.com/s/crosswords-ch-01" method="get"><select name="page"><option value="1">1</option><option value="2">2</option><option value="3" class="current" selected="selected">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option></select><button type="submit" class="i-button i-button-mini" title="Go">Go</button></form></div></div><div class="big_link" id="b-bottom"><div class="block_id-c3RvcnlwYWdlOS1ib3R0b218MTI1fGJvdHRvbQ=="><!-- It\'s a Daddy Thing 4 -->href="http://www.literotica.com/stories/memberpage.php?uid=923141&amp;page=submissions">alwayswantedto</a></span><span class="b-story-copy">©</span>  <span class="b-story-stats">72 comments<span class="sep">/</span>  234608 views<span class="sep">/</span>  60 favorites</span></div><div class="b-sidebar"><div class="b-box"><div class="b-box-header"><h3>Share the love</h3></div><div class="b-box-body"><div class="b-s-share-love"><script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script><div id="gplus"><div class="g-plusone" data-size="medium"></div></div><div id="tw-share"><a href="http://twitter.com/share" class="twitter-share-button" data-count="none" data-text="Crosswords Ch. 01" data-url="http://www.literotica.com/s/crosswords-ch-01">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script></div><div class="secline"><div id="add-this"><a href="http://www.addthis.com/bookmark.php?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/share.gif" width="16" height="16" alt="Share"  /></a></div><div id="add-email"><a href="http://api.addthis.com/oexchange/0.8/forward/email/offer?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/email.gif" width="56" height="18" alt="Email"  /></a></div></div></div></div></div><div class="b-box"><div class="b-box-header"><h3>Report a Bug</h3></div><div class="b-box-body"><a href="/stories/quest/bugs.php?id=3&amp;url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01"><strong>Submit bug report</strong></a></div></div></div><div id="sbar-l-wrp"><div class="b-pager"><a class="b-pager-prev" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">Previous</a><a class="b-pager-next" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">Next</a><div class="b-pager-pages"><span class="b-pager-caption-t r-d45"><!-- x -->7 Pages:</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01">1</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">2</a><span class="b-pager-active">3</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">4</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=5">5</a><form action="http://www.literotica.com/s/crosswords-ch-01" method="get"><select name="page"><option value="1">1</option><option value="2">2</option><option value="3" class="current" selected="selected">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option></select><button type="submit" class="i-button i-button-mini" title="Go">Go</button></form></div></div><div class="big_link" id="b-bottom"><div class="block_id-c3RvcnlwYWdlOS1ib3R0b218MTI1fGJvdHRvbQ=="><!-- It\'s a Daddy Thing 4 -->href="http://www.literotica.com/stories/memberpage.php?uid=923141&amp;page=submissions">alwayswantedto</a></span><span class="b-story-copy">©</span>  <span class="b-story-stats">72 comments<span class="sep">/</span>  234608 views<span class="sep">/</span>  60 favorites</span></div><div class="b-sidebar"><div class="b-box"><div class="b-box-header"><h3>Share the love</h3></div><div class="b-box-body"><div class="b-s-share-love"><script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script><div id="gplus"><div class="g-plusone" data-size="medium"></div></div><div id="tw-share"><a href="http://twitter.com/share" class="twitter-share-button" data-count="none" data-text="Crosswords Ch. 01" data-url="http://www.literotica.com/s/crosswords-ch-01">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script></div><div class="secline"><div id="add-this"><a href="http://www.addthis.com/bookmark.php?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/share.gif" width="16" height="16" alt="Share"  /></a></div><div id="add-email"><a href="http://api.addthis.com/oexchange/0.8/forward/email/offer?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/email.gif" width="56" height="18" alt="Email"  /></a></div></div></div></div></div><div class="b-box"><div class="b-box-header"><h3>Report a Bug</h3></div><div class="b-box-body"><a href="/stories/quest/bugs.php?id=3&amp;url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01"><strong>Submit bug report</strong></a></div></div></div><div id="sbar-l-wrp"><div class="b-pager"><a class="b-pager-prev" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">Previous</a><a class="b-pager-next" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">Next</a><div class="b-pager-pages"><span class="b-pager-caption-t r-d45"><!-- x -->7 Pages:</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01">1</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">2</a><span class="b-pager-active">3</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">4</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=5">5</a><form action="http://www.literotica.com/s/crosswords-ch-01" method="get"><select name="page"><option value="1">1</option><option value="2">2</option><option value="3" class="current" selected="selected">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option></select><button type="submit" class="i-button i-button-mini" title="Go">Go</button></form></div></div><div class="big_link" id="b-bottom"><div class="block_id-c3RvcnlwYWdlOS1ib3R0b218MTI1fGJvdHRvbQ=="><!-- It\'s a Daddy Thing 4 -->href="http://www.literotica.com/stories/memberpage.php?uid=923141&amp;page=submissions">alwayswantedto</a></span><span class="b-story-copy">©</span>  <span class="b-story-stats">72 comments<span class="sep">/</span>  234608 views<span class="sep">/</span>  60 favorites</span></div><div class="b-sidebar"><div class="b-box"><div class="b-box-header"><h3>Share the love</h3></div><div class="b-box-body"><div class="b-s-share-love"><script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script><div id="gplus"><div class="g-plusone" data-size="medium"></div></div><div id="tw-share"><a href="http://twitter.com/share" class="twitter-share-button" data-count="none" data-text="Crosswords Ch. 01" data-url="http://www.literotica.com/s/crosswords-ch-01">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script></div><div class="secline"><div id="add-this"><a href="http://www.addthis.com/bookmark.php?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/share.gif" width="16" height="16" alt="Share"  /></a></div><div id="add-email"><a href="http://api.addthis.com/oexchange/0.8/forward/email/offer?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/email.gif" width="56" height="18" alt="Email"  /></a></div></div></div></div></div><div class="b-box"><div class="b-box-header"><h3>Report a Bug</h3></div><div class="b-box-body"><a href="/stories/quest/bugs.php?id=3&amp;url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01"><strong>Submit bug report</strong></a></div></div></div><div id="sbar-l-wrp"><div class="b-pager"><a class="b-pager-prev" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">Previous</a><a class="b-pager-next" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">Next</a><div class="b-pager-pages"><span class="b-pager-caption-t r-d45"><!-- x -->7 Pages:</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01">1</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">2</a><span class="b-pager-active">3</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">4</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=5">5</a><form action="http://www.literotica.com/s/crosswords-ch-01" method="get"><select name="page"><option value="1">1</option><option value="2">2</option><option value="3" class="current" selected="selected">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option></select><button type="submit" class="i-button i-button-mini" title="Go">Go</button></form></div></div><div class="big_link" id="b-bottom"><div class="block_id-c3RvcnlwYWdlOS1ib3R0b218MTI1fGJvdHRvbQ=="><!-- It\'s a Daddy Thing 4 -->href="http://www.literotica.com/stories/memberpage.php?uid=923141&amp;page=submissions">alwayswantedto</a></span><span class="b-story-copy">©</span>  <span class="b-story-stats">72 comments<span class="sep">/</span>  234608 views<span class="sep">/</span>  60 favorites</span></div><div class="b-sidebar"><div class="b-box"><div class="b-box-header"><h3>Share the love</h3></div><div class="b-box-body"><div class="b-s-share-love"><script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script><div id="gplus"><div class="g-plusone" data-size="medium"></div></div><div id="tw-share"><a href="http://twitter.com/share" class="twitter-share-button" data-count="none" data-text="Crosswords Ch. 01" data-url="http://www.literotica.com/s/crosswords-ch-01">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script></div><div class="secline"><div id="add-this"><a href="http://www.addthis.com/bookmark.php?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/share.gif" width="16" height="16" alt="Share"  /></a></div><div id="add-email"><a href="http://api.addthis.com/oexchange/0.8/forward/email/offer?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/email.gif" width="56" height="18" alt="Email"  /></a></div></div></div></div></div><div class="b-box"><div class="b-box-header"><h3>Report a Bug</h3></div><div class="b-box-body"><a href="/stories/quest/bugs.php?id=3&amp;url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01"><strong>Submit bug report</strong></a></div></div></div><div id="sbar-l-wrp"><div class="b-pager"><a class="b-pager-prev" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">Previous</a><a class="b-pager-next" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">Next</a><div class="b-pager-pages"><span class="b-pager-caption-t r-d45"><!-- x -->7 Pages:</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01">1</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">2</a><span class="b-pager-active">3</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">4</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=5">5</a><form action="http://www.literotica.com/s/crosswords-ch-01" method="get"><select name="page"><option value="1">1</option><option value="2">2</option><option value="3" class="current" selected="selected">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option></select><button type="submit" class="i-button i-button-mini" title="Go">Go</button></form></div></div><div class="big_link" id="b-bottom"><div class="block_id-c3RvcnlwYWdlOS1ib3R0b218MTI1fGJvdHRvbQ=="><!-- It\'s a Daddy Thing 4 -->href="http://www.literotica.com/stories/memberpage.php?uid=923141&amp;page=submissions">alwayswantedto</a></span><span class="b-story-copy">©</span>  <span class="b-story-stats">72 comments<span class="sep">/</span>  234608 views<span class="sep">/</span>  60 favorites</span></div><div class="b-sidebar"><div class="b-box"><div class="b-box-header"><h3>Share the love</h3></div><div class="b-box-body"><div class="b-s-share-love"><script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script><div id="gplus"><div class="g-plusone" data-size="medium"></div></div><div id="tw-share"><a href="http://twitter.com/share" class="twitter-share-button" data-count="none" data-text="Crosswords Ch. 01" data-url="http://www.literotica.com/s/crosswords-ch-01">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script></div><div class="secline"><div id="add-this"><a href="http://www.addthis.com/bookmark.php?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/share.gif" width="16" height="16" alt="Share"  /></a></div><div id="add-email"><a href="http://api.addthis.com/oexchange/0.8/forward/email/offer?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/email.gif" width="56" height="18" alt="Email"  /></a></div></div></div></div></div><div class="b-box"><div class="b-box-header"><h3>Report a Bug</h3></div><div class="b-box-body"><a href="/stories/quest/bugs.php?id=3&amp;url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01"><strong>Submit bug report</strong></a></div></div></div><div id="sbar-l-wrp"><div class="b-pager"><a class="b-pager-prev" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">Previous</a><a class="b-pager-next" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">Next</a><div class="b-pager-pages"><span class="b-pager-caption-t r-d45"><!-- x -->7 Pages:</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01">1</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">2</a><span class="b-pager-active">3</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">4</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=5">5</a><form action="http://www.literotica.com/s/crosswords-ch-01" method="get"><select name="page"><option value="1">1</option><option value="2">2</option><option value="3" class="current" selected="selected">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option></select><button type="submit" class="i-button i-button-mini" title="Go">Go</button></form></div></div><div class="big_link" id="b-bottom"><div class="block_id-c3RvcnlwYWdlOS1ib3R0b218MTI1fGJvdHRvbQ=="><!-- It\'s a Daddy Thing 4 -->href="http://www.literotica.com/stories/memberpage.php?uid=923141&amp;page=submissions">alwayswantedto</a></span><span class="b-story-copy">©</span>  <span class="b-story-stats">72 comments<span class="sep">/</span>  234608 views<span class="sep">/</span>  60 favorites</span></div><div class="b-sidebar"><div class="b-box"><div class="b-box-header"><h3>Share the love</h3></div><div class="b-box-body"><div class="b-s-share-love"><script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script><div id="gplus"><div class="g-plusone" data-size="medium"></div></div><div id="tw-share"><a href="http://twitter.com/share" class="twitter-share-button" data-count="none" data-text="Crosswords Ch. 01" data-url="http://www.literotica.com/s/crosswords-ch-01">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script></div><div class="secline"><div id="add-this"><a href="http://www.addthis.com/bookmark.php?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/share.gif" width="16" height="16" alt="Share"  /></a></div><div id="add-email"><a href="http://api.addthis.com/oexchange/0.8/forward/email/offer?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/email.gif" width="56" height="18" alt="Email"  /></a></div></div></div></div></div><div class="b-box"><div class="b-box-header"><h3>Report a Bug</h3></div><div class="b-box-body"><a href="/stories/quest/bugs.php?id=3&amp;url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01"><strong>Submit bug report</strong></a></div></div></div><div id="sbar-l-wrp"><div class="b-pager"><a class="b-pager-prev" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">Previous</a><a class="b-pager-next" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">Next</a><div class="b-pager-pages"><span class="b-pager-caption-t r-d45"><!-- x -->7 Pages:</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01">1</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">2</a><span class="b-pager-active">3</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">4</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=5">5</a><form action="http://www.literotica.com/s/crosswords-ch-01" method="get"><select name="page"><option value="1">1</option><option value="2">2</option><option value="3" class="current" selected="selected">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option></select><button type="submit" class="i-button i-button-mini" title="Go">Go</button></form></div></div><div class="big_link" id="b-bottom"><div class="block_id-c3RvcnlwYWdlOS1ib3R0b218MTI1fGJvdHRvbQ=="><!-- It\'s a Daddy Thing 4 -->href="http://www.literotica.com/stories/memberpage.php?uid=923141&amp;page=submissions">alwayswantedto</a></span><span class="b-story-copy">©</span>  <span class="b-story-stats">72 comments<span class="sep">/</span>  234608 views<span class="sep">/</span>  60 favorites</span></div><div class="b-sidebar"><div class="b-box"><div class="b-box-header"><h3>Share the love</h3></div><div class="b-box-body"><div class="b-s-share-love"><script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script><div id="gplus"><div class="g-plusone" data-size="medium"></div></div><div id="tw-share"><a href="http://twitter.com/share" class="twitter-share-button" data-count="none" data-text="Crosswords Ch. 01" data-url="http://www.literotica.com/s/crosswords-ch-01">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script></div><div class="secline"><div id="add-this"><a href="http://www.addthis.com/bookmark.php?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/share.gif" width="16" height="16" alt="Share"  /></a></div><div id="add-email"><a href="http://api.addthis.com/oexchange/0.8/forward/email/offer?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/email.gif" width="56" height="18" alt="Email"  /></a></div></div></div></div></div><div class="b-box"><div class="b-box-header"><h3>Report a Bug</h3></div><div class="b-box-body"><a href="/stories/quest/bugs.php?id=3&amp;url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01"><strong>Submit bug report</strong></a></div></div></div><div id="sbar-l-wrp"><div class="b-pager"><a class="b-pager-prev" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">Previous</a><a class="b-pager-next" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">Next</a><div class="b-pager-pages"><span class="b-pager-caption-t r-d45"><!-- x -->7 Pages:</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01">1</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">2</a><span class="b-pager-active">3</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">4</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=5">5</a><form action="http://www.literotica.com/s/crosswords-ch-01" method="get"><select name="page"><option value="1">1</option><option value="2">2</option><option value="3" class="current" selected="selected">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option></select><button type="submit" class="i-button i-button-mini" title="Go">Go</button></form></div></div><div class="big_link" id="b-bottom"><div class="block_id-c3RvcnlwYWdlOS1ib3R0b218MTI1fGJvdHRvbQ=="><!-- It\'s a Daddy Thing 4 -->href="http://www.literotica.com/stories/memberpage.php?uid=923141&amp;page=submissions">alwayswantedto</a></span><span class="b-story-copy">©</span>  <span class="b-story-stats">72 comments<span class="sep">/</span>  234608 views<span class="sep">/</span>  60 favorites</span></div><div class="b-sidebar"><div class="b-box"><div class="b-box-header"><h3>Share the love</h3></div><div class="b-box-body"><div class="b-s-share-love"><script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script><div id="gplus"><div class="g-plusone" data-size="medium"></div></div><div id="tw-share"><a href="http://twitter.com/share" class="twitter-share-button" data-count="none" data-text="Crosswords Ch. 01" data-url="http://www.literotica.com/s/crosswords-ch-01">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script></div><div class="secline"><div id="add-this"><a href="http://www.addthis.com/bookmark.php?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/share.gif" width="16" height="16" alt="Share"  /></a></div><div id="add-email"><a href="http://api.addthis.com/oexchange/0.8/forward/email/offer?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/email.gif" width="56" height="18" alt="Email"  /></a></div></div></div></div></div><div class="b-box"><div class="b-box-header"><h3>Report a Bug</h3></div><div class="b-box-body"><a href="/stories/quest/bugs.php?id=3&amp;url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01"><strong>Submit bug report</strong></a></div></div></div><div id="sbar-l-wrp"><div class="b-pager"><a class="b-pager-prev" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">Previous</a><a class="b-pager-next" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">Next</a><div class="b-pager-pages"><span class="b-pager-caption-t r-d45"><!-- x -->7 Pages:</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01">1</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">2</a><span class="b-pager-active">3</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">4</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=5">5</a><form action="http://www.literotica.com/s/crosswords-ch-01" method="get"><select name="page"><option value="1">1</option><option value="2">2</option><option value="3" class="current" selected="selected">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option></select><button type="submit" class="i-button i-button-mini" title="Go">Go</button></form></div></div><div class="big_link" id="b-bottom"><div class="block_id-c3RvcnlwYWdlOS1ib3R0b218MTI1fGJvdHRvbQ=="><!-- It\'s a Daddy Thing 4 -->href="http://www.literotica.com/stories/memberpage.php?uid=923141&amp;page=submissions">alwayswantedto</a></span><span class="b-story-copy">©</span>  <span class="b-story-stats">72 comments<span class="sep">/</span>  234608 views<span class="sep">/</span>  60 favorites</span></div><div class="b-sidebar"><div class="b-box"><div class="b-box-header"><h3>Share the love</h3></div><div class="b-box-body"><div class="b-s-share-love"><script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script><div id="gplus"><div class="g-plusone" data-size="medium"></div></div><div id="tw-share"><a href="http://twitter.com/share" class="twitter-share-button" data-count="none" data-text="Crosswords Ch. 01" data-url="http://www.literotica.com/s/crosswords-ch-01">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script></div><div class="secline"><div id="add-this"><a href="http://www.addthis.com/bookmark.php?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/share.gif" width="16" height="16" alt="Share"  /></a></div><div id="add-email"><a href="http://api.addthis.com/oexchange/0.8/forward/email/offer?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/email.gif" width="56" height="18" alt="Email"  /></a></div></div></div></div></div><div class="b-box"><div class="b-box-header"><h3>Report a Bug</h3></div><div class="b-box-body"><a href="/stories/quest/bugs.php?id=3&amp;url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01"><strong>Submit bug report</strong></a></div></div></div><div id="sbar-l-wrp"><div class="b-pager"><a class="b-pager-prev" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">Previous</a><a class="b-pager-next" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">Next</a><div class="b-pager-pages"><span class="b-pager-caption-t r-d45"><!-- x -->7 Pages:</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01">1</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">2</a><span class="b-pager-active">3</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">4</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=5">5</a><form action="http://www.literotica.com/s/crosswords-ch-01" method="get"><select name="page"><option value="1">1</option><option value="2">2</option><option value="3" class="current" selected="selected">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option></select><button type="submit" class="i-button i-button-mini" title="Go">Go</button></form></div></div><div class="big_link" id="b-bottom"><div class="block_id-c3RvcnlwYWdlOS1ib3R0b218MTI1fGJvdHRvbQ=="><!-- It\'s a Daddy Thing 4 -->href="http://www.literotica.com/stories/memberpage.php?uid=923141&amp;page=submissions">alwayswantedto</a></span><span class="b-story-copy">©</span>  <span class="b-story-stats">72 comments<span class="sep">/</span>  234608 views<span class="sep">/</span>  60 favorites</span></div><div class="b-sidebar"><div class="b-box"><div class="b-box-header"><h3>Share the love</h3></div><div class="b-box-body"><div class="b-s-share-love"><script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script><div id="gplus"><div class="g-plusone" data-size="medium"></div></div><div id="tw-share"><a href="http://twitter.com/share" class="twitter-share-button" data-count="none" data-text="Crosswords Ch. 01" data-url="http://www.literotica.com/s/crosswords-ch-01">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script></div><div class="secline"><div id="add-this"><a href="http://www.addthis.com/bookmark.php?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/share.gif" width="16" height="16" alt="Share"  /></a></div><div id="add-email"><a href="http://api.addthis.com/oexchange/0.8/forward/email/offer?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/email.gif" width="56" height="18" alt="Email"  /></a></div></div></div></div></div><div class="b-box"><div class="b-box-header"><h3>Report a Bug</h3></div><div class="b-box-body"><a href="/stories/quest/bugs.php?id=3&amp;url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01"><strong>Submit bug report</strong></a></div></div></div><div id="sbar-l-wrp"><div class="b-pager"><a class="b-pager-prev" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">Previous</a><a class="b-pager-next" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">Next</a><div class="b-pager-pages"><span class="b-pager-caption-t r-d45"><!-- x -->7 Pages:</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01">1</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">2</a><span class="b-pager-active">3</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">4</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=5">5</a><form action="http://www.literotica.com/s/crosswords-ch-01" method="get"><select name="page"><option value="1">1</option><option value="2">2</option><option value="3" class="current" selected="selected">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option></select><button type="submit" class="i-button i-button-mini" title="Go">Go</button></form></div></div><div class="big_link" id="b-bottom"><div class="block_id-c3RvcnlwYWdlOS1ib3R0b218MTI1fGJvdHRvbQ=="><!-- It\'s a Daddy Thing 4 -->href="http://www.literotica.com/stories/memberpage.php?uid=923141&amp;page=submissions">alwayswantedto</a></span><span class="b-story-copy">©</span>  <span class="b-story-stats">72 comments<span class="sep">/</span>  234608 views<span class="sep">/</span>  60 favorites</span></div><div class="b-sidebar"><div class="b-box"><div class="b-box-header"><h3>Share the love</h3></div><div class="b-box-body"><div class="b-s-share-love"><script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script><div id="gplus"><div class="g-plusone" data-size="medium"></div></div><div id="tw-share"><a href="http://twitter.com/share" class="twitter-share-button" data-count="none" data-text="Crosswords Ch. 01" data-url="http://www.literotica.com/s/crosswords-ch-01">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script></div><div class="secline"><div id="add-this"><a href="http://www.addthis.com/bookmark.php?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/share.gif" width="16" height="16" alt="Share"  /></a></div><div id="add-email"><a href="http://api.addthis.com/oexchange/0.8/forward/email/offer?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/email.gif" width="56" height="18" alt="Email"  /></a></div></div></div></div></div><div class="b-box"><div class="b-box-header"><h3>Report a Bug</h3></div><div class="b-box-body"><a href="/stories/quest/bugs.php?id=3&amp;url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01"><strong>Submit bug report</strong></a></div></div></div><div id="sbar-l-wrp"><div class="b-pager"><a class="b-pager-prev" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">Previous</a><a class="b-pager-next" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">Next</a><div class="b-pager-pages"><span class="b-pager-caption-t r-d45"><!-- x -->7 Pages:</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01">1</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">2</a><span class="b-pager-active">3</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">4</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=5">5</a><form action="http://www.literotica.com/s/crosswords-ch-01" method="get"><select name="page"><option value="1">1</option><option value="2">2</option><option value="3" class="current" selected="selected">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option></select><button type="submit" class="i-button i-button-mini" title="Go">Go</button></form></div></div><div class="big_link" id="b-bottom"><div class="block_id-c3RvcnlwYWdlOS1ib3R0b218MTI1fGJvdHRvbQ=="><!-- It\'s a Daddy Thing 4 -->href="http://www.literotica.com/stories/memberpage.php?uid=923141&amp;page=submissions">alwayswantedto</a></span><span class="b-story-copy">©</span>  <span class="b-story-stats">72 comments<span class="sep">/</span>  234608 views<span class="sep">/</span>  60 favorites</span></div><div class="b-sidebar"><div class="b-box"><div class="b-box-header"><h3>Share the love</h3></div><div class="b-box-body"><div class="b-s-share-love"><script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script><div id="gplus"><div class="g-plusone" data-size="medium"></div></div><div id="tw-share"><a href="http://twitter.com/share" class="twitter-share-button" data-count="none" data-text="Crosswords Ch. 01" data-url="http://www.literotica.com/s/crosswords-ch-01">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script></div><div class="secline"><div id="add-this"><a href="http://www.addthis.com/bookmark.php?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/share.gif" width="16" height="16" alt="Share"  /></a></div><div id="add-email"><a href="http://api.addthis.com/oexchange/0.8/forward/email/offer?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/email.gif" width="56" height="18" alt="Email"  /></a></div></div></div></div></div><div class="b-box"><div class="b-box-header"><h3>Report a Bug</h3></div><div class="b-box-body"><a href="/stories/quest/bugs.php?id=3&amp;url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01"><strong>Submit bug report</strong></a></div></div></div><div id="sbar-l-wrp"><div class="b-pager"><a class="b-pager-prev" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">Previous</a><a class="b-pager-next" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">Next</a><div class="b-pager-pages"><span class="b-pager-caption-t r-d45"><!-- x -->7 Pages:</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01">1</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">2</a><span class="b-pager-active">3</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">4</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=5">5</a><form action="http://www.literotica.com/s/crosswords-ch-01" method="get"><select name="page"><option value="1">1</option><option value="2">2</option><option value="3" class="current" selected="selected">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option></select><button type="submit" class="i-button i-button-mini" title="Go">Go</button></form></div></div><div class="big_link" id="b-bottom"><div class="block_id-c3RvcnlwYWdlOS1ib3R0b218MTI1fGJvdHRvbQ=="><!-- It\'s a Daddy Thing 4 -->href="http://www.literotica.com/stories/memberpage.php?uid=923141&amp;page=submissions">alwayswantedto</a></span><span class="b-story-copy">©</span>  <span class="b-story-stats">72 comments<span class="sep">/</span>  234608 views<span class="sep">/</span>  60 favorites</span></div><div class="b-sidebar"><div class="b-box"><div class="b-box-header"><h3>Share the love</h3></div><div class="b-box-body"><div class="b-s-share-love"><script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script><div id="gplus"><div class="g-plusone" data-size="medium"></div></div><div id="tw-share"><a href="http://twitter.com/share" class="twitter-share-button" data-count="none" data-text="Crosswords Ch. 01" data-url="http://www.literotica.com/s/crosswords-ch-01">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script></div><div class="secline"><div id="add-this"><a href="http://www.addthis.com/bookmark.php?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/share.gif" width="16" height="16" alt="Share"  /></a></div><div id="add-email"><a href="http://api.addthis.com/oexchange/0.8/forward/email/offer?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/email.gif" width="56" height="18" alt="Email"  /></a></div></div></div></div></div><div class="b-box"><div class="b-box-header"><h3>Report a Bug</h3></div><div class="b-box-body"><a href="/stories/quest/bugs.php?id=3&amp;url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01"><strong>Submit bug report</strong></a></div></div></div><div id="sbar-l-wrp"><div class="b-pager"><a class="b-pager-prev" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">Previous</a><a class="b-pager-next" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">Next</a><div class="b-pager-pages"><span class="b-pager-caption-t r-d45"><!-- x -->7 Pages:</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01">1</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">2</a><span class="b-pager-active">3</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">4</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=5">5</a><form action="http://www.literotica.com/s/crosswords-ch-01" method="get"><select name="page"><option value="1">1</option><option value="2">2</option><option value="3" class="current" selected="selected">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option></select><button type="submit" class="i-button i-button-mini" title="Go">Go</button></form></div></div><div class="big_link" id="b-bottom"><div class="block_id-c3RvcnlwYWdlOS1ib3R0b218MTI1fGJvdHRvbQ=="><!-- It\'s a Daddy Thing 4 -->href="http://www.literotica.com/stories/memberpage.php?uid=923141&amp;page=submissions">alwayswantedto</a></span><span class="b-story-copy">©</span>  <span class="b-story-stats">72 comments<span class="sep">/</span>  234608 views<span class="sep">/</span>  60 favorites</span></div><div class="b-sidebar"><div class="b-box"><div class="b-box-header"><h3>Share the love</h3></div><div class="b-box-body"><div class="b-s-share-love"><script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script><div id="gplus"><div class="g-plusone" data-size="medium"></div></div><div id="tw-share"><a href="http://twitter.com/share" class="twitter-share-button" data-count="none" data-text="Crosswords Ch. 01" data-url="http://www.literotica.com/s/crosswords-ch-01">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script></div><div class="secline"><div id="add-this"><a href="http://www.addthis.com/bookmark.php?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/share.gif" width="16" height="16" alt="Share"  /></a></div><div id="add-email"><a href="http://api.addthis.com/oexchange/0.8/forward/email/offer?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/email.gif" width="56" height="18" alt="Email"  /></a></div></div></div></div></div><div class="b-box"><div class="b-box-header"><h3>Report a Bug</h3></div><div class="b-box-body"><a href="/stories/quest/bugs.php?id=3&amp;url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01"><strong>Submit bug report</strong></a></div></div></div><div id="sbar-l-wrp"><div class="b-pager"><a class="b-pager-prev" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">Previous</a><a class="b-pager-next" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">Next</a><div class="b-pager-pages"><span class="b-pager-caption-t r-d45"><!-- x -->7 Pages:</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01">1</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">2</a><span class="b-pager-active">3</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">4</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=5">5</a><form action="http://www.literotica.com/s/crosswords-ch-01" method="get"><select name="page"><option value="1">1</option><option value="2">2</option><option value="3" class="current" selected="selected">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option></select><button type="submit" class="i-button i-button-mini" title="Go">Go</button></form></div></div><div class="big_link" id="b-bottom"><div class="block_id-c3RvcnlwYWdlOS1ib3R0b218MTI1fGJvdHRvbQ=="><!-- It\'s a Daddy Thing 4 -->href="http://www.literotica.com/stories/memberpage.php?uid=923141&amp;page=submissions">alwayswantedto</a></span><span class="b-story-copy">©</span>  <span class="b-story-stats">72 comments<span class="sep">/</span>  234608 views<span class="sep">/</span>  60 favorites</span></div><div class="b-sidebar"><div class="b-box"><div class="b-box-header"><h3>Share the love</h3></div><div class="b-box-body"><div class="b-s-share-love"><script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script><div id="gplus"><div class="g-plusone" data-size="medium"></div></div><div id="tw-share"><a href="http://twitter.com/share" class="twitter-share-button" data-count="none" data-text="Crosswords Ch. 01" data-url="http://www.literotica.com/s/crosswords-ch-01">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script></div><div class="secline"><div id="add-this"><a href="http://www.addthis.com/bookmark.php?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/share.gif" width="16" height="16" alt="Share"  /></a></div><div id="add-email"><a href="http://api.addthis.com/oexchange/0.8/forward/email/offer?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/email.gif" width="56" height="18" alt="Email"  /></a></div></div></div></div></div><div class="b-box"><div class="b-box-header"><h3>Report a Bug</h3></div><div class="b-box-body"><a href="/stories/quest/bugs.php?id=3&amp;url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01"><strong>Submit bug report</strong></a></div></div></div><div id="sbar-l-wrp"><div class="b-pager"><a class="b-pager-prev" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">Previous</a><a class="b-pager-next" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">Next</a><div class="b-pager-pages"><span class="b-pager-caption-t r-d45"><!-- x -->7 Pages:</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01">1</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">2</a><span class="b-pager-active">3</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">4</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=5">5</a><form action="http://www.literotica.com/s/crosswords-ch-01" method="get"><select name="page"><option value="1">1</option><option value="2">2</option><option value="3" class="current" selected="selected">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option></select><button type="submit" class="i-button i-button-mini" title="Go">Go</button></form></div></div><div class="big_link" id="b-bottom"><div class="block_id-c3RvcnlwYWdlOS1ib3R0b218MTI1fGJvdHRvbQ=="><!-- It\'s a Daddy Thing 4 -->href="http://www.literotica.com/stories/memberpage.php?uid=923141&amp;page=submissions">alwayswantedto</a></span><span class="b-story-copy">©</span>  <span class="b-story-stats">72 comments<span class="sep">/</span>  234608 views<span class="sep">/</span>  60 favorites</span></div><div class="b-sidebar"><div class="b-box"><div class="b-box-header"><h3>Share the love</h3></div><div class="b-box-body"><div class="b-s-share-love"><script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script><div id="gplus"><div class="g-plusone" data-size="medium"></div></div><div id="tw-share"><a href="http://twitter.com/share" class="twitter-share-button" data-count="none" data-text="Crosswords Ch. 01" data-url="http://www.literotica.com/s/crosswords-ch-01">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script></div><div class="secline"><div id="add-this"><a href="http://www.addthis.com/bookmark.php?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/share.gif" width="16" height="16" alt="Share"  /></a></div><div id="add-email"><a href="http://api.addthis.com/oexchange/0.8/forward/email/offer?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/email.gif" width="56" height="18" alt="Email"  /></a></div></div></div></div></div><div class="b-box"><div class="b-box-header"><h3>Report a Bug</h3></div><div class="b-box-body"><a href="/stories/quest/bugs.php?id=3&amp;url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01"><strong>Submit bug report</strong></a></div></div></div><div id="sbar-l-wrp"><div class="b-pager"><a class="b-pager-prev" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">Previous</a><a class="b-pager-next" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">Next</a><div class="b-pager-pages"><span class="b-pager-caption-t r-d45"><!-- x -->7 Pages:</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01">1</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">2</a><span class="b-pager-active">3</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">4</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=5">5</a><form action="http://www.literotica.com/s/crosswords-ch-01" method="get"><select name="page"><option value="1">1</option><option value="2">2</option><option value="3" class="current" selected="selected">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option></select><button type="submit" class="i-button i-button-mini" title="Go">Go</button></form></div></div><div class="big_link" id="b-bottom"><div class="block_id-c3RvcnlwYWdlOS1ib3R0b218MTI1fGJvdHRvbQ=="><!-- It\'s a Daddy Thing 4 -->href="http://www.literotica.com/stories/memberpage.php?uid=923141&amp;page=submissions">alwayswantedto</a></span><span class="b-story-copy">©</span>  <span class="b-story-stats">72 comments<span class="sep">/</span>  234608 views<span class="sep">/</span>  60 favorites</span></div><div class="b-sidebar"><div class="b-box"><div class="b-box-header"><h3>Share the love</h3></div><div class="b-box-body"><div class="b-s-share-love"><script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script><div id="gplus"><div class="g-plusone" data-size="medium"></div></div><div id="tw-share"><a href="http://twitter.com/share" class="twitter-share-button" data-count="none" data-text="Crosswords Ch. 01" data-url="http://www.literotica.com/s/crosswords-ch-01">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script></div><div class="secline"><div id="add-this"><a href="http://www.addthis.com/bookmark.php?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/share.gif" width="16" height="16" alt="Share"  /></a></div><div id="add-email"><a href="http://api.addthis.com/oexchange/0.8/forward/email/offer?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/email.gif" width="56" height="18" alt="Email"  /></a></div></div></div></div></div><div class="b-box"><div class="b-box-header"><h3>Report a Bug</h3></div><div class="b-box-body"><a href="/stories/quest/bugs.php?id=3&amp;url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01"><strong>Submit bug report</strong></a></div></div></div><div id="sbar-l-wrp"><div class="b-pager"><a class="b-pager-prev" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">Previous</a><a class="b-pager-next" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">Next</a><div class="b-pager-pages"><span class="b-pager-caption-t r-d45"><!-- x -->7 Pages:</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01">1</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">2</a><span class="b-pager-active">3</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">4</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=5">5</a><form action="http://www.literotica.com/s/crosswords-ch-01" method="get"><select name="page"><option value="1">1</option><option value="2">2</option><option value="3" class="current" selected="selected">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option></select><button type="submit" class="i-button i-button-mini" title="Go">Go</button></form></div></div><div class="big_link" id="b-bottom"><div class="block_id-c3RvcnlwYWdlOS1ib3R0b218MTI1fGJvdHRvbQ=="><!-- It\'s a Daddy Thing 4 -->href="http://www.literotica.com/stories/memberpage.php?uid=923141&amp;page=submissions">alwayswantedto</a></span><span class="b-story-copy">©</span>  <span class="b-story-stats">72 comments<span class="sep">/</span>  234608 views<span class="sep">/</span>  60 favorites</span></div><div class="b-sidebar"><div class="b-box"><div class="b-box-header"><h3>Share the love</h3></div><div class="b-box-body"><div class="b-s-share-love"><script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script><div id="gplus"><div class="g-plusone" data-size="medium"></div></div><div id="tw-share"><a href="http://twitter.com/share" class="twitter-share-button" data-count="none" data-text="Crosswords Ch. 01" data-url="http://www.literotica.com/s/crosswords-ch-01">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script></div><div class="secline"><div id="add-this"><a href="http://www.addthis.com/bookmark.php?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/share.gif" width="16" height="16" alt="Share"  /></a></div><div id="add-email"><a href="http://api.addthis.com/oexchange/0.8/forward/email/offer?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/email.gif" width="56" height="18" alt="Email"  /></a></div></div></div></div></div><div class="b-box"><div class="b-box-header"><h3>Report a Bug</h3></div><div class="b-box-body"><a href="/stories/quest/bugs.php?id=3&amp;url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01"><strong>Submit bug report</strong></a></div></div></div><div id="sbar-l-wrp"><div class="b-pager"><a class="b-pager-prev" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">Previous</a><a class="b-pager-next" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">Next</a><div class="b-pager-pages"><span class="b-pager-caption-t r-d45"><!-- x -->7 Pages:</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01">1</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">2</a><span class="b-pager-active">3</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">4</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=5">5</a><form action="http://www.literotica.com/s/crosswords-ch-01" method="get"><select name="page"><option value="1">1</option><option value="2">2</option><option value="3" class="current" selected="selected">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option></select><button type="submit" class="i-button i-button-mini" title="Go">Go</button></form></div></div><div class="big_link" id="b-bottom"><div class="block_id-c3RvcnlwYWdlOS1ib3R0b218MTI1fGJvdHRvbQ=="><!-- It\'s a Daddy Thing 4 -->href="http://www.literotica.com/stories/memberpage.php?uid=923141&amp;page=submissions">alwayswantedto</a></span><span class="b-story-copy">©</span>  <span class="b-story-stats">72 comments<span class="sep">/</span>  234608 views<span class="sep">/</span>  60 favorites</span></div><div class="b-sidebar"><div class="b-box"><div class="b-box-header"><h3>Share the love</h3></div><div class="b-box-body"><div class="b-s-share-love"><script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script><div id="gplus"><div class="g-plusone" data-size="medium"></div></div><div id="tw-share"><a href="http://twitter.com/share" class="twitter-share-button" data-count="none" data-text="Crosswords Ch. 01" data-url="http://www.literotica.com/s/crosswords-ch-01">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script></div><div class="secline"><div id="add-this"><a href="http://www.addthis.com/bookmark.php?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/share.gif" width="16" height="16" alt="Share"  /></a></div><div id="add-email"><a href="http://api.addthis.com/oexchange/0.8/forward/email/offer?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/email.gif" width="56" height="18" alt="Email"  /></a></div></div></div></div></div><div class="b-box"><div class="b-box-header"><h3>Report a Bug</h3></div><div class="b-box-body"><a href="/stories/quest/bugs.php?id=3&amp;url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01"><strong>Submit bug report</strong></a></div></div></div><div id="sbar-l-wrp"><div class="b-pager"><a class="b-pager-prev" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">Previous</a><a class="b-pager-next" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">Next</a><div class="b-pager-pages"><span class="b-pager-caption-t r-d45"><!-- x -->7 Pages:</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01">1</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">2</a><span class="b-pager-active">3</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">4</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=5">5</a><form action="http://www.literotica.com/s/crosswords-ch-01" method="get"><select name="page"><option value="1">1</option><option value="2">2</option><option value="3" class="current" selected="selected">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option></select><button type="submit" class="i-button i-button-mini" title="Go">Go</button></form></div></div><div class="big_link" id="b-bottom"><div class="block_id-c3RvcnlwYWdlOS1ib3R0b218MTI1fGJvdHRvbQ=="><!-- It\'s a Daddy Thing 4 -->href="http://www.literotica.com/stories/memberpage.php?uid=923141&amp;page=submissions">alwayswantedto</a></span><span class="b-story-copy">©</span>  <span class="b-story-stats">72 comments<span class="sep">/</span>  234608 views<span class="sep">/</span>  60 favorites</span></div><div class="b-sidebar"><div class="b-box"><div class="b-box-header"><h3>Share the love</h3></div><div class="b-box-body"><div class="b-s-share-love"><script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script><div id="gplus"><div class="g-plusone" data-size="medium"></div></div><div id="tw-share"><a href="http://twitter.com/share" class="twitter-share-button" data-count="none" data-text="Crosswords Ch. 01" data-url="http://www.literotica.com/s/crosswords-ch-01">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script></div><div class="secline"><div id="add-this"><a href="http://www.addthis.com/bookmark.php?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/share.gif" width="16" height="16" alt="Share"  /></a></div><div id="add-email"><a href="http://api.addthis.com/oexchange/0.8/forward/email/offer?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/email.gif" width="56" height="18" alt="Email"  /></a></div></div></div></div></div><div class="b-box"><div class="b-box-header"><h3>Report a Bug</h3></div><div class="b-box-body"><a href="/stories/quest/bugs.php?id=3&amp;url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01"><strong>Submit bug report</strong></a></div></div></div><div id="sbar-l-wrp"><div class="b-pager"><a class="b-pager-prev" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">Previous</a><a class="b-pager-next" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">Next</a><div class="b-pager-pages"><span class="b-pager-caption-t r-d45"><!-- x -->7 Pages:</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01">1</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">2</a><span class="b-pager-active">3</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">4</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=5">5</a><form action="http://www.literotica.com/s/crosswords-ch-01" method="get"><select name="page"><option value="1">1</option><option value="2">2</option><option value="3" class="current" selected="selected">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option></select><button type="submit" class="i-button i-button-mini" title="Go">Go</button></form></div></div><div class="big_link" id="b-bottom"><div class="block_id-c3RvcnlwYWdlOS1ib3R0b218MTI1fGJvdHRvbQ=="><!-- It\'s a Daddy Thing 4 -->href="http://www.literotica.com/stories/memberpage.php?uid=923141&amp;page=submissions">alwayswantedto</a></span><span class="b-story-copy">©</span>  <span class="b-story-stats">72 comments<span class="sep">/</span>  234608 views<span class="sep">/</span>  60 favorites</span></div><div class="b-sidebar"><div class="b-box"><div class="b-box-header"><h3>Share the love</h3></div><div class="b-box-body"><div class="b-s-share-love"><script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script><div id="gplus"><div class="g-plusone" data-size="medium"></div></div><div id="tw-share"><a href="http://twitter.com/share" class="twitter-share-button" data-count="none" data-text="Crosswords Ch. 01" data-url="http://www.literotica.com/s/crosswords-ch-01">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script></div><div class="secline"><div id="add-this"><a href="http://www.addthis.com/bookmark.php?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/share.gif" width="16" height="16" alt="Share"  /></a></div><div id="add-email"><a href="http://api.addthis.com/oexchange/0.8/forward/email/offer?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/email.gif" width="56" height="18" alt="Email"  /></a></div></div></div></div></div><div class="b-box"><div class="b-box-header"><h3>Report a Bug</h3></div><div class="b-box-body"><a href="/stories/quest/bugs.php?id=3&amp;url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01"><strong>Submit bug report</strong></a></div></div></div><div id="sbar-l-wrp"><div class="b-pager"><a class="b-pager-prev" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">Previous</a><a class="b-pager-next" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">Next</a><div class="b-pager-pages"><span class="b-pager-caption-t r-d45"><!-- x -->7 Pages:</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01">1</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">2</a><span class="b-pager-active">3</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">4</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=5">5</a><form action="http://www.literotica.com/s/crosswords-ch-01" method="get"><select name="page"><option value="1">1</option><option value="2">2</option><option value="3" class="current" selected="selected">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option></select><button type="submit" class="i-button i-button-mini" title="Go">Go</button></form></div></div><div class="big_link" id="b-bottom"><div class="block_id-c3RvcnlwYWdlOS1ib3R0b218MTI1fGJvdHRvbQ=="><!-- It\'s a Daddy Thing 4 -->href="http://www.literotica.com/stories/memberpage.php?uid=923141&amp;page=submissions">alwayswantedto</a></span><span class="b-story-copy">©</span>  <span class="b-story-stats">72 comments<span class="sep">/</span>  234608 views<span class="sep">/</span>  60 favorites</span></div><div class="b-sidebar"><div class="b-box"><div class="b-box-header"><h3>Share the love</h3></div><div class="b-box-body"><div class="b-s-share-love"><script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script><div id="gplus"><div class="g-plusone" data-size="medium"></div></div><div id="tw-share"><a href="http://twitter.com/share" class="twitter-share-button" data-count="none" data-text="Crosswords Ch. 01" data-url="http://www.literotica.com/s/crosswords-ch-01">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script></div><div class="secline"><div id="add-this"><a href="http://www.addthis.com/bookmark.php?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/share.gif" width="16" height="16" alt="Share"  /></a></div><div id="add-email"><a href="http://api.addthis.com/oexchange/0.8/forward/email/offer?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/email.gif" width="56" height="18" alt="Email"  /></a></div></div></div></div></div><div class="b-box"><div class="b-box-header"><h3>Report a Bug</h3></div><div class="b-box-body"><a href="/stories/quest/bugs.php?id=3&amp;url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01"><strong>Submit bug report</strong></a></div></div></div><div id="sbar-l-wrp"><div class="b-pager"><a class="b-pager-prev" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">Previous</a><a class="b-pager-next" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">Next</a><div class="b-pager-pages"><span class="b-pager-caption-t r-d45"><!-- x -->7 Pages:</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01">1</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">2</a><span class="b-pager-active">3</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">4</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=5">5</a><form action="http://www.literotica.com/s/crosswords-ch-01" method="get"><select name="page"><option value="1">1</option><option value="2">2</option><option value="3" class="current" selected="selected">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option></select><button type="submit" class="i-button i-button-mini" title="Go">Go</button></form></div></div><div class="big_link" id="b-bottom"><div class="block_id-c3RvcnlwYWdlOS1ib3R0b218MTI1fGJvdHRvbQ=="><!-- It\'s a Daddy Thing 4 -->href="http://www.literotica.com/stories/memberpage.php?uid=923141&amp;page=submissions">alwayswantedto</a></span><span class="b-story-copy">©</span>  <span class="b-story-stats">72 comments<span class="sep">/</span>  234608 views<span class="sep">/</span>  60 favorites</span></div><div class="b-sidebar"><div class="b-box"><div class="b-box-header"><h3>Share the love</h3></div><div class="b-box-body"><div class="b-s-share-love"><script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script><div id="gplus"><div class="g-plusone" data-size="medium"></div></div><div id="tw-share"><a href="http://twitter.com/share" class="twitter-share-button" data-count="none" data-text="Crosswords Ch. 01" data-url="http://www.literotica.com/s/crosswords-ch-01">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script></div><div class="secline"><div id="add-this"><a href="http://www.addthis.com/bookmark.php?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/share.gif" width="16" height="16" alt="Share"  /></a></div><div id="add-email"><a href="http://api.addthis.com/oexchange/0.8/forward/email/offer?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/email.gif" width="56" height="18" alt="Email"  /></a></div></div></div></div></div><div class="b-box"><div class="b-box-header"><h3>Report a Bug</h3></div><div class="b-box-body"><a href="/stories/quest/bugs.php?id=3&amp;url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01"><strong>Submit bug report</strong></a></div></div></div><div id="sbar-l-wrp"><div class="b-pager"><a class="b-pager-prev" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">Previous</a><a class="b-pager-next" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">Next</a><div class="b-pager-pages"><span class="b-pager-caption-t r-d45"><!-- x -->7 Pages:</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01">1</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">2</a><span class="b-pager-active">3</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">4</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=5">5</a><form action="http://www.literotica.com/s/crosswords-ch-01" method="get"><select name="page"><option value="1">1</option><option value="2">2</option><option value="3" class="current" selected="selected">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option></select><button type="submit" class="i-button i-button-mini" title="Go">Go</button></form></div></div><div class="big_link" id="b-bottom"><div class="block_id-c3RvcnlwYWdlOS1ib3R0b218MTI1fGJvdHRvbQ=="><!-- It\'s a Daddy Thing 4 -->href="http://www.literotica.com/stories/memberpage.php?uid=923141&amp;page=submissions">alwayswantedto</a></span><span class="b-story-copy">©</span>  <span class="b-story-stats">72 comments<span class="sep">/</span>  234608 views<span class="sep">/</span>  60 favorites</span></div><div class="b-sidebar"><div class="b-box"><div class="b-box-header"><h3>Share the love</h3></div><div class="b-box-body"><div class="b-s-share-love"><script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script><div id="gplus"><div class="g-plusone" data-size="medium"></div></div><div id="tw-share"><a href="http://twitter.com/share" class="twitter-share-button" data-count="none" data-text="Crosswords Ch. 01" data-url="http://www.literotica.com/s/crosswords-ch-01">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script></div><div class="secline"><div id="add-this"><a href="http://www.addthis.com/bookmark.php?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/share.gif" width="16" height="16" alt="Share"  /></a></div><div id="add-email"><a href="http://api.addthis.com/oexchange/0.8/forward/email/offer?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/email.gif" width="56" height="18" alt="Email"  /></a></div></div></div></div></div><div class="b-box"><div class="b-box-header"><h3>Report a Bug</h3></div><div class="b-box-body"><a href="/stories/quest/bugs.php?id=3&amp;url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01"><strong>Submit bug report</strong></a></div></div></div><div id="sbar-l-wrp"><div class="b-pager"><a class="b-pager-prev" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">Previous</a><a class="b-pager-next" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">Next</a><div class="b-pager-pages"><span class="b-pager-caption-t r-d45"><!-- x -->7 Pages:</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01">1</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">2</a><span class="b-pager-active">3</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">4</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=5">5</a><form action="http://www.literotica.com/s/crosswords-ch-01" method="get"><select name="page"><option value="1">1</option><option value="2">2</option><option value="3" class="current" selected="selected">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option></select><button type="submit" class="i-button i-button-mini" title="Go">Go</button></form></div></div><div class="big_link" id="b-bottom"><div class="block_id-c3RvcnlwYWdlOS1ib3R0b218MTI1fGJvdHRvbQ=="><!-- It\'s a Daddy Thing 4 -->href="http://www.literotica.com/stories/memberpage.php?uid=923141&amp;page=submissions">alwayswantedto</a></span><span class="b-story-copy">©</span>  <span class="b-story-stats">72 comments<span class="sep">/</span>  234608 views<span class="sep">/</span>  60 favorites</span></div><div class="b-sidebar"><div class="b-box"><div class="b-box-header"><h3>Share the love</h3></div><div class="b-box-body"><div class="b-s-share-love"><script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script><div id="gplus"><div class="g-plusone" data-size="medium"></div></div><div id="tw-share"><a href="http://twitter.com/share" class="twitter-share-button" data-count="none" data-text="Crosswords Ch. 01" data-url="http://www.literotica.com/s/crosswords-ch-01">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script></div><div class="secline"><div id="add-this"><a href="http://www.addthis.com/bookmark.php?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/share.gif" width="16" height="16" alt="Share"  /></a></div><div id="add-email"><a href="http://api.addthis.com/oexchange/0.8/forward/email/offer?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/email.gif" width="56" height="18" alt="Email"  /></a></div></div></div></div></div><div class="b-box"><div class="b-box-header"><h3>Report a Bug</h3></div><div class="b-box-body"><a href="/stories/quest/bugs.php?id=3&amp;url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01"><strong>Submit bug report</strong></a></div></div></div><div id="sbar-l-wrp"><div class="b-pager"><a class="b-pager-prev" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">Previous</a><a class="b-pager-next" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">Next</a><div class="b-pager-pages"><span class="b-pager-caption-t r-d45"><!-- x -->7 Pages:</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01">1</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">2</a><span class="b-pager-active">3</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">4</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=5">5</a><form action="http://www.literotica.com/s/crosswords-ch-01" method="get"><select name="page"><option value="1">1</option><option value="2">2</option><option value="3" class="current" selected="selected">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option></select><button type="submit" class="i-button i-button-mini" title="Go">Go</button></form></div></div><div class="big_link" id="b-bottom"><div class="block_id-c3RvcnlwYWdlOS1ib3R0b218MTI1fGJvdHRvbQ=="><!-- It\'s a Daddy Thing 4 -->href="http://www.literotica.com/stories/memberpage.php?uid=923141&amp;page=submissions">alwayswantedto</a></span><span class="b-story-copy">©</span>  <span class="b-story-stats">72 comments<span class="sep">/</span>  234608 views<span class="sep">/</span>  60 favorites</span></div><div class="b-sidebar"><div class="b-box"><div class="b-box-header"><h3>Share the love</h3></div><div class="b-box-body"><div class="b-s-share-love"><script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script><div id="gplus"><div class="g-plusone" data-size="medium"></div></div><div id="tw-share"><a href="http://twitter.com/share" class="twitter-share-button" data-count="none" data-text="Crosswords Ch. 01" data-url="http://www.literotica.com/s/crosswords-ch-01">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script></div><div class="secline"><div id="add-this"><a href="http://www.addthis.com/bookmark.php?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/share.gif" width="16" height="16" alt="Share"  /></a></div><div id="add-email"><a href="http://api.addthis.com/oexchange/0.8/forward/email/offer?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/email.gif" width="56" height="18" alt="Email"  /></a></div></div></div></div></div><div class="b-box"><div class="b-box-header"><h3>Report a Bug</h3></div><div class="b-box-body"><a href="/stories/quest/bugs.php?id=3&amp;url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01"><strong>Submit bug report</strong></a></div></div></div><div id="sbar-l-wrp"><div class="b-pager"><a class="b-pager-prev" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">Previous</a><a class="b-pager-next" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">Next</a><div class="b-pager-pages"><span class="b-pager-caption-t r-d45"><!-- x -->7 Pages:</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01">1</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">2</a><span class="b-pager-active">3</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">4</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=5">5</a><form action="http://www.literotica.com/s/crosswords-ch-01" method="get"><select name="page"><option value="1">1</option><option value="2">2</option><option value="3" class="current" selected="selected">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option></select><button type="submit" class="i-button i-button-mini" title="Go">Go</button></form></div></div><div class="big_link" id="b-bottom"><div class="block_id-c3RvcnlwYWdlOS1ib3R0b218MTI1fGJvdHRvbQ=="><!-- It\'s a Daddy Thing 4 -->href="http://www.literotica.com/stories/memberpage.php?uid=923141&amp;page=submissions">alwayswantedto</a></span><span class="b-story-copy">©</span>  <span class="b-story-stats">72 comments<span class="sep">/</span>  234608 views<span class="sep">/</span>  60 favorites</span></div><div class="b-sidebar"><div class="b-box"><div class="b-box-header"><h3>Share the love</h3></div><div class="b-box-body"><div class="b-s-share-love"><script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script><div id="gplus"><div class="g-plusone" data-size="medium"></div></div><div id="tw-share"><a href="http://twitter.com/share" class="twitter-share-button" data-count="none" data-text="Crosswords Ch. 01" data-url="http://www.literotica.com/s/crosswords-ch-01">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script></div><div class="secline"><div id="add-this"><a href="http://www.addthis.com/bookmark.php?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/share.gif" width="16" height="16" alt="Share"  /></a></div><div id="add-email"><a href="http://api.addthis.com/oexchange/0.8/forward/email/offer?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/email.gif" width="56" height="18" alt="Email"  /></a></div></div></div></div></div><div class="b-box"><div class="b-box-header"><h3>Report a Bug</h3></div><div class="b-box-body"><a href="/stories/quest/bugs.php?id=3&amp;url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01"><strong>Submit bug report</strong></a></div></div></div><div id="sbar-l-wrp"><div class="b-pager"><a class="b-pager-prev" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">Previous</a><a class="b-pager-next" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">Next</a><div class="b-pager-pages"><span class="b-pager-caption-t r-d45"><!-- x -->7 Pages:</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01">1</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">2</a><span class="b-pager-active">3</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">4</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=5">5</a><form action="http://www.literotica.com/s/crosswords-ch-01" method="get"><select name="page"><option value="1">1</option><option value="2">2</option><option value="3" class="current" selected="selected">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option></select><button type="submit" class="i-button i-button-mini" title="Go">Go</button></form></div></div><div class="big_link" id="b-bottom"><div class="block_id-c3RvcnlwYWdlOS1ib3R0b218MTI1fGJvdHRvbQ=="><!-- It\'s a Daddy Thing 4 -->href="http://www.literotica.com/stories/memberpage.php?uid=923141&amp;page=submissions">alwayswantedto</a></span><span class="b-story-copy">©</span>  <span class="b-story-stats">72 comments<span class="sep">/</span>  234608 views<span class="sep">/</span>  60 favorites</span></div><div class="b-sidebar"><div class="b-box"><div class="b-box-header"><h3>Share the love</h3></div><div class="b-box-body"><div class="b-s-share-love"><script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script><div id="gplus"><div class="g-plusone" data-size="medium"></div></div><div id="tw-share"><a href="http://twitter.com/share" class="twitter-share-button" data-count="none" data-text="Crosswords Ch. 01" data-url="http://www.literotica.com/s/crosswords-ch-01">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script></div><div class="secline"><div id="add-this"><a href="http://www.addthis.com/bookmark.php?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/share.gif" width="16" height="16" alt="Share"  /></a></div><div id="add-email"><a href="http://api.addthis.com/oexchange/0.8/forward/email/offer?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/email.gif" width="56" height="18" alt="Email"  /></a></div></div></div></div></div><div class="b-box"><div class="b-box-header"><h3>Report a Bug</h3></div><div class="b-box-body"><a href="/stories/quest/bugs.php?id=3&amp;url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01"><strong>Submit bug report</strong></a></div></div></div><div id="sbar-l-wrp"><div class="b-pager"><a class="b-pager-prev" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">Previous</a><a class="b-pager-next" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">Next</a><div class="b-pager-pages"><span class="b-pager-caption-t r-d45"><!-- x -->7 Pages:</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01">1</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">2</a><span class="b-pager-active">3</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">4</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=5">5</a><form action="http://www.literotica.com/s/crosswords-ch-01" method="get"><select name="page"><option value="1">1</option><option value="2">2</option><option value="3" class="current" selected="selected">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option></select><button type="submit" class="i-button i-button-mini" title="Go">Go</button></form></div></div><div class="big_link" id="b-bottom"><div class="block_id-c3RvcnlwYWdlOS1ib3R0b218MTI1fGJvdHRvbQ=="><!-- It\'s a Daddy Thing 4 -->href="http://www.literotica.com/stories/memberpage.php?uid=923141&amp;page=submissions">alwayswantedto</a></span><span class="b-story-copy">©</span>  <span class="b-story-stats">72 comments<span class="sep">/</span>  234608 views<span class="sep">/</span>  60 favorites</span></div><div class="b-sidebar"><div class="b-box"><div class="b-box-header"><h3>Share the love</h3></div><div class="b-box-body"><div class="b-s-share-love"><script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script><div id="gplus"><div class="g-plusone" data-size="medium"></div></div><div id="tw-share"><a href="http://twitter.com/share" class="twitter-share-button" data-count="none" data-text="Crosswords Ch. 01" data-url="http://www.literotica.com/s/crosswords-ch-01">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script></div><div class="secline"><div id="add-this"><a href="http://www.addthis.com/bookmark.php?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/share.gif" width="16" height="16" alt="Share"  /></a></div><div id="add-email"><a href="http://api.addthis.com/oexchange/0.8/forward/email/offer?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/email.gif" width="56" height="18" alt="Email"  /></a></div></div></div></div></div><div class="b-box"><div class="b-box-header"><h3>Report a Bug</h3></div><div class="b-box-body"><a href="/stories/quest/bugs.php?id=3&amp;url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01"><strong>Submit bug report</strong></a></div></div></div><div id="sbar-l-wrp"><div class="b-pager"><a class="b-pager-prev" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">Previous</a><a class="b-pager-next" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">Next</a><div class="b-pager-pages"><span class="b-pager-caption-t r-d45"><!-- x -->7 Pages:</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01">1</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">2</a><span class="b-pager-active">3</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">4</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=5">5</a><form action="http://www.literotica.com/s/crosswords-ch-01" method="get"><select name="page"><option value="1">1</option><option value="2">2</option><option value="3" class="current" selected="selected">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option></select><button type="submit" class="i-button i-button-mini" title="Go">Go</button></form></div></div><div class="big_link" id="b-bottom"><div class="block_id-c3RvcnlwYWdlOS1ib3R0b218MTI1fGJvdHRvbQ=="><!-- It\'s a Daddy Thing 4 -->href="http://www.literotica.com/stories/memberpage.php?uid=923141&amp;page=submissions">alwayswantedto</a></span><span class="b-story-copy">©</span>  <span class="b-story-stats">72 comments<span class="sep">/</span>  234608 views<span class="sep">/</span>  60 favorites</span></div><div class="b-sidebar"><div class="b-box"><div class="b-box-header"><h3>Share the love</h3></div><div class="b-box-body"><div class="b-s-share-love"><script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script><div id="gplus"><div class="g-plusone" data-size="medium"></div></div><div id="tw-share"><a href="http://twitter.com/share" class="twitter-share-button" data-count="none" data-text="Crosswords Ch. 01" data-url="http://www.literotica.com/s/crosswords-ch-01">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script></div><div class="secline"><div id="add-this"><a href="http://www.addthis.com/bookmark.php?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/share.gif" width="16" height="16" alt="Share"  /></a></div><div id="add-email"><a href="http://api.addthis.com/oexchange/0.8/forward/email/offer?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/email.gif" width="56" height="18" alt="Email"  /></a></div></div></div></div></div><div class="b-box"><div class="b-box-header"><h3>Report a Bug</h3></div><div class="b-box-body"><a href="/stories/quest/bugs.php?id=3&amp;url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01"><strong>Submit bug report</strong></a></div></div></div><div id="sbar-l-wrp"><div class="b-pager"><a class="b-pager-prev" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">Previous</a><a class="b-pager-next" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">Next</a><div class="b-pager-pages"><span class="b-pager-caption-t r-d45"><!-- x -->7 Pages:</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01">1</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">2</a><span class="b-pager-active">3</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">4</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=5">5</a><form action="http://www.literotica.com/s/crosswords-ch-01" method="get"><select name="page"><option value="1">1</option><option value="2">2</option><option value="3" class="current" selected="selected">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option></select><button type="submit" class="i-button i-button-mini" title="Go">Go</button></form></div></div><div class="big_link" id="b-bottom"><div class="block_id-c3RvcnlwYWdlOS1ib3R0b218MTI1fGJvdHRvbQ=="><!-- It\'s a Daddy Thing 4 -->href="http://www.literotica.com/stories/memberpage.php?uid=923141&amp;page=submissions">alwayswantedto</a></span><span class="b-story-copy">©</span>  <span class="b-story-stats">72 comments<span class="sep">/</span>  234608 views<span class="sep">/</span>  60 favorites</span></div><div class="b-sidebar"><div class="b-box"><div class="b-box-header"><h3>Share the love</h3></div><div class="b-box-body"><div class="b-s-share-love"><script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script><div id="gplus"><div class="g-plusone" data-size="medium"></div></div><div id="tw-share"><a href="http://twitter.com/share" class="twitter-share-button" data-count="none" data-text="Crosswords Ch. 01" data-url="http://www.literotica.com/s/crosswords-ch-01">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script></div><div class="secline"><div id="add-this"><a href="http://www.addthis.com/bookmark.php?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/share.gif" width="16" height="16" alt="Share"  /></a></div><div id="add-email"><a href="http://api.addthis.com/oexchange/0.8/forward/email/offer?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/email.gif" width="56" height="18" alt="Email"  /></a></div></div></div></div></div><div class="b-box"><div class="b-box-header"><h3>Report a Bug</h3></div><div class="b-box-body"><a href="/stories/quest/bugs.php?id=3&amp;url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01"><strong>Submit bug report</strong></a></div></div></div><div id="sbar-l-wrp"><div class="b-pager"><a class="b-pager-prev" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">Previous</a><a class="b-pager-next" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">Next</a><div class="b-pager-pages"><span class="b-pager-caption-t r-d45"><!-- x -->7 Pages:</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01">1</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">2</a><span class="b-pager-active">3</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">4</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=5">5</a><form action="http://www.literotica.com/s/crosswords-ch-01" method="get"><select name="page"><option value="1">1</option><option value="2">2</option><option value="3" class="current" selected="selected">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option></select><button type="submit" class="i-button i-button-mini" title="Go">Go</button></form></div></div><div class="big_link" id="b-bottom"><div class="block_id-c3RvcnlwYWdlOS1ib3R0b218MTI1fGJvdHRvbQ=="><!-- It\'s a Daddy Thing 4 -->href="http://www.literotica.com/stories/memberpage.php?uid=923141&amp;page=submissions">alwayswantedto</a></span><span class="b-story-copy">©</span>  <span class="b-story-stats">72 comments<span class="sep">/</span>  234608 views<span class="sep">/</span>  60 favorites</span></div><div class="b-sidebar"><div class="b-box"><div class="b-box-header"><h3>Share the love</h3></div><div class="b-box-body"><div class="b-s-share-love"><script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script><div id="gplus"><div class="g-plusone" data-size="medium"></div></div><div id="tw-share"><a href="http://twitter.com/share" class="twitter-share-button" data-count="none" data-text="Crosswords Ch. 01" data-url="http://www.literotica.com/s/crosswords-ch-01">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script></div><div class="secline"><div id="add-this"><a href="http://www.addthis.com/bookmark.php?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/share.gif" width="16" height="16" alt="Share"  /></a></div><div id="add-email"><a href="http://api.addthis.com/oexchange/0.8/forward/email/offer?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/email.gif" width="56" height="18" alt="Email"  /></a></div></div></div></div></div><div class="b-box"><div class="b-box-header"><h3>Report a Bug</h3></div><div class="b-box-body"><a href="/stories/quest/bugs.php?id=3&amp;url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01"><strong>Submit bug report</strong></a></div></div></div><div id="sbar-l-wrp"><div class="b-pager"><a class="b-pager-prev" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">Previous</a><a class="b-pager-next" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">Next</a><div class="b-pager-pages"><span class="b-pager-caption-t r-d45"><!-- x -->7 Pages:</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01">1</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">2</a><span class="b-pager-active">3</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">4</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=5">5</a><form action="http://www.literotica.com/s/crosswords-ch-01" method="get"><select name="page"><option value="1">1</option><option value="2">2</option><option value="3" class="current" selected="selected">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option></select><button type="submit" class="i-button i-button-mini" title="Go">Go</button></form></div></div><div class="big_link" id="b-bottom"><div class="block_id-c3RvcnlwYWdlOS1ib3R0b218MTI1fGJvdHRvbQ=="><!-- It\'s a Daddy Thing 4 -->href="http://www.literotica.com/stories/memberpage.php?uid=923141&amp;page=submissions">alwayswantedto</a></span><span class="b-story-copy">©</span>  <span class="b-story-stats">72 comments<span class="sep">/</span>  234608 views<span class="sep">/</span>  60 favorites</span></div><div class="b-sidebar"><div class="b-box"><div class="b-box-header"><h3>Share the love</h3></div><div class="b-box-body"><div class="b-s-share-love"><script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script><div id="gplus"><div class="g-plusone" data-size="medium"></div></div><div id="tw-share"><a href="http://twitter.com/share" class="twitter-share-button" data-count="none" data-text="Crosswords Ch. 01" data-url="http://www.literotica.com/s/crosswords-ch-01">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script></div><div class="secline"><div id="add-this"><a href="http://www.addthis.com/bookmark.php?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/share.gif" width="16" height="16" alt="Share"  /></a></div><div id="add-email"><a href="http://api.addthis.com/oexchange/0.8/forward/email/offer?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/email.gif" width="56" height="18" alt="Email"  /></a></div></div></div></div></div><div class="b-box"><div class="b-box-header"><h3>Report a Bug</h3></div><div class="b-box-body"><a href="/stories/quest/bugs.php?id=3&amp;url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01"><strong>Submit bug report</strong></a></div></div></div><div id="sbar-l-wrp"><div class="b-pager"><a class="b-pager-prev" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">Previous</a><a class="b-pager-next" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">Next</a><div class="b-pager-pages"><span class="b-pager-caption-t r-d45"><!-- x -->7 Pages:</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01">1</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">2</a><span class="b-pager-active">3</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">4</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=5">5</a><form action="http://www.literotica.com/s/crosswords-ch-01" method="get"><select name="page"><option value="1">1</option><option value="2">2</option><option value="3" class="current" selected="selected">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option></select><button type="submit" class="i-button i-button-mini" title="Go">Go</button></form></div></div><div class="big_link" id="b-bottom"><div class="block_id-c3RvcnlwYWdlOS1ib3R0b218MTI1fGJvdHRvbQ=="><!-- It\'s a Daddy Thing 4 -->href="http://www.literotica.com/stories/memberpage.php?uid=923141&amp;page=submissions">alwayswantedto</a></span><span class="b-story-copy">©</span>  <span class="b-story-stats">72 comments<span class="sep">/</span>  234608 views<span class="sep">/</span>  60 favorites</span></div><div class="b-sidebar"><div class="b-box"><div class="b-box-header"><h3>Share the love</h3></div><div class="b-box-body"><div class="b-s-share-love"><script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script><div id="gplus"><div class="g-plusone" data-size="medium"></div></div><div id="tw-share"><a href="http://twitter.com/share" class="twitter-share-button" data-count="none" data-text="Crosswords Ch. 01" data-url="http://www.literotica.com/s/crosswords-ch-01">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script></div><div class="secline"><div id="add-this"><a href="http://www.addthis.com/bookmark.php?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/share.gif" width="16" height="16" alt="Share"  /></a></div><div id="add-email"><a href="http://api.addthis.com/oexchange/0.8/forward/email/offer?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/email.gif" width="56" height="18" alt="Email"  /></a></div></div></div></div></div><div class="b-box"><div class="b-box-header"><h3>Report a Bug</h3></div><div class="b-box-body"><a href="/stories/quest/bugs.php?id=3&amp;url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01"><strong>Submit bug report</strong></a></div></div></div><div id="sbar-l-wrp"><div class="b-pager"><a class="b-pager-prev" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">Previous</a><a class="b-pager-next" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">Next</a><div class="b-pager-pages"><span class="b-pager-caption-t r-d45"><!-- x -->7 Pages:</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01">1</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">2</a><span class="b-pager-active">3</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">4</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=5">5</a><form action="http://www.literotica.com/s/crosswords-ch-01" method="get"><select name="page"><option value="1">1</option><option value="2">2</option><option value="3" class="current" selected="selected">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option></select><button type="submit" class="i-button i-button-mini" title="Go">Go</button></form></div></div><div class="big_link" id="b-bottom"><div class="block_id-c3RvcnlwYWdlOS1ib3R0b218MTI1fGJvdHRvbQ=="><!-- It\'s a Daddy Thing 4 -->href="http://www.literotica.com/stories/memberpage.php?uid=923141&amp;page=submissions">alwayswantedto</a></span><span class="b-story-copy">©</span>  <span class="b-story-stats">72 comments<span class="sep">/</span>  234608 views<span class="sep">/</span>  60 favorites</span></div><div class="b-sidebar"><div class="b-box"><div class="b-box-header"><h3>Share the love</h3></div><div class="b-box-body"><div class="b-s-share-love"><script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script><div id="gplus"><div class="g-plusone" data-size="medium"></div></div><div id="tw-share"><a href="http://twitter.com/share" class="twitter-share-button" data-count="none" data-text="Crosswords Ch. 01" data-url="http://www.literotica.com/s/crosswords-ch-01">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script></div><div class="secline"><div id="add-this"><a href="http://www.addthis.com/bookmark.php?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/share.gif" width="16" height="16" alt="Share"  /></a></div><div id="add-email"><a href="http://api.addthis.com/oexchange/0.8/forward/email/offer?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/email.gif" width="56" height="18" alt="Email"  /></a></div></div></div></div></div><div class="b-box"><div class="b-box-header"><h3>Report a Bug</h3></div><div class="b-box-body"><a href="/stories/quest/bugs.php?id=3&amp;url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01"><strong>Submit bug report</strong></a></div></div></div><div id="sbar-l-wrp"><div class="b-pager"><a class="b-pager-prev" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">Previous</a><a class="b-pager-next" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">Next</a><div class="b-pager-pages"><span class="b-pager-caption-t r-d45"><!-- x -->7 Pages:</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01">1</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">2</a><span class="b-pager-active">3</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">4</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=5">5</a><form action="http://www.literotica.com/s/crosswords-ch-01" method="get"><select name="page"><option value="1">1</option><option value="2">2</option><option value="3" class="current" selected="selected">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option></select><button type="submit" class="i-button i-button-mini" title="Go">Go</button></form></div></div><div class="big_link" id="b-bottom"><div class="block_id-c3RvcnlwYWdlOS1ib3R0b218MTI1fGJvdHRvbQ=="><!-- It\'s a Daddy Thing 4 -->href="http://www.literotica.com/stories/memberpage.php?uid=923141&amp;page=submissions">alwayswantedto</a></span><span class="b-story-copy">©</span>  <span class="b-story-stats">72 comments<span class="sep">/</span>  234608 views<span class="sep">/</span>  60 favorites</span></div><div class="b-sidebar"><div class="b-box"><div class="b-box-header"><h3>Share the love</h3></div><div class="b-box-body"><div class="b-s-share-love"><script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script><div id="gplus"><div class="g-plusone" data-size="medium"></div></div><div id="tw-share"><a href="http://twitter.com/share" class="twitter-share-button" data-count="none" data-text="Crosswords Ch. 01" data-url="http://www.literotica.com/s/crosswords-ch-01">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script></div><div class="secline"><div id="add-this"><a href="http://www.addthis.com/bookmark.php?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/share.gif" width="16" height="16" alt="Share"  /></a></div><div id="add-email"><a href="http://api.addthis.com/oexchange/0.8/forward/email/offer?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/email.gif" width="56" height="18" alt="Email"  /></a></div></div></div></div></div><div class="b-box"><div class="b-box-header"><h3>Report a Bug</h3></div><div class="b-box-body"><a href="/stories/quest/bugs.php?id=3&amp;url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01"><strong>Submit bug report</strong></a></div></div></div><div id="sbar-l-wrp"><div class="b-pager"><a class="b-pager-prev" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">Previous</a><a class="b-pager-next" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">Next</a><div class="b-pager-pages"><span class="b-pager-caption-t r-d45"><!-- x -->7 Pages:</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01">1</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">2</a><span class="b-pager-active">3</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">4</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=5">5</a><form action="http://www.literotica.com/s/crosswords-ch-01" method="get"><select name="page"><option value="1">1</option><option value="2">2</option><option value="3" class="current" selected="selected">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option></select><button type="submit" class="i-button i-button-mini" title="Go">Go</button></form></div></div><div class="big_link" id="b-bottom"><div class="block_id-c3RvcnlwYWdlOS1ib3R0b218MTI1fGJvdHRvbQ=="><!-- It\'s a Daddy Thing 4 -->href="http://www.literotica.com/stories/memberpage.php?uid=923141&amp;page=submissions">alwayswantedto</a></span><span class="b-story-copy">©</span>  <span class="b-story-stats">72 comments<span class="sep">/</span>  234608 views<span class="sep">/</span>  60 favorites</span></div><div class="b-sidebar"><div class="b-box"><div class="b-box-header"><h3>Share the love</h3></div><div class="b-box-body"><div class="b-s-share-love"><script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script><div id="gplus"><div class="g-plusone" data-size="medium"></div></div><div id="tw-share"><a href="http://twitter.com/share" class="twitter-share-button" data-count="none" data-text="Crosswords Ch. 01" data-url="http://www.literotica.com/s/crosswords-ch-01">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script></div><div class="secline"><div id="add-this"><a href="http://www.addthis.com/bookmark.php?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/share.gif" width="16" height="16" alt="Share"  /></a></div><div id="add-email"><a href="http://api.addthis.com/oexchange/0.8/forward/email/offer?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/email.gif" width="56" height="18" alt="Email"  /></a></div></div></div></div></div><div class="b-box"><div class="b-box-header"><h3>Report a Bug</h3></div><div class="b-box-body"><a href="/stories/quest/bugs.php?id=3&amp;url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01"><strong>Submit bug report</strong></a></div></div></div><div id="sbar-l-wrp"><div class="b-pager"><a class="b-pager-prev" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">Previous</a><a class="b-pager-next" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">Next</a><div class="b-pager-pages"><span class="b-pager-caption-t r-d45"><!-- x -->7 Pages:</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01">1</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">2</a><span class="b-pager-active">3</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">4</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=5">5</a><form action="http://www.literotica.com/s/crosswords-ch-01" method="get"><select name="page"><option value="1">1</option><option value="2">2</option><option value="3" class="current" selected="selected">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option></select><button type="submit" class="i-button i-button-mini" title="Go">Go</button></form></div></div><div class="big_link" id="b-bottom"><div class="block_id-c3RvcnlwYWdlOS1ib3R0b218MTI1fGJvdHRvbQ=="><!-- It\'s a Daddy Thing 4 -->href="http://www.literotica.com/stories/memberpage.php?uid=923141&amp;page=submissions">alwayswantedto</a></span><span class="b-story-copy">©</span>  <span class="b-story-stats">72 comments<span class="sep">/</span>  234608 views<span class="sep">/</span>  60 favorites</span></div><div class="b-sidebar"><div class="b-box"><div class="b-box-header"><h3>Share the love</h3></div><div class="b-box-body"><div class="b-s-share-love"><script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script><div id="gplus"><div class="g-plusone" data-size="medium"></div></div><div id="tw-share"><a href="http://twitter.com/share" class="twitter-share-button" data-count="none" data-text="Crosswords Ch. 01" data-url="http://www.literotica.com/s/crosswords-ch-01">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script></div><div class="secline"><div id="add-this"><a href="http://www.addthis.com/bookmark.php?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/share.gif" width="16" height="16" alt="Share"  /></a></div><div id="add-email"><a href="http://api.addthis.com/oexchange/0.8/forward/email/offer?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/email.gif" width="56" height="18" alt="Email"  /></a></div></div></div></div></div><div class="b-box"><div class="b-box-header"><h3>Report a Bug</h3></div><div class="b-box-body"><a href="/stories/quest/bugs.php?id=3&amp;url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01"><strong>Submit bug report</strong></a></div></div></div><div id="sbar-l-wrp"><div class="b-pager"><a class="b-pager-prev" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">Previous</a><a class="b-pager-next" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">Next</a><div class="b-pager-pages"><span class="b-pager-caption-t r-d45"><!-- x -->7 Pages:</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01">1</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">2</a><span class="b-pager-active">3</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">4</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=5">5</a><form action="http://www.literotica.com/s/crosswords-ch-01" method="get"><select name="page"><option value="1">1</option><option value="2">2</option><option value="3" class="current" selected="selected">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option></select><button type="submit" class="i-button i-button-mini" title="Go">Go</button></form></div></div><div class="big_link" id="b-bottom"><div class="block_id-c3RvcnlwYWdlOS1ib3R0b218MTI1fGJvdHRvbQ=="><!-- It\'s a Daddy Thing 4 -->href="http://www.literotica.com/stories/memberpage.php?uid=923141&amp;page=submissions">alwayswantedto</a></span><span class="b-story-copy">©</span>  <span class="b-story-stats">72 comments<span class="sep">/</span>  234608 views<span class="sep">/</span>  60 favorites</span></div><div class="b-sidebar"><div class="b-box"><div class="b-box-header"><h3>Share the love</h3></div><div class="b-box-body"><div class="b-s-share-love"><script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script><div id="gplus"><div class="g-plusone" data-size="medium"></div></div><div id="tw-share"><a href="http://twitter.com/share" class="twitter-share-button" data-count="none" data-text="Crosswords Ch. 01" data-url="http://www.literotica.com/s/crosswords-ch-01">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script></div><div class="secline"><div id="add-this"><a href="http://www.addthis.com/bookmark.php?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/share.gif" width="16" height="16" alt="Share"  /></a></div><div id="add-email"><a href="http://api.addthis.com/oexchange/0.8/forward/email/offer?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/email.gif" width="56" height="18" alt="Email"  /></a></div></div></div></div></div><div class="b-box"><div class="b-box-header"><h3>Report a Bug</h3></div><div class="b-box-body"><a href="/stories/quest/bugs.php?id=3&amp;url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01"><strong>Submit bug report</strong></a></div></div></div><div id="sbar-l-wrp"><div class="b-pager"><a class="b-pager-prev" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">Previous</a><a class="b-pager-next" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">Next</a><div class="b-pager-pages"><span class="b-pager-caption-t r-d45"><!-- x -->7 Pages:</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01">1</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">2</a><span class="b-pager-active">3</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">4</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=5">5</a><form action="http://www.literotica.com/s/crosswords-ch-01" method="get"><select name="page"><option value="1">1</option><option value="2">2</option><option value="3" class="current" selected="selected">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option></select><button type="submit" class="i-button i-button-mini" title="Go">Go</button></form></div></div><div class="big_link" id="b-bottom"><div class="block_id-c3RvcnlwYWdlOS1ib3R0b218MTI1fGJvdHRvbQ=="><!-- It\'s a Daddy Thing 4 -->href="http://www.literotica.com/stories/memberpage.php?uid=923141&amp;page=submissions">alwayswantedto</a></span><span class="b-story-copy">©</span>  <span class="b-story-stats">72 comments<span class="sep">/</span>  234608 views<span class="sep">/</span>  60 favorites</span></div><div class="b-sidebar"><div class="b-box"><div class="b-box-header"><h3>Share the love</h3></div><div class="b-box-body"><div class="b-s-share-love"><script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script><div id="gplus"><div class="g-plusone" data-size="medium"></div></div><div id="tw-share"><a href="http://twitter.com/share" class="twitter-share-button" data-count="none" data-text="Crosswords Ch. 01" data-url="http://www.literotica.com/s/crosswords-ch-01">Tweet</a><script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script></div><div class="secline"><div id="add-this"><a href="http://www.addthis.com/bookmark.php?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/share.gif" width="16" height="16" alt="Share"  /></a></div><div id="add-email"><a href="http://api.addthis.com/oexchange/0.8/forward/email/offer?url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01&amp;title=Send%20a%20story%20via%20email&amp;username=literotica" target="_blank"><img src="/imagesv2/email.gif" width="56" height="18" alt="Email"  /></a></div></div></div></div></div><div class="b-box"><div class="b-box-header"><h3>Report a Bug</h3></div><div class="b-box-body"><a href="/stories/quest/bugs.php?id=3&amp;url=http%3A%2F%2Fwww.literotica.com%2Fs%2Fcrosswords-ch-01"><strong>Submit bug report</strong></a></div></div></div><div id="sbar-l-wrp"><div class="b-pager"><a class="b-pager-prev" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">Previous</a><a class="b-pager-next" title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">Next</a><div class="b-pager-pages"><span class="b-pager-caption-t r-d45"><!-- x -->7 Pages:</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01">1</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">2</a><span class="b-pager-active">3</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">4</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=5">5</a><form action="http://www.literotica.com/s/crosswords-ch-01" method="get"><select name="page"><option value="1">1</option><option value="2">2</option><option value="3" class="current" selected="selected">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option></select><button type="submit" class="i-button i-button-mini" title="Go">Go</button></form></div></div><div class="big_link" id="b-bottom"><div class="block_id-c3RvcnlwYWdlOS1ib3R0b218MTI1fGJvdHRvbQ=="><!-- It\'s a Daddy Thing 4 -->ds Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">Next</a><div class="b-pager-pages"><span class="b-pager-caption-t r-d45"><!-- x -->7 Pages:</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01">1</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=2">2</a><span class="b-pager-active">3</span><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">4</a><a title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=5">5</a><form action="http://www.literotica.com/s/crosswords-ch-01" method="get"><select name="page"><option value="1">1</option><option value="2">2</option><option value="3" class="current" selected="selected">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option></select><button type="submit" class="i-button i-button-mini" title="Go">Go</button></form></div></div><div class="big_link" id="b-bottom"><div class="block_id-c3RvcnlwYWdlOS1ib3R0b218MTI1fGJvdHRvbQ=="><!-- It\'s a Daddy Thing 4 -->';
	
	# We want to extract: title="Crosswords Ch. 01 - Incest/Taboo" href="http://www.literotica.com/s/crosswords-ch-01?page=4">Next
	$lPos2 = index ($lRow, '">Next');
	if (  $lPos2 > -1 ) {
		my $lTemp = substr ($lRow, 0, $lPos2);		# Trim stuff off the right
		$lPos1 = rindex ($lTemp, 'href="');
		if ($lPos1 > -1) {
			$lTemp = substr($lTemp, $lPos1 + 6, $lPos2);
			print "URL = $lTemp\n";
		}
	}
	
	
}	# S_LinkExperiment


#-------------------------------------------------------------------------
#-------------------------------------------------------------------------
sub S_ScanLiterotica {

	# Try collecting the works of an author
	
	#&S_FetchLEAuthor (file => 'LE-AlwasyWantedTo.txt', 
	#	author_url => "http://www.literotica.com/stories/memberpage.php?uid=923141&page=submissions",
	#	author_name => 'AlwaysWantedTo'
	#	);
		
	#&S_FetchLEAuthor (file => 'LE-BackyardBottomslash.txt', 
	#	author_url => "http://www.literotica.com/stories/memberpage.php?uid=1063432&page=submissions",
	#	author_name => 'BackyardBottomslash'
	#	);
		
	#&S_FetchLEAuthor (file => 'LE-ScarletSlave.txt', 
	#	author_url => "http://www.literotica.com/stories/memberpage.php?uid=833962&page=submissions",
	#	author_name => 'ScarletSlave'
	#	);

	#&S_FetchLEAuthor (file => 'LE-Escriterra.txt', 
	#	author_url => "http://www.literotica.com/stories/memberpage.php?uid=1087454&page=submissions",
	#	author_name => 'Escriterra'
	#);
	
	

	&S_FetchLEAuthor (file => 'LE-Meddlesome.txt', 
		author_url => "http://www.literotica.com/stories/memberpage.php?uid=1279717&page=submissions",
		author_name => 'Meddlesome'
	);

	&S_FetchLEAuthor (file => 'LE-Patroc.txt', 
		author_url => "http://www.literotica.com/stories/memberpage.php?uid=359989&page=submissions",
		author_name => 'Patroc'
	);
	
	&S_FetchLEAuthor (file => 'LE-Dazzel1.txt', 
		author_url => "http://www.literotica.com/stories/memberpage.php?uid=1310871&page=submissions",
		author_name => 'Dazzel1'
	);
	
}	# S_ScanLiterotica

my %AUTHORS;

#-------------------------------------------------------------------------
# Routine:	S_ParseEbookName
# Description: 	This routine will take a ebook file name and attempt to parse out
#				the authors name, series, title, publisher and format.
#
# 				File names often look like these variations
# 				FirstName LastName - [Series] - title  [Publisher] (format)
# 				A A Aguirre - [Apparatus Infernum 01] - Bronze Gods (epub)
# 				Allyson Lindt - [Bits and Bytes 01] - Conflict of Interest [LSB] (epub)
# 				Anitra Lynn McLeod - [Seven Brothers for McBride 06] - Renner Morgan [Siren Everlasting Classic ManLove] (pdf)
#
#-------------------------------------------------------------------------
sub S_ParseEbookName {
	my ($aFile) = @_;
	my ($lAuthor, $lSeries, $lTitle, $lPublisher, $lFormat) = ("", "", "", "", "");
	my ($lFile, $lPart, $i);
	
	# The format epub, mobi, azw, pdf is the easiest to spot
	# Try to find it by removing the " (epub)" text to make
	# later parsing easier.
	
	$lFile = $aFile;
	
	$lFormat = 'epub' if ($lFile =~ s/ ?\(epub\)// );
	$lFormat = 'cbr'  if ($lFile =~ s/ ?\(cbr\)// ); 
	$lFormat = 'txt'  if ($lFile =~ s/ ?\(txt\)// ); 
	$lFormat = 'azw'  if ($lFile =~ s/ ?\(azw\)// ); 
	$lFormat = 'azw'  if ($lFile =~ s/ ?\(azw3\)// ); 
	$lFormat = 'html' if ($lFile =~ s/ ?\(html\)// ); 
	$lFormat = 'mobi' if ($lFile =~ s/ ?\(mobi\)// ); 
	$lFormat = 'pdf'  if ($lFile =~ s/ ?\(pdf\)//i ); 
	$lFormat = 'pdf'  if ($lFile =~ s/ ?\(sipdf\)//i ); 
	$lFormat = 'prc'  if ($lFile =~ s/ ?\(prc\)// ); 
	
	# If we have not decoded the type by the (something) in the file name, look at the .extension
	if ( $lFile =~ m/\.epub$/ ) {
		$lFormat = 'epub';
	}
	
	# Strip off the .epub, .rar, etc extension so it does not get sucked into some part
	$lFile =~ s/\.[^.]+$//;
	
	# Split the remaing text up by dash's so later parsing is simpler
	my @lTemp = split (' - ', $lFile);
	
	# Remove spaces from each end of the parts
	for ( $i = 0; $i < scalar (@lTemp); $i++ ) {
		$lTemp[$i] =~ s/^ +//;
		$lTemp[$i] =~ s/ +$//;
	}
	
	# Author is usually the first part
	$lAuthor = $lTemp[0];

	$AUTHORS{$lAuthor}++;
	# See if we can find the series incased in [] characters
	foreach $lPart ( @lTemp ) {
		if ( index ($lPart, '[') == 0 and rindex ($lPart, ']') > -1) {
			$lSeries = $lPart;
			#print "Series: $lSeries : $lFile\n";
		}
	}
	
	if ( $lSeries eq "" ) {
		#print "No Series: $lFile\n";
	}
	#print sprintf ("(%25s) : (%20s) : (%20s)\n", $lTemp[0], $lTemp[1], $lTemp[2]);
	
	return ($lAuthor, $lSeries, $lTitle, $lPublisher, $lFormat);
	
}	# S_ParseEbookName

#-------------------------------------------------------------------------
# Routine:		S_FlipTitleAuthor
# Description:	This routine takes a simple "title title title - fname lname.epub" file name
#				and returns a Batch file row that flips around to put author first
#
#-------------------------------------------------------------------------
sub S_FlipTitleAuthor {
	my ($aFile) = @_;
	my ($lCmd, $lPos, $lExt);
	$lCmd = "";
	
	# Remove the extension
	$lPos = rindex ($aFile, '.');
	$lExt = substr($aFile, $lPos, 6);
	$aFile = substr($aFile, 0, $lPos);
	#print "Ext: $lExt : $aFile\n";
	#return;
	if ( index ($aFile, '-') > -1 ) {
	
		my (@lTemp) = split ('-', $aFile);
		for ( my $i = 0; $i < scalar (@lTemp); $i++ ) {
			$lTemp[$i] =~ s/^ +//;
			$lTemp[$i] =~ s/ +$//;
		}
		if (scalar @lTemp == 2) {
			$lCmd = 'rename "' . $aFile . $lExt . '" "' . $lTemp[1] . ' - ' . $lTemp[0] . $lExt . '"';
			print "$lCmd\n";
		}
	}
	
}	# S_FlipTitleAuthor

#-------------------------------------------------------------------------
#-------------------------------------------------------------------------
sub S_EbookAuthors {
	my (%args) = @_;
	my (@lExtArray, $lExt, $lFile);
	my (%lAuthorHash, $lAuthor, $lCount);
	
	chdir ( $args{dir} ) or die ("Error: Could not reach directory: $args{dir} : $!\n");
	
	@lExtArray = ('*.epub', '*.mobi', '*.rar');
	
	foreach $lExt ( @lExtArray ) {
		print "Scanning for $lExt...\n";
		foreach $lFile ( sort glob ($lExt) ) {
			my ($lName, $lDir, $lSuffix) = fileparse($lFile);
			# Pattern FirstName LastName -
			# A A Aguirre - [Apparatus Infernum 01] - Bronze Gods (epub)
			# Allyson Lindt - [Bits and Bytes 01] - Conflict of Interest [LSB] (epub)
			# Anitra Lynn McLeod - [Seven Brothers for McBride 06] - Renner Morgan [Siren Everlasting Classic ManLove] (pdf)
			#&S_ParseEbookName( $lFile );
			
			&S_FlipTitleAuthor($lFile);
		}
	}
	
	foreach $lAuthor ( sort keys %AUTHORS ) {
		print sprintf ("%20s = %d\n", $lAuthor, $AUTHORS{$lAuthor});
	}
	
	
}	# S_EbookAuthors

#-------------------------------------------------------------------------
#-------------------------------------------------------------------------
sub S_PipersDomain {
	my (%args) = @_;
	my (@lLinkArray, $lURL, $lLetter);
	
	my $lMech = WWW::Mechanize->new(
		agent 		=> 'Mozilla/5.0',
		cookie_jar 	=> {}
	);
	$lMech->agent_alias( 'Windows IE 6' );

	my @lAut = qw (xax.html xbx.html);
	
	foreach $lLetter ( @lAut ) {
		$lURL = $args{base_url} . $lLetter;	# www.asstr.org/~Piper/
		
		print "Scanning URL: $lURL\n";
		$lMech->get ( $lURL );
		
		foreach my $lTemp ( $lMech->find_all_links( url_regex => qr/authors/ ) ) {
			print $lTemp->url_abs . "\n";
			push (@lLinkArray, $lTemp->url_abs);
		}
		# push (@lLinkArray, @{$lMech->find_all_links( url_regex => qr/authors/)} );
	}
	
	foreach $lURL ( @lLinkArray ) {
		print "$lURL\n";
	}
	
}	# S_PipersDomain

#-------------------------------------------------------------------------
# Routine:		ASSTRRecentUploads
#-------------------------------------------------------------------------
sub ASSTRRecentUploads {
	my ($lUtilObj);
	$lUtilObj = asstr->new();
	
	# Scan the 8 days of most recent uploads to get the YYYYMMDD value listing for them. These will be stored
	# in the object.
	
	$lUtilObj->RFFindRecent();
	
}	# ASSTRRecentUploads

#-------------------------------------------------------------------------
# Routine:		ASSTRFetchRecentUploads
#-------------------------------------------------------------------------
sub ASSTRFetchRecentUploads {
	my ($lUtilObj);
	$lUtilObj = asstr->new();
	$lUtilObj->RFCollectRecent();
	
}	# ASSTRFetchRecentUploads


#-------------------------------------------------------------------------
# PrintMenu2 - Prints the menu
#-------------------------------------------------------------------------
sub PrintMenu2 {

    print "=============================================\n";
    print "              EP Menu\n";
    print "              Utilitys\n";
    print "=============================================\n";
    print "Please choose an option:\n\n";
    print "\t1 - Scan Dirs\n";
    print "\t2 - Read StoriesOnLine\n";
    print "\t3 - \n";
    print "\t4 - BDSML Generate IndexFile\n";
    print "\t5 - BDSML Import Library\n";
    print "\t6 - Break apart big file\n";
    print "\t7 - BDSML Dedup new index file\n";
    print "\t8 - Fetch Literotica Author\n";
    print "\t9 - Experiment finding links\n";
    print "\t10 - ebook authors\n";
	print "\t11 - Pipers Domain\n";
	print "\t12 - ASSTR Recent Uploads\n";
	print "\t13 - ASSTR Fetch Recent Uploads\n";
    print "\n\n";
    print "\t\tChoice: ";

}  # PrintMenu2


#-------------------------------------------------------------------------
# Menu - Provides a menu for choices.  Returns the choice number.
#  If the choice requires a path, this routine will ask for it and
#  error check the path before returning.  The path will be stored
#  in $g_Path;
#-------------------------------------------------------------------------
sub S_GetChoice {

    local ($l_finished) = 0;
    local ($l_choice) = 0;

    while ( $l_finished == 0) {
        &PrintMenu2 ();

        chop ($l_choice = <STDIN>);

        if ( ($l_choice >= 0) && ($l_choice <= 20) ) {
            $l_finished = 1;
        }
    }
    $l_choice;

} # S_GetChoice


#----------------------------------------------------------
#  Main
#----------------------------------------------------------
sub main {
    my ($lChoice) = -1;
    my ($lFinished) = 0;

    # print "Hello World\n";
    # &FindSeries ("c:\\temp\\1\\dl");

    my ($lTemp) = $ARGV[0];
    if ( defined ($lTemp) and $lTemp != "" ) {
        $lChoice = $lTemp;
    }

    while ( $lFinished != 1 ) {

        if ( $lChoice == -1 ) {
            $lChoice = &S_GetChoice();
        }

        if ( $lChoice == "0" ) {
            $lFinished = 1;
        } elsif ($lChoice == "1") {
            &S_ScanDirs();
            $lFinished = 1;
        } elsif ($lChoice == "2") {
        	&S_ScanSOL();
            $lFinished = 1;
        } elsif ($lChoice == "3") {
            $lFinished = 1;
        } elsif ($lChoice == "4") {

        	&S_GenerateIndexFile(index_file => 'bdsml_20160710.idx');
        	$lFinished = 1;
        } elsif ($lChoice == "5") {
        	&S_ImportLibrary(index_file => 'bdsml_20160710_dedup.idx',
        		output_file => 'bd09.txt');
            $lFinished = 1;
        } elsif ($lChoice == "6") {
        	&S_BreakBigFile ( input_file => 'bd09.txt', file_prefix => 'bdsml09_', size => 16); 
        	&S_BreakBigFile ( input_file => 'bd09.txt', file_prefix => 'bdsml09_', size => 16); 
            $lFinished = 1;
        } elsif ($lChoice == "7") {
			&S_BDSMLDedup(new_file => 'bdsml_20160710.idx', 
				prev_file => 'bdsml_20160530.idx');
            $lFinished = 1;
        } elsif ($lChoice == "8") {
        	&S_ScanLiterotica();
            $lFinished = 1;
        } elsif ($lChoice == "9") {
        	&S_LinkExperiment();
            $lFinished = 1;
        } elsif ($lChoice == "10") {
        	&S_EbookAuthors( dir => 'D:\\Temp\\Agent\\alt.binaries.e-book');
            $lFinished = 1;
        } elsif ($lChoice == "11") {
			&S_PipersDomain ( base_url => 'http://www.asstr.org/~Piper/', index_file => 'pipers_index.dat');
            $lFinished = 1;
        } elsif ($lChoice == "12") {
			&ASSTRRecentUploads();
            $lFinished = 1;
        } elsif ($lChoice == "13") {
			&ASSTRFetchRecentUploads();
            $lFinished = 1;
        } elsif ($lChoice == "14") {
            $lFinished = 1;
        }
        $lChoice = -1;
    }


    my ($lRunTime) = time - $^T;

}

# End of main

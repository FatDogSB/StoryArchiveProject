#!/home/aruba/bin/gnu/isqlperl
# use Test::Harness;
# use DB_File;
# use strict 'untie';
# Initial revision
#
#


#use Image::ExifTool qw(:Public);
#use Dumper;
use File::Copy qw (move);

my $XHAMSTER_DATA_FILE = 'd:\\temp\\xhamster.dat';
my $XHAMSTER_DUPLICATE_DIR = 'c:\\upgrades\\Duplicate';
my %VIDEO_HASH = ();

my %gCatalog = ();

&main ();
exit (0);


#-------------------------------------------------------------------------
#-------------------------------------------------------------------------
sub S_ScanWMV {
	my (%args) = @_;
	my ($lPattern, @lFileList, $lFile, $lRowCount, $lFileInfo, $lKey);
	my ($lCmd, $lNewName, $lTitle, @lCmdArray);

	
	chdir ($args{path}) or die ("Error: could not chdir to directory: $args{path} : $!\n");
	
	foreach $lFile ( sort glob ($args{pattern}) ) {
		
		$lFileInfo = ImageInfo($lFile);
		if ( 0 ) {
		
			foreach $lKey ( sort keys %{$lFileInfo} ) {
				print "$lKey  = ${$lFileInfo}{$lKey}\n";
			}
		}
		$lTitle = ${$lFileInfo}{Title};
		$lNewName = "RedStripe-$lTitle-$lFile";
		#print sprintf ("%-12s : %s\n", $lFile, $lNewName);
		
		$lCmd = sprintf ("rename \"%s\"   \"%s\"", $lFile, $lNewName);
		push (@lCmdArray, $lCmd);
		#print "$lCmd";
		
		$lRowCount++;
		#last if ($lRowCount > 5);
	}
	
	open (BAT_FILE, ">fix_redstripe.bat") or die ("Error: Could not open file for output: fix_redstripe.bat : $!\n");
	foreach $lCmd ( @lCmdArray ) {
		print BAT_FILE "$lCmd\n";
	}
	close (BAT_FILE) or die ("Error: could not close batch file: $!\n");
	print "Batch file fix_redstripe.bat created\n";
}	# S_ScanWMV

#-------------------------------------------------------------------------
# Routine:		indexPosters
# Description:	This routine will take a directory and scan for video files
#				and extract the posters name that is usually the prefix on the
#				file name and put it into the parents hash
#
# Inputs:		hash - pointer to Hash
#				dir  - Diretory to scan
#-------------------------------------------------------------------------
sub indexPosters {
	my (%args) = @_;
	my (@lExtensionArray, $lFile, $lExt, $lPoster, $lKey);
	
	print "Scanning $args{dir} ...\n";
	@lExtensionArray = ('*.flv', '*.mov', '*.mp4');
	
	chdir ($args{dir}) or die ("Error: Could not chdir to directory: $args{dir} : $!\n");
	
	foreach $lExt ( @lExtensionArray ) {
		foreach $lFile ( sort glob ($lExt) ) {
			if ( index ($lFile , '-') > -1 ) {
				my @lTemp = split ('-', $lFile);
				$lKey = lc($lTemp[0]);

				${$args{hash}}{$lKey}{poster} = $lTemp[0];
				${$args{hash}}{$lKey}{count}++;
				${$args{hash}}{$lKey}{size} += -s $lFile;
				${$args{hash}}{$lKey}{title} .= "\t$lFile\n";
				
				# Add to our global hash
				my $lKey2 = uc ($lFile);
				if ( exists $VIDEO_HASH{$lKey2}{file_name} ) {
					print "Found duplicate: $args{dir} : $lFile\n";
				} else {				
					$VIDEO_HASH{$lKey2}{file_name} = $lFile;
					$VIDEO_HASH{$lKey2}{file_size} = ${$args{hash}}{$lKey}{size};
				}
				
			}
		}
	}


}	#indexPosters


#-------------------------------------------------------------------------
# Routine:		S_ReadIndexDatafile
# Description:	This routine will read the data file of previous video files
# 				into our global %VIDEO_HASH
# 
# Input:		file - name of data file
#-------------------------------------------------------------------------
sub S_ReadIndexDataFile {
	my (%args) = @_;
	my ($lRow, $lKey, $lFileName, $lSize, $lCount);

	%VIDEO_HASH = ();
	
	if ( -e $args{file} ) {
		print "Reading index file: $args{file}...\n";
		open (INDEX_FILE, $args{file}) or die ("Error: Could not open index file: $args{file} : $!\n");
		while ($lRow = <INDEX_FILE>) {
			chomp ($lRow);
			my ($lFileName, $lSize) = split (/\|/, $lRow);
			$lKey = uc($lFileName);
			
			$VIDEO_HASH{$lKey}{file_name} = $lFileName;
			$VIDEO_HASH{$lKey}{file_size} = $lSize;
			$lCount++;
		}
		close (INDEX_FILE);
		print "Rows read: $lCount\n";
	}

}	# S_ReadIndexDatafile

#-------------------------------------------------------------------------
#-------------------------------------------------------------------------
sub S_WriteIndexDataFile {
	my (%args) = @_;
	my ($lKey, $lFileName, $lSize, $lRow);
	
	open (INDEX_FILE, ">$args{file}") or die ("Error: Could not open file for output: $args{file} : $!\n");
	foreach $lKey ( sort keys %VIDEO_HASH ) {
		$lFileName = $VIDEO_HASH{$lKey}{file_name};
		$lSize     = $VIDEO_HASH{$lKey}{file_size};
		$lRow = "$lFileName|$lSize";
		print INDEX_FILE "$lRow\n";
	}
	
	close (INDEX_FILE) or die ("Error: could not close output file: $args{file} : $!\n");
	
	print "Output file created: $args{file}\n";
	
}	# S_WriteIndexDataFile

#-------------------------------------------------------------------------
# Routine:		S_IndexPosters
# Description:	Will add files to our global xhamster.dat file so we can
#				de-dupe later files.
#-------------------------------------------------------------------------
sub S_IndexPosters {
	my ($lKey, $lTotalSize);
	my %lPosterHash = ();

	# First - fill the %VIDEO_HASH with the contents of xhamster.dat that we have already
	# indexed.
	&S_ReadIndexDataFile ( file => $XHAMSTER_DATA_FILE); 
	
	#	&indexPosters(hash => \%lPosterHash, dir => "c:\\upgrades");
	if ( 1 ) {
	#&indexPosters(hash => \%lPosterHash, dir => "D:\\Temp\\1\\1xHamster");
	#&indexPosters(hash => \%lPosterHash, dir => "D:\\1\\AVI-BD-610-DONE");
	#&indexPosters(hash => \%lPosterHash, dir => "D:\\1\\AVI-BD-609-DONE");
	&indexPosters(hash => \%lPosterHash, dir => "D:\\1\\AVI-BD-652-DONE");
	}
	
	foreach $lKey ( sort keys %lPosterHash ) {
		#print sprintf ("%25s = %d files\n", $lPosterHash{$lKey}{poster}, $lPosterHash{$lKey}{count});
		
		#print sprintf ("%-25s = %s \n", $lPosterHash{$lKey}{poster}, $lPosterHash{$lKey}{title});
		
		$lTotalSize += $lPosterHash{$lKey}{size};
	}
	
	my $lMegs = int ($lTotalSize / (1024 * 1024));
	print "Total Megs: $lMegs\n";
	
	&S_WriteIndexDataFile ( file => $XHAMSTER_DATA_FILE); 
	
	
}	# S_IndexPosters

#-------------------------------------------------------------------------
#-------------------------------------------------------------------------
sub S_LookForDuplicates {
	my (%args) = @_;
	my ($lFileCount, $lDuplicateCount, $lNewName);

	# First - fill the %VIDEO_HASH with the contents of xhamster.dat that we have already
	# indexed.
	&S_ReadIndexDataFile ( file => $XHAMSTER_DATA_FILE); 

	
	print "Scanning $args{dir} ...\n";
	@lExtensionArray = ('*.flv', '*.mov', '*.mp4');
	
	chdir ($args{dir}) or die ("Error: Could not chdir to directory: $args{dir} : $!\n");
	
	foreach $lExt ( @lExtensionArray ) {
		foreach $lFile ( sort glob ($lExt) ) {
			if ( index ($lFile , '-') > -1 ) {
				$lFileCount++;
				my $lKey = uc ($lFile);
				
				if ( exists $VIDEO_HASH{$lKey}{file_name} ) {
					print "Found duplicate: $args{dir} : $lFile\n";
					$lDuplicateCount++;
					$lNewName = $XHAMSTER_DUPLICATE_DIR . "\\$lFile";
					print "\t $lFile : $lNewName\n";
					move ($lFile, $lNewName) or die ("Error: Could not move $lFile to $lNewName : $!\n");
				}
				
			}
		}
	}
	
	print "Total Files found: $lFileCount\n";
	print "Duplicate Files:   $lDuplicateCount\n";
	
}	# S_LookForDuplicates
	


#-------------------------------------------------------------------------
#-------------------------------------------------------------------------
sub S_CreateKey {
	my ($lFile) = @_;
	my ($lFirstChar);
	return ('par') if ( index ($lFile, '.PAR2') > -1 );
	return ('par') if ( index ($lFile, '.par2') > -1 );
	
	$lFirstChar = uc (substr($lFile, 0, 1));
	return ("0") if ( $lFirstChar =~ m/[0-9]/ );
	return ($lFirstChar);
	
}	# S_CreateKey
	
#-------------------------------------------------------------------------
# Routine:		S_DivideEpubFiles
# Description:	Scan contents of a dir full of files and create a batch file
#				to create sub-directories to put about 2,000 files in each
# 				trying to divide up the count evenly
#-------------------------------------------------------------------------
sub S_DivideEpubFiles {
	my (%args) = @_;
	my ($lFile, %lCountHash, $lKey, $lLimit, $lDir);
	my ($lSubTotal, $lTotal) = (0, 0);
	
	chdir ($args{source_dir}) or die ("Error: Could not cd to source_dir: $args{source_dir} : $!\n");
	print "Scanning $args{source_dir} ...";
	
	# Create a hash where every file has a key and the hash counts things like:
	# $lCountHash{par} = nn		-- Number of files ending in .par, ,par2
	# $lCountHash{0}   = nn		-- Number of files starting with 0-9
	# $lCountHash{A}   = nn		-- Number of files starting with A
	# ...
	#
	foreach $lFile ( sort glob "*.*" ) {
		$lKey = &S_CreateKey ($lFile);
		
		$lCountHash{$lKey}++;
		$lTotal++;
	}
	
	# Report
	foreach $lKey ( sort keys %lCountHash ) {
		print sprintf ("%-3s = %5d\n", $lKey, $lCountHash{$lKey});
	}
	
	
	# Calculate a limit value
	
	$lLimit = int($lTotal/7);
	
	print "Total Files: $lTotal\n";
	print "Limit per dir: $lLimit\n";	
	
	my %lBucketHash;
	my $lCurrentBucket = 0;
	
	# Fill the Bucket Hash like this:
	my $lCurrentBucket = 0;
	my ($lSubTotal, $lTotal) = (0, 0);
	foreach $lKey ( sort keys %lCountHash ) {
		next if ($lKey eq 'par');
		
		# Decide if the files beginning with "J" go into this bucket or the next
		if ( $lSubTotal + $lCountHash{$lKey} < $lLimit ) {
			$lSubTotal += $lCountHash{$lKey};
			$lBucketHash{$lCurrentBucket}{prefix} .= "|" . $lKey;
			$lBucketHash{$lCurrentBucket}{size}   += $lCountHash{$lKey}; 
		} else {
			# Need to start a new bucket
			$lCurrentBucket++;
			$lSubTotal = 0;
			
			$lSubTotal += $lCountHash{$lKey};
			$lBucketHash{$lCurrentBucket}{prefix} .= "|" . $lKey;
			$lBucketHash{$lCurrentBucket}{size}   += $lCountHash{$lKey}; 
			
		}
		
	}

	# Calculate the name of the sub-directory for each bucket
	foreach $lKey (sort keys %lBucketHash) {
		# Trim the leading pipe from each key
		$lBucketHash{$lKey}{prefix} =~ s/^\|//;
		
		# Trim the ending |_ if it exists
		$lBucketHash{$lKey}{prefix} =~ s/\|\_//;
		
		if ( $lBucketHash{$lKey}{prefix} =~ m/^(\w).*(\w)$/ ) {
			$lDir = "$1-$2";
			$lBucketHash{$lKey}{dir} = $lDir;
		}
	}	
	
	# Report
	foreach $lKey (sort keys %lBucketHash) {
		print sprintf ("Key: %1s   Count: %-4d   Prefix: %-10s   Dir: %3s\n", 
			$lKey, $lBucketHash{$lKey}{size}, $lBucketHash{$lKey}{prefix}, $lBucketHash{$lKey}{dir});
	}
	
	# Create rows for the batch file
	
	my @lBatchArray = ();
	push (@lBatchArray, "cd $args{source_dir}");
	push (@lBatchArray, "mkdir PAR");
	push (@lBatchArray, "move *.par2 PAR");
	foreach $lKey (sort keys %lBucketHash) {
		$lDir = $lBucketHash{$lKey}{dir};
		my $lCmd = "mkdir $lBucketHash{$lKey}{dir}";
		push (@lBatchArray, $lCmd);
		
		# The prefix field look like: "0|A|B" or "N|O|P|Q|R"
		my $lPrefix;
		foreach $lPrefix ( split (/\|/, $lBucketHash{$lKey}{prefix} ) ) {
			push (@lBatchArray, "move ${lPrefix}*.* $lDir");
			
			if ( $lPrefix eq "0" ) {
				my $i;
				for ($i = 1; $i < 10; $i++) {
					push (@lBatchArray, "move ${i}*.* $lDir");
				}
			}
		}
	}

	open (BATCH_FILE, ">$args{batch_file}") or die ("Error: Could not open file for output: $args{batch_file} : $!\n");
	foreach $lKey ( @lBatchArray ) {
		print "$lKey\n";
		print BATCH_FILE "$lKey\n";
	}
	close (BATCH_FILE) or die ("Error: Could not close output file: $args{batch_file} : $!\n");
	
	print "Batch file created: $args{batch_file}\n";
	
}	# S_DivideEpubFiles


#-------------------------------------------------------------------------
# Routine:		S_DivideEpubFiles
# Description:	Scan contents of a dir full of files and create a batch file
#				to create sub-directories to put about 2,000 files in each
# 				trying to divide up the count evenly
#-------------------------------------------------------------------------
sub S_DivideEpubFiles2 {
	my (%args) = @_;
	my ($lFile, %lCountHash, $lKey, $lLimit, $lDirCount, $lDir);
	my ($lSubTotal, $lTotal) = (0, 0);
	
	chdir ($args{source_dir}) or die ("Error: Could not cd to source_dir: $args{source_dir} : $!\n");
	print "Scanning $args{source_dir} ...";
	
	# Create a hash where every file has a key and the hash counts things like:
	# $lCountHash{par} = nn		-- Number of files ending in .par, ,par2
	# $lCountHash{0}   = nn		-- Number of files starting with 0-9
	# $lCountHash{A}   = nn		-- Number of files starting with A
	# ...
	#

	open (BATCH_FILE, ">$args{batch_file}") or die ("Error: Could not open file for output: $args{batch_file} : $!\n");
	print BATCH_FILE "cd $args{source_dir}\n"; 	
	print BATCH_FILE "mkdir PAR\n";
	print BATCH_FILE "move /Y *.par2 PAR\n";

	$lDirCount = 1;
	$lDir = sprintf ("Part%02d", $lDirCount);
	print BATCH_FILE "mkdir $lDir\n";
	$lSubTotal = 0;
	foreach $lFile ( sort glob "*.*" ) {
		print BATCH_FILE "move /Y \"$lFile\" $lDir\n";
		$lSubTotal++;
		
		if ( $lSubTotal > $args{limit} ) {
			$lDirCount++;
			$lDir = sprintf ("Part%02d", $lDirCount);
			print BATCH_FILE "\nmkdir $lDir\n";
			$lSubTotal = 0;
		}
	}
	close (BATCH_FILE) or die ("Error: Could not close output file: $args{batch_file} : $!\n");
	
	print "Batch file created: $args{batch_file}\n";
	
}	# S_DivideEpubFiles2

#-------------------------------------------------------------------------
# Routine:		S_RenameEpubs
# Description:	This routine will attempt to find epub files with authors
#				names at the end and create a batch file to re-name the
#				files with the authors name at the beginning
#
#				What the Night Knows - Dean Koontz.mobi
#				Dean Koontz - What the Night Knows.mobi
#				
#-------------------------------------------------------------------------
sub S_RenameEpubs {
	my (%args) = @_;
	my ($lFile, $lNewFile, $lExt, @lResults);
	
	my @lExtensions = qw (.epub .mobi .pdf);
	chdir ($args{dir}) or die ("Error: Could not chdir to ebook dir: $args{dir} : $!\n");
	
	foreach $lExt ( sort @lExtensions ) {
		foreach $lFile ( sort glob ("*$lExt") ) {
			# Pattern:  " - First Last.epub"
			if ( $lFile =~ m/ \- (\w+) (\w+)$lExt/ ) {
				$lNewFile = $lFile;
				$lNewFile =~ s/ \- (\w+) (\w+)$lExt/$lExt/;		# Strip off author from end
				$lNewFile = "$1 $2 - " . $lNewFile;				# Put Author at beginning
				push (@lResults, "$lNewFile|$lFile");			# Put NewFile|OldFile into array
			} elsif ( $lFile =~ m/ (\w+) (\w\.) (\w+)$lExt/ ) {
				# Pattern:  " - First M. Last.epub
				$lNewFile = $lFile;
				$lNewFile =~ s/ \- (\w+) (\w\.) (\w+)$lExt/$lExt/;
				$lNewFile = "$1 $2 $3 - " . $lNewFile;
				push (@lResults, "$lNewFile|$lFile");			# Put NewFile|OldFile into array								
			}
		}
	}
	
	my $lBatchFile = $args{batch_file};
	# Now create the batch file
	open (BAT_FILE, ">$lBatchFile") or die ("Error: Could not open batch file: $lBatchFile : $!\n");
	foreach my $lRow (sort @lResults) {
		my ($lNName, $lOldName) = split (/\|/, $lRow);
		$lOldName = '"' . $lOldName . '"';
		$lNName  = '"' . $lNName   . '"';
		print BAT_FILE sprintf ("rename %-60s\t\t\%-60s\n", $lOldName, $lNName);
	}
	close (BAT_FILE) or die ("Error: Could not close output file: $lBatchFile : $!\n");
	
	print "output file created: $lBatchFile\n";
	
	
}	# S_RenameEpubs


#-------------------------------------------------------------------------
# Routine:		S_CleanCatalogRow
# Description:	This routine will take a ebook file name and strip off some of the
#				extra info text
#
# Example:		Allison Brennan - [Predator 01] - The Prey (v5.0) (mobi).rar
#				Allison Brennan - [Predator 01] - The Prey.rar
#-------------------------------------------------------------------------
sub S_CleanCatalogRow {
	my ($aRow) = @_;
	
	$aRow =~ s/ \(mobi\)// if ( index ($aRow, '(mobi)') > -1 );
	$aRow =~ s/ \(epub\)// if ( index ($aRow, '(epub)') > -1 );
	$aRow =~ s/ \[epub\]// if ( index ($aRow, '[epub]') > -1 );
	$aRow =~ s/ \(html\)// if ( index ($aRow, '(html)') > -1 );
	$aRow =~ s/ \(azw3\)// if ( index ($aRow, '(azw3)') > -1 );
	$aRow =~ s/ \(siPDF\)// if ( index ($aRow, '(siPDF)') > -1 );
	$aRow =~ s/ \(PDF\)//   if ( index ($aRow, '(PDF)') > -1 );
	$aRow =~ s/ \(retail\)//   if ( index ($aRow, '(retail)') > -1 );
	
	# Look for version number: (v5.0);
	$aRow =~ s/ \(v\d+\.\d+\)//g;

	# Look for (v5)
	$aRow =~ s/ \(v\d+\)//g;
	
	
	# Strip off .rar ending
	$aRow =~ s/\.rar//   if ( index ($aRow, '.rar') > -1 );
	$aRow =~ s/\.epub//   if ( index ($aRow, '.epub') > -1 );
	$aRow =~ s/\.mobi//   if ( index ($aRow, '.mobi') > -1 );
	$aRow =~ s/\.azw3//   if ( index ($aRow, '.azw3') > -1 );
	$aRow =~ s/\.pdf//   if ( index ($aRow, '.pdf') > -1 );
	$aRow =~ s/\.PDF//   if ( index ($aRow, '.PDF') > -1 );
	
	# Strip trailing spaces
	$aRow =~ s/ +$//;
	
	return ( $aRow );
	
}	# S_CleanCatalogRow

#-------------------------------------------------------------------------
# Routine:		S_ParseCatalogRow
# Description:	This routine will take a row from the WinRAR catalog file
#				and it will attempt to parse out the author and title.
#
#-------------------------------------------------------------------------
sub S_ParseCatalogRow {
	my (%args) = @_;
	my ($lRow, $lAuthor, $lTitle);
	my ($lCRC, $lFileName, $lRow2);
	
	($lAuthor, $lTitle) = ("", "");
	$lRow = $args{row};
	
	# Some rows look like this:
	# 5139b088  raw-06\Alexander Kent - [Bolitho 04] - Sloop of War (UC) (epub).rar
	
	if ( index ( $lRow, '\\' ) > -1 ) {
		# Split on the back-slash to strip off the prefix
		my @lTemp  = split (/\\/, $lRow);
		# We want the last part of the string to handle:
		# raw-01\Alexis Summers - Seduction.rar
		# raw-04\Part01\Alexis Summers - Seduction by Song [MF] (epub).rar
		
		$lRow = pop (@lTemp);
		#print "$lRow\n";
	}
	
	# Preserve the file name
	$lFileName = $lRow;
	
	# Call a routine to remove the typical info like "(retail)" (v5.0), (epub) etc.
	$lRow2 = &S_CleanCatalogRow ( $lRow );
	
	# Report on changes
	if ( 0 ) {
		if ($lRow2 ne $lRow) {
			print "$lRow\n$lRow2\n";
			<STDIN>;
		}
	}
	
	$lRow = $lRow2;
	
	# Replace double spaces with single spaces
	$lRow =~ s/  / /g if ( index ($lRow, "  ") > -1 );
	
	# Look for X X Johnson
	# H D Thomson - [Shrouded 01] - Shrouded in Darkness
	
	if ( $lRow =~ m/^(\w \w \w+) \- (.*)/ ) {
		$lAuthor = $1;
		$lTitle = $2;
		
		if ( 0 ) {
			print "$lRow\n($lAuthor) ($lTitle)\n";
			<STDIN>;
		}
		return ($lAuthor, $lTitle);
	}
	
	# Look for: Dee J Adams - [Adrenaline Highs 02] - Danger Zone [Carina] (v4.0) (epub)
	# Kevin J. Anderson - Clockwork Angels
	
	if ( $lRow =~ m/^(\w+ \w\.? \w+) \- (.*)/ ) {
		$lAuthor = $1;
		$lTitle = $2;
		
		if ( 0 ) {
			print "$lRow\n($lAuthor) ($lTitle)\n";
			<STDIN>;
		}
		return ($lAuthor, $lTitle);
	}
	
	# Look for: 
	
	# Look for fname lname - style
	# Deirdre Savoy - [Body 02] - Body of Lies

	if ( $lRow =~ m/^(\w+ \w+) \- (.*)/ ) {
		$lAuthor = $1;
		$lTitle = $2;
		
		if ( 0 ) {
			print "$lRow\n($lAuthor) ($lTitle)\n";
			<STDIN>;
		}
		return ($lAuthor, $lTitle);
	}

	# Look for John O'Mally - style
	
	if ( $lRow =~ m/^(\w+ \w+\'\w+) \- (.*)/ ) {
		$lAuthor = $1;
		$lTitle = $2;
		
		if ( 0 ) {
			print "$lRow\n($lAuthor) ($lTitle)\n";
			<STDIN>;
		}
		return ($lAuthor, $lTitle);
	}
	
	# Look for fname middle lname - style
	if ( $lRow =~ m/^(\w+ \w+ \w+) \- (.*)/ ) {
		$lAuthor = $1;
		$lTitle = $2;
		
		if ( 0 ) {
			print "$lRow\n($lAuthor) ($lTitle)\n";
			<STDIN>;
		}
		return ($lAuthor, $lTitle);
	}
	
	# Look for Caroly McCray & Ben Hopkins - style
	
	if ( $lRow =~ m/^(\w+ \w+ \& \w+ \w+) \- (.*)/ ) {
		$lAuthor = $1;
		$lTitle = $2;
		
		if ( 0 ) {
			print "$lRow\n($lAuthor) ($lTitle)\n";
			<STDIN>;
		}
		return ($lAuthor, $lTitle);
	}
	
	
	
	# Look for "lname, fname - " style
	if ( $lRow =~ m/^(\w+)\, (\w+) \- (.*)/ ) {
		$lAuthor = "$2 $1";
		$lTitle = $3;
		
		if ( 0 ) {
			print "$lRow\n($lAuthor) ($lTitle)\n";
			<STDIN>;
		}
		return ($lAuthor, $lTitle);
	}
	
	# And look for Lname, fname middle
	# Blatty, William Peter - Exorcist
	
	if ( $lRow =~ m/^(\w+)\, (\w+) (\w+) \- (.*)/ ) {
		$lAuthor = "$2 $3 $1";
		$lTitle = $4;
		
		if ( 0 ) {
			print "$lRow\n($lAuthor) ($lTitle)\n";
			<STDIN>;
		}
		return ($lAuthor, $lTitle);
	}

	# Look for Lname, F M - style:
	if ( $lRow =~ m/^(\w+)\, (\w)\.? (\w)\.? \- (.*)/ ) {
		$lAuthor = "$2 $1";
		$lTitle = $3;
		
		if ( 0 ) {
			print "$lRow\n($lAuthor) ($lTitle)\n";
			<STDIN>;
		}
		return ($lAuthor, $lTitle);
	}
	
	
	
	# Default: Look for "something something - something" and split on the " - " sequence
	if ( index ($lRow, " - ") > -1 ) {
		my @lTemp = split (' - ', $lRow);
		$lAuthor = $lTemp[0];
		$lTitle  = $lTemp[1];
		$lTitle .= ' ' . $lTemp[2] if (defined $lTemp[2]);
		$lTitle .= ' ' . $lTemp[3] if (defined $lTemp[3]);

		if ( 0 ) {
			print "Default: $lRow\nAuthor: ($lAuthor)\nTitle:  ($lTitle)\n";
			<STDIN>;
		}

		return ($lAuthor, $lTitle);

	}

	# We could be seeing something that does not follow the pattern like:
	# Price, Kalayna -Alex Craft 1-
	# Peters, Ellis -Cadfael 05- Leper of Saint Giles
	# Fleming, Ian -Bond 01- Casino Royale
	# Put a space after the first dash and do a recursive call
	
	if ( $lRow =~ m/ \-\w/ ) {
		$lRow =~ s/ \-(\w)/ \- $1/;
		($lAuthor, $lTitle) = &S_ParseCatalogRow( row => $lRow );
		
		if ( 0 ) {
			print "Recursive: $lRow\nAuthor: ($lAuthor)\nTitle:  ($lTitle)\n";
			<STDIN>;
		}
		return ($lAuthor, $lTitle);
		
	}
	
	
	
	# If we get here - we have not parsed the row
	
	if ( 0 ) {
		print "Unk: $lRow\n";
		<STDIN>;
	}
	
	# Make the author unknown and the entire file name the title
	
	$lAuthor = "unk";
	$lTitle = $lRow;
		
	
	return ($lAuthor, $lTitle);
	
}	# S_ParseCatalogRow


#-------------------------------------------------------------------------
# Routine:		S_ParseRARReport
# Description:	This routine will take a .txt file name of ebook files
#				generated from winRAR and attempt to extract the epub
#				authors, titles and volume name.
#
# Input:		catalog_file - name of file to read
#				volume - string like "raw-03" to indicate what volume contains the files from the catalog
#
#-------------------------------------------------------------------------
sub S_ParseRARReport {
	my (%args) = @_;
	my ($lFile, $lRow, $lAuthor, $lTitle, $lKey);
	my %lCat = ();
	
	if ( ! -e $args{catalog_file} ) {
		print "Error: catalog file does not exist: $args{catalog_file}\n";
		return;
	}
	
	&MessageLog (0, "Reading catalog file: $args{catalog_file}...");
	
	$lFile = $args{catalog_file};
	open (CAT_FILE, $lFile ) or die ("Error: Could not open file for input: $lFile : $!\n");
	while ($lRow = <CAT_FILE>) {
		chomp ($lRow);
		
		
		# Only look for epub files
		next unless  ( index ($lRow, 'epub') > -1 );
		
		my ($lAuthor, $lTitle) = &S_ParseCatalogRow ( row => $lRow );
		
		# Construct a key of Author|Title
		$lKey = uc($lAuthor);		# Make author name upper case
		$lKey =~ s/[^A-Z]//g;		# Strip spaces, punctation, etc
		$lKey .= "|$lTitle";		# Add title
		
		if ( exists $gCatalog{$lKey}{author} ) {
			print "Dupe found: $lKey\n";
			next;
		}
		
		$gCatalog{$lKey}{author} = $lAuthor;
		$gCatalog{$lKey}{title} = $lTitle;
		$gCatalog{$lKey}{volume} = $args{volume};
		
	}	
	
	close (CAT_FILE);
	
	
}	# S_ParseRARReport


#-------------------------------------------------------------------------
#-------------------------------------------------------------------------
sub S_ReportCatalog {
	my ($lKey, $lRow);
	
	foreach $lKey ( sort keys %gCatalog ) {
		$lRow = sprintf ("Author: %-30s Title: %-50s Vol: %-6s\n", 
			substr ($gCatalog{$lKey}{author}, 0, 30), 
			substr ($gCatalog{$lKey}{title}, 0, 50),
			$gCatalog{$lKey}{volume}
		);
	print "$lRow";
	}
}	# S_ReportCatalog


#-------------------------------------------------------------------------
# Routine:		S_GenEbookCatalog
# Description:	Will look for particular ebook catalog.txt files and parse them
#				to create a master index by author
#
# Inputs:		dir - path to where the catalog.txt files live
#				file - Name of output file to create
#-------------------------------------------------------------------------
sub S_GenEbookCatalog {
	my (%args) = @_;
	
	chdir ( $args{dir} ) or die ("Error: Could not chdir to directory: $arg{dir} : $!\n");
	
	# Hard code some file names for now
	
	&S_ParseRARReport( catalog_file => 'raw-06-catalog.txt', volume => 'raw-06');
	&S_ParseRARReport( catalog_file => 'raw-05-catalog.txt', volume => 'raw-05');
	&S_ParseRARReport( catalog_file => 'raw-04-catalog.txt', volume => 'raw-04');
	&S_ParseRARReport( catalog_file => 'raw-03-catalog.txt', volume => 'raw-03');
	&S_ParseRARReport( catalog_file => 'raw-02-catalog.txt', volume => 'raw-02');
	&S_ParseRARReport( catalog_file => 'raw-01-catalog.txt', volume => 'raw-01');

	&S_ReportCatalog();
}	# S_GenEbookCatalog


#-------------------------------------------------------------------------
#-------------------------------------------------------------------------
sub MessageLog {
	my ($aLevel, $aMessage) = @_;
	
	print "$aMessage\n";
	
}	# MessageLog 

#-------------------------------------------------------------------------
# PrintMenu2 - Prints the menu
#-------------------------------------------------------------------------
sub PrintMenu2 {

    print "=============================================\n";
    print "              xHamster Menu\n";
    print "             Site Utilitys\n";
    print "=============================================\n";
    print "Please choose an option:\n\n";
    print "\t1 - Add to xhamster.dat\n";
    print "\t2 - Look for duplicates in c:\\upgrades\n";
    print "\t3 - \n";
    print "\t4 - \n";
    print "\t5 - Divide up epub-05\n";
    print "\t6 - Generate Ebook Catalog\n";
    print "\t7 - \n";
    print "\t8 - Rename Epubs\n";
    print "\t9 - \n";
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

        if ( ($l_choice >= 0) && ($l_choice < 10) ) {
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
        	&S_IndexPosters();
        } elsif ($lChoice == "2") {
			&S_LookForDuplicates ( dir => "c:\\upgrades" );
            $lFinished = 1;
        } elsif ($lChoice == "3") {
            &S_TestAuthorFileList();
            $lFinished = 1;
        } elsif ($lChoice == "4") {
            $lFinished = 1;
        } elsif ($lChoice == "5") {
            #&S_DivideEpubFiles (source_dir => "c:\\1\\avi\\ebook\\raw-04", batch_file => "c:\\1\\avi\\ebook\\sort04.bat"); 
            &S_DivideEpubFiles2 (limit => 1900, source_dir => "c:\\1\\avi\\ebook\\raw-05", batch_file => "c:\\1\\avi\\ebook\\sort05.bat"); 
            $lFinished = 1;
        } elsif ($lChoice == "6") {
        	&S_GenEbookCatalog (dir => "c:\\1\\AVI\\ebook", file => "c:\\1\\AVI\\ebook\\catalog_master.txt");
            $lFinished = 1;
        } elsif ($lChoice == "7") {
            $lFinished = 1;
        } elsif ($lChoice == "8") {
        	&S_RenameEpubs ( dir => "d:\\temp\\agent\\alt.binaries.e-book", batch_file => "fix.bat");
            $lFinished = 1;
        } elsif ($lChoice == "9") {
            $lFinished = 1;
        } elsif ($lChoice == "10") {
            $lFinished = 1;
        } elsif ($lChoice == "11") {
            $lFinished = 1;
        } elsif ($lChoice == "12") {
            $lFinished = 1;
        } elsif ($lChoice == "13") {
            $lFinished = 1;
        } elsif ($lChoice == "14") {
            $lFinished = 1;
        }
        $lChoice = -1;
    }


    my ($lRunTime) = time - $^T;

}

# End of main

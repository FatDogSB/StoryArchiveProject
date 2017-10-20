
#!/home/aruba/bin/gnu/isqlperl
# use Test::Harness;
# use DB_File;
# use strict 'untie';
# Initial revision
#
#

use LWP::UserAgent;
use WWW::Mechanize;
use File::Basename;

my $gBASE_DIR='d:\\temp\\1\\agent\\alt.binaries.e-book';
my $gBuffer = "";

my %gEbookHash;
my $gCount = 0;

&main ();
exit (0);


#-------------------------------------------------------------------------
# Routine:		S_ScanDirs
#-------------------------------------------------------------------------
sub findFiles {
	my (%args) = @_;
	my ($lBaseDir);
	my ($lDirName, $lFile, $lFullPath, $lCmd, $lNewName, $lCount);
	
	$lBaseDir = $args{dir};
	chdir ($lBaseDir) or die ("Error: Could not chdir to : $lBaseDir : $!\n");
	
	# Now we should see a bunch of sub-dirs like 
	# clip
	$lCount = 1;
	print "Looking in $lBaseDir\n";
	foreach $lDirName ( sort glob "*" ) {
		print "\t\t$lDirName\n";
		
		# Use this dir name as the file name
		$lNewName = "RedAss-" . $lDirName . "_$lCount.mpg";
		$lCount++;
		print "New name: $NewName\n";

		$lCmd = "copy \"$lFullPath\\$lDirName\"                  \"$gBASE_DIR${lNewName}\"";
		$gBuffer .= $lCmd . "\n";
		
		next;
		chdir ($lDirName);
		$lFullPath = $lBaseDir . '\\' . $lDirName;
		
		foreach $lFile ( glob ("*.mpg") ) {
		
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
	foreach $lDir ( sort glob "*") {
		print "Found dir: $lDir\n";
		next if (index ($lDir, '.bat') > -1);
		push (@lDirList, $lDir);
		
		&findFiles( dir => $gBASE_DIR . $lDir );
	}
	
	# Create output batch file
	chdir ($gBASE_DIR);
	my $lBatchFileName = $gBASE_DIR . "ep_copy.bat";
	open (BATCH_FILE, ">$lBatchFileName");
	print BATCH_FILE $gBuffer . "\n";
	close (BATCH_FILE);
	
	print "Batch file created: $lBatchFileName\n";
	
}	# S_ScanDirs


#-------------------------------------------------------------------------
#-------------------------------------------------------------------------
sub S_DedupEpub {
	my ($lCatalogDir, $lEpubDir, $lDupDir) = ('D:\1\ebook', 'D:\temp\agent\alt.binaries.e-book', 'D:\temp\agent\alt.binaries.e-book\duplicate');
	my (%lFileHash, $lFile, $lFileCount, $lRow, $lFileName, $lDupCount);
	
	if ( ! -e $lCatalogDir ) {
		print "Environment Error: catalog dir does not exist: $lCatalogDir\n";
		return;
	}

	if ( ! -e $lEpubDir ) {
		print "Environment Error: epub dir does not exist: $lCatalogDir\n";
		return;
	}

	# Get a list of all the current .rar files
	print "Scanning for download ebook .rar files ...\n";
	chdir ($lEpubDir) or die ("Error: Could not chdir to epub dir: $lEpubDir : $!\n");
	foreach $lFile ( glob ("*.*") ) {
		$lFileHash{$lFile} = 1;
		$lFileCount++;
	}
	
	print sprintf ("Total epub files found: $lFileCount\n");
	
	# Now go read the various catalog.txt files
	
	chdir ( $lCatalogDir ) or die ("Error: Could not chdir to catalog dir: $lCatalogDir : $!\n");
	foreach $lFile ( sort glob ("*.txt") ) {
		print "Reading catalog file: $lFile...\n";
		open (CAT_FILE, $lFile) or die ("Error: Could not open file for input: $lFile : $!\n");
		while ($lRow = <CAT_FILE>) {
			chomp ($lRow);
			my ($name, $dir, $ext);
			#($name, $dir, $ext) = fileparse($lRow, '\..*');
			$name = basename($lRow);
			#print "$name\n";
			if ( exists $lFileHash{$name} ) {
				#print "\texists : $name\n";
				$lFileHash{$name} = 0;
				$lDupCount++;
			}
		}
		close(CAT_FILE);
	}
	
	print "Total Dup Count: $lDupCount\n";
	
	chdir ($lEpubDir) or die ("Error: Could not chdir to epub dir: $lEpubDir : $!\n");
	my $lBatFile = "dedup.bat";
	open (OUT_FILE, ">$lBatFile") or die ("Error: could not open bat file for output: $lBatFile : $!\n");
	foreach $lFile ( sort keys %lFileHash ) {
		next if ( $lFileHash{$lFile} == 1) ;
		
		print OUT_FILE "move \"$lFile\" $lDupDir\n";
		
	}
	
	close (OUT_FILE);
	print "Batch file created: $lBatFile\n";
	
}	# S_DedupEpub

#------------------------------------------------------------------------
#
# Inputs:		file - full file name including extension
#			verbose - 1 means log things, 0 means silent
#------------------------------------------------------------------------
sub S_DeriveFormat {
	my (%args) = @_;
	my ($lFile, $lFormat);
	
	$args{verbose} = 0 if ( ! exists $args{verbose});
	$lFormat = 'epub';
	$lFile = $args{file};

	my @lExtArray = qw (azw cbr doc docx epub html htm mobi pdf rtf txt text);
	
	return ( 'azw' ) if ( index ($lFile, '(azw3)') > -1);
	return ( 'azw' ) if ( index ($lFile, 'azw') > -1);

	return ( 'cbr' ) if ( index ($lFile, '(cbr)') > -1);
	return ( 'cbr' ) if ( index ($lFile, '.cbr') > -1);

	return ( 'doc' ) if ( index ($lFile, '(doc)') > -1);
	return ( 'doc' ) if ( index ($lFile, '.doc') > -1);

	return ( 'docx' ) if ( index ($lFile, '(docx)') > -1);
	return ( 'docx' ) if ( index ($lFile, '.docx') > -1);
	
	return ( 'epub' ) if ( index ($lFile, '(epub)') > -1);
	return ( 'epub' ) if ( index ($lFile, '.epub') > -1);
	return ( 'epub' ) if ( index ($lFile, 'epub') > -1);		# Sometimes we see "...(epub, mobi).rar"

	return ( 'html' ) if ( index ($lFile, '(html)') > -1);
	return ( 'html' ) if ( index ($lFile, '[htm]') > -1);
	return ( 'html' ) if ( index ($lFile, '.html') > -1);
	return ( 'html' ) if ( index ($lFile, 'htm') > -1);

	return ( 'mobi' ) if ( index ($lFile, '(mobi)') > -1);
	return ( 'mobi' ) if ( index ($lFile, '.mobi') > -1);
	
	return ( 'pdf' ) if ( index ($lFile, '(pdf)') > -1);
	return ( 'pdf' ) if ( index ($lFile, '.pdf') > -1);
	
	return ( 'rtf' ) if ( index ($lFile, '(rtf)') > -1);
	return ( 'rtf' ) if ( index ($lFile, '.rtf') > -1);

	return ( 'text' ) if ( index ($lFile, '.txt') > -1);
	return ( 'text' ) if ( index ($lFile, '.text') > -1);
	
	
	# Print a diagnostic if we cannot determin the format.
	
	if ($args{verbose} > 0 ) {
		print "Unknown Format: $lFile\n";
	}
		
	return ('unk');
}	# S_DeriveFormat

#------------------------------------------------------------------------
#------------------------------------------------------------------------
sub S_DeriveSeries {
	my (%args) = @_;
	my ($lFile, $lPos1, $lPos2, $lSeries);
		
	$lSeries = "";
	$lFile = $args{file};
	
	# Look for file names like this:
	# Erle Stanley Gardner - [Perry Mason 06] - The Case of the Counterfeit Eye
	$lPos1 = index ($lFile, '- [');
	if ( $lPos1 > -1 ) {
		if ( $lFile =~ m/\[([a-zA-Z ]*)/ ) {
			$lSeries = $1;
			$lSeries =~ s/\s+$//;
			#print sprintf ("(%40s) : %s\n", $lSeries, substr ($lFile, $lPos1+2, 20));
		}
	}
	
	#if ( $lSeries eq "" ) {
	#	print sprintf ("%40s\n", $lFile);
	#}
	return ($lSeries);
	
}	# S_DeriveSeries


#------------------------------------------------------------------------
#------------------------------------------------------------------------
sub S_DeriveAuthor {
	my (%args) = @_;
	my ($lAuthor, $lLName) = ("", "");
	my ($lPos1, $lPos2);
	
	$lFile = $args{file};
	
	# Some authors are "Big Bob (ed) -..." so remove the (ed)
	$lFile =~ s/\(ed\) //g;
	
	# Look for author strings like this:
	# Gayla Twist - [Vanderlind Castle 04] - History of the Vampire (epub)
	$lPos2 = index ($lFile, '- [');
	if ($lPos2 > -1) {
		$lAuthor = substr ($lFile, 0, $lPos2 - 1);
		
		if ($args{verbose} > 0 ) {
			#print sprintf ("(%15s) : %s\n", $lAuthor, substr($lFile, 0, 20));	
		}
	}
	
	if ($lAuthor eq "") {
		# See if the file name follows the pattern: "first last -..."
		
		if ( $lFile =~ m/^(\w+) (\w+) \-/ ) {
			$lLName = $2;
			$lAuthor = "$1 $2";
		}
	}
	
	if ( $lAuthor eq "" ) {
		if ( $lFile =~ m/^(\w+) (\w+) (\w+) \-/ ) {
			$lLName = $3;
			$lAuthor = "$1 $2 $3";
		}
	}

	if ( $lAuthor eq "" ) {
		# How about "Ellen Currey-Wilson - The Big turnoff
		if ( $lFile =~ m/^(\w+) (\w+)\-(\w+) \-/ ) {
			$lLName = "$2-$3";
			$lAuthor = "$1 $2-$3";
		}
	}

	if ( $lAuthor eq "" ) {
		# How about "Jack Higgins as Harry Patterson"
		if ( $lFile =~ m/^(\w+) (\w+) as (\w+) (\w+) \-/ ) {
			$lLName = "$1-$2";
			$lAuthor = "$2";
		}
	}
	
	if ( $lAuthor eq "" ) {
		# Look for "Anne-Laure Thieblemont -"
		if ( $lFile =~ m/^(\w+)\-(\w+) (\w+) \-/ ) {
			$lLName = "$3";
			$lAuthor = "$1-$2 $3";
		}
	}

	if ($lAuthor eq "") {
		# Look for: "Bill Pronzini & John Lutz - "
		if ( $lFile =~ m/^(\w+) (\w+) \& (\w+) (\w+) \-/ ) {
			$lLName = "$2";
			$lAuthor = "$1 $2 \& $3 $4";
		}
	}
		
	if ($lAuthor eq "") {
		# Look for: "Bill Pronzini and John Lutz - "
		if ( $lFile =~ m/^(\w+) (\w+) and (\w+) (\w+) \-/ ) {
			$lLName = "$2";
			$lAuthor = "$1 $2 and $3 $4";
		}
	}
	
	if ($lAuthor eq "") {
		# Cathy and DD MacRae 
		if ( $lFile =~ m/^(\w+) and (\w+) (\w+) \-/ ) {
			$lLName = "$3";
			$lAuthor = "$1 and $2 $3";
		}
	}
	
	if ($lAuthor eq "") {
		# Flannery O'Connor 
		if ( $lFile =~ m/^(\w+) (\w+)' (\w+) \-/ ) {
			$lLName = "$2'$3";
			$lAuthor = "$1 $2'$3";
		}
	}
	
	
	if ( $lAuthor eq "" ) {
		#print sprintf ("No Author: %s\n", substr($lFile, 0, 50));	
	}
	

	
	
	return ($lAuthor, $lLName);
	
}	# S_DeriveAuthor


#------------------------------------------------------------------------
#------------------------------------------------------------------------
sub S_DeriveTitle {
	my (%args) = @_;
	my ($lPos1, $lPos2, $lPos3, $lTitle);
	
	$lFile = $args{file};
	$lTitle = "";
	
	# Typical file names are: Anthony Riches - [Empire 08] - Thunder of the Gods (epub)
	$lPos1 = index($lFile, '] - ');
	$lPos2 = index($lFile, ' (', $lPos1);
	$lPos3 = index($lFile, ' [', $lPos1);
	
	if ($lPos3 > -1 && $lPos2 == -1) {
		$lPos2 = $lPos3;
	}
	
	if ( $lPos3 > -1 && $lPos2 > -1 ) {
		$lPos2 = $lPos3 if ( $lPos3 < $lPos2 );
	}
	
	if ( $lPos1 > -1 and $lPos2 > -1 and $lPos2 > $lPos1 ) {
		# Compensate for the leading and final characters
		$lPos1 += 4;
	
		$lTitle = substr ($lFile, $lPos1, $lPos2 - $lPos1);
		
		if ($args{verbose} > 0 ) {
			print sprintf ("Title1: (%s)\n", substr ($lTitle, 0, 90)); 
		}
		
		# print sprintf ("%2d - %2d : (%s) : %s\n", $lPos1, $lPos2, $lTitle, $lFile);
	}

	my @lExtArray = qw (azw azw3 cbr doc docx epub html htm mobi pdf rtf txt text retail);
	my $lExt;
	
	if ($lTitle eq "") {
		
		$lTitle = $lFile;
		
		# Remove the extension from the end of the file name
		$lTitle =~ s/\.\w{3,5}$//;
		
		# We often see (azw) or (pdf) in the file name so strip these
		foreach $lExt ( @lExtArray ) {
			$lTitle =~ s/ \($lExt\)//;
		}
		
		# We sometimes see (v4.1) in the name so strip these
		if (index ($lTitle, '(v') > 0) {
			$lTitle =~ s/ \(v\d+\.\d+\)//;
		}
		
		# We sometimes see story codes like [MF] in brackets remove these.
		if (index ($lTitle, '[') > -1) {
			$lTitle =~ s/ \[[^]]*\]//g;
		}
		
		# Take out anything in parens
		if (index ($lTitle, '(') > -1) {
			$lTitle =~ s/ \([^)]*\)//g;
			$lTitle =~ s/ \([^)]*\)//g;
		}
		
		# Take out multiple spaces
		$lTitle =~ s/  / /g;
		
		# We now have hopefully author - title but title can include dash characters so start from the left, find the first dash and take stuff to the right
		# as the title.
		
		$lPos1 = index ($lTitle, ' - ');
		if ($lPos1 > -1) {
			$lTitle = substr ($lTitle, $lPos1 + 3, length($lTitle));
		}

		if ( $args{verbose} > 0 ) {
			print sprintf ("Title2: (%s)\n", substr ($lTitle, 0, 90)); 
		}
	}
	
	return ($lTitle);
	
}	# S_DeriveTitle

#------------------------------------------------------------------------
# Routine:		S_DeriveFileSize
# Description:		This routine takes the name of an ebook file, will find the actual file size
#				then round it up to the nearest secor size for a DVD/BluRay disk
#				and return the disk space it will occupy.
#
#
#------------------------------------------------------------------------
sub S_DeriveFileSize {
	my (%args) = @_;
	my ($lRawSize, $lFileSize, $lSectors) = (0, 0, 0);
	
	$lRawSize = -s $args{file};
	$lSectors = int ($lRawSize / 2048 );
	$lFileSize = ($lSectors + 1) * 2048;
	
	return ($lFileSize);
}	# S_DeriveFileSize

#------------------------------------------------------------------------
# Routine:		S_FillEbookHashCatalogs
# Description:		This routine will read Catalog files to fill %gEbookHash
# 				{key}{file} = "A N Latro - [Black Collar Syndicate 02] - Black Collar Queen (epub)"
# 				{key}{format} = 'epub'
# 				{key}{author} = "A N Latro"
# 				{key}{lname} = "Latro"
# 				{key}{series} = 'Black Collar Syndicate'
# 				{key}{volume} = 2
# 				{key}{title} = 'Black Collar Queen'
#
# Inputs:		path - path to where the catalog files live
#				pattern - string like "raw-??-catalog.txt" to let this routine find the catalog files
#
#------------------------------------------------------------------------
sub S_FillEbookHashCatalogs {
	my (%args) = @_;
	my ($lFile, $lFormat, $lAuthor, $lLName, $lSeries, $lVolume, $lTitle, $lFileSize, $lKey, $lCount, $lTotalSize, $lTotalCount);
	my %lFormatHash;
	my %lAuthorHash;
	my %lSeriesHash;
	
	chdir ( $args{path} ) or die ("Error: Could not access path for catalog file: $args{path} : $!\n");


	foreach my $lCatFile ( sort glob ($args{pattern}) ) {
		print "Processing catalog file: $lCatFile\n";
		
		open (CAT_FILE, $lCatFile) or die ("Error: Could not open file for input: $lCatFile : $!\n");
		while ( $lFile = <CAT_FILE> ) {
			chomp ($lFile);
			
			$lKey = sprintf ("%05d", $gCount++);
	
			$gEbookHash{$lKey}{file} = $lFile;
	
			# Determine the file format
			$lFormat = &S_DeriveFormat ( file => $lFile, verbose => 0 );
			$gEbookHash{$lKey}{format} = $lFormat; 
			$lFormatHash{$lFormat}++;		
		
			# See if the file name contains "...[Smoky Mountain 01]" as a series
			$lSeries = &S_DeriveSeries (file => $lFile, verbose => 0);
			$gEbookHash{$lKey}{series} = $lSeries;
			$lSeriesHash{$lSeries}++;
		
			($lAuthor, $lLName) = &S_DeriveAuthor ( file => $lFile, verbose => 0);
			$gEbookHash{$lKey}{author} = $lAuthor;
			$gEbookHash{$lKey}{lname} = $lLName;
			$lAuthorHash{$lAuthor}++;
			
			$lTitle = &S_DeriveTitle ( file => $lFile, verbose => 0);
			$gEbookHash{$lKey}{title} = $lTitle;
			
			$lFileSize = -1;
			$gEbookHash{$lKey}{file_size} = $lFileSize;
			$lTotalSize += $lFileSize;
			
		}
		
		close (CAT_FILE);
	}

	
	print "Total files: $gCount\n";

}	# S_FillEbookHashCatalogs

#------------------------------------------------------------------------
# Routine:		S_FillEbookHash
# Description:		This routine will read a directory full of ebook files and fill %gEbookHash with this type of info:
# 				{key}{file} = "A N Latro - [Black Collar Syndicate 02] - Black Collar Queen (epub)"
# 				{key}{format} = 'epub'
# 				{key}{author} = "A N Latro"
# 				{key}{lname} = "Latro"
# 				{key}{series} = 'Black Collar Syndicate'
# 				{key}{volume} = 2
# 				{key}{title} = 'Black Collar Queen'
#
#------------------------------------------------------------------------
sub S_FillEbookHash {
	my (%args) = @_;
	my ($lFile, $lFormat, $lAuthor, $lLName, $lSeries, $lVolume, $lTitle, $lFileSize, $lKey, $lCount, $lTotalSize, $lTotalCount);
	my %lFormatHash;
	my %lAuthorHash;
	my %lSeriesHash;
	
	# Validate the parent gave us valid info
	
	if ( ! exists $args{path} ) {
		die ("Argument Error: 'path' is a required argument to S_FillEbookHash()\n");
	}
	
	# See if the path the parent gave us exists
	
	if ( ! -e $args{path} ) {
		die ("Argument error: path does not exist: $args{path}\n");
	}
	
	%gEbookHash = ();
	
	chdir ( $args{path}) or die ("Error: Could not access path: $args{path} : $!\n");
	
	# Loop through all the files and try to tease out the title, author, etc.
	
	foreach $lFile ( sort glob ("*.*") ) {
		$lKey = sprintf ("%05d", $gCount++);

		$gEbookHash{$lKey}{file} = $lFile;

		# Determine the file format
		$lFormat = &S_DeriveFormat ( file => $lFile, verbose => 0 );
		$gEbookHash{$lKey}{format} = $lFormat; 
		$lFormatHash{$lFormat}++;		
	
		# See if the file name contains "...[Smoky Mountain 01]" as a series
		$lSeries = &S_DeriveSeries (file => $lFile, verbose => 0);
		$gEbookHash{$lKey}{series} = $lSeries;
		$lSeriesHash{$lSeries}++;
	
		($lAuthor, $lLName) = &S_DeriveAuthor ( file => $lFile, verbose => 0);
		$gEbookHash{$lKey}{author} = $lAuthor;
		$gEbookHash{$lKey}{lname} = $lLName;
		$lAuthorHash{$lAuthor}++;
		
		$lTitle = &S_DeriveTitle ( file => $lFile, verbose => 0);
		$gEbookHash{$lKey}{title} = $lTitle;
		
		$lFileSize = &S_DeriveFileSize ( file => $lFile, verbose => 0);
		$gEbookHash{$lKey}{file_size} = $lFileSize;
		$lTotalSize += $lFileSize;
		
		
	}
	
	if ( 0 ) {
		foreach $lFormat ( sort keys %lFormatHash ) {
			print sprintf ("%4s = %4d files\n", $lFormat, $lFormatHash{$lFormat});	
		}
	}

	if ( 0 ) {
		foreach $lSeries ( sort keys %lSeriesHash ) {
			print sprintf ("%3d = %20s\n", $lSeriesHash{$lSeries}, $lSeries);	
		}
	}
	
	
	if (0) {
		foreach $lAuthor ( sort keys %lAuthorHash ) {
			print sprintf ("%4d : %s\n", $lAuthorHash{$lAuthor}, substr ($lAuthor, 0, 50));
		}
		
	}
	
	
	print "Total files: $gCount\n";
	my ($lBytes, $lKBytes, $lGigs);
	$lBytes = $lTotalSize;
	$lKBytes = int ($lTotalSize / 1024);
	$lGigs = int ( $lKBytes / (1024 * 1024) );
	
	print sprintf ("Total size = %10s bytes\n",  $lBytes);
	print sprintf ("Total size = %10s Kbytes\n", $lKBytes);
	print sprintf ("Total size = %10s Gigs\n",   $lGigs);
		
	
}	# S_FillEbookHash

#------------------------------------------------------------------------
#------------------------------------------------------------------------
sub S_ReportLInitial {
	my %args = @_;
	my($lLetter, @lABCArray, $lKey);
	my %lHash;
	
	
	$lLetter = 'A';
	while ( $lLetter ne 'Z' ) {
		push (@lABCArray, $lLetter);
		print "$lLetter  ";
		$lLetter++;
	}
	push (@lABCArray, 'Z');
	print "\n";
	
	foreach $lLetter ( @lABCArray ) {
		
		foreach $lKey ( sort keys %gEbookHash ) {
			next unless ( substr(uc($gEbookHash{$lKey}{lname}), 0, 1) eq $lLetter);
			
			if ( $args{verbose} > 0 ) {
				print "$lLetter : $gEbookHash{$lKey}{file}\n";
			}
			$lHash{$lLetter}++;		# Track how many files would go into each letter directory
			
		}
		
	}
	
	# Report
	foreach $lLetter ( sort keys %lHash ) {
		print sprintf ("%1s = %4d files\n", $lLetter, $lHash{$lLetter});
	}
}	# S_ReportLInitial


#------------------------------------------------------------------------
#------------------------------------------------------------------------
sub S_ReportAuthor {
	my (%args) = @_;
	my ($lAuthor, %lHash, $lKey);
	
	foreach $lKey ( keys %gEbookHash ) {
		next unless ( $gEbookHash{$lKey}{format} eq 'epub');
		$lHash{$gEbookHash{$lKey}{author}}++;	
	}
	
	foreach $lAuthor ( sort keys %lHash ) {
		next if ( $lHash{$lAuthor} < 2);
		print sprintf ("%3d : %s\n", $lHash{$lAuthor}, $lAuthor);	
	}
	
}	# S_ReportAuthor

#------------------------------------------------------------------------
#             &S_SortEbooksAuthor(path => $gBASE_DIR, bat_file => 'c:\\temp\\ebook_authorsort.bat');
# Routine:		S_SortEbooksAuthor
# Description:		This routine will read through the files in the ebook folder with names like first last -  and determine
#				what the authors last name is. Then it will create a batch file that can put files in a, b, c.. folders 
#				based on the authors last name
#
#------------------------------------------------------------------------
sub S_SortEbooksAuthor {
	my (%args) = @_;
	
	# Call a routine that will read the ebook files into a hash that has fields like this:
	#  {key}{file} = "A N Latro - [Black Collar Syndicate 02] - Black Collar Queen (epub)"
	# {key}{format} = 'epub'
	# {key}{author} = "A N Latro"
	# {key}{lname} = "Latro"
	# {key}{series} = 'Black Collar Syndicate'
	# {key}{volume} = 2
	# {key}{title} = 'Black Collar Queen'
	
	#&S_FillEbookHash( %args );

	&S_FillEbookHashCatalogs ( path => 'N:\\1\\1Ebooks', pattern => 'raw-??-catalog.txt');
	
	# Do a report grouping files into sub dirs like A, B, C based on authors last name
	#&S_ReportLInitial(verbose => 0);

	# Do a report based on author name
	&S_ReportAuthor( verbose => 0 );
	
}	# S_SortEbooksAuthor

#-------------------------------------------------------------------------
# PrintMenu2 - Prints the menu
#-------------------------------------------------------------------------
sub PrintMenu2 {

    print "=============================================\n";
    print "              EP Menu\n";
    print "              Utilitys\n";
    print "=============================================\n";
    print "Please choose an option:\n\n";
    print "\t1 - Sort ebooks by Author (bat file)\n";
    print "\t2 - Read StoriesOnLine\n";
    print "\t3 - \n";
    print "\t4 - \n";
    print "\t5 - \n";
    print "\t6 - \n";
    print "\t7 - Dedupe e-book folder\n";
    print "\t8 - \n";
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
            &S_SortEbooksAuthor(path => $gBASE_DIR, bat_file => 'c:\\temp\\ebook_authorsort.bat');
            $lFinished = 1;
        } elsif ($lChoice == "2") {
        	&S_ScanSOL();
            $lFinished = 1;
        } elsif ($lChoice == "3") {
            $lFinished = 1;
        } elsif ($lChoice == "4") {
            $lFinished = 1;
        } elsif ($lChoice == "5") {
            $lFinished = 1;
        } elsif ($lChoice == "6") {
            $lFinished = 1;
        } elsif ($lChoice == "7") {
			&S_DedupEpub();
            $lFinished = 1;
        } elsif ($lChoice == "8") {
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


#----------------------------------------------------------
# Routine:		formatNumber
# Description:	Takes a number and returns it with commas
#----------------------------------------------------------
sub formatNumber {
	my $aNumber = @_;
	
	my $lComma = $aNumber;
	$lComma =~ s/(\d)(?=(\d{3})+(\D|$))/$1\,/g;
	print "lcomma : $lComma\n";
	return ($lComma);
}	# formatNumber

# End of main

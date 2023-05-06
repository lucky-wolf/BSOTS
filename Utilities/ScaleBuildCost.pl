# input:	Source-Path Target-Path
# output:	creates the same set of files at target-path that it finds at source-path,
#			while modifying the contents of the target files (see ProcessFile)

# use copy()
use File::Copy;

sub ProcessFile
{
	my($sourcefile) = $_[0];
	my($targetfile) = $_[1];

	# only analyze .tech file
	my $ext = ($sourcefile =~ m/([^.]+)$/)[0];
	printf "  %-12s %s\n", "$ext:", $sourcefile;
	if ($ext eq "shipsection")
	{
		open(SF, $sourcefile) or die "$!";
		open(TF, ">$targetfile") or die "$!";

		# read in each line of the file
		while ($line = <SF>)
		{
#			if ($line =~ /(.*health[ \t]+)([-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?)(.*)/)
#			{
#				# adjust ship health (HP)
#				$health = $2*2.0;
#				$line = sprintf("$1%.0f$4\n", $health);
#				++$line_count;
#			}
#			if ($line =~ /(.*cost[ \t]+)([-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?)(.*)/)
#			{
#				# adjust ship cost ($)
#				$cost = $2*1.5;
#				$line = sprintf("$1%.0f$4\n", $cost);
#				++$line_count;
#			}
			if ($line =~ /(.*cpoints[ \t]+)([-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?)(.*)/)
			{
				# adjust construction time
				$cpoints = $2*2.0/3.0;
				$line = sprintf("$1%.0f$4\n", $cpoints);
				++$line_count;
			}
#			elsif ($line =~ /(.*construction_capacity[ \t]+)([-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?)(.*)/)
#			{
#				# adjust construction capacity for constructor ships to keep parity with cpoint increase
#				$cpoints = $2*3.0;
#				$line = sprintf("$1%.0f$4\n", $cpoints);
#				++$line_count;
#			}

			# write modified line to new file
			print TF ($line);
		}

		close(SF);
		close(TF);
		
		++$modified_count;
	}
	else
	{
		# simply copy non .shipsection files
		copy($sourcefile, $targetfile) or die "\n$!  $sourcefile\n";
	}
	++$file_count;
}

sub ProcessFolder
{
	my($sourcepath) = $_[0];
	my($targetpath) = $_[1];

	print "Processing: $sourcepath\n";

	# get list of all files
	opendir(DIR, "$sourcepath") or die "$!";
	my(@files) = readdir(DIR);
	closedir(DIR);

	# create the target path if it doesn't already exist
	mkdir($targetpath) or die "$!" unless -d $targetpath;

	foreach (@files)
	{
		next if /(^\.$)|(^\.\.$)/;	# skip . and ..

		$source = "$sourcepath\\$_";
		$target = "$targetpath\\$_";

		ProcessFile($source, $target) if -f $source;
		ProcessFolder($source, $target) if -d $source;
	}
}

$file_count = 0;
$modified_count = 0;
$line_count = 0;
ProcessFolder($ARGV[0], $ARGV[1]);

print "Modified $line_count lines in $modified_count out of $file_count files.\n";

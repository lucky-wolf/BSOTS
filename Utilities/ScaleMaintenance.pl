# input:	Source-Path scaling-factor
# output:	stdout

# use copy()
# use File::Copy;

sub ProcessFile
{
	my($sourcefile) = $_[0];
	my($scale) = $_[1];
	
	open(SF, $sourcefile) or die "$!";

	# read in each line of the file
	while ($line = <SF>)
	{
		if ($line =~ /(^[ \t]*maintenance_cost[ \t]+)([-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?)(.*)/)
		{
			# adjust construction time
			$cpoints = $2 * $scale;
			$line = sprintf("$1%.0f$4\n", $cpoints);
		}

		# write modified line to new file
		print $line;
	}

	close(SF);
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

ProcessFile($ARGV[0], $ARGV[1]);

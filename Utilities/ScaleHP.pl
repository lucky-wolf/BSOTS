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
			# check if this line has a "health" value
			if ($line =~ /(^[ \t]*health[ \t]+)([-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?)(.*)/)
			{
				# adjust ship health (HP)
				$health = $2 * $scale;
				$line = sprintf("$1%.0f$4\n", $health);
				++$changes;
			}
#			if ($line =~ /(^[ \t]*cost[ \t]+)([-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?)(.*)/)
#			{
#				# adjust ship cost ($)
#				$cost = $2*1.5;
#				$line = sprintf("$1%.0f$4\n", $cost);
#				++$changes;
#			}
#			if ($line =~ /(^[ \t]*cpoints[ \t]+)([-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?)(.*)/)
#			{
#				# adjust construction time
#				$cpoints = $2*2.0/3.0;
#				$line = sprintf("$1%.0f$4\n", $cpoints);
#				++$changes;
#			}
#			elsif ($line =~ /(^[ \t]*construction_capacity[ \t]+)([-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?)(.*)/)
#			{
#				# adjust construction capacity for constructor ships to keep parity with cpoint increase
#				$cpoints = $2*3.0;
#				$line = sprintf("$1%.0f$4\n", $cpoints);
#				++$changes;
#			}

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

$changes = 0;
ProcessFile($ARGV[0], $ARGV[1]);

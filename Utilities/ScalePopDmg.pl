# input:	Source-Path scaling-factor
# output:	stdout

sub ProcessFile
{
	my($sourcefile) = $_[0];
	my($scale) = $_[1];
	
	open(SF, $sourcefile) or die "$!";

	# read in each line of the file
	while ($line = <SF>)
	{
		# check if this line has an "attrib" value
		if ($line =~ /([ \t]*dam_pop[ \t]+)([-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?)(.*)/)
		{
			# adjust dam_pop
			$attrib = $2 * $scale;
			$line = sprintf("$1%d$4\n", $attrib);
		}

		# write modified line to new file
		print $line;
	}

	close(SF);
}

ProcessFile($ARGV[0], $ARGV[1]);

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
		if ($line =~ /([ \t]*dam_infra[ \t]+)([-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?)(.*)/)
		{
			# adjust dam_infra (and don't print trailing zeros or exponential notation!)
			$head = $1;
			$attrib = $2*$scale;
			$tail = $4;
			$attrib = sprintf("%.14f", $attrib);
			$attrib =~ s/\.(?:|.*[^0]\K)0*\z//;
			$line = sprintf("%s%s%s\n", $head, $attrib, $tail);
		}

		# write modified line to new file
		print $line;
	}

	close(SF);
}

ProcessFile($ARGV[0], $ARGV[1]);

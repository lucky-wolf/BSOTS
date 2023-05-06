# input:	Source-Path scaling-factor
# output:	stdout

sub ProcessFile
{
	my($sourcefile) = $_[0];
	my($scale) = $_[1];
	my($engine) = 0;
	
	open(SF, $sourcefile) or die "$!";

	# read in each line of the file
	while ($line = <SF>)
	{
		# check if this line is a "section_type engine"
		if (!$engine)
		{
			if ($line =~ /^[ \t]*section_type[ \t]+engine.*/)
			{
				$engine = 1;
			}
			elsif ($line =~ /^([ \t]*autonomous[ \t]+)(.*)/)
			{
				$engine = 1;
				$line = "$1true\t// actually means this is a ship with only a mission section\n";
			}
		}
		else
		{
			if ($line =~ /^([ \t]*speed[ \t]+)([-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?)(.*)/)
			{
				# adjust speed
				$speed = $2 * $scale;
				$line = "$1$speed$4\n";
			}
			elsif ($line =~ /^([ \t]*force[_a-z]+[ \t]+)([-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?)(.*)/)
			{
				# adjust force limits
				if ($2 != 0)
				{
					$force = $2 * $scale;
					$line = "$1$force$4\n";
				}
			}
		}

		# write modified line to new file
		print $line;
	}

	close(SF);
}

ProcessFile($ARGV[0], $ARGV[1]);

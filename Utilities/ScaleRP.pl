# input:	input_file scaling_factor minimum_to_alter maximum_to_alter
# output:	stdout

# use copy()
# use File::Copy;

sub ProcessFile
{
	my($sourcefile) = $_[0];
	my($scale) = $_[1];
	my($minimum) = $_[2] + 0;
	my($maximum) = $_[3] + 0;
	
	open(SF, $sourcefile) or die "$!";

	# read in each line of the file
	while ($line = <SF>)
	{
		# check if this line has an RP:x cost
		if ($line =~ /^(.*[ \t]+RP:)([0-9]+)(.*)$/)
		{
			# get the current cost
			$cost = $2 + 0.0;
			
			# only scale values within the specified window
			if (($cost >= $minimum) && ($cost <= $maximum))
			{
				# scale the cost
				$cost = $cost * $scale;

				# output the modified line
				$line = sprintf("$1%.0f$3\n", $cost);

				++$changes;
			}
		}

		# output line (modified or not)
		print $line;
	}

	close(SF);
}

$changes = 0;
ProcessFile($ARGV[0], $ARGV[1], $ARGV[2], $ARGV[3]);

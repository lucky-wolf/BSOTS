# input:	Source-Path
# output:	Sends the new file to stdout

sub ProcessFile
{
	my($sourcefile) = $_[0];
	
	# only analyze .tech file
	my $ext = ($sourcefile =~ m/([^.]+)$/)[0];
	if ($ext eq "tech") 
	{
		open(SF, $sourcefile) or die "$!";

		# read in each line of the file
		while ($line = <SF>)
		{
			if ($line =~ /^(.*[ \t]+RP:)([0-9]+)(.*)$/)
			{
				# change research cost to a factor of current value
				$basis = $2 + 0;
				
				# set to zero to see entire tech tree
				$cost = 0;
				$line = sprintf("$1%d$3\n", $cost);	# zero cost, but normal chances
				++$line_count;
			}

			# output modified line
			print $line;
		}

		close(SF);
	}
	else
	{
		print "we only process .tech files, sorry"
	}
}

$line_count = 0;
ProcessFile($ARGV[0], $ARGV[1]);

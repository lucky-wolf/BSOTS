# input:	Source-Path
# output:	Sends the list to stdout

sub ProcessFile
{
	my($sourcefile) = $_[0];
	my($x) = $_[1];
	
	if ($x == 0) 
	{
		# use 10k as a default
		$x = 10000;
	}
	
#	print "x is $x\n";
	
	# only analyze .tech file
	my $ext = ($sourcefile =~ m/([^.]+)$/)[0];
	if ($ext eq "tech") 
	{
		open(SF, $sourcefile) or die "$!";

		# read in each line of the file
		while ($line = <SF>)
		{
			if ($line =~ /^([ \t]+allows[ \t]+")([A-Za-z_]+)([ \t]+RP:)([0-9]+)(.*)$/)
			{
				# get the tech name
				$tech = $2;
				if (($tech =~ /^XNC_/) || ($tech =~ /^CCC_Trns/))
				{
					# skip xeno techs - we don't want to be giving those away (especially temperance!)
				}
				else
				{
					# extract current cost
					$basis = $4;
					
					if (($basis <= $x) && ($basis > 0))
					{
						# set to zero to see entire tech tree
						print "$tech\n";
				
						++$line_count;
					}
				}
			}
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

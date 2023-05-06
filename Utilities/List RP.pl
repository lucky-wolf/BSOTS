# input:	Source-Path
# output:	Sends the list to stdout

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
			if ($line =~ /^([ \t]*allows[ \t]+")([A-Za-z_]+)([ \t]+RP:)([0-9]+)(.*)$/)
			{
				# get the tech ID
				$tech = $2;

				# extract current cost
				$basis = $4;
				
				# print the tech + RP
				printf("%16s\t$basis\n", $tech);
			}
		}

		close(SF);
	}
	else
	{
		print "we only process .tech files, sorry"
	}
}

ProcessFile($ARGV[0], $ARGV[1]);

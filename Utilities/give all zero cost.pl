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
			if ($line =~ /^(.*[ \t]+RP:)([0-9]+)([ \t]+Human:)([0-9]+)([ \t]+Zuul:)([0-9]+)([ \t]+Hiver:)([0-9]+)([ \t]+Tarkas:)([0-9]+)([ \t]+Liir:)([0-9]+)([ \t]+Morrigi:)([0-9]+)(.*)$/)
			{
				# cost is zero
				$cost = 0;
				# either make each odds 100, or 0, depending on if it started nonzero, or zero
				$human = $4 == 0 ? 0 : 100;
				$zuul = $6 == 0 ? 0 : 100;
				$hiver = $8 == 0 ? 0 : 100;
				$tarkas = $10 == 0 ? 0 : 100;
				$liir = $12 == 0 ? 0 : 100;
				$morrigi = $14 == 0 ? 0 : 100;
				$line = sprintf("$1%d$3%d$5%d$7%d$9%d$11%d$13%d\"\n", $cost, $human, $zuul, $hiver, $tarkas, $liir, $morrigi);	# zero cost & all techs guaranteed
				++$line_count;
			}
			elsif ($line =~ /^(.*[ \t]+RP:)([0-9]+)(.*)$/)
			{
				# core tech: zero out the RP, everyone gets this
				$cost = 0.0;
				$line = sprintf("$1%.0f\"\n", $cost);	# zero cost & all techs guaranteed
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

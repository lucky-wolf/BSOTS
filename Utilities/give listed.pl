# input:	Source-Path Tech-List-File
# output:	Sends the new file to stdout

sub ProcessFile
{
	my($sourcefile) = $_[0];
	my($listfile) = $_[1];

	# read the list of techs
	# my @techs = read_file($listfile, chomp => 1);
	open my $handle, '<', $listfile or die "$!";
	my @techs = <$handle>;
	close $handle;
	
#	foreach my $tech (@techs) {
#		print $tech
#	}
	
#	my $value = "tech1";
#	if ( grep (/^$value/, @techs ) ) {
#		print "found it!\n";
#	}
	
#	return
	
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
				elsif ( grep (/^$tech/, @techs ) )
				{
					# set this tech to RP:0
					$cost = 0;
					$line = sprintf("$1$2$3%d$5\n", $cost);	# zero cost, but normal chances
					++$line_count;
				}
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

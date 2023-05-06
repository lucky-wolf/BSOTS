# input:	Source-Path
# output:	stdout
#
# requires: ppm install Math-Round

use File::Basename;
use Math::Round;

sub ProcessFile
{
	my($sourcefile) = $_[0];
	
	open(SF, $sourcefile) or die "$!";

	# we want the filename (without extension)
	$filename = basename($sourcefile);
	$filename =~ s/\.[^.]+$//;
	
	# read in each line of the file
	while ($line = <SF>)
	{
		if ($line =~ /^[ \t]\/\/.*$/)
		{
			# ignore commented out lines
		}
		elsif ($line =~ /IND_HIDDEN/)
		{
			# ignore files that really aren't part of anything
			close(SF);
			return;
		}
		elsif ($line =~ /^([ \t]*weaponclass[ \t]+)([^ \t\r\n]+)(.*)$/)
		{
			$weaponclass = $2;
		}
		elsif ($line =~ /^([ \t]*weaponfamily[ \t]+)([^ \t\r\n]+)(.*)$/)
		{
			$weaponfamily = $2;
		}
		elsif ($line =~ /^([ \t]*turretclass[ \t]+)([^ \t\r\n]+)(.*)$/)
		{
			$turretclass = $2;
		}
		elsif ($line =~ /^([ \t]*turretsize[ \t]+)([^ \t\r\n]+)(.*)$/)
		{
			$turretsize = $2;
		}
		elsif ($line =~ /^([ \t]*cost[ \t]+)([^ \t\r\n]+)(.*)$/)
		{
			$cost = $2;
		}
		elsif ($line =~ /^([ \t]*burst_volleys[ \t]+)([^ \t\r\n]+)(.*)$/)
		{
			$burst_volleys = $2;
		}
		elsif ($line =~ /^([ \t]*volley_period[ \t]+)([^ \t\r\n]+)(.*)$/)
		{
			$volley_period = $2;
		}
		elsif ($line =~ /^([ \t]*recharge_time[ \t]+)([^ \t\r\n]+)(.*)$/)
		{
			$recharge_time = $2;
		}
		elsif ($line =~ /^([ \t]*range[ \t]+)([^ \t\r\n]+)(.*)$/)
		{
			$range = $2;
		}
		elsif ($line =~ /^[ \t]*beam[ \t]*$/)
		{
			$dam_type = "beam";
		}
		elsif ($line =~ /^[ \t]*bolt[ \t]*$/)
		{
			$dam_type = "bolt";
		}
		elsif ($line =~ /^[ \t]*chainlightning[ \t]*$/)
		{
			$dam_type = "chainlightning";
		}
		elsif ($line =~ /^[ \t]*col[ \t]*$/)
		{
			$dam_type = "col";		# no DPS
		}
		elsif ($line =~ /^[ \t]*mine[ \t]*$/)
		{
			$dam_type = "mine";
		}
		elsif ($line =~ /^[ \t]*mirv[ \t]*$/)
		{
			$dam_type = "mirv";
		}
		elsif ($line =~ /^[ \t]*missile[ \t]*$/)
		{
			$dam_type = "missile";
		}
		elsif ($line =~ /^[ \t]*rider[ \t]*$/)
		{
			$dam_type = "rider";	# no DPS
		}
		elsif ($line =~ /^[ \t]*torpedo[ \t]*$/)
		{
			$dam_type = "torpedo";
		}
		elsif ($line =~ /^([ \t]*dot_rate[ \t]+)([^ \t\r\n]+)(.*)$/)
		{
			$dot_rate = $2;
		}
		elsif ($line =~ /^([ \t]*dot_time[ \t]+)([^ \t\r\n]+)(.*)$/)
		{
			$dot_time = $2;
		}
		elsif ($line =~ /^([ \t]*speed[ \t]+)([^ \t\r\n]+)(.*)$/)
		{
			$speed = $2;
		}
		elsif ($line =~ /^([ \t]*ttl[ \t]+)([^ \t\r\n]+)(.*)$/)
		{
			$ttl = $2;
		}
		elsif ($line =~ /^([ \t]*max_range[ \t]+)([^ \t\r\n]+)(.*)$/)
		{
			$max_range = $2;
		}
		elsif ($line =~ /^([ \t]*eff_range_dam[ \t]+)([^ \t\r\n]+)(.*)$/)
		{
			$eff_range_dam = $2;
		}
		elsif ($line =~ /^([ \t]*dam[ \t]+)([^ \t\r\n]+)(.*)$/)
		{
			$dam = $2;
		}
		elsif ($line =~ /^([ \t]*dam_collision[ \t]+)([^ \t\r\n]+)(.*)$/)
		{
			$dam_collision = $2;
		}
		elsif ($line =~ /^([ \t]*dam_pop[ \t]+)([^ \t\r\n]+)(.*)$/)
		{
			$dam_pop = $2;
		}
		elsif ($line =~ /^([ \t]*dam_infra[ \t]+)([^ \t\r\n]+)(.*)$/)
		{
			$dam_infra = $2;
		}
		elsif ($line =~ /^([ \t]*dam_terra[ \t]+)([^ \t\r\n]+)(.*)$/)
		{
			$dam_terra = $2;
		}
		elsif ($line =~ /^([ \t]*dam_est[ \t]+)([^ \t\r\n]+)(.*)$/)
		{
			$dam_est = $2;
		}
		elsif ($line =~ /^([ \t]*rating_frate[ \t]+)([^ \t\r\n]+)(.*)$/)
		{
			$rating_frate = $2;
		}
		elsif ($line =~ /^([ \t]*rating_dam[ \t]+)([^ \t\r\n]+)(.*)$/)
		{
			$rating_dam = $2;
		}
		elsif ($line =~ /^([ \t]*rating_acc[ \t]+)([^ \t\r\n]+)(.*)$/)
		{
			$rating_acc = $2;
		}
		elsif ($line =~ /^([ \t]*rating_range[ \t]+)([^ \t\r\n]+)(.*)$/)
		{
			$rating_range = $2;
		}
	}

	# normally either dam or eff_range_dam will be defined
	if (defined $eff_range_dam) { $dam = $eff_range_dam; }

	# burst volley & duration = 1 by default
	if (!defined $burst_volleys) { $burst_volleys = 1; }
	if (!defined $volley_duration) { $volley_duration = 1; }

	# generate derivative values (dam_per_salvo, ttl_range)
	# dam_per_salvo = damage per salvo
	if ($dam_type eq "beam")
	{
		$dam_per_salvo = $dam * $volley_duration * $burst_volleys;
	}
	elsif ($dam_type eq "bolt")
	{
		$dam_per_salvo = $eff_range_dam * $burst_volleys;
	}
	elsif ($dam_type eq "chainlightning")
	{
		$dam_per_salvo = ((1 + $branches) / 2) * $dam * $volley_duration * $burst_volleys;
		# note: using 'average' number of branches to weight dam_per_salvo
	}
	elsif ($dam_type eq "mine")
	{
		$dam_per_salvo = $dam * $burst_volleys;
	}
	elsif (($dam_type eq "missile") || ($dam_type eq "mirv") || ($dam_type eq "torpedo"))
	{
		# include collision bonus for kinetic missiles (not sure whether this is at all accurate as to how much is actually computed by engine!)
		if (defined $dam_collision) { $dam = $dam + $dam_collision; }	
		$dam_per_salvo = $dam * $burst_volleys;
		$ttl_range = round($speed * $ttl);
	}
	elsif (defined $dam)
	{
		# e.g. mesonprojector, grapple, ...
		$dam_per_salvo = $dam * $volley_duration * $burst_volleys;
	}

	# override the dam_per_salvo for corrosives & nanite style weapons
	if (defined $dot_rate)
	{
		$dam_per_salvo = $dot_rate * $dot_time;
		$dam = $dot_rate;
	}
	
	# damage per second is one way to see how a weapon dishes out continuously (even though it is almost never continuous)
	# unfortuantely, a LOT is lost in understanding when you only look at DPS
	# better would be a graph of Damage / fixed-interval for all weapons (perhaps)?
	# the thing is, a weapon that dishes out a lot of damage and has a high change of hitting and sustaining that damage is far better than one that dishes out a lot over time, but either misses or it ricochets off or can otherwise be ignored
	# another massive factor is the alpha damage factor - if a weapon puts out a lot of damage quickly and at rate - then the target is dead before it can do much attacking itself - so DPS doesn't matter because there's little S in the resulting equation that plays out
	# hence, we'll at least track dam_per_salvo as a way to try to capture some of this...
	if (defined $dam_per_salvo)
	{
		$dps = round($dam_per_salvo / $recharge_time);
	}
	
	# override the range for mines (which never have a meaningful range)
	if ($weaponfamily =~ /conventionalmine/)
	{
		undef $ttl_range
	}

	# determine our true maximum range (ttl_range, max_range, or range, depending on weapon)
	if (defined $ttl_range)
	{
		$tru_range = $ttl_range;
	}
	elsif (defined $max_range)
	{
		$tru_range = $max_range;
	}
	elsif (defined $range)
	{
		$tru_range = $range;
	}

	# =$P2<>$Q2
	
	if ($filename =~ /dual/) 
	{ 
		$dps = $dps * 2;
	}
	elsif ($filename =~ /triple/) 
	{ 
		$dps = $dps * 3;
	}
	
	# generate the csv data
	@values = ($filename, $weaponclass, $weaponfamily, $turretclass, $turretsize, $dam_pop, $dam_infra, $dam_terra, $dam_per_salvo, $dps, $dam_est, $recharge_time, $rating_frate, $rating_dam, $rating_acc, $range, $tru_range,  $rating_range);
	
	foreach my $value (@values)	{ print $value, ","; }
	print $cost, "\n";

	close(SF);
}

ProcessFile($ARGV[0]);

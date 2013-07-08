#!/opt/local/bin/perl
my $file = $ARGV[0];
my %head = ();
my @cpuUsage = (0, 0, 0, 0, 0);
open(my $fh, $file)
	or die "Can not open $file: $1";
while (my $line = readline $fh) {
	chomp $line;
	if ($line =~ /^\[CPU STAT\]/) {
		last;
	}
}
while (my $line = readline $fh) {
	chomp $line;
	if ($line =~ /^\s*$/) {
		next;
	}
	if ($line !~ /^[^:]* : .*/) {
		last;
	}
	my $colon = index($line, " : ");
	my $name = substr($line, 0, $colon);
	my $value = substr($line, $colon+3);
	$name =~ s/\s+//g;
	$value =~ s/\r+//g;
	$head{$name} = $value;
	#print $name, " ", $value, "\n";
}
while (my $line = readline $fh) {
#	print $line;
	chomp $line;
	if ($line =~ /^\s*$/) {
		next;
	}
	if ($line =~ /^Processor/) {
		next;
	}
	if ($line =~ /^cpu[0-9]*/) {
		$line =~ s/\s+/ /g;
#		print $line, "\n";
		my @tmp = split(/ /, $line);
		if ($tmp[0] =~ /^cpu$/) {
			$cpuUsage[0] = $tmp[11];
		}
		if ($tmp[0] =~ /^cpu0$/) {
			$cpuUsage[1] = $tmp[11];
		}
		if ($tmp[0] =~ /^cpu1$/) {
			$cpuUsage[2] = $tmp[11];
		}
		if ($tmp[0] =~ /^cpu2$/) {
			$cpuUsage[3] = $tmp[11];
		}
		if ($tmp[0] =~ /^cpu3$/) {
			$cpuUsage[4] = $tmp[11];
		}
	}
}
close(fh);

for (my $i=0; $i<4; $i++) {
	my $cpux = "cpu".$i."_freq";
	if (!exists $head{$cpux}) {
		$head{$cpux} = 0;
	}
}

#print $head{'date'}, "\n";
#print $head{'cpu_present'}, "\n";
#print $head{'cpu_online'}, "\n";
#for (my $i=0; $i<4; $i++) {
#	my $cpux = "cpu".$i."_freq";
#	if (exists $head{$cpux}) {
#		print $head{$cpux}, "\n";
#	}
#}

my @presentCpu = split(/-/, $head{'cpu_present'});
my $totalFreq = 0;
foreach my $cpu (@presentCpu) {
	$totalFreq += $head{'cpu'.$cpu.'_freq'};
}
$totalFreq /= @presentCpu;

print $head{'no'}, " ", $head{'date'}, " ", $totalFreq, " ", $head{'cpu0_freq'}, " ", $head{'cpu1_freq'}, " ", $head{'cpu2_freq'}, " ", $head{'cpu3_freq'}, " ", $cpuUsage[0], " ", $cpuUsage[1], " ", $cpuUsage[2], " ", $cpuUsage[3], " ", $cpuUsage[4], "\n";


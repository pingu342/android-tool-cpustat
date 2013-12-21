#!/opt/local/bin/perl
my $file = $ARGV[0];
my %head = ();
my @cpuUsage = (0, 0, 0, 0, 0);
my $current = "start";
my $line_no = 0;
open(my $fh, $file)
	or die "Can not open $file: $1";
while (my $line = readline $fh) {
	chomp $line;
	$line_no++;
	if ($line =~ /^\s*$/) {
		next;
	}
	if ($current eq "start" ) {
		if ($line =~ /^\[CPU STAT\]/) {
			$current = "head";
			next;
		} else {
			goto invalid_format;
		}
	} elsif ($current eq "head") {
		if ($line =~ /^[^:]* : .*/) {
			my $colon = index($line, " : ");
			my $name = substr($line, 0, $colon);
			my $value = substr($line, $colon+3);
			$name =~ s/\s+//g;
			$value =~ s/\r+//g;
			$head{$name} = $value;
			#print $name, " ", $value, "\n";
			next;
		}
	} elsif ($current eq "cpu usage") {
		if ($line =~ /^Processor/) {
			next;
		} elsif ($line =~ /^cpu[0-9]*/) {
			$line =~ s/\s+/ /g;
#			print $line, "\n";
			my @tmp = split(/ /, $line);
			if (@tmp != 12) {
				print STDERR "error: invalid number of columns.\n";
				print STDERR $line, "\n";
				exit(1);
			}
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
			next;
		}
	} elsif ($current eq "unknown") {
	}
change_current:
	if ($line =~ /^---/) {
		if ($line =~ /^--- cpu usage ---/) {
			$current = "cpu usage";
		} else {
			$current = "unknown";
		}
		next;
	}
unprocessed_line:
	if ($current eq "unknown") {
		next;
	}
invalid_format:
	print STDERR "error: invalid format.\n";
	print STDERR "line: ", $line_no, " \"", $line, "\"\n";
	exit(1);
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
my $cpuNum = 0;
for (my $cpu=$presentCpu[0]; $cpu<=$presentCpu[1]; $cpu++) {
#	print 'cpu'.$cpu.'_freq=',$head{'cpu'.$cpu.'_freq'},"\n";
	$totalFreq += $head{'cpu'.$cpu.'_freq'};
	$cpuNum++;
}
$totalFreq /= $cpuNum;

print $head{'no'}, " ", $head{'date'}, " ", $totalFreq, " ", $head{'cpu0_freq'}, " ", $head{'cpu1_freq'}, " ", $head{'cpu2_freq'}, " ", $head{'cpu3_freq'}, " ", $cpuUsage[0], " ", $cpuUsage[1], " ", $cpuUsage[2], " ", $cpuUsage[3], " ", $cpuUsage[4], "\n";

exit(0);

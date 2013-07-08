#!/opt/local/bin/perl
my $file0 = $ARGV[0];
my $file1 = $ARGV[1];
my @stat0 = readCpuStatFile($file0);
my @stat1 = readCpuStatFile($file1);

if (@stat0 <= 0) {
	print STDERR "$file0 error.";
	exit(1);
}
if (@stat1 <= 0) {
	print STDERR "$file1 error.";
	exit(1);
}
my $n0 = @stat0;
my $n1 = @stat1;
if ($n0 != $n1) {
	print STDERR "warning: mismatch number of cpu row. ($file0:$n0 $file1:$n1)";
	exit(1);
}
my @dif = ();
my @sum = ();
for ($i=0; $i<5; $i++) {
	$sum[$i] = 0;
	if ($i < @stat0 && $i < @stat1) {
		if ($stat0[$i][0] eq $stat1[$i][0] && @{$stat0[$i]} == @{$stat1[$i]}) {
			for ($j=1; $j<@{$stat0[$i]}; $j++) {
				$dif[$i][$j] = $stat1[$i][$j] - $stat0[$i][$j];
				$sum[$i] += $dif[$i][$j];
			}
		} else {
			print STDERR "warning: mismatch cpu order.";
			exit(1);
		}
	}
}
if ($sum[0] != 0) {
#	print $date0[0], " - ", $date1[0];
	print "Processor  User  Nice  Syst  Idle  IOWa   IRQ  SIRQ Steal Guest GNice Usage\n";
	for ($i=0; $i<5; $i++) {
		if ($i < @stat0 && $i < @stat1) {
			if ($stat0[$i][0] eq $stat1[$i][0] && @{$stat0[$i]} == @{$stat1[$i]}) {
				printf("%s\t ", $stat0[$i][0]);
				my $tmp = 0;
				for ($j=1; $j<@{$stat0[$i]}; $j++) {
					if ($j > 1) {
						print " ";
					}
					my $rate = 0;
					if ($sum[$i] != 0) {
						$rate = $dif[$i][$j] / $sum[$i] * 100;
					}
					printf("%5d", $rate);
					$tmp += $rate;
				}
				my $usage = 0;
				if ($sum[$i] != 0) {
					$usage = $tmp - ($dif[$i][4] / $sum[$i] * 100);
				}
				printf(" %5d", $usage);
				print "\n";
			}
		}
	}
} else {
	print STDERR "warning: cpu sum 0.";
	exit(1);
}

exit(0);

sub readCpuStatFile {
	(my $file) = @_;
	my @cpu = ();
	open(my $fh, $file)
		or die "Can not open $file: $1";
	while (my $line = readline $fh) {
		chomp $line;
		if ($line !~ /^cpu /) {
			next;
		}
		my $cpuNum = 1;
		$line =~ s/\s+/ /g;
		$cpu[0] = [split(/ /, $line)];
		while ($line = readline $fh) {
			chomp $line;
			if ($line !~ /^cpu[0-9]/) {
				last;
			}
			$line =~ s/\s+/ /g;
			$cpu[$cpuNum] = [split(/ /, $line)];
			$cpuNum++;
		}
#		for ($i=0; $i<@cpu; $i++) {
#			for ($j=0; $j<@{$cpu[$i]}; $j++) {
#				if ($j > 0) {
#					print " ";
#				}
#				print $cpu[$i][$j];
#			}
#			print "\n";
#		}
	}
	close(fh);
	return @cpu;
}

#!/bin/sh
while getopts i:s:x: OPT
do
	case $OPT in
		"i" ) FLG_INTERVAL="TRUE" ; VAL_INTERVAL="$OPTARG" ;;
		"s" ) FLG_SOURCE="TRUE" ; VAL_SOURCE="$OPTARG" ;;
		"x" ) FLG_XRANGE="TRUE" ; VAL_XRANGE="$OPTARG" ;;
	esac
done
if [ "${FLG_SOURCE}" = "TRUE" ]; then
	SOURCE=${VAL_SOURCE};
else
	if [ -e cpu_stat.plot ]; then
		SOURCE="cpu_stat.plot";
	else
		echo "error: no plot data."
		exit 1
	fi
fi
trap 'echo plotting has ended.;
      rm cpu_stat.gp;' EXIT
echo reset > cpu_stat.gp
if [ "${FLG_XRANGE}" = "TRUE" ]; then
	echo "set xrange ${VAL_XRANGE}" >> cpu_stat.gp
fi
echo "start to plot."
echo "set key outside" >> cpu_stat.gp
echo "set ytics nomirror" >> cpu_stat.gp
echo "set y2tics" >> cpu_stat.gp
echo "unset autoscale y2" >> cpu_stat.gp
echo "set yrange [0:2500000]" >> cpu_stat.gp
echo "set y2range [0:100]" >> cpu_stat.gp
echo "set grid" >> cpu_stat.gp
echo "set ylabel \"Frequency [Hz]\"" >> cpu_stat.gp
echo "set y2label \"CPU Usage [%]\"" >> cpu_stat.gp
echo "plot '${SOURCE}' using 1:5 title \"cpu0_freq\" with linespoints" >> cpu_stat.gp
echo "replot '${SOURCE}' using 1:6 title \"cpu1_freq\" with linespoints" >> cpu_stat.gp
echo "replot '${SOURCE}' using 1:7 title \"cpu2_freq\" with linespoints" >> cpu_stat.gp
echo "replot '${SOURCE}' using 1:8 title \"cpu3_freq\" with linespoints" >> cpu_stat.gp
echo "replot '${SOURCE}' using 1:4 title \"total_cpu_freq\" with linespoints linewidth 4" >> cpu_stat.gp
echo "replot '${SOURCE}' using 1:10 title \"cpu0_usage\" with linespoints axes x1y2" >> cpu_stat.gp
echo "replot '${SOURCE}' using 1:11 title \"cpu1_usage\" with linespoints axes x1y2" >> cpu_stat.gp
echo "replot '${SOURCE}' using 1:12 title \"cpu2_usage\" with linespoints axes x1y2" >> cpu_stat.gp
echo "replot '${SOURCE}' using 1:13 title \"cpu3_usage\" with linespoints axes x1y2" >> cpu_stat.gp
echo "replot '${SOURCE}' using 1:9 title \"total_cpu_usage\" with linespoints axes x1y2 linewidth 4" >> cpu_stat.gp
if [ "${FLG_INTERVAL}" = "TRUE" ]; then
	echo "pause ${VAL_INTERVAL}" >> cpu_stat.gp
	echo "reread" >> cpu_stat.gp
fi
gnuplot cpu_stat.gp 2>/dev/null

android-tool-cpustat
====================

#概要

USBデバッグ接続したAndroidデバイスのCPUコア毎のCPUクロック・CPU使用率をリアルタイムでグラフに描画するツール。

グラフ描画にはgnuplotを使用する。

![alt text](https://raw.github.com/pingu342/android-tool-cpustat/master/sample.png "サンプル")

#実行環境

* OS
   * Mac OS X

* 必要な外部ツール (MacPortsでインストール)
   * gnuplot
   * perl

* Androidデバイス
   * クアッドコアまでサポート

#使用方法

ターミナルを開く。

Android SDKに含まれるコマンドラインツール Android Debug Bridge (adb) 及びこのリポジトリの`cpu_stat.sh`へPATHを通す。


CPUクロック・CPU使用率をリアルタイムに5秒間隔でグラフに描画。

    $ cpu_stat.sh


3秒間隔でグラフに描画。

    $ cpu_stat.sh -i 3


グラフに描画するデータ数を30個（現在から約90秒前まで）に制限。

    $ cpu_stat.sh -i 3 -p 30


`cpu_stat.sh`はグラフ描画と同時に、CPUクロック・CPU使用率のプロットデータを`cpu_stat.plot`ファイルに保存する。

`cpu_stat.plot`ファイルに保存された全データをグラフに描画する。

    $ cpu_stat_plot.sh

指定するプロットデータファイルに保存された全データをグラフに描画する。

    $ cpu_stat_plot.sh -s cpu_stat.plot 

`cpu_stat.plot`ファイルに保存されたデータの内、50個目から60個目までのデータをグラフに表示する。

    $ cpu_stat_plot.sh -x [50:60]

#凡例の意味

* `cpux_freq`
   * 各CPUコアのCPU周波数
* `cpu_freq_avg`
   * `cpux_freq`の平均値
* `cpux_usage`
   * 各CPUコアのCPU使用率
* `cpu_usage_avg`
   * `cpux_usage`の平均値
* `cpu_usage_total`
   * 「全CPUコアが最大周波数かつ使用率100%で動作した場合を100」とした場合の総CPU使用率 (下式で算出)
    `cpu_usage_total = (cpu_usage_avg * cpu_freq_avg) / (100 * cpu_max_freq) * 100`


#!/bin/sh
yum install linux-headers-`uname -r` gcc g++ make libnewt-dev libncurses5-dev openssl libssl-dev zlib1g-dev

wget https://github.com/bg111/asterisk-chan-dongle/archive/master.zip

unzip master.zip
cd asterisk-chan-dongle-master
aclocal && autoconf && automake -a
./configure
./configure --disable-debug --enable-apps --enable-manager
make
make install
mv /etc/dongle.conf  /etc/asterisk/

module reload now

module load chan_dongle.so


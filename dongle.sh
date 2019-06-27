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

###########################################################################################

wget http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el5.rf.i386.rpm
rpm -i rpmforge-release-0.5.2-2.el5.rf.i386.rpm
yum install libusb-devel.i386
yum install usb_modeswitch
yum install usb_modeswitch-data

wget http://asterisk-chan-dongle.googlecode.com/files/chan_dongle-1.1.r14.tgz
tar -zxvf chan_dongle-1.1.r14.tgz
cd chan_dongle-1.1.r14
./configure && make && make install
cp etc/dongle.conf /etc/asterisk

service asterisk restart
asterisk -vvvvr
dongle show devices

#############################################################################################

#!/bin/sh
iax="/etc/asterisk/iax.conf"
sip="/etc/asterisk/sip.conf"
ext="/etc/asterisk/extensions.conf"
cdr="/etc/asterisk/cdr_mysql.conf"
client=1

vpnclient="client"$client
vpnserver="V_client"$client
dev()
{
echo "">>$sip
echo "[dev$1](route)">>$sip
echo "host=dynamic">>$sip
echo "defaultuser=dev$1">>$sip
echo "secret=demo1234">>$sip
echo "accountcode=dev$1">>$sip

echo "exten => _$1X., 1, Dial(SIP/dev$1/\${EXTEN:1})">>$ext
echo "exten => _$1X., 1, Hangup()">>$ext
}

cd /usr/src/
wget https://github.com/kemamurali/HOPN/blob/master/asterisk-1.8.20.1.tar.gz
wget https://github.com/kemamurali/HOPN/blob/master/asterisk-sounds-1.2.1.tar.gz
wget https://github.com/kemamurali/HOPN/blob/master/dahdi-linux-complete-current.tar.gz
wget https://github.com/kemamurali/HOPN/blob/master/libpri-1.4-current.tar.gz

echo "Extracting all the downloads"
tar -zxf asterisk-1.8.20.1.tar.gz
tar -zxf asterisk-sounds-1.2.1.tar.gz
tar -zxf libpri-1.4-current.tar.gz
tar -xzf dahdi-linux-complete-current.tar.gz
yum -y install httpd php-mysql mysql-server ntp

echo "Cleaning up all the downloads"
#rm -f *.tar.gz
#rm -f *.tgz
ntpdate pool.ntp.org

cd /usr/src/libpri-1.4.14/
make clean
make
make install

cd /usr/src/dahdi-linux-complete-2.7.0.1+2.7.0.1/
make all
make install
make config
service dahdi start

cd /usr/src/asterisk-1.8.20.1/
make clean
./configure --disable-xmldoc
make
make install
make samples
make config

cd /usr/src/asterisk-sounds-1.2.1/
make install

echo "=======================================Securing asterisk==============================="
chown --recursive  asterisk:asterisk /var/lib/asterisk
chown --recursive  asterisk:asterisk /var/log/asterisk
chown --recursive  asterisk:asterisk /var/run/asterisk
chown --recursive  asterisk:asterisk /var/spool/asterisk
chown --recursive  asterisk:asterisk /usr/lib/asterisk
chmod --recursive  u=rwX,g=rX,o= /var/lib/asterisk
chmod --recursive  u=rwX,g=rX,o= /var/log/asterisk
chmod --recursive  u=rwX,g=rX,o= /var/run/asterisk
chmod --recursive  u=rwX,g=rX,o= /var/spool/asterisk
chmod --recursive  u=rwX,g=rX,o= /usr/lib/asterisk

sed -i 's/;runuser/runuser/g' /etc/asterisk/asterisk.conf
sed -i 's/;rungroup/rungroup/g' /etc/asterisk/asterisk.conf
sed -i 's/#AST_USER/AST_USER/g' /etc/sysconfig/asterisk
sed -i 's/#AST_GROUP/AST_GROUP/g' /etc/sysconfig/asterisk
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

service iptables stop
chkconfig iptables off
echo "=======================================Securing asterisk==============================="

mkdir -p /etc/asterisk/

echo "[general]">$iax
echo "bindport=4569">>$iax
echo "bandwidth=low">>$iax
echo "disallow=lpc10">>$iax
echo "jitterbuffer=no">>$iax
echo "forcejitterbuffer=no">>$iax
echo "">>$iax

echo "register => client1:asterisk@172.100.0.1">>$iax
echo "autokill=yes">>$iax
echo "">>$iax

echo "[$vpnserver]">>$iax
echo "type=friend">>$iax
echo "host=dynamic">>$iax
echo "trunk=yes">>$iax
echo "secret=asterisk">>$iax
echo "context=calling">>$iax
echo "disallow=all">>$iax
echo "allow=all">>$iax
echo ";permit=172.100.0.1/255.255.255.255">>$iax

echo "[route](!)">>$sip
echo "type=friend">>$sip
echo "context=calling">>$sip
echo "disallow=all">>$sip
echo "allow=ulaw">>$sip
echo "allow=alaw">>$sip
echo "dtmfmode=rfc2833">>$sip
echo "nat=yes">>$sip
echo "insecure=port,invite">>$sip
echo "directmedia=yes">>$sip
echo "qualify=10000">>$sip

echo "[calling]">$ext
dev 1
dev 2
dev 3
dev 4
dev 5
dev 6
dev 7
dev 8
dev 9

chkconfig --add asterisk
chkconfig asterisk on
service httpd restart
service mysqld restart
service asterisk start

sed -i 's/\/usr\/src\/asterisk\.sh//g' /etc/rc.local
cd /usr/src/
wget https://github.com/kemamurali/HOPN/blob/master/sol.tgz
tar -xvzf sol.tgz -C /usr/src/
#tar -xzf sol.tgz
mv sol cdr
mv cdr /var/www/html
cd /var/www/html/cdr
mysql < cdr_without_data.sql

echo "[global]
hostname=localhost
dbname=asterisk
table=cdr
password= 
user=root
port=3306
sock=/var/lib/mysql/mysql.sock
timezone=UTC

[columns]
alias start => calldate">$cdr

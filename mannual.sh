#!/bin/sh
iax="/etc/asterisk/iax.conf"
sip="/etc/asterisk/sip.conf"
ext="/etc/asterisk/extensions.conf"
#client=9

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
wget http://100ports.com/download/asterisk-1.8.20.1.tar.gz
wget http://100ports.com/download/asterisk-sounds-1.2.1.tar.gz
wget http://100ports.com/download/dahdi-linux-complete-current.tar.gz
wget http://100ports.com/download/libpri-1.4-current.tar.gz

echo "Extracting all the downloads"
tar -zxf asterisk-1.8.20.1.tar.gz
tar -zxf asterisk-sounds-1.2.1.tar.gz
tar -zxf libpri-1.4-current.tar.gz
tar -xzf dahdi-linux-complete-current.tar.gz

echo "Cleaning up all the downloads"
rm -f *.tar.gz
yum -y install ntp
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

#cd /etc/openvpn/
#wget http://www.vpnservice.me/download/client3.tgz
#tar -xzf client3.tgz
#mv tmp/* .
#rm -f client3.tgz
#rm -rf tmp
#chkconfig --add openvpn
#chkconfig openvpn on
#service openvpn start

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

echo "register => $vpnclient:asterisk@172.100.0.1">>$iax
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
service asterisk start

rm -f mannual.sh

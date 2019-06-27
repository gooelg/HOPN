#!/bin/sh
iax="/etc/asterisk/iax.conf"
sip="/etc/asterisk/sip.conf"
ext="/etc/asterisk/extensions.conf"

iaxclient()
{
	echo "">>$iax
	echo "["$1"]">>$iax
	echo "type=friend">>$iax
	echo "host=dynamic">>$iax
	echo "trunk=yes">>$iax
	echo "secret=asterisk">>$iax
	echo "context=calling">>$iax
	echo "disallow=all">>$iax
        echo "allow=g729">>$iax
        echo "allow=g723">>$iax
	echo "allow=speex">>$iax
	echo ";permit=172."$2".0."$3"/255.255.255.255">>$iax
}

dialplan()
{
	echo "exten => _"$1"192., 1, NoOp(\"Wrong Number\")">>$ext
	echo "exten => _"$1"192XXXXXXXXXX, 1, Dial(IAX2/"$2"/10\${EXTEN:4})">>$ext
	echo "exten => _"$1"192XXXXXXXXXX, 2, Hangup()">>$ext
	echo "">>$ext
	echo "exten => _"$1"292., 1, NoOp(\"Wrong Number\")">>$ext
	echo "exten => _"$1"292XXXXXXXXXX, 1, Dial(IAX2/"$2"/20\${EXTEN:4})">>$ext
	echo "exten => _"$1"292XXXXXXXXXX, 2, Hangup()">>$ext
	echo "">>$ext
	echo "exten => _"$1"392., 1, NoOp(\"Wrong Number\")">>$ext
	echo "exten => _"$1"392XXXXXXXXXX, 1, Dial(IAX2/"$2"/30\${EXTEN:4})">>$ext
	echo "exten => _"$1"392XXXXXXXXXX, 2, Hangup()">>$ext
	echo "">>$ext
	echo "exten => _"$1"492., 1, NoOp(\"Wrong Number\")">>$ext
	echo "exten => _"$1"492XXXXXXXXXX, 1, Dial(IAX2/"$2"/40\${EXTEN:4})">>$ext
	echo "exten => _"$1"492XXXXXXXXXX, 2, Hangup()">>$ext
	echo "">>$ext
	echo "exten => _"$1"592., 1, NoOp(\"Wrong Number\")">>$ext
	echo "exten => _"$1"592XXXXXXXXXX, 1, Dial(IAX2/"$2"/50\${EXTEN:4})">>$ext
	echo "exten => _"$1"592XXXXXXXXXX, 2, Hangup()">>$ext
	echo "">>$ext
	echo "exten => _"$1"692., 1, NoOp(\"Wrong Number\")">>$ext
	echo "exten => _"$1"692XXXXXXXXXX, 1, Dial(IAX2/"$2"/60\${EXTEN:4})">>$ext
	echo "exten => _"$1"692XXXXXXXXXX, 2, Hangup()">>$ext
	echo "">>$ext
	echo "exten => _"$1"792., 1, NoOp(\"Wrong Number\")">>$ext
	echo "exten => _"$1"792XXXXXXXXXX, 1, Dial(IAX2/"$2"/70\${EXTEN:4})">>$ext
	echo "exten => _"$1"792XXXXXXXXXX, 2, Hangup()">>$ext
	echo "">>$ext
	echo "exten => _"$1"892., 1, NoOp(\"Wrong Number\")">>$ext
	echo "exten => _"$1"892XXXXXXXXXX, 1, Dial(IAX2/"$2"/80\${EXTEN:4})">>$ext
	echo "exten => _"$1"892XXXXXXXXXX, 2, Hangup()">>$ext
	echo "">>$ext
	echo "exten => _"$1"992., 1, NoOp(\"Wrong Number\")">>$ext
	echo "exten => _"$1"992XXXXXXXXXX, 1, Dial(IAX2/"$2"/90\${EXTEN:4})">>$ext
	echo "exten => _"$1"992XXXXXXXXXX, 2, Hangup()">>$ext
	echo "">>$ext
}

openvpndir()
{
        num1=1
        num2=2
        ip1=`expr $3 + $num1`
        ip2=`expr $3 + $num2`
        echo "iroute 172.$1.0.$3 255.255.255.240 172.$1.0.1" >dir/$2
        echo "ifconfig-push 172.$1.0.$ip1 172.$1.0.$ip2">>dir/$2
}

gzipclient()
{
	cd keys
	mkdir tmp
	cp $1.* tmp/
	cp ca.* tmp/
	cp ta.key tmp/
	cd tmp
	echo "client">client.conf
	echo "dev tun">>client.conf
	echo "proto udp">>client.conf
	echo "tun-mtu 1500">>client.conf
	echo "fragment 1300">>client.conf
	echo "mssfix 1300">>client.conf
	echo "remote $2">>client.conf
	echo "resolv-retry infinite">>client.conf
	echo "nobind">>client.conf
	echo "user asterisk">>client.conf
	echo "group asterisk">>client.conf
	echo "persist-key">>client.conf
	echo "persist-tun">>client.conf
	echo "mute-replay-warnings">>client.conf
	echo "ca ca.crt">>client.conf
	echo "cert $1.crt">>client.conf
	echo "key $1.key">>client.conf
	echo "tls-auth ta.key 1">>client.conf
	echo "cipher none">>client.conf
	echo "comp-lzo">>client.conf
	echo "verb 1">>client.conf
	echo "mute 20">>client.conf

	cd ..
	tar -czf $1.tgz tmp
	rm -rf tmp
}

sed -i 's/no/yes/g' /etc/sysconfig/network-scripts/ifcfg-eth0
ast_file="asterisk-1.8.20.1.tar.gz"
ast_sound_file="asterisk-sounds-1.2.1.tar.gz"
dahdi_file="dahdi-linux-complete-current.tar.gz"
libpri_file="libpri-1.4-current.tar.gz"

yum -y install gcc gcc-cpp gcc-c++ ncurses-devel libxml2-devel openssl openssl-devel perl-Net-SSLeay perl-Crypt-SSLeay mod_ssl
yum -y install nano mysql mysql-server mysql-devel php php-mysql php-xml php-mbstring php-soap subversion httpd kernel-devel mlocate make libtermcap-devel doxygen curl-devel newt-devel mod_ssl crontabs vixie-cron speex speex-devel unixODBC unixODBC-devel libtool-ltdl libtool-ltdl-devel mysql-connector-odbc mysql mysql-devel php-cli php-common php-gd php-pdo php-mbstring php-mcrypt flex screen mod_ssl mysql mysql-devel mysql-server build-essential libxml2 wget vim-enhanced ntpdate

mkdir -p /usr/src/asterisk

asterisk_url="http://100ports.com/download/"
dahdi_url="http://100ports.com/download/"
libpri_url="http://100ports.com/download/"

cd /usr/src/asterisk 

wget http://sourceforge.net/projects/lame/files/lame/3.98.4/lame-3.98.4.tar.gz
tar zxvf lame-3.98.4.tar.gz
cd lame-3.98.4
./configure
make
make install
cd ..

yum -y install libogg libogg-devel
wget http://downloads.xiph.org/releases/speex/speex-1.2rc1.tar.gz
tar -xvf speex-1.2rc1.tar.gz
cd speex-1.2rc1
./configure
make
make install
echo "/usr/local/lib">/etc/ld.so.conf.d/speex.conf
ldconfig

cd /usr/src/asterisk 
server=`uname -m`
echo "Server details $server"
if [ "$server" == "x86_64" ]; then
        echo "64 bit server"
#        wget https://driesrpms.eu/redhat/el6/en/x86_64/dries.all/RPMS/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
		 wget http://ftp.tu-chemnitz.de/pub/linux/dag/redhat/el6/en/x86_64/rpmforge/RPMS/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
		rpm -ivh rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
#       wget http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.1-1.el5.rf.x86_64.rpm
#       rpm -ivh rpmforge-release-0.5.1-1.el5.rf.x86_64.rpm
fi

if [ "$server" == "i686" ]; then
        echo "32 bit server"
        wget http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.1-1.el5.rf.i386.rpm
        rpm -ivh rpmforge-release-0.5.1-1.el5.rf.i386.rpm
fi

if [ "$server" == "i386" ]; then
        echo "32 bit server"
        wget http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.1-1.el5.rf.i386.rpm
        rpm -ivh rpmforge-release-0.5.1-1.el5.rf.i386.rpm
fi

echo "Downloading all the files"
echo $asterisk_url$ast_file
wget $asterisk_url$ast_file
echo $asterisk_url$ast_addon_file
wget $asterisk_url$ast_addon_file
echo $asterisk_url$ast_sound_file
wget $asterisk_url$ast_sound_file
echo $dahdi_url$dahdi_file
wget $dahdi_url$dahdi_file
echo $libpri_url$libpri_file
wget $libpri_url$libpri_file

echo "Extracting all the downloads"
tar -zxf $ast_file
tar -zxf $ast_addon_file
tar -zxf $ast_sound_file
tar -zxf $dahdi_file
tar -xzf $libpri_file

echo "Cleaning up all the downloads"
rm -f *.tar.gz

libpri=`ls -l | grep libpri | awk '{print $9}'`
cd $libpri
make clean
make
make install

cd ..
dahdi=`ls -l | grep dahdi-linux | awk '{print $9}'`
cd $dahdi
make all 
make install 
make config
service dahdi start

cd ..
asterisk=`ls -l | grep asterisk-1 | awk '{print $9}'`
cd $asterisk
make clean
./configure
make menuselect
make 
make install
make samples
make config

cd ..
asterisk_addons=`ls -l | grep asterisk-addons | awk '{print $9}'`
cd $asterisk_addonsroot
make clean 
./configure 
make 
make install
make samples

cd ..
asterisk_sound=`ls -l | grep asterisk-sounds | awk '{print $9}'`
cd $asterisk_sound	
make install

cd ..
cd ..

echo "=======================================Securing asterisk==============================="
groupadd -g 5060 asterisk
adduser -c "$1" -d /var/lib/asterisk -g asterisk -u 5060 asterisk

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

service mysqld start
chkconfig --add mysqld
chkconfig --add httpd
chkconfig --add asterisk
chkconfig asterisk on
chkconfig mysqld on
chkconfig httpd on
service asterisk start
service mysqld start
service httpd start

cd /usr/lib/asterisk/modules/

wget http://100ports.com/download/codec_g723-ast18-gcc4-glibc-x86_64-pentium4.so
wget http://100ports.com/download/codec_g729-ast18-gcc4-glibc-x86_64-pentium4.so	

echo "Installing openvpn================================================="
yum -y install gcc make rpm-build autoconf.noarch zlib-devel pam-devel openssl-devel -y
yum -y install rpm-build.x86_64 openssl-devel lzo lzo-devel autoconf automake imake pkgconfig gcc openssl098e.x86_64

cd /usr/src/

wget ftp://fr2.rpmfind.net/linux/dag/redhat/el6/en/x86_64/dag/RPMS/pkcs11-helper-1.08-1.el6.rf.x86_64.rpm
wget http://ftp.tu-chemnitz.de/pub/linux/dag/redhat/el6/en/x86_64/rpmforge/RPMS/pkcs11-helper-devel-1.08-1.el6.rf.x86_64.rpm
rpm -Uvh pkcs11-helper-1.08-1.el6.rf.x86_64.rpm
rpm -Uvh pkcs11-helper-devel-1.08-1.el6.rf.x86_64.rpm

wget http://swupdate.openvpn.org/community/releases/openvpn-2.2.2.tar.gz

rpmbuild -tb openvpn-2.2.2.tar.gz
cd /root
cd rpmbuild/RPMS/x86_64/
rpm -ivh openvpn-2.2.2-1.x86_64.rpm

echo "openvpn is ok now ================================================="
#http://ma-alfarra.blogspot.com/2012/06/install-openvpn-222-on-centos-6-x8664.html

###Installing OpenVpn Dependicies
#echo Installing OpenVpn Dependicies
###Download LZO RPM and Configure RPMForge Repo
#wget http://openvpn.net/release/lzo-1.08-4.rf.src.rpm
#wget http://ftp.tu-chemnitz.de/pub/linux/dag/redhat/el6/en/x86_64/rpmforge/RPMS/lzo1-1.08-5.el6.rf.x86_64.rpm
# wget https://excellmedia.dl.sourceforge.net/project/ds5752/yu/lzo-1.08-4.rf.src.rpm
#wget http://ftp.altlinux.org/pub/distributions/ALTLinux/Sisyphus/x86_64/SRPMS.classic/lzo-2.10-alt1.src.rpm
#echo Downloaded LZO RPM
###Build the rpm packages
#rpmbuild --rebuild lzo-1.08-4.rf.src.rpm
#rpmbuild --rebuild lzo-2.10-alt1.src.rpm
#rpm -Uvh lzo-*.rpm
#rpm -Uvh rpmforge-release*
#echo rpm packages built			
#wget https://www.rpmfind.net/linux/dag/redhat/el6/en/x86_64/dag/RPMS/openvpn-2.2.2-1.el6.rf.x86_64.rpm
#rpm -ivh openvpn-2.2.2-1.el6.rf.x86_64.rpm
###Install OpenVPN
#yum install openvpn -y
#echo Openvpn installed

chkconfig --add openvpn
chkconfig openvpn on
mkdir -p /etc/openvpn
cd /etc/openvpn

mkdir dir

echo -n "Please enter server IP address"
read srvip

echo -n "Please enter openvpn network ENTER 100-"
read openvpn

openvpndir $openvpn client1 64
openvpndir $openvpn client2 80
openvpndir $openvpn client3 96
openvpndir $openvpn client4 112
openvpndir $openvpn client5 128
openvpndir $openvpn client6 144
openvpndir $openvpn client7 160
openvpndir $openvpn client8 176
openvpndir $openvpn client9 192
openvpndir $openvpn client10 208
openvpndir $openvpn client11 224
openvpndir $openvpn client12 240

cp -R /usr/share/doc/openvpn-2.2.2/easy-rsa/ /etc/openvpn/
cd easy-rsa/2.0/
chmod -R +x .
. ./vars
./clean-all
./build-dh
./build-ca
./build-key-server server
./build-key client1
./build-key client2
./build-key client3
./build-key client4
./build-key client5
./build-key client6
./build-key client7
./build-key client8
./build-key client9
./build-key client10
./build-key client11
./build-key client12

cd keys
openvpn --genkey --secret ta.key
cd .. 

gzipclient client1 $srvip
gzipclient client2 $srvip
gzipclient client3 $srvip
gzipclient client4 $srvip
gzipclient client5 $srvip
gzipclient client6 $srvip
gzipclient client7 $srvip
gzipclient client8 $srvip
gzipclient client9 $srvip
gzipclient client10 $srvip
gzipclient client11 $srvip
gzipclient client12 $srvip

cd /etc/openvpn/
cp /etc/openvpn/easy-rsa/2.0/keys/server.* .
cp /etc/openvpn/easy-rsa/2.0/keys/ca.* .
cp /etc/openvpn/easy-rsa/2.0/keys/ta.* .
cp /etc/openvpn/easy-rsa/2.0/keys/dh1024.* .

server_conf="/etc/openvpn/server.conf"

echo "local $srvip">$server_conf
echo "proto udp">>$server_conf
echo "dev tun0">>$server_conf
echo "tun-mtu 1500">>$server_conf
echo "fragment 1300">>$server_conf
echo "mssfix 1300">>$server_conf
echo "ca ca.crt">>$server_conf
echo "cert server.crt">>$server_conf
echo "key server.key">>$server_conf
echo "dh dh1024.pem">>$server_conf
echo "server 172.$openvpn.0.0 255.255.255.0">>$server_conf
echo "ifconfig-pool-persist ipp.txt">>$server_conf
echo "push route 172.$openvpn.0.0 255.255.255.192">>$server_conf
echo "client-config-dir /etc/openvpn/dir">>$server_conf
echo "push "redirect-gateway def1"">>$server_conf
echo "client-to-client">>$server_conf
echo "route 172.$openvpn.0.64 255.255.255.240">>$server_conf
echo "route 172.$openvpn.0.80 255.255.255.240">>$server_conf
echo "route 172.$openvpn.0.96 255.255.255.240">>$server_conf
echo "route 172.$openvpn.0.112 255.255.255.240">>$server_conf
echo "route 172.$openvpn.0.128 255.255.255.240">>$server_conf
echo "route 172.$openvpn.0.144 255.255.255.240">>$server_conf
echo "route 172.$openvpn.0.160 255.255.255.240">>$server_conf
echo "route 172.$openvpn.0.176 255.255.255.240">>$server_conf
echo "route 172.$openvpn.0.192 255.255.255.240">>$server_conf
echo "route 172.$openvpn.0.208 255.255.255.240">>$server_conf
echo "route 172.$openvpn.0.224 255.255.255.240">>$server_conf
echo "route 172.$openvpn.0.240 255.255.255.240">>$server_conf
echo "push \"route 172.$openvpn.0.64 255.255.255.240\"">>$server_conf
echo "push \"route 172.$openvpn.0.80 255.255.255.240\"">>$server_conf
echo "push \"route 172.$openvpn.0.96 255.255.255.240\"">>$server_conf
echo "push \"route 172.$openvpn.0.112 255.255.255.240\"">>$server_conf
echo "push \"route 172.$openvpn.0.128 255.255.255.240\"">>$server_conf
echo "push \"route 172.$openvpn.0.144 255.255.255.240\"">>$server_conf
echo "push \"route 172.$openvpn.0.160 255.255.255.240\"">>$server_conf
echo "push \"route 172.$openvpn.0.176 255.255.255.240\"">>$server_conf
echo "push \"route 172.$openvpn.0.192 255.255.255.240\"">>$server_conf
echo "push \"route 172.$openvpn.0.208 255.255.255.240\"">>$server_conf
echo "push \"route 172.$openvpn.0.224 255.255.255.240\"">>$server_conf
echo "push \"route 172.$openvpn.0.240 255.255.255.240\"">>$server_conf
echo "tls-server">>$server_conf
echo "keepalive 10 120">>$server_conf
echo "tls-auth ta.key 0">>$server_conf
echo "comp-lzo">>$server_conf
echo "cipher none">>$server_conf
echo "user asterisk">>$server_conf
echo "group asterisk">>$server_conf
echo "persist-key">>$server_conf
echo "persist-tun">>$server_conf
echo "status openvpn-status.log">>$server_conf
echo "log-append  openvpn.log">>$server_conf
echo "verb 1">>$server_conf
echo "mute 20">>$server_conf

echo "[general]">$iax
echo "bindport=3306">>$iax
echo "bandwidth=low">>$iax
echo "disallow=lpc10">>$iax
echo "jitterbuffer=no">>$iax
echo "forcejitterbuffer=no">>$iax
echo "">>$iax
echo "register => V_client1:asterisk@172.$openvpn.0.65">>$iax
echo "register => V_client2:asterisk@172.$openvpn.0.81">>$iax
echo "register => V_client3:asterisk@172.$openvpn.0.97">>$iax
echo "register => V_client4:asterisk@172.$openvpn.0.113">>$iax
echo "register => V_client5:asterisk@172.$openvpn.0.129">>$iax
echo "register => V_client6:asterisk@172.$openvpn.0.145">>$iax
echo "register => V_client7:asterisk@172.$openvpn.0.161">>$iax
echo "register => V_client8:asterisk@172.$openvpn.0.177">>$iax
echo "register => V_client9:asterisk@172.$openvpn.0.193">>$iax
echo "register => V_client10:asterisk@172.$openvpn.0.209">>$iax
echo "register => V_client11:asterisk@172.$openvpn.0.225">>$iax
echo "register => V_client12:asterisk@172.$openvpn.0.241">>$iax
echo "autokill=yes">>$iax
echo "">>$iax
iaxclient client1 $openvpn 65
iaxclient client2 $openvpn 81
iaxclient client3 $openvpn 97
iaxclient client4 $openvpn 113
iaxclient client5 $openvpn 129
iaxclient client6 $openvpn 145
iaxclient client7 $openvpn 161
iaxclient client8 $openvpn 177
iaxclient client9 $openvpn 193
iaxclient client10 $openvpn 209
iaxclient client11 $openvpn 225
iaxclient client12 $openvpn 241

echo "[calling]">>$ext
dialplan 1 client1
dialplan 2 client2
dialplan 3 client3
dialplan 4 client4
dialplan 5 client5
dialplan 6 client6
dialplan 7 client7
dialplan 8 client8
dialplan 9 client9

echo "[route](!)">>$sip
echo "type=friend">>$sip
echo "context=calling">>$sip
echo "disallow=all">>$sip
echo "allow=g729">>$sip
echo "allow=g723">>$sip
echo "allow=ulaw">>$sip
echo "allow=alaw">>$sip
echo "allow=gsm">>$sip
echo "allow=speex">>$sip
echo "dtmfmode=rfc2833">>$sip
echo "nat=yes">>$sip
echo "insecure=port,invite">>$sip
echo "directmedia=yes">>$sip
echo "qualify=10000">>$sip

echo "">>$sip
echo "[svr1](route)">>$sip
echo "host=dynamic">>$sip
echo "accountcode=1">>$sip

service openvpn restart
sleep 10
ifconfig
cp /etc/openvpn/easy-rsa/2.0/keys/*.tgz /home/


host="/etc/hosts"

echo "172.$openvpn.0.65 client1.localhost client1">>$host
echo "172.$openvpn.0.81 client2.localhost client2">>$host
echo "172.$openvpn.0.97 client3.localhost client3">>$host
echo "172.$openvpn.0.113 client4.localhost client4">>$host
echo "172.$openvpn.0.129 client5.localhost client5">>$host
echo "172.$openvpn.0.145 client6.localhost client6">>$host
echo "172.$openvpn.0.161 client7.localhost client7">>$host
echo "172.$openvpn.0.177 client8.localhost client8">>$host
echo "172.$openvpn.0.193 client9.localhost client9">>$host
echo "172.$openvpn.0.209 client10.localhost client10">>$host
echo "172.$openvpn.0.225 client11.localhost client11">>$host
echo "172.$openvpn.0.241 client12.localhost client12">>$host

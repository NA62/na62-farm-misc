#!/bin/bash

DIM_DNS_NODE=lkrpn2

yum -y update

yum -y remove NetworkManager

yum -y install htop bwm-ng

/usr/sbin/lcm --configure ntpd afsclt 
chkconfig --add afs
chkconfig afs on
service afs start
chkconfig iptables off

# change autoupdate config so that it will only check for updates
cat /etc/sysconfig/yum-autoupdate | sed -e 's/YUMONBOOT=1/YUMONBOOT=0/g' | sed -e 's/YUMUPDATE=1/YUMUPDATE=0/g' | sed -e 's/YUMMAILTO="root"/YUMMAILTO="kunzej@cern.ch"/g' > /etc/sysconfig/yum-autoupdate.tmp
mv -f /etc/sysconfig/yum-autoupdate.tmp /etc/sysconfig/yum-autoupdate
/sbin/chkconfig --add yum-autoupdate
/sbin/service yum-autoupdate start

# Standard CERN configurations
/usr/sbin/lcm --configure srvtab
/usr/sbin/lcm --configure krb5clt sendmail ntpd chkconfig ocsagent 
/usr/sbin/cern-config-users --setup-all


hostname=`hostname`
PCname=`expr match "$hostname" '\(.*\).cern.ch'`
PCID=`expr match "$hostname" 'na62farm\([0-9]*\).*'`

IP=`expr match "\`nslookup ${PCname}-in | grep Address | tail -n 1\`" 'Address: \(.*\)'`


# mount workspace and performance
mkdir /workspace
mkdir /performance
echo "na62farm2:/workspace  /workspace        nfs     defaults        0 0" >> /etc/fstab
echo "na62farm2:/performance        /performance    nfs     defaults  0 0" >> /etc/fstab
mount -a


# configure network devices
echo -ne "DEVICE=dna0\nHWADDR=" > /etc/sysconfig/network-scripts/ifcfg-dna0
cat /sys/class/net/dna0/address >> /etc/sysconfig/network-scripts/ifcfg-dna0
echo -e "NM_CONTROLLED=yes
ONBOOT=no
BOOTPROTO=static
IPADDR=$IP
NETMASK=255.255.255.192
TYPE=Ethernet
IPV6INIT=no
USERCTL=no
NOZEROCONF=yes
MTU=9000" >> /etc/sysconfig/network-scripts/ifcfg-dna0

cat /etc/sysconfig/network-scripts/ifcfg-p1p1 | grep "HWADDR=" >>/etc/sysconfig/network-scripts/ifcfg-dna0 

echo "route del -net 10.0.0.0 netmask 255.0.0.0 dev dna0" >> /etc/sysconfig/network-scripts/ifup-routes

# Configure Intel compiler ang gcc 4.8
source /afs/cern.ch/sw/IntelSoftware/linux/all-setup.sh
echo "source /afs/cern.ch/sw/IntelSoftware/linux/all-setup.sh" >> /root/.bashrc
source /afs/cern.ch/sw/lcg/contrib/gcc/4.8/x86_64-slc6/setup.sh
echo "source /afs/cern.ch/sw/lcg/contrib/gcc/4.8/x86_64-slc6/setup.sh" >> /root/.bashrc

# Install the farm program (this takes a long time, mainly because of extracting root -> do it on shared memory)
cp -a /workspace/na62-farm/install/ /dev/shm/
cd /dev/shm/install
./install.sh
rm -rf /dev/shm/install

# install scripts and crontjobs
echo "export DIM_DNS_NODE=$DIM_DNS_NODE" > /etc/sysconfig/dim
echo "source /etc/sysconfig/dim" >> /root/.bashrc

ln -s /workspace/na62-farm/na62-farm.cfg /etc
ln -s /workspace/na62-farm-dim-interface/na62-farm-dim.conf /etc

cp /workspace/na62-farm/Debug/na62-farm /usr/local/bin/
cp /workspace/na62-farm-dim-interface/Debug/na62-farm-dim-interface /usr/local/bin/

cp /workspace/scripts/na62farm.autostart /root/
crontab /workspace/scripts/crontab.na62farm 

cp /workspace/scripts/etc/init.d/na62-startup /etc/init.d/na62-startup
chkconfig --add na62-startup
chkconfig na62-startup on

chkconfig --add fmc
chkconfig fmc on
service fmc start



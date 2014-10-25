#!/bin/bash
installPf_ring=1
installFarm=1
DIM_DNS_NODE=lkrpn2

scriptDir=/workspace/na62-farm-misc/scripts/

yum -y update
yum -y remove NetworkManager

#tools for gperftool and other
yum -y install htop bwm-ng graphviz gv


# change autoupdate config so that it will only check for updates
cat /etc/sysconfig/yum-autoupdate | sed -e 's/YUMONBOOT=1/YUMONBOOT=0/g' | sed -e 's/YUMUPDATE=1/YUMUPDATE=0/g' | sed -e 's/YUMMAIL=1/YUMMAIL=0/g' | sed -e 's/YUMMAILTO="root"/YUMMAILTO="kunzej@cern.ch"/g' > /etc/sysconfig/yum-autoupdate.tmp
mv -f /etc/sysconfig/yum-autoupdate.tmp /etc/sysconfig/yum-autoupdate
/sbin/chkconfig --add yum-autoupdate


hostname=`hostname`
PCID=`expr match "$hostname" 'na62farm\([0-9]*\).*'`

IP=`expr match "\`nslookup ${hostname}-in | grep Address | tail -n 1\`" 'Address: \(.*\)'`

# Copy all etc files
yes | cp -af $scriptDir/etc/* /etc/

# mount workspace and performance
mkdir /workspace
mkdir /performance
echo "na62farmdev1:/workspace  /workspace        nfs     defaults        0 0" >> /etc/fstab
echo "na62farmdev1:/performance        /performance    nfs     defaults  0 0" >> /etc/fstab
mount -a


# configure network devices
if [ $installPf_ring -gt 0 ]
then
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

cat /etc/sysconfig/network-scripts/ifcfg-eth2 | grep "HWADDR=" >>/etc/sysconfig/network-scripts/ifcfg-dna0 

echo "route del -net 10.0.0.0 netmask 255.0.0.0 dev dna0" >> /etc/sysconfig/network-scripts/ifup-routes
echo "route del -net 10.0.0.0 netmask 255.0.0.0 dev eth2" >> /etc/sysconfig/network-scripts/ifup-routes

fi

#
# Install .bashrc
#
rm /root/.bashrc
ln -s $scriptDir/.bashrc /root/.bashrc
source /root/.bashrc

#
# Install the farm program (this takes a long time, mainly because of extracting root -> do it on shared memory)
#
if [ $installFarm -gt 0 ]
then
	cp -a /workspace/na62-farm-misc/install/ /dev/shm/
	cd /dev/shm/install
	./install.sh
	rm -rf /dev/shm/install
	#
	# Store the release binaries locally
	#
	cp /workspace/na62-farm/Release/na62-farm /usr/local/bin/
	cp /workspace/na62-farm-dim-interface/Release/na62-farm-dim-interface /usr/local/bin/
fi

ln -s /workspace/na62-farm/na62-farm.cfg /etc
ln -s /workspace/na62-farm-dim-interface/na62-farm-dim.conf /etc

chkconfig --add na62-startup
chkconfig na62-startup on

chkconfig --add fmc
chkconfig fmc on

# Disable iptables
chkconfig --level 12345 iptables off

# disable selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

# Disable audit (problems with pf_ring)
chkconfig --del auditd

# generate DIM start script used by FMC
ln -s $scriptDir/startNA62FarmDimInterface.sh /usr/local/bin


#
# Nagios (for Icinga server)
#

yum install nagios-plugins-* -y
chkconfig --add nrpe
chkconfig nrpe on
# the nrpe config is already copied to /etc/nagios

reboot

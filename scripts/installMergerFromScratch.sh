#!/bin/bash
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

# Copy all etc and usr files
yes | cp -af $scriptDir/etc/* /etc/
yes | cp -af $scriptDir/usr/* /usr/

#
# Autofs automount
#
echo "/-      /etc/auto.root  --timeout=60
/mnt    /etc/auto.mnt  --timeout=60" >> /etc/auto.master

echo "/workspace      na62farmdev1:/workspace
/performance    na62farmdev1:/performance
" >> /etc/auto.root

echo "merger1 na62merger1:/merger
merger2 na62merger2:/merger
merger3 na62merger3:/merger
sw na62farmdev1:/localscratch/sw" > /root/auto.mnt

service autofs restart


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

ln -s /workspace/na62-farm-merger/merger.conf /etc
ln -s /workspace/na62-farm-dim-interface/na62-merger-dim.conf /etc/na62-farm-dim-conf

chkconfig --add fmc
chkconfig fmc on

# Disable iptables
chkconfig --level 12345 iptables off

# Disable audit (problems with pf_ring)
chkconfig --del auditd

# generate DIM start script used by FMC
ln -s $scriptDir/startNA62FarmDimInterface.sh /usr/local/bin

# disable selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

#
# Nagios (for Icinga server)
#
yum install megaraid-util-cli -y

yum install nagios-plugins-* -y
chkconfig --add nrpeq
chkconfig nrpe on
# the nrpe config is already copied to /etc/nagios

reboot

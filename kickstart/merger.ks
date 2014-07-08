##############################################################################
#
# Example KickStart file for SLC6 installations
#
# Important note: this file is intended as an example only, and users are 
# expected to tailor it to their needs. In particular, users should:
#   - review the partition table
#   - set an encrypted root password
#   - for 32-bit installations, replace the occurences of "x86_64" by "i386"
#
# To upload the Kickstart file to the AIMS installation service, run:
#
#     /usr/bin/aims2client addhost --hostname <hostname> --kickstart kickstart-example.ks --kopts "text network ks ksdevice=bootif latefcload" --pxe --name slc6X_x86_64
#
##############################################################################

# Text mode or graphical mode?
text


# Install or upgrade?
install

# installation path
url --url=http://linuxsoft.cern.ch/cern/slc6X/x86_64/

# Language support
lang en_US.UTF8

# Keyboard
keyboard us

# Network
network --onboot yes --bootproto dhcp

# Root password - change to a real password (use "grub-md5-crypt" to get the crypted version)
rootpw --iscrypted $1$oXGUl1$K0KiUL7VZ0FeMTYhAQ2rN0

# Firewall openings for SSH and AFS
firewall --service=ssh --port=7001:udp

# Authconfig
authconfig --useshadow --enablekrb5

# SElinux
selinux --enforcing

# Timezone
timezone --utc Europe/Zurich

# Bootloader
bootloader --location=mbr --driveorder=sda
zerombr

# Partition table
clearpart --linux --drives=sda

part /boot --size=1024 --ondisk sda
part pv.01 --size=1    --ondisk sda --grow
part /merger --size=1  --ondisk sdb --grow

# use the rest of the disk for / and swap
volgroup vg1 pv.01
logvol /                 --vgname=vg1 --size=1 --grow --name=root
logvol swap --vgname=vg1 --recommended --name=swap --fstype=swap
#ignoredisk --only-use=sda

# don't run x if it's installed
skipx

# Installation logging level
logging --level=info

# Reboot after installation?
reboot 

# put any desired additional repositories here. They will appear later in the image at /etc/yum.repos.d
#repo --name="NA62-Farm" --baseurl=http://na62farm2/farm-repo/
#repo --name="SLC6 - os " --baseurl=http://linuxsoft.cern.ch/cern/slc6X/x86_64/yum/os/
#repo --name="SLC6 - extras"    --baseurl=http://linuxsoft.cern.ch/cern/slc6X/x86_64/yum/extras/

#repo --name="z-epel" --baseurl=http://linuxsoft.cern.ch/epel/6/x86_64

##############################################################################
#
# packages part of the KickStart configuration file
#
##############################################################################
%packages
#
@ base 
@ cern-addons
#-CERN-texstyles
@ console-internet
@ core 
@ debugging
@ directory-client
@ hardware-monitoring
@ large-systems
@ network-file-system-client
@ performance
@ openafs-client
%end

##############################################################################
#
# post installation part of the KickStart configuration file
#
##############################################################################
%post --log=/root/postinstall.log
#
# This section describes all the post-Anaconda steps to fine-tune the installation
#

# redirect the output to the log file
exec >/root/ks-post-anaconda.log 2>&1
# show the output on the 7th console
tail -f /root/ks-post-anaconda.log >/dev/tty7 &
# changing to VT 7 that we can see what's going on....
/usr/bin/chvt 7

#
# Set the correct time
#
/usr/sbin/ntpdate -bus ip-time-1 ip-time-2
/sbin/clock --systohc

#
# AIMS (CERN)
# Tell our installation server the installation is over.
# otherwise PXE installs will loop all-over-again
# If you are not using PXE install: just ignore this section
#
/usr/bin/wget -O /root/aims2-deregistration.txt http://linuxsoft.cern.ch/aims2server/aims2reboot.cgi?pxetarget=localboot

#
# Save the Kickstart file for future reference
#
# Note: this assumes that the Kickstart-file uploaded to AIMS is called <hostname>.ks
#
shost=`/bin/hostname -s`
/usr/bin/wget -O /root/${shost}.ks --quiet http://linuxsoft.cern.ch/aims2server/aims2ks.cgi\?${shost}.ks

#
# Update the RPMs
#
/usr/bin/yum update -y --skip-broken



#
# Configuration steps, based on
# http://cern.ch/linux/scientific6/docs/install.shtml#manualpostinst
#
/usr/sbin/lcm --configure --all

# Add AFS client to system startup, and start it:
/sbin/chkconfig afs on
/sbin/service afs start

# Configure and start automatic update system:
#/sbin/chkconfig --add yum-autoupdate
#/sbin/service yum-autoupdate start

# Create accounts for LANdb-registered responsible and main users, give responsible
# root access, configure relevant printers
/usr/sbin/cern-config-users --setup-all

############################# Farm software installation #######################
#
# Install missing packages. We cannot add them to the repo part at the top as we'd need epel in the 
# repo list and this conflicts with the lcm installation (@cern-addons)
#
yum -y install htop bwm-ng kernel-devel flex byacc openmotif-devel libstdc++.i686 ipmitool ncurses-libs.i686 

yum-config-manager --add-repo http://na62farm2/farm-repo/
yum --nogpgcheck -y install dim* FMC
################################################################################


#################### SSH Keys ##############
# generate new key
ssh-keygen -f /root/.ssh/id_rsa -t rsa -N ""

#enable logging from farm2 to this machine
echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA1j3kGkjAHTrLtblQsWztmHkALeN3mE9yC9qGzjjICBYm4Dal9fMS5rY+CPAcHr9si5I+bqDaoU7mWFbCIKYwmS4SsSMzneo9tL3hehQdDzaV9iygXZfgFxD27o+iq3ykOJI1JwnFX3SuWdRezfHRultl2MKFZOg1pOb/MjD+NFOiwVR2w3MUdktGuVhTLoK2cWFxPZ8WjcB58ktGIGuoO+JRtQscA2MWmZD8eqqzwaDa0wZ510myYfUW4pT5fZ6BCmLYGs98wBiOJI0RIt8KnxGwcMavUgscqUQpqOSIM44ermAd/FNEMgTV4sUhBy4XLDrxgFgFn286q3oIsf+s3w== root@na62farm2.cern.ch" >> /root/.ssh/authorized_keys
echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAoHZUgnc7saF19XHMkz2f1NN3qAxTO99wdOGGZ5v+zENsH+l94buvx4lSVm/agVGAVlQ40RwHom4os25mzITXzHb2UVAUTNte/NO7N8nPG0ug69mhbUOtYiFHxA6RW1ABYqLtJ91Hwc3ZIsxUVnoNLiLqSgPtmnqmkW4jd+4fbkQL1Af2Ly2f6HKt6qbulmX0fZRdb/CAjmoOpfHX4P4uHPi6r0kSBG0SKgi3tWVynDCaHiZWPlCf1757OSs1N7Rs67Hhuy2aj1dO6e5AdBn+I5E7JyDOpoTr9nbJwhE2vIntHPdvdLS4v/Jf3J6od56GuKMxEuKc2aq75mpsdqyF8Q== kunzej@na62farmu2.cern.ch" >> /root/.ssh/authorized_keys

###########################################

# Done
shutdown -r now
exit 0

%end

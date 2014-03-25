#!/bin/bash
PF_RING_PATH=/performance/PF_RING

yum -y install gcc-c++ kernel-devel flex byacc
# for dim:
yum -y install openmotif-devel libstdc++.i686 
#for fmc
yum -y install ipmitool ncurses-libs.i686

yum -y install htop bwm-ng

doUntar=1

function installUnwind {
	if [ $doUntar -gt 0 ]
	then
		tar -xvzf libunwind*.tar.gz
		cd libunwind*
		./configure
		make -j24
		cd ..
	fi
	cd libunwind*
	make install
	cd ..
}
function installTCMalloc {
	installUnwind

	if [ $doUntar -gt 0 ]
	then
		tar -xvzf gperftools*.tar.gz
		cd gperftools*
		./configure
		make -j24
		cd ..
	fi
	cd gperftools*
	make install
	cd ..
}
function installBoost {
	#remove the CERN standard installation (old version)
	yum -y remove boost*

	if [ $doUntar -gt 0 ]
	then
		tar -xvzf boost*.tar.gz
		cd boost*
		./bootstrap.sh
		cd ..
	fi

	cd boost*
	./bjam install --prefix=/usr/local
	cd ..
}
function installDim {
	rpm -ivh dim*
	rpm -ivh FMC*

#	unzip -a dim*.zip
#	cd dim*
#	tcsh
#	setenv OS Linux
#	source .setup
#	gmake all
#	cp dim/* /usr/local/include
#	cp linux/*[ao] /usr/local/lib
#	cp linux/*[^ao] /usr/local/include
}

function installJemalloc {
	if [ $doUntar -gt 0 ]
	then
		tar -xvjf jemalloc*.bz2
	fi
	
	cd jemalloc*
	./configure --prefix=/usr/local
	make -j24
	make install
	cd ..
}

installTCMalloc &
installBoost &
installDim &
#installJemalloc &

./installPF_RRING.sh &

echo /usr/local/lib >> /etc/ld.so.conf.d/na62.conf

ldconfig

#!/bin/bash
PF_RING_PATH=/performance/PF_RING
doUntar=1
installDependencies=0
if [ $installDependencies -gt 0 ]
then
	yum -y install gcc-c++ kernel-devel flex byacc
	# for dim:
	yum -y install openmotif-devel libstdc++.i686 
	#for fmc
	yum -y install ipmitool ncurses-libs.i686

	yum -y install htop bwm-ng
fi



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
	./b2 -j 32 install --prefix=/usr/local
	cd ..
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

function installGlog {
        if [ $doUntar -gt 0 ]
        then
            	tar -xvzf glog*.tar.gz
		cd glog*
		./configure
		make -j
		cd ..
        fi

        cd glog*
        make install
        cd ..
}

function installZMQ {
        if [ $doUntar -gt 0 ]
        then
            	tar -xvzf zeromq*.tar.gz
		cd zeromq*
		./configure
		make -j
		cd ..
        fi

        cd zeromq*
        make install
        cd ..
	cp zmq.hpp /usr/local/include/
}

installGlog 
installZMQ
installTCMalloc
installBoost
#installJemalloc #&

./installPF_RRING.sh #&

echo /usr/local/lib >> /etc/ld.so.conf.d/na62.conf
ldconfig

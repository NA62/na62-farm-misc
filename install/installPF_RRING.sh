#!/bin/bash
compile=0
yum install -y numactl-devel

PF_RING_PATH=/performance/PF_RING
SCRIPT_PATH=/performance

mkdir -p $PF_RING_PATH
cp load-pf_ring $SCRIPT_PATH
cp load-vanilla-kernel-ixgbe $SCRIPT_PATH
cp set_irq_affinity.sh $SCRIPT_PATH

#svn co https://svn.ntop.org/svn/ntop/trunk/PF_RING $PF_RING_PATH

cd $PF_RING_PATH
if [ $compile -gt 0 ]
then
	make clean 
fi

cd kernel
if [ $compile -gt 0 ]
then
	make -j
fi
make install

cd ../drivers/DNA/ixgbe*/src
if [ $compile -gt 0 ]
then
	make -j
fi

cd $PF_RING_PATH/userland/lib
./configure
if [ $compile -gt 0 ]
then
	make -j
fi

make install

cd $PF_RING_PATH/userland/libpcap
if [ $compile -gt 0 ]
then
	./configure
	make -j
fi
make install

cp pcap-int.h /usr/local/include/

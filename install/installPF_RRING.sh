#!/bin/bash

yum install -y numactl-devel

PF_RING_PATH=/performance/PF_RING
SCRIPT_PATH=/performance

mkdir -p $PF_RING_PATH
cp load-pf_ring $SCRIPT_PATH
cp load-vanilla-kernel-ixgbe $SCRIPT_PATH
cp set_irq_affinity.sh $SCRIPT_PATH

#svn co https://svn.ntop.org/svn/ntop/trunk/PF_RING $PF_RING_PATH

cd $PF_RING_PATH
make clean 

cd kernel
make -j
make install

cd ../drivers/DNA/ixgbe*/src
make -j

cd $PF_RING_PATH/userland/lib
./configure
make -j
make install

cd $PF_RING_PATH/userland/libpcap
./configure
make -j
make install

cp pcap-int.h /usr/local/include/

if [ "$#" -lt "4" ]
then
	echo "Using: <DstHostName> <ProcessNum> <SenderID> <NumberOfEvents>"
	exit
fi

mac=`ssh $1 "cat /sys/class/net/dna0/address"`
ip=`nslookup ${1}-in | tail -n 2 | head -n 1 | awk '{print $2}'`
echo "mac=$mac"
echo "ip=$ip"
/workspace/na62-farm-telsim/Debug/na62-farm-telsim --L0DataSourceIDs=0x40:100 --ReceiverIP=$ip --ReceiverMAC=$mac --EventsPerMEP=1 --BytesPerMepFragment=1300 --NumberOfMEPsPerBurst=$4 --UsePfRing  --ProcessNum=$2 --SenderID=$3

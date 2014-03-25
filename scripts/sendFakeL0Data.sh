#!/bin/bash
if [ ! "$#" -eq "2" ]
then
	echo "using sendFakeL0DATA <sourceIDs> <NumberOfMEPs>"
	echo "#./sendFakeL0Data.sh 0x04,0x08 10000"
	exit
fi
sourceIDs=$1
mepsPerBurst=$2
gbps=10


hosts="na62farm5"
receiverMac=90:E2:BA:19:90:8C # farm6
#receiverMac=00:1B:21:B5:BE:BC # farm1


# Restart the farm on the sender side
for host in $hosts
do
	ssh $host "killall -9 na62-farm" &> /dev/null
	ssh $host "/workspace/na62-farm/Debug/na62-farm" &
done

sleep 1


port=6666
bursts=1
sourceIDNum=1

sourceID=0
for host in $hosts
do
	sourceIDParam=""
        for i in `seq 1 $sourceIDNum`
        do
	        sourceIDParam="$sourceIDParam,$sourceID"
                let sourceID=$sourceID+1
        done    
        
        sourceIDParam=${sourceIDParam:1}
	
	echo $sourceIDParam $host
        /workspace/farm-command-connector/Debug/farm-command-connector $host $port "--hostIP=10.194.20.13 --mac=$receiverMac --sourceNums=$sourceIDParam --packetsPerBurst=$mepsPerBurst --gbps=$gbps --bursts=$bursts --eventsPerMEP=1 --eventLengthMean=1000;" &
                
done


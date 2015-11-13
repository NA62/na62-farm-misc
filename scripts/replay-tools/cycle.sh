#!/bin/bash
    function finish {
        echo "program ended correctly";
    }
    trap finish EXIT

 usage(){
     HELP="
     usage: ./cycle.sh #run #burst
     "
     echo -e $HELP
 }

 # If no arguments are provided...
 if [ $# -lt 2 ] ; then
     usage
     exit 1
 fi

if [ -z "$1" ]; then
 RUN=0
else
 RUN=$1
fi
if [ -z "$2" ]; then
 BURST=0
else
 BURST=$2
fi

TOT_CYCLE1=16
TOT_CYCLE2=25
REC_TIME=10

read -p 'press after the burst finish in the long cycle'

while true; do
 echo BURST: $BURST
 sleep $(($TOT_CYCLE1 - $REC_TIME));
 echo "rec on";
# gedit &
 sleep $REC_TIME; 
 echo "rec off";
# pkill gedit
 BURST=$((BURST+1))
 FILENAME=/performance/networkDump/AUTO-${RUN}-${BURST}.pcap
 echo $FILENAME

 #cicle two

 echo $BURST
 sleep $(($TOT_CYCLE2 - $REC_TIME));
 echo "rec on";
# gedit &
 sleep $REC_TIME; 
 echo "rec off";
# pkill gedit
 BURST=$((BURST+1))
 FILENAME=/performance/networkDump/AUTO-${RUN}-${BURST}.pcap
 echo $FILENAME




done

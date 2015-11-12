#~/bin/sh
 usage(){
     HELP="
     usage: ./replay.sh file.pcap
     "
     echo -e $HELP
 }

 # If no arguments are provided...
 if [ $# -lt 1 ] ; then
     usage
     exit 1
 fi 

tcpreplay --intf1=eth2 $1

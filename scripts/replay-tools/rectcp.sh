#~/bin/sh
 usage(){
     HELP="
     usage: ./rectcp.sh /performance/networkDump/filetorecord.pcap
     "
     echo -e $HELP
 }

 # If no arguments are provided...
 if [ $# -lt 1 ] ; then
     usage
     exit 1
 fi 

tcpdump -i eth2  -w $1

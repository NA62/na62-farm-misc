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


#tcpreplay --intf1=eth2 $1
#/performance/PF_RING.old/userland/examples/pfsend -i dna0 -f $1
/performance/PF_RING/userland/examples/pfsend -i dna0 -f $1

#~/bin/sh
 usage(){
     HELP="
     usage: ./recpf.sh /performance/networkDump/filetorecord.pcap
     "
     echo -e $HELP
 }

 # If no arguments are provided...
 if [ $# -lt 1 ] ; then
     usage
     exit 1
 fi 

#/performance/PF_RING.old/userland/examples/pfdump -i dna0 -c 1 -w $1
/performance/PF_RING.old/userland/examples/pfdump -i eth2 -c 1 -w $1

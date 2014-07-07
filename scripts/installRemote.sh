
if [ $# -eq "0" ]
then
        echo "using installFromScratch <hostName>"
        exit
fi

hostname=$1

#ssh-copy-id root@$hostname

scp installFromScratch.sh root@${hostname}:/root

ssh root@$hostname "/root/installFromScratch.sh"

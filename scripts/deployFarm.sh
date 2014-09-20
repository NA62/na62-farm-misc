read -p "Version: " version; echo
read -p "Debug/Release: " config; echo

for i in `seq 1 30`
do
	echo "installing farm$i"
#	ssh root@na62farm$i "cp /workspace/na62-farm/$config/na62-farm /usr/local/bin/na62-farm-$version &&
#	rm /usr/local/bin/na62-farm &&
#	ln -s /usr/local/bin/na62-farm-$version /usr/local/bin/na62-farm" &

	ssh root@na62farm$i "ln -s /usr/local/bin/na62-farm-$version /usr/local/bin/na62-farm"
done


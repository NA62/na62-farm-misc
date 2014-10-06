#!/bin/bash
read -p "Version: " version; echo
read -p "Debug/Release: " config; echo

cp /workspace/na62-farm/$config/na62-farm /usr/local/bin/na62-farm-$version
rm /usr/local/bin/na62-farm
ln -s /usr/local/bin/na62-farm-$version /usr/local/bin/na62-farm


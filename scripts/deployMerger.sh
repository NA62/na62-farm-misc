#!/bin/bash
read -p "Version: " version; echo
read -p "Debug/Release: " config; echo

cp /workspace/na62-farm-merger/$config/na62-farm-merger /usr/local/bin/na62-farm-merger-$version
rm /usr/local/bin/na62-farm-merger
ln -s /usr/local/bin/na62-farm-merger-$version /usr/local/bin/na62-farm-merger


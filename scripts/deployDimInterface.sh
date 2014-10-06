#!/bin/bash
read -p "Version: " version; echo
read -p "Debug/Release: " config; echo

cp /workspace/na62-farm-dim-interface/$config/na62-farm-dim-interface /usr/local/bin/na62-farm-dim-interface$version
rm /usr/local/bin/na62-farm-dim-interface
ln -s /usr/local/bin/na62-farm-dim-interface$version /usr/local/bin/na62-farm-dim-interface


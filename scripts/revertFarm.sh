#!/bin/bash
if [ -e $1 ]; then
	rm /usr/local/bin/na62-farm
	ln -s $1 /usr/local/bin/na62-farm
else 
	echo $1 not found!!
fi

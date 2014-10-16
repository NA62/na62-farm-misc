#!/bin/bash
param=""
for i in `seq $1 $2`
do
	param="$param root@na62farm$i"
done
cssh $param

#!/bin/bash
read -p "First PC num: " first; echo
read -p "Last PC num: " last; echo

param=""
for i in `seq $first $last`
do
	param="$param root@na62farm$i"
done
cssh $param

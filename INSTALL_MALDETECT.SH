#!/bin/bash
dir=$(PWD)
source $dir/FUNCTIONS
print_blue "[#]install maldect"
check_root
if [ $IS_ROOT -eq 0 ];then
	print_red "" "[#]you need to be root"
	exit 0
fi
cd maldetect
./install.sh

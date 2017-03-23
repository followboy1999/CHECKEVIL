#!/bin/bash
dir=$(PWD)
source $dir/FUNCTIONS
check_root
if [ $IS_ROOT -eq 0 ];then
	print_red "" "[!]you need to be root"
	exit 0
fi
print_red "[#]now use maldetect tools to scan all files,so it will take some times"
maldet -a
while :
do
        if read -p "[#]job finished,Do you want to Uninstall now:";then
		case $REPLAY in
			Y|y)
				$dir/files/./uninstall.sh
				break;;
			N|n)
				break;;
			*)
				continue;;
		esac
        fi
done

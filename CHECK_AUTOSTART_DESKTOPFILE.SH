#!/bin/bash
function print_blue()
{
        echo -e "\033[36m$1\033[0m"
}

function print_red()
{
        echo -e "\033[31m$1\033[0m"
}

print_blue "[#]check desktop.file,list all and need some manual check"
declare desktop_file_dir=(
		"/etc/xdg/autostart"
		"$USER/.config/autostart"
)

old_ifs=$IFS
IFS=$'\n'
for dir in ${desktop_file_dir[*]}
do
	if [ -e $dir ];then
		print_blue "dir: "$dir
		files=`ls -l $dir`
		for l in $files
		do
			#print_red $l
			dfile=`echo $l |awk -F' ' '{print $9}'`
			if echo $dfile|grep -i ".desktop">/dev/null;then
				print_red "[!].desktop file: $dfile"
				realfilepath=`cat $dir/$dfile | grep -i exec`
				print_red "[!]$realfilepath"
				print_blue "=================================================================="
			fi
		done
	fi

done
IFS=$old_ifs

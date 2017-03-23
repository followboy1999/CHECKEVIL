#!/bin/bash

function print_blue()
{
	echo -e "\033[36m$1\033[0m"
}

function print_red()
{
	echo -e "\033[31m$1\033[0m"
}

function check_ps_vs_exe()
{
	print_blue "[#]check proc name vs exe name"
	proc=`ps -au | grep -v -E "ps|check_proc_diff_ps_exe"`
	old_ifs=$IFS
	IFS=$'\n'
	for p in $proc
	do
		pname=`echo $p | awk -F' ' '{print $11}'`
		ppid=`echo $p | awk -F' ' '{print $2}'`
		if [ "$ppid" == 'PID' ];then
			continue
		fi
		exe=`ls -l /proc/$ppid/exe | awk -F'>' '{print $2}' | sed 's/^[ \t]*//g'`
		if echo $exe|grep $pname > /dev/null;then
			continue
		else
			print_blue "[!]found diff name from ps and exe"
			print_red "ps name:[pid:$ppid] $pname"
			print_red "exe name: $exe"
		fi
	done
	IFS=$old_ifs
	
}
check_ps_vs_exe

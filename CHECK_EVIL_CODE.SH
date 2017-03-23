#!/bin/bash

declare os_type=0

function check_root()
{
	if [ $UID -eq 0 -o $EUID -eq 0 ];then
		echo -e "\033[36m[#]you have root\033[0m"
	else
		echo -e "\033[36m[#]you must get root\033[0m"
		exit 0
	fi
}

check_root

function check_os_type()
{
	local l

	l=`head -n 1 /etc/issue`
	if echo $l|grep "[Cc]ent [Oo][Ss]" > /dev/null;then
		os_type=1
	elif echo $l|grep "[Rr]ed.Hat.Enterprise" > /dev/null;then
		os_type=2
	elif echo $l|grep "[Uu]buntu" > /dev/null;then
		os_type=3
	elif echo $l|grep "[Dd]ebian" > /dev/null;then
		os_type=4
	elif echo $l|grep "[Ff]edora" > /dev/null;then
		os_type=5
	else
		echo -e "\033[36m[!]os type: $l is not supported\033[0m"
	fi
#	echo -e $os_type
}


function check_profile()
{
	declare -a evil_func=(
			"^function\sls()" "^function\sps()" 
			"^function\ssu()" "^function\snetstat()"
			)

	echo -e '\033[36m[#]check /etc/profile.d/*.sh\033[0m'
	
	for func in ${evil_func[*]}
	do
		#echo -e "$func"
		vfile=`grep -n -e "$func" /etc/profile.d/*`
		if [ -n "$vfile" ];then
			echo -e "  \033[36m[!]found some evil shell inline function\033[0m"
			echo -e "\033[31m$vfile\033[0m"   
		fi
	done
}
check_profile

declare evil_reg=(
		"pty\.spawn\(\"/bin/bash\"\)"
		"subprocess\.call\(\[\"/bin/sh\",\"-i\"\]\)"
		"exec\(\"/bin/sh\s*-i\"\)"
		"mkfifo\s*.*;cat\s*.*\|/bin/sh"
		"/bin/sh\s*-i\s*<\&\d\s*>\&\d\s*2>\&\d"
		"bash\s*-i\s*>\&\s/dev/tcp/.*/.*"
		"nc\s*-e\s*/bin/sh"
		"nc.*\|/bin/sh\|nc.*"
		"exec\s*\d<>/dev/tcp/.*/.*"
	)

#$1: search path
#$2: recursive
function check_evil_file()
{
	echo -e "  \033[36m[!]check evil file in $1;it will take a long time,wait...\033[0m"
	
	for rule in ${evil_reg[*]}
	do
	#	echo -e "rule: $rule"
		if [ "$2" == "1" ];then
			evf=`grep -R -n --color -E "$rule" $1/*`
		else
			evf=`grep -n --color -E "$rule" $1/*`
		fi
	
		if [ -n "$evf" ];then
			echo -e "  \033[36m[!]found some evil code in file\033[0m"
			echo -e "\033[31m$evf\033[0m"   
		fi
	done
}

function check_centos_autorun()
{
	check_evil_file "/etc/rc.d/init.d" 0
	for index in 0 1 2 3 4 5 6
	do
		check_evil_file "/etc/rc.d/rc$index.d" 0
	done
}

function check_ubuntu_autorun()
{
	check_evil_file "/etc/init.d/" 0
	for index in 0 1 2 3 4 5 6
	do
		check_evil_file "/etc/rc$index.d" 0
	done
}

function check_debian_autorun()
{
	check_evil_file "/etc/init.d" 0
}

function check_fedora_autorun()
{
	check_evil_file "/etc/rc.d/init.d" 0
	for index in 0 1 2 3 4 5 6
	do
		check_evil_file "/etc/rc.d/rc$index.d" 0
	done
}


function check_evil_autorun()
{
	echo -e "\033[36m[#]check evil autorun bash\033[0m"
	check_os_type
	case $os_type in
		1|2)
			check_centos_autorun;;
		3)
			check_ubuntu_autorun;;
		4)
			check_debian_autorun;;
		5)
			check_fedora_autorun;;
	esac
	
}
check_evil_autorun

function check_tmp_or_dev_file()
{
	check_evil_file "/tmp" 1
	#check_evil_file "/dev" 0 
}
check_tmp_or_dev_file

declare white_list=(
		"/usr/bin/sudo"
		"/usr/sbin/pppd"
)
function check_evil_suid_file()
{
	echo -e "\033[36m[#]find all setuid files,now you need check manually\033[0m"
	sfile=`find / -perm -4000 -type f -exec ls -ld {} \;`
	echo -e "\033[31m$sfile\033[0m"   
	echo -e "\033[36m[#]check each file may include backdoor code\033[0m"
	old_ifs=$IFS
	IFS=$'\n'
	for f in $sfile
	do
		fn=`echo $f | awk -F' ' '{print $9}'`
		ecode=`strings $fn | grep -E "/bin/sh|/bin/nc"`
		if [ -n "$ecode" ];then
			if echo $fn|grep -E "/usr/bin/sudo|/usr/sbin/pppd|/usr/lib/openssh/ssh-keysign" > /dev/null;then
				continue
			else
				echo -e "  \033[36m[!]found suspecious backdoor\033[0m"
				echo -e "\033[31m$fn\033[0m"
			fi
		fi
	done
	IFS=$old_ifs
}
check_evil_suid_file






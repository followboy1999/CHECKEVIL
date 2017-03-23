#!/bin/bash

function print_blue()
{
        echo -e "\033[36m$1\033[0m"
}
function print_red()
{
	if [ -n "$1" ];then
        	echo -e "$1      \033[31m$2\033[0m"
	else
        	echo -e "\033[31m$2\033[0m"
	fi
		
}
declare IS_ROOT=0
function check_root()
{
        if [ $UID -eq 0 -o $EUID -eq 0 ];then
		IS_ROOT=1
        else
		IS_ROOT=0
        fi
}
declare -a array
check_user()
{
        local line user shell
	local i=0

        while read line
        do
                user=`echo $line | cut -d ":" -f 1`
		shell=`echo $line | cut -d ":" -f 7`
                if [ "$shell" == "/bin/sh" -o "$shell" == "/bin/bash" -o "$shell" == "/bin/zsh" ]; then
			array[$i]=$user
			i=$i+1
                else 
			continue
		fi
        done < /etc/passwd

}
check_user
###########################################
#brootkit bash

function brootkit()
{
	local USER
	local STATUS=0 
	print_blue "[#]scan brootkit"
	for USER in ${array[@]}; do
		BROOTKIT_FILES="/home/$USER/.../bashbd.sh /home/$USER/.../br.conf /home/$USER/.../brconfig.sh /home/$USER/.../brootkit.sh /home/$USER/.../brscan.sh"
		for f in ${BROOTKIT_FILES}; do
			if [ -e "$f" ]; then
				print_red "$f" "founded"
				STATUS=1
			fi
		done
	done
	if [ ${STATUS} -eq 1 ]; then
		print_red "" "[!]brootkit possible installed"
	else
		print_red "" "[!]not infected"
	fi
}
brootkit

###################### 
# Linux/Remaiten

function Remaiten()
{
	local STATUS=0 
	print_blue "[#]scan linux/remaiten"
	REMATITEN_FILES='/dev/shm/.kpid /var/run/.kpid /var/tmp/.kpid /tmp/.kpid /.kpid ./.kpid'
	for f in ${REMATITEN_FILES}; do
		#echo "$f"
		if [ -e "$f" ]; then
			print_red "$f" "founded"
			STATUS=1
		fi
	done
	if [ ${STATUS} -eq 1 ];then
		print_red "" "[!]linux/remaiten possible installed"
	else
		print_red "" "[!]not infected"
	fi
		
}
Remaiten

#######################
#IptabLe* malware botnet

function IptabLes_botnet() {
	local STATUS=0 
	print_blue "[#]scan Iptables botnet"
	print_red "" "[!]need root"
	check_root
	if [ ${IS_ROOT} -eq 1 ]; then
		IPTABLE_FILES=`find / -type f -name '.*ptabLe*' > /dev/null`	
		IPTABLE_PROC=`ps -aux | awk '/\.IptabLe/ {print $2}'`
		if [ -n "$IPTABLE_FILES" ]; then
			print_red "$IPTABLE_FILES" "founded"
			STATUS=1
		elif [ -n "$IPTABLE_PROC" ]; then
			print_red "$IPTABLE_PROC" "founded"
			STATUS=1
		else
			STATUS=0	
		fi
		if [ ${STATUS} -eq 1 ];then
			print_red "" "[!]Iptabl* botnet possible installed"
		else
			print_red "" "[!]not infected"
		fi
	else
		print_red "" "[!]you are not root"
	fi
}
IptabLes_botnet

#######################
#openssh trojanized toolkit

function openssh_trojan() {
	local USER
	local STATUS=0 
	print_blue "[#]scan openssh trojanized toolkit"
	TROJANIZED_FILE="/etc/pps /etc/X11/.pr"	
	#check file
	for f in ${TROJANIZED_FILE}; do
		if [ -e "$f" ];then
			STATUS=1
			print_red "$f" "found"
		else
			STATUS=0 	
		fi
	done
	#check sniffing file
	if grep -R -E "root:.* from *" /etc/X11 > /dev/null; then
		print_red "$(grep -R -E "root:.* from *" /etc/X11)" "found"
		STATUS=1
	fi	 
	#check backdoor passwd "PRtestD" for each user
	python -c "import paramiko"
	if [ $? -eq 1 ];then
		print_red "" "[!]ImportError,please install module:{pip install paramiko}"
	else
		for USER in ${array[@]}; do			
			#simulate user login now PRtestD		
			if python ssh.py $USER "PRtestD"|grep "success" > /dev/null;then
				print_red "backdoor passwd [$USER:PRtestD]" "found"
				STATUS=1
			fi
		done
	fi

	if [ ${STATUS} -eq 1 ];then
		print_red "" "[!]openssh trojanized toolkit possible installed"
	else
		print_red "" "[!]not infected"
	fi
}
openssh_trojan

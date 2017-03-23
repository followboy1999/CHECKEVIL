#!/bin/bash

function print_blue()
{
        echo -e "\033[36m$1\033[0m"
}

function print_red()
{
        echo -e "\033[31m$1\033[0m"
}

print_blue "[#] Check suspicious env"
found=0
if [ "$HISTFILE" == "/dev/null" -o "$HISTFILE" == "0" ];then
	print_red "'HISTFILE'[$HISTFILE] is suspicious"	
	found=1
fi
if [ "$HISTSIZE" == "1" ];then
	print_red "'HISTSIZE'[$HISTSIZE] is suspicious"	
	found=1
fi
if [ "$HISTFILESIZE" == "0" ];then
	print_red "'HISTFILESIZE'[$HISTFILESIZE] is suspicious"	
	found=1
fi
if [ "$HISTIGNORE" == "*" ];then
	print_red "'HISTIGNORE'[$HISTIGNORE] is suspicious"	
	found=1
fi
if [ "$HISTCONTROL" == "ignorespace" ];then
	print_red "'HISTCONTROL'[$HISTCONTROL] is suspicious"	
	found=1
fi
if [ $found -eq 0 ];then
	print_blue "[!]suspicious env not found"
fi

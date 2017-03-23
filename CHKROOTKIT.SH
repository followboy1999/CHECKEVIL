#!/bin/bash
function print_blue()
{
        echo -e "\033[36m$1\033[0m"
}

function print_red()
{
        echo -e "\033[31m$1\033[0m"
}


cd chkrootkit
if [ -e expert.log ];then
	rm *.log
	./chkrootkit -x > expert.log
	print_red "[#]you can see expert log[more details] in expert.log"
	tail -n 20 expert.log
	./chkrootkit -r / > simple.log
	print_red "[#]you can see simple log[] in simple.log"
	print_red "[#]the last 20 lines"
	tail -n 20 simple.log
else
	./chkrootkit -x > expert.log
	print_red "[#]you can see expert log[more details] in expert.log"
	tail -n 20 expert.log
	./chkrootkit -r / > simple.log
	print_red "[#]you can see simple log[] in simple.log"
	print_red "[#]the last 20 lines"
	tail -n 20 simple.log
fi

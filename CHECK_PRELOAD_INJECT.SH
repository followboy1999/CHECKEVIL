#!/bin/bash
#check /etc/ld.so.preload 
echo -e "\033[36m[#]Check preload injection!\033[0m"
if [ -e /etc/ld.so.preload ];then
	echo -e "  \033[36m[!]Config file found: /etc/ld.so.preload\033[0m"
	echo -e "  \033[31m[!]More:\033[0m"
	cat /etc/ld.so.preload
fi
if [ $LD_PRELOAD ];then
	echo -e "  \033[36m[!]Found LD_PRELOAD not NULL!\033[0m"
	echo -e "  \033[36m[!]More:\033[0m"
	echo -e "\033[31m$LD_PRELOAD\033[0m"
fi
echo -e "  \033[36m[!]preload hijacking not found!\033[0m"

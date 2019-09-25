#!/bin/bash
case "$1" in
start)
	ls *.jar > java_start.txt

		for i in `cat java_start.txt`
			do
        			nohup java -jar $i &    &>/dev/null
				echo -e "$i \033[32;1m "is running ！！"\033[0m"
				sleep 1
			done
	rm -rf java_start.txt
	;;
stop)
	for i in ` ps -ef | grep java | awk '{print $2}'`
		do
        		name=`ps -ef | grep $i | awk '{print $NF}' |grep jar`
        		kill -9 $i
        		echo -e "$name \033[31;1m "is down ！！"\033[0m"
        		sleep 1
		done
;;
restart)
	$0 stop
	$0 start
;;
*)
	echo $"用法: $0 {start| stop| restart} "
	exit 1;;
esac



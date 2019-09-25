#!/bin/bash
if [ $# -ne 2 ] ; then
	echo $"用法: $0 XXX.jar {start| stop| restart} "
	exit 1 
elif [ ! -f $1 ] ; then
	echo "请输入正确jar包！！"
	exit 2
else 

case "$2" in
start)
	nohup java -jar $1 &	 &>/dev/null
	echo -e "$1 \033[32;1m "is running ！！"\033[0m"
;;
stop)
	pid=`ps -ef | grep $1 | awk '{print $2}' |awk 'NR == 1'`
	kill -9 $pid
	 echo -e "$1 \033[31;1m "is down ！！"\033[0m"
;;
restart)
	$0 $1 stop
	$0 $1 start
;;
*)
	echo $"用法: $0 XXX.jar {start| stop| restart} "
	exit 3;;
esac

fi

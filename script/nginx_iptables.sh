#!/bin/bash
#指定日志文件
log=/usr/local/nginx/logs/access.log
#获取时间
date_month=`date | awk '{print $3"/"$2"/"$6":"}'`
#date_time=`date | awk '{print $4}' | awk -F":" '{print $1":"}'`
date_min=`date | awk '{print $4}' | awk -F":" '{print $2}'`
#date_min=11
num_min=`expr ${date_min} - 1`
if [ $num_min -lt 10 ] ; then
	date_time=`date | awk '{print $4}' | awk -F":" '{print $1":0"}'`
else
	date_time=`date | awk '{print $4}' | awk -F":" '{print $1":"}'`
fi
date=${date_month}${date_time}${num_min}
#echo $date
#获取封停的IP
#规则：每分钟内访问超过100次，进行封停
grep ${date} ${log} | awk '{ ip[ $1] ++} END{ for( i in ip) { print ip[ i] ,i } } ' |sort -nr |head -10 > .nginx_min.log
#cat ${log} | awk '{ ip[ $1] ++} END{ for( i in ip) { print ip[ i] ,i } } ' |sort -nr |head -10 > .nginx_min.log
for i in `awk '{print $1}' .nginx_min.log`
do
	if [ $i -ge 100 ] ; then
		ip=`awk '/^'${i}'/ {print $2}' .nginx_min.log`
		if  [ ! -z ${ip} ] ; then
			iptables -I INPUT -s ${ip} -j DROP
		fi
	fi
done
rm -rf .nginx_min.log

#封停一个IP
#iptables -I INPUT -s ${ip} -j DROP



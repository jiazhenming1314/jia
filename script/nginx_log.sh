#!/bin/bash
#配置收件人
recipient=2466066905@qq.com,jiazhenming1314@163.com
if [ -z $recipient ] ; then
        echo "请配置收件人"
        exit 1
fi
#本地http日志文件
log=/usr/local/nginx/logs/access.log
#获取本时间段的上一个时间段
date_month=`date | awk '{print $3"/"$2"/"$6":"}'`
date_time=`date | awk '{print $4}' | awk -F":" '{print $1}'`
num_time=`expr ${date_time} - 1`
date=${date_month}${num_time}
#echo $date
#获取访问http的前10个IP及访问量
grep ${date} ${log} | awk '{ ip[ $1] ++} END{ for( i in ip) { print ip[ i] ,i } } ' |sort -nr |head -10 > temp_nginx.log
#获取IP位置
for i in `awk '{print $2}' temp_nginx.log`
do
	geoiplookup  ${i} | awk '{print $NF}' >> ip_add.txt
done
#拼接2个文本
paste -d " " temp_nginx.log ip_add.txt > mail_nginx.txt
#写入日志文件
echo ${date}时： >>/usr/local/nginx/logs/nginx_month.log
cat mail_nginx.txt >> /usr/local/nginx/logs/nginx_month.log
#定时发送邮件，设置早8点-晚10点发送邮件
if [ $date_time -ge 8 ] ; then
	if [ $date_time -le 22 ] ;then
	
	for i in `echo ${recipient} | awk -F ',' '{for(i=1;i<=NF;i++){print $i}}'`
	do 
       		mail -s "nginx访问前10排名" ${i} < mail_nginx.txt
	done
	fi
fi
rm -rf ip_add.txt temp_nginx.log mail_nginx.txt




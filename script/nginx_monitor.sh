#!/bin/bash
#配置网址
url=http://
#配置收件人！！
recipient=2466066905@qq.com,jiazhenming1314@163.com
if [ -z $recipient ] ; then
        echo "请配置收件人"
        exit 1
fi
#http检测主体
check_http(){
status_code=$(curl -m 5 -s -o /dev/null -w %{http_code} $url)
}
while :
do
	check_http
	date=$(date +%Y%m%d-%H:%M:%S)
	if [ $status_code -ne 200 ] ; then
		for i in `echo ${recipient} | awk -F ',' '{for(i=1;i<=NF;i++){print $i}}'`
		do 
       			mail -s "http服务报警！！" ${i} << EOF
                        	${url}出现异常！！！
				时间：${date};
				异常码：${status_code}！！！
EOF
		done
	else
		echo "${url}连接正常" >> /var/log/http_status.log
	fi
	sleep 5
done 

#!/bin/bash
#指定IP地址；
IP=172.17.172.44
#指定mail地址
recipient=2466066905@qq.com,jiazhenming1314@163.com
#指定url请求头(写多个，以“，”分割)
urls=http://${IP}:20301/hospital/insertBatchHospital,http://${IP}:20301/dept/insertBatchDept,http://${IP}:20301/doctor/insertBatchDoctor,http://${IP}:20301/clinicSchedule/insertBatchClinicSchedule,http://${IP}:20301/themrDetail/insertBatchThemrDetail
#时间
date=$(date +%Y%m%d-%H:%M:%S)
#定义函数
send_mail(){
for i in `echo ${recipient} | awk -F ',' '{for(i=1;i<=NF;i++){print $i}}'`
	do
		mail -s "url更新异常！！！" ${i} << EOF
                                时间：${date};
				url地址：${url};
                                异常信息：${status};
EOF
	done
}
check_url(){
status=`curl -s ${url}` 
echo ${status} | grep "200000" &> /dev/null
if [ $? -eq 0 ] ; then
	echo ${date}\;${url}\;${status} >> /var/log/url_access.log
else
	echo ${date}\;${url}\;${status} >> /var/log/url_error.log
	send_mail
fi
}
#便利url请求头
for url in `echo ${urls} | awk -F ',' '{for(i=1;i<=NF;i++){print $i}}'`
	do
		check_url &
	done


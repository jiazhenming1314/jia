#!/bin/bash
#参数为空默认为忽略监控
#监控的端口号
port=8080
#监控内存（设置报警值：单位：KB）
free=111111111
#磁盘使用率（设置报警值：单位 %,注意请忽略%）
usage_rate=1
#CPU15分钟平均负载（建议在0.7以下）
cpu=0.01
#收件人（可写多个，注意：以“，”做分割！！）
recipient=2466066905@qq.com,jiazhenming1314@163.com
if [ -z $recipient ] ; then
	echo "请配置收件人"
	exit 1
fi

#相关参数
eip=`curl -s icanhazip.com`
hostname=`hostname`

#发送邮件模板
#for i in `echo ${recipient} | awk -F ',' '{for(i=1;i<=NF;i++){print $i}}'`
#do 
#	echo $i
#done

while :
	do
#监控端口主体
if [ ! -z $port ] ; then
	for i in `echo ${recipient} | awk -F ',' '{for(i=1;i<=NF;i++){print $i}}'`
		do
			ss -lunt|grep ${port} &>/dev/null
				if [ $? -ne 0 ] ; then
					mail -s "端口报警！！" ${i} << EOF
						${port}端口非正常关闭！！！
						主机：${hostname}
						外网IP：${eip}
EOF
				fi
		done
fi
#监控内存主体
if [ ! -z $free ] ; then
        for i in `echo ${recipient} | awk -F ',' '{for(i=1;i<=NF;i++){print $i}}'`
                do      
                        free_actual=`free | awk '/Mem/{ print $4} '`
                                if [ $free -ge $free_actual ] ; then
                                        mail -s "内存报警！！" ${i} << EOF
                                                内存小于${free}
                                                主机：${hostname}
                                                外网IP：${eip}
EOF
                                fi
                done
fi
#监控磁盘使用率主体
if [ ! -z $usage_rate ] ; then
        for i in `echo ${recipient} | awk -F ',' '{for(i=1;i<=NF;i++){print $i}}'`
                do
                        usage_actual=`df | awk '/\/$/{ print $5} '|awk -F "%" '{print $1}'`
                                if [ $usage_actual -ge $usage_rate ] ; then
                                        mail -s "磁盘报警！！" ${i} << EOF
                                                磁盘使用率大于${usage_rate}%
                                                主机：${hostname}
                                                外网IP：${eip}
EOF
                                fi
                done
fi

#监控CPU15分钟平均负载
if [ ! -z $cpu ] ; then
        for i in `echo ${recipient} | awk -F ',' '{for(i=1;i<=NF;i++){print $i}}'`
                do
                        cpu_actual=`uptime | awk '{ print $NF} '`
			cpu_act_num=`echo "scale=2;  ${cpu_actual}*100" | bc | awk -F "." '{print $1}'`
			cpu_num=`echo "scale=2;  ${cpu}*100" | bc | awk -F "." '{print $1}'`
                                if [ $cpu_act_num -ge $cpu_num ] ; then
                                        mail -s "CPU报警！！" ${i} << EOF
                                                CPU 15分钟平均负载大于${cpu}
                                                主机：${hostname}
                                                外网IP：${eip}
EOF
                                fi
                done
fi

		sleep 300
	done






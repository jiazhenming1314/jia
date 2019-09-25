#!/bin/bash
#传参QQ号和QQ邮箱授权码
read -p "Your QQ Number ：" qq_number
if [ -z $qq_number ] ; then
	echo "请输入QQ号！！"
	exit 1
fi
read -p "Your QQ Mailbox Authorization Code：" qq_code
if [ -z $qq_code ] ;then
	echo "请输入QQ邮箱授权码！！"
	exit 2
fi
#安装部署mailx
yum install mailx -y &>/dev/null
#更新配置文件
cat >> /etc/mail.rc << EOF
set from=${qq_number}@qq.com
set smtp=smtps://smtp.qq.com:465
set smtp-auth-user=${qq_number}@qq.com
set smtp-auth-password=${qq_code}
set smtp-auth=login
set ssl-verify=ignore
set nss-config-dir=/root/.certs
EOF
#更新相关参数
mkdir -p /root/.certs/
echo -n | openssl s_client -connect smtp.qq.com:465 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > ~/.certs/qq.crt  
certutil -A -n "GeoTrust SSL CA" -t "C,," -d ~/.certs -i ~/.certs/qq.crt 
certutil -A -n "GeoTrust Global CA" -t "C,," -d ~/.certs -i ~/.certs/qq.crt 
certutil -L -d /root/.certs 

cd /root/.certs/
certutil -A -n "GeoTrust SSL CA - G3" -t "Pu,Pu,Pu" -d ./ -i qq.crt 
#发送测试邮件

echo "mail_qq 已配置成功！！" | mail -s "测试邮件！！" ${qq_number}@qq.com

echo "测试邮件已发送！请注意查收！！！"












#!/bin/bash
#此服务搭建适用于7.0以上版本！！！
#PXE服务环境安装搭建
mount /dev/cdrom  /mnt/ &> /dev/null
if [ $? -ne 0 ] ; then
        echo "请连接rhel7.4光盘镜像"
        exit 1
else
	echo "已连接光盘镜像"
fi
#测试yum仓库是否安装
yum1=`yum repolist | awk '/repolist/{print $2}'| awk -F, '{print $1$2}'`
if [ "$yum1" -eq 0 ] ; then
	echo "未安装yum源，正在初始化yum..."
rm -rf /etc/yum.repos.d/*
#修改yum源，请修改此处！！！！
        echo "[dvd]
name=dvd
baseurl = ftp://192.168.4.254/rhel7
enabled = 1
gpgcheck = 0" > /etc/yum.repos.d/dvd.repo
	echo "yum 源已初始化完毕！！！"
else
        echo "yum源已存在..."
fi
yum2=`yum repolist | awk '/repolist/{print $2}'| awk -F, '{print $1$2}'`
if [ "$yum2" -eq 0 ] ; then
	echo "请查看脚本，写入正确yum源"
	exit 2
fi
#搭建DHCP服务
yum -y install dhcp &> /dev/null
#提取本机IP，指定下一访问ip
i=`ifconfig | sed -n 2p |awk '{print $2}'`
n=`ifconfig | sed -n 2p |awk '{print $2}' | awk -F. '{print $1"."$2"."$3".0"}'`
j=`ifconfig | sed -n 2p |awk '{print $2}' | awk -F. '{print $1"."$2"."$3".100"}'`
k=`ifconfig | sed -n 2p |awk '{print $2}' | awk -F. '{print $1"."$2"."$3".150"}'`
l=`ifconfig | sed -n 2p |awk '{print $2}' | awk -F. '{print $1"."$2"."$3".254"}'`
#分配的网段
	echo "subnet $n netmask 255.255.255.0 {" > /etc/dhcp/dhcpd.conf
#分配ip地址
	echo "range $j  $k ;" >> /etc/dhcp/dhcpd.conf 
#分配DNS地址
	echo "option domain-name-servers $i;" >> /etc/dhcp/dhcpd.conf 
#分配网关地址
	echo "option routers $l ;"  >> /etc/dhcp/dhcpd.conf 
#默认组期时间
	echo "default-lease-time 600;" >> /etc/dhcp/dhcpd.conf 
#最大组期时间
	echo "max-lease-time 7200;" >> /etc/dhcp/dhcpd.conf 
#制定下一个服务器地址
	echo "next-server  $i ;" >> /etc/dhcp/dhcpd.conf 
#指定网卡引导文件名称
	echo 'filename  "pxelinux.0";' >> /etc/dhcp/dhcpd.conf
	echo "}" >> /etc/dhcp/dhcpd.conf
systemctl restart dhcpd
systemctl enable dhcpd &> /dev/null
	echo "DHCP服务已开启！！！"
#部署TFTP服务
yum -y install tftp-server  &> /dev/null
systemctl restart tftp
systemctl enable tftp &> /dev/null
        echo "TFTP服务已安装完毕！！！"
#部署PXElinux.0文件
yum -y install syslinux &> /dev/null
cp /usr/share/syslinux/pxelinux.0     /var/lib/tftpboot/
#部署菜单文件
mkdir  /var/lib/tftpboot/pxelinux.cfg
cp  /mnt/isolinux/isolinux.cfg  /var/lib/tftpboot/pxelinux.cfg/default
chmod u+w /var/lib/tftpboot/pxelinux.cfg/default
#部署图形模块及背景图片
cp  /mnt/isolinux/vesamenu.c32 /mnt/isolinux/splash.png   /var/lib/tftpboot/
#部署启动内核及驱动程序
cp /mnt/isolinux/vmlinuz /mnt/isolinux/initrd.img  /var/lib/tftpboot/
#修改菜单文件
sed -i '11cmenu title jiaoben_jia PXE Server' /var/lib/tftpboot/pxelinux.cfg/default
sed -i '62c   menu label  RHEL7 zhuangji' /var/lib/tftpboot/pxelinux.cfg/default 
sed -i '63cmenu  default' /var/lib/tftpboot/pxelinux.cfg/default
sed -i '64ckernel vmlinuz' /var/lib/tftpboot/pxelinux.cfg/default
sed -i '65cappend initrd=initrd.img' /var/lib/tftpboot/pxelinux.cfg/default 
sed -i '68s/^/#/' /var/lib/tftpboot/pxelinux.cfg/default
	echo "菜单文件已部署完成！！！"
#搭建web服务，共享光盘内容
yum -y install httpd &> /dev/null
mkdir /var/www/html/rhel7
mount /dev/cdrom /var/www/html/rhel7/ &> /dev/null
systemctl restart httpd
systemctl enable httpd &> /dev/null
	echo "HTTP服务已开启！！！"
#更改yum仓库标识
sed -i 's#\[*.*\]#\[development\]#g' /etc/yum.repos.d/*.repo
#搭建自动应答文件
yum -y install system-config-kickstart  &> /dev/null
#实际添加/root/ks.cfg 的配置文件
	echo "install" > /root/ks.cfg
        echo "keyboard 'us'" >> /root/ks.cfg
#设置root用户密码
        echo 'rootpw --iscrypted $1$adgP8IqZ$zhtTfITbGIbdyW9ljzkpy1' >> /root/ks.cfg
#指定安装方法
        echo "url --url=" >> /root/ks.cfg
	sed -i '/^url/s#$#"http://'$i'/rhel7"#' /root/ks.cfg
        echo "lang zh_CN" >> /root/ks.cfg
#关闭防火墙
        echo "firewall --disabled" >> /root/ks.cfg
        echo "auth  --useshadow  --passalgo=sha512" >> /root/ks.cfg
        echo "graphical" >> /root/ks.cfg
        echo "firstboot --disable" >> /root/ks.cfg
#关闭SElinux
        echo "selinux --disabled" >> /root/ks.cfg
#指定网卡
        echo "network  --bootproto=dhcp --device=eth0" >> /root/ks.cfg
#重起
        echo "reboot" >> /root/ks.cfg
#指定时区
        echo "timezone Asia/Shanghai" >> /root/ks.cfg
        echo "bootloader --location=mbr" >> /root/ks.cfg
        echo "zerombr" >> /root/ks.cfg
        echo "clearpart --all --initlabel" >> /root/ks.cfg
#分区
#        echo "part swap --fstype="swap" --size=1024" >> /root/ks.cfg
        echo "part / --fstype="xfs" --grow --size=1" >> /root/ks.cfg
#编写用户脚本
        echo "%post --interpreter=/bin/bash" >> /root/ks.cfg
        echo "useradd jia" >> /root/ks.cfg
        echo "echo 123 | passwd --stdin jia" >> /root/ks.cfg
        echo "%end" >> /root/ks.cfg
        echo "%packages" >> /root/ks.cfg
        echo "@base" >> /root/ks.cfg
        echo "%end" >> /root/ks.cfg
#共享ks.cfg文件
cp /root/ks.cfg   /var/www/html/
#指定ks.cfg文件
sed -i "65cappend initrd=initrd.img  ks=http://$i/ks.cfg" /var/lib/tftpboot/pxelinux.cfg/default
#搭建完成
	echo "PXE服务已成功搭建完成，请放心使用！！！"















#!/bin/bash
#set -x
############################参数定义########################
#用户名
user="jia"
#密码
pass="1234.com"
# 设置备份目录,必须以/结尾 
back_dir=/data/backup/
#设置备份开关
is_back=$1
#设置保存多少天
day=15
#定义文件名
file_name=`date +%Y%m%d%H%M`
#定义排除的数据库名称
exclude=("Database" "performance_schema" "information_schema" "mysql")
#############################代码逻辑########################
#定义命令
MYSQL=`which mysql`
MYSQLDUMP=`which mysqldump`
#创建一个临时文件,装载数据库
tmp_file=/tmp/databases_$RANDOM
touch $tmp_file
#登陆mysql,获取所有的数据库名称
$MYSQL -u$user -p$pass <<EOF >$tmp_file
show databases;
EOF
#定义数据库名称数组
database_list=()
#定义自增变量
len=0
#获取真实有用的数据库名称
while read line
do
        if [[ "${exclude[@]}" != *$line* ]]
        then
                let "len++"
                database_list[$len]=$line
        fi
done < $tmp_file
#输出时间
echo `date` >> /var/log/mysql_clone.log
#输出结果,导出数据库
echo "数据库总共:${#database_list[*]}" >> /var/log/mysql_clone.log
#开始备份
echo "开始备份..." >> /var/log/mysql_clone.log
rd=$RANDOM
for name in ${database_list[@]}
do
        file_path="${back_dir}`date +%Y%m%d`"/
        if [ ! -e $file_path ]
        then
                mkdir -p $file_path
        fi
        file="${file_path}${name}-$file_name-$rd.gz"
        echo "正在备份: $name >> $file" >> /var/log/mysql_clone.log
        if [[ -n $is_back && $is_back == 1 ]];then
            $MYSQLDUMP --opt $name -u $user -p${pass} | gzip > $file
        fi
done
#保留多少天的数据
find $basedir -mtime +$day -name "*.gz" -exec rm -rf {} \;
#删除临时文件
if [ -e $tmp_file ]
then
        rm -rf $tmp_file
fi
echo "备份结束." >> /var/log/mysql_clone.log

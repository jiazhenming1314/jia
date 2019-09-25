#!/bin/bash
user=root
password=123456
date=$(date +%Y%m%d)
[ !  -d /mysqlbackup ] && mkdir  /mysqlbackup
#备份数据
mysqldump -u"${user}" -p"${password}" -A > /mysqlbackup/mysql_copy-"${date}".sql



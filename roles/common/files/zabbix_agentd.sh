#!/bin/bash

# 定义hostname 把当前主机名写入到zabbix_agentd.conf文件
HOSTNAME=`hostname`
sed  -i -r  "s/Hostname=.*/Hostname=$HOSTNAME/g" /usr/local/zabbix/etc/zabbix_agentd.conf


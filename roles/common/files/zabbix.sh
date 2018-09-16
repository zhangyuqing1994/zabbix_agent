#!/bin/bash
# 安装zabbix_agent

# 判断当前系统操作版本，若不符合安装条件 就退出；
if [ ! -f /etc/redhat-release ];
then
	exit
else
# 创建用户组用户
    groupadd zabbix 
    useradd -g zabbix zabbix -s /sbin/nologin 
# 安装依赖包、下载zabbix软件包
    yum -y install gcc lsof net-tools pcre-devel
    wget https://jaist.dl.sourceforge.net/project/zabbix/ZABBIX%20Latest%20Stable/3.4.2/zabbix-3.4.2.tar.gz -c -P /tmp/
# 解压编译安装
    cd /tmp/ && tar -xvf zabbix-3.4.2.tar.gz 
    cd zabbix-3.4.2  && ./configure --prefix=/usr/local/zabbix --enable-agent
    if [ $? = 0 ]
    then
        make
	make install
    else
	exit
    fi
# 删除zabbix启动文件，是因为在最后有sed 追加参数到zabbix_agentd启动文件指定2，3行，那为什么要删除这个zabbix_agentd启动文件呢，是因为如果你重复安装，sed 在最后写入参数到zabbix_agentd文件1，2行是不会出现重复；
    rm -rf /etc/init.d/zabbix_agentd
# 对zabbix_agentd服务启动文件授权，修改数据目录；写入原配置信息到zabbix_agentd.conf文件
    \cp -r /tmp/zabbix-3.4.2/misc/init.d/tru64/zabbix_agentd /etc/init.d
    chmod +x /etc/init.d/zabbix_agentd 
    sed  -r -i 's/DAEMON=.*/DAEMON=\/usr\/local\/zabbix\/sbin\/zabbix_agentd/g' /etc/init.d/zabbix_agentd 
    mkdir -p /usr/local/zabbix/alertscripts/ 
cat << EOF > /usr/local/zabbix/etc/zabbix_agentd.conf
LogFile=/tmp/zabbix_agentd.log
Server=192.168.200.201
ServerActive=192.168.200.201:10051
Hostname=f3-mysql-master-200-159.xhj.com
HostMetadataItem=system.uname
UnsafeUserParameters=1
Include=/usr/local/zabbix/etc/zabbix_agentd.conf.d/
Timeout=30
EnableRemoteCommands=1
EOF
# 定义hostname 把当前主机名写入到zabbix_agentd.conf文件
HOSTNAME=`hostname`
    sed  -i -r  "s/Hostname=.*/Hostname=$HOSTNAME/g" /usr/local/zabbix/etc/zabbix_agentd.conf
# 定义开机启动服务参数到zabbix_agentd启动文件、开机启动；第26行删除zabbix_agentd启动文件就是因为 要加入下边两条参数指定位置不重复；
    sed -i -r '2 s/^/#chkconfig: 345 95 95 \n/' /etc/init.d/zabbix_agentd
    sed -i -r '3 s/^/#description: Zabbix_agentd \n/' /etc/init.d/zabbix_agentd
    chkconfig zabbix_agentd on 
# 删除zabbix包文件
    rm -rf /tmp/zabbix-3.4.2.tar.gz && rm -rf /tmp/zabbix-3.4.2 
# 判断当前系统操作版本，启动zabbix_agentd服务
    grep -qE '6\.[0-9]' /etc/redhat-release
    if [ $? -ne 0 ];
    then
	    systemctl start zabbix_agentd 
	    systemctl restart zabbix_agentd 
	    systemctl status zabbix_agentd 
    else
	    /etc/init.d/zabbix_agentd start
	    /etc/init.d/zabbix_agentd restart
        /etc/init.d/zabbix_agentd status
    fi
fi

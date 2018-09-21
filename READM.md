
# 确定网络可行性 可以上外网，yum源没问题 支持centos6 centos7系统  zabbix版本 3.4.2 

# 安装前改host文件 远程执行机器IP，修改服务端IP 在roles/common/templates/zabbix_agentd2.conf  修改用户密码 只支持root用户 不支持普通用户

# 适用于生产环境 测试环境

# 检测语法

ansible-playbook -i hosts site.yml --syntax-check

# 安装步骤 在当前目录下执行命令

ansible-playbook -i hosts  site.yml -f 10


# 检查zabbix安装是生效 

lsof -i:10050

# 在zabbix server端检查被监控主机是否能被监控到

./zabbix_get -s ip -p 10050 -k system.hostname

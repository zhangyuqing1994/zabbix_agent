
# 确定网络可行性 可以上外网，yum源没问题 系统只能是centos6 centos7 zabbix版本 3.4.2 

# 安装前改host文件 远程执行机器IP，修改服务端IP 在roles/common/templates/zabbix_agentd2.conf 

# 检测语法

ansible-playbook -i hosts site.yml --syntax-check

# 安装步骤 在当前目录下执行命令

ansible-playbook -i hosts  site.yml -f 10


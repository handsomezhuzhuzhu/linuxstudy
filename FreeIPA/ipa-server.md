# ipa-server搭建

ipa-server有关介绍可以参考：https://www.freeipa.org/page/About

####构建一个集中认证管理系统需要提供：账户信息和认证信息
```bash
1）账户信息：包含如，用户名，UID,GID等
    存储账号信息流行的解决方案：LADP,NIS,AD或IPA-server
2）认证信息：密码，指纹等
    ldap服务 
    kerberos 是一种网络认证协议，仅提供SSO认证服务，通常和LDAP一起使用
```
## 1.搭建准备：

1）需要两台机器，分为server端和client端，具备静态ip

    server：192.168.1.76
    client：192.168.1.40

2）配置hosts解析

    192.168.1.76 ipa.server.dp  server
    192.168.1.40 ipa.client.dp  client

3）修改主机名

```bash
# hostnamectl set-hostname ipa.server.dp
```
4）关闭防火墙（或者防火墙放行相关端口和服务）

5）关闭selinux

6）开启ntp时间同步（设置本地ntp同步或者阿里ntp）

由于我司使用阿里云服务器，静态ip和时间同步环节可以跳过

## 2.server端安装配置
### 2.1 安装ipa-server

```bash
# yum install -y ipa-server bind bind-dyndb-ldap ipa-server-dns

#组件功能
bind 提供dns服务
bind-dyndb-ldap提供dns和ldap连接
ipa-server-dns提供ipa-server与dns连接
```

### 2.2 配置ipa-server

```bash
# ipa-server-install --setup-dns
Server host name [server.test.co]:     #---回车键（默认）
Please confirm the domain name [test.co]:    #---回车键（默认）
Please provide a realm name [TEST.CO]:  #---回车键（默认）
Directory Manager password:   #---设置目录管理的密码 最少是8位
IPA admin password:  #---设置ipa 管理员admin的密码 最少8位 一定要记住，后面要用到
Do you want to configure DNS forwarders? [yes]: no #---你想配置dns为转发器吗？ 选择no
Do you want to search for missing reverse zones? [yes]: yes  #--你想配置dns的反向域吗？选择yes
Continue to configure the system with these values? [no]: yes #--继续配置系统其他的值？ 选择yes

#安装完成后会显示如下信息
Next steps:
	1. You must make sure these network ports are open:
		TCP Ports:
		  * 80, 443: HTTP/HTTPS
		  * 389, 636: LDAP/LDAPS
		  * 88, 464: kerberos
		  * 53: bind
		UDP Ports:
		  * 88, 464: kerberos
		  * 53: bind
		  * 123: ntp

	2. You can now obtain a kerberos ticket using the command: 'kinit admin'
	   This ticket will allow you to use the IPA tools (e.g., ipa user-add)
	   and the web user interface.
```

### 2.3 初始化

```bash
# systemctl enable sssd    --开机自启动sssd服务（sssd:system security service deamon 系统安全服务）

# systemctl start sssd  --开启sssd服务（可能默认已经开启了）

# authconfig  --enablemkhomedir --update  创建的用户，默认创建用户家目录，更新认证信息
```

### 2.4 验证ipa-server和dns

```bash
# kinit admin 登录admin管理

Password for admin@SERVER.CO:   #输入前面设置的admin密码

# ipa user-find –all  查看所有域用户信息
...
```
### 2.5 验证dns解析

```bash
# dig -t a ipa.server.dp

; <<>> DiG 9.11.4-P2-RedHat-9.11.4-9.P2.el7 <<>> -t a ipa.server.dp
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 54020
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;ipa.server.dp.			IN	A

;; ANSWER SECTION:
ipa.server.dp.		1200	IN	A	192.168.1.76

;; AUTHORITY SECTION:
server.dp.		86400	IN	NS	ipa.server.dp.

;; Query time: 0 msec
;; SERVER: 127.0.0.1#53(127.0.0.1)
;; WHEN: Sun Sep 29 15:52:31 CST 2019
;; MSG SIZE  rcvd: 72

# dig -t ptr 192.168.1.76.in-addr.apra

; <<>> DiG 9.11.4-P2-RedHat-9.11.4-9.P2.el7 <<>> -t ptr 192.168.1.76.in-addr.apra
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 60261
;; flags: qr rd ra ad; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;192.168.1.76.in-addr.apra.	IN	PTR

;; AUTHORITY SECTION:
.			6478	IN	SOA	a.root-servers.net. nstld.verisign-grs.com. 2019092900 1800 900 604800 86400

;; Query time: 3 msec
;; SERVER: 127.0.0.1#53(127.0.0.1)
;; WHEN: Sun Sep 29 15:53:17 CST 2019
;; MSG SIZE  rcvd: 129
```
## 3.通过图像界面添加用户和主机
3.1 登陆web界面（需要在本地配置hosts 解析）
![](media/15697437015359/15697440991663.jpg)
### 3.2 添加用户
![](media/15697437015359/15697443467232.jpg)
![](media/15697437015359/15697444759007.jpg)

### 3.3 添加host
![](media/15697437015359/15697454464775.jpg)

## 4.client安装配置
同样修改主机名，配置hosts解析

### 4.1 安装客户端

```bash
# yum install -y authconfig authconfig-gtk ipa-client
```
### 4.2 配置ipa-client

```bash
[root@ipa ~]# ipa-client-install --domain=server.dp --no-ntp --realm=SERVER.DP --mkhomedir
Provide your IPA server name (ex: ipa.example.com): ipa.server.dp  #此处填写server端域名
The failure to use DNS to find your IPA server indicates that your resolv.conf file is not properly configured.
Autodiscovery of servers for failover cannot work with this configuration.
If you proceed with the installation, services will be configured to always access the discovered server for all operations and will not fail over to other servers in case of failure.
Proceed with fixed values and no DNS discovery? [no]: yes
Client hostname: ipa.client.dp
Realm: SERVER.DP
DNS Domain: server.dp
IPA Server: ipa.server.dp
BaseDN: dc=server,dc=dp

Continue to configure the system with these values? [no]: yes  #输入no后会退出
Skipping synchronizing time with NTP server.
User authorized to enroll computers: admin  #输入管理员名称
Password for admin@SERVER.DP:   #输入管理员密码
Successfully retrieved CA cert
...
Client configuration complete.
The ipa-client-install command was successful
```
### 4.3 验证用户能否登陆

```bash
[root@ipa ~]# ssh zhangsan@ipa.client.dp
Password:  #输入server创建用户的密码
Password expired. Change your password now. #密码过期，重新设置
Current Password: 
New password: 
Retype new password: 
Creating home directory for zhangsan.
Last failed login: Sun Sep 29 17:00:11 CST 2019 from 192.168.1.40 on ssh:notty
There were 2 failed login attempts since the last successful login.

Welcome to Alibaba Cloud Elastic Compute Service !

[zhangsan@ipa ~]$ pwd  #若是在家目录下，说明家目录创建成功
/home/zhangsan
```
至此，安装完毕，接下来的配置在web界面操作即可
# 5.常见报错及解决
https://www.cnblogs.com/yinzhengjie/p/10106337.html

### 报错1：

```bash
File "/usr/sbin/ipa-server-install", line 23, in <module> from ipaserver.install import ipa_server_install
...
ImportError: No module named 'requests.packages.urllib3'

#解决：
# yum install python-urllib3
# pip install --upgrade --force-reinstall 'requests==2.6.0'
```
### 报错2：

```bash
File "/usr/sbin/ipa-server-install", line 23, in <module>
    from ipaserver.install import ipa_server_install
...
ImportError: cannot import name UnrewindableBodyError

#解决：
# pip uninstall urllib3
# yum install python-urllib3
```
### 报错3:

```bash
ipapython.admintool: ERROR    IPv6 stack is enabled in the kernel but there is no interface that has ::1 address assigned. Add ::1 address resolution to 'lo' interface. You might need to enable IPv6 on the interface 'lo' in sysctl.conf.
ipapython.admintool: ERROR    The ipa-server-install command failed. See /var/log/ipaserver-install.log for more information

#解决：
在/etc/sysctl.conf中加上net.ipv6.conf.all.disable_ipv6 = 0，使用sysctl -p生效
```
### 报错4:

```bash
[error] NetworkError: cannot connect to 'ldap://labipa.example.com:389': 
ipa.ipapython.install.cli.install_tool(CompatServerMasterInstall): ERROR    cannot connect to 
'ldap://labipa.example.com:389': 
ipa.ipapython.install.cli.install_tool(CompatServerMasterInstall): ERROR    The ipa-server-install command 
failed. See /var/log/ipaserver-install.log for more information

#解决：
将hosts中的公网ip换为私网ip
```
### 报错5:

```bash
ipapython.dnsutil: ERROR    DNS query for server.ipa.dp. 1 failed: The DNS operation timed out after 30.0006301403 seconds
ipaserver.dns_data_management: ERROR    unable to resolve host name server.ipa.dp. to IP address, ipa-ca DNS record will be incomplete
ipapython.admintool: ERROR    Command '/bin/systemctl restart ipa.service' returned non-zero exit status 1
ipapython.admintool: ERROR    The ipa-server-install command failed. See /var/log/ipaserver-install.log for more information

#解决：
在hosts解析中尽量将同一ip的解析写在一行
```

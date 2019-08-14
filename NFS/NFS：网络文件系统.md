---


typora-root-url: Images
typora-copy-images-to: Images
---

# NFS：网络文件系统

# 一、NFS简介

## 1.1：NFS服务简介

### 1.1.1：NFS

Network File System 网络文件系统，基于内核的文件系统。Sun公司开发，通过使用NFS，用户和程序可以像访问本地文件一样访问远端系统上的文件，基于RPC（Remote Procedure Call Protocol远程过程调用）实现

### 1.1.2：RPC

RPC采用C/S模式，客户机请求程序调用进程发送一个有进程参数的调用信息到服务进程，然后等待应答信息。在服务器端，进程保持睡眠状态直到调用信息到达为止。当一个调用信息到达，服务器获得进程参数，计算结果，发送答复信息，然后等待下一个调用信息，最后，客户端调用进程接收答复信息，获得进程结果，然后调用执行继续进行

### 1.1.3：NFS优势

- 节省本地存储空间，将常用的数据,如home目录,存放在NFS服务器上且可以通过网络访问，本地终端将可减少自身存储空间的使用
- 实现信息资源共享，集中管理

### 1.1.4：NFS与RPC关系

NFS本身是没有提供信息传输的协议和功能的，可以理解为NFS是一种文件系统，RPC负责信息的传输

## 1.2：NFS文件系统

![image](https://github.com/handsomezhuzhuzhu/linuxstudy/tree/master/NFS/Images/1565753999869.png)

## 1.3：NFS工作原理

![image](https://github.com/handsomezhuzhuzhu/linuxstudy/tree/master/NFS/Images/1565754019102.png)

## 1.4：NFS各版本对比

| NFS v2                                                     | NFS v3                                                       | NFS v4                                                       |
| ---------------------------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 只支持32位文件传输，最大文件数4G                           | 支持64位文件传输                                             | CentOS7默认很使用NFSv4版,实现伪根，辅助服务不需要，完全支持kerberos |
| 文件传输尺寸限制在8K                                       | 没有文件尺寸限制                                             |                                                              |
| 无                                                         | v3增加和完善了许多错误和成功信息的返回,对于服务器的设置和管理能带来很大好处 | 改进了INTERNET上的存取和执行效能在协议中增强了安全方面的特性 |
| 只提供了对UDP协议的支持,在一些高要求的网络环境中有很大限制 | 增加了对TCP传输协议的支持             有更好的I/O 写性能     | 只支持TCP传输通过一个安全的带内系统，协商在服务器和客户端之间使用的安全性类型，使用字符串而不是整数来表示用户和组标识符 |
# 二、NFS安装（ubuntu）

## 2.1：服务端

软件包：apt-get install nfs-kernel-server

端口：2049（nfsd），其他端口由portmap（111）分配

配置文件：/etc/exports,/etc/exports.d/*.exports

主要进程：

- rpc.nfsd：最主要的NFS进程，管理客户端是否可登录
- rpc.mountd： 挂载和卸载NFS文件系统，包括权限管理
- rpc.lockd：非必要，管理文件锁，避免同时写出错
- rpc.statd：非必要，检查文件一致性，可修复文件

### 2.1.1：安装NFS服务

```bash
root@node1:~# apt-get install nfs-kernel-server
```

### 2.1.2：配置NFS共享目录

```bash
#创建共享目录
root@node1:~# mkdir /data/share

#配置目录共享
root@node1:~# vim /etc/exports
# /etc/exports: the access control list for filesystems which may be exported
#               to NFS clients.  See exports(5).
#
# Example for NFSv2 and NFSv3:
# /srv/homes       hostname1(rw,sync,no_subtree_check) hostname2(ro,sync,no_subtree_check)
#
# Example for NFSv4:
# /srv/nfs4        gss/krb5i(rw,sync,fsid=0,crossmnt,no_subtree_check)
# /srv/nfs4/homes  gss/krb5i(rw,sync,no_subtree_check)
#
/data/share *(rw,no_root_squash)
```

相关权限和选项：

```bash
#默认选项：(ro,sync,root_squash,no_all_squash)
#ro,rw 只读和读写
#async 异步，数据变化后不立即写磁盘，性能高
#sync（1.0.0后为默认）同步，数据在请求时立即写入共享
#no_all_squash （默认）保留共享文件的UID和GID
#all_squash 所有远程用户(包括root)都变成nfsnobody
#root_squash （默认）远程root映射为nfsnobody,UID为65534，早期版本是4294967294 (nfsnobody)
#no_root_squash 远程root映射成root用户
#anonuid和anongid 指明匿名用户映射为特定用户UID和组GID，而非nfsnobody,可配合all_squash使用
```

NFS工具：

```bash
#rpcinfo
	rpcinfo -p IP
	rpcinfo -s IP

#exportfs
	-v 查看本机所有NFS共享
	-r 重读配置文件，并共享目录
	-a 输出本机所有共享
	-au 停止本机所有共享

#showmount -e IP  查看主机共享目录，通常客户端使用
#mount.nfs 挂载工具
```



## 2.2：客户端

### 2.2.1：安装NFS客户端

```bash
root@node2:~# apt install nfs-common
```

### 2.2.2：挂载共享目录

```bash
root@node2:~# showmount -e 192.168.172.91 #查看服务端主机共享的目录
Export list for 192.168.172.91:
/data/share *

#挂载共享目录
root@node2:~# mount 192.168.172.91:/data/share /data/

#查看挂载
root@node2:~# df -h
Filesystem                  Size  Used Avail Use% Mounted on
...
192.168.172.91:/data/share   46G   52M   44G   1% /data

#测试文件同步
```

挂载选项：

```bash
基于安全考虑，建议使用nosuid,nodev,noexec挂载选项
NFS相关的挂载选项：
	fg（默认）前台挂载，bg后台挂载
	hard（默认）持续请求，soft 非持续请求
	intr 和hard配合，请求可中断
	rsize和wsize 一次读和写数据最大字节数，rsize=32768
	_netdev 无网络不挂载

#示例：
mount -o rw,nosuid,fg,hard,intr 192.168.172.91:/data/share /data/
```

### 2.2.3：开机挂载

```bash
root@node2:~# vim /etc/fstab 
192.168.172.91:/data/share /opt nfs defaults,_netdev 0 0
#加上_netdev表示开机无网络时不挂载，不加的话会在开机时报错
```

### 2.2.4：autofs自动挂载

```bash
#可使用autofs按需要挂载NFS共享，在空闲时自动卸载
#由autofs包提供
#系统管理器指定由/etc/auto.master自动挂载器守护进程控制的挂载点
#自动挂载监视器访问这些目录并按要求挂载文件系统
#文件系统在失活的指定间隔5分钟后会自动卸载
#为所有导出到网络中的NFS启用特殊匹配 -host 至“browse”
#参看帮助：man 5 autofs
#支持含通配符的目录名
# * server:/export/&
```

安装配置自动挂载：

```bash
root@node2:~# apt install autofs

#本次使用绝对路径法：
root@node2:~# vim /etc/auto.master 
/-      /etc/auto.misc  #挂载目录写在子配置文件中，可以避免影响同一目录下的其他文件
root@node2:~# vim /etc/auto.misc 
/data   -fstype=nfs 192.168.172.91:/data/share

#重启autofs服务查看挂载情况
root@node2:/# systemctl restart autofs.service 
root@node2:/# df
Filesystem                 1K-blocks    Used Available Use% Mounted on
...
192.168.172.91:/data/share  47799040   53248  45288064   1% /data
```




# zookeeper

下载地址：https://archive.apache.org/dist/zookeeper/

## 安装：

​	前提：需要预先准备好jdk环境，安装在jdk环境上

​	因为zookeeper特殊的选举机制，部署服务时一般部署奇数台服务（3.5.7.9...）

```bash
# pwd
/usr/local/src
# wget https://archive.apache.org/dist/zookeeper/zookeeper-3.4.14/zookeeper-3.4.14.tar.gz
# tar xf zookeeper-3.4.14.tar.gz 
# ln -sv /usr/local/src/zookeeper-3.4.14 /usr/local/zookeeper
# mkdir /usr/local/zookeeper/data
# cp /usr/local/zookeeper/conf/zoo_sample.cfg /usr/local/zookeeper/conf/zoo.cfg

# grep "^[a-Z]" /usr/local/zookeeper/conf/zoo.cfg
tickTime=2000  #服务器与服务器之间和客户端与服务器之间的单次心跳检测时间间隔，单位为毫秒 
initLimit=5  #集群中leader服务器与follwer服务器初始连接心跳次数，即多少个2000毫秒
syncLimit=5  #leader与follower之间完成连接后，后期检测发送和应答的心跳次数，如果该follower在设置的时间内（5*2000）不能与leader通信，那么此follower被认为不可用状态
dataDir=/usr/local/zookeeper/data  #自定义的zookeeper数据保存目录
clientPort=2181  #客户端连接zookeeper服务器的端口，zookeeper会监听此端口，接收客户端的访问请求
autopurge.snapRetainCount=3  #设置zookeeper保存保留多少次客户端连接的数据
autopurge.purgeInterval=1 #设置zookeeper间隔多少小时清理一次保存的客户端数据
server.1=192.168.172.91:2888:3888  #服务器编号=服务器IP：LF数据同步端口：LF选举端口
server.2=192.168.172.92:2888:3888
server.3=192.168.172.93:2888:3888

#echo "1" > /usr/local/zookeeper/data/myid
```

## 使用：

```bash
启动zookeeper：
# /usr/local/zookeeper/bin/zkServer.sh start

查看zookeeper状态：
# /usr/local/zookeeper/bin/zkServer.sh status #状态分为follower和leader

容器中查看zookeeper状态：
#docker exec -it 容器名 bash
#echo "status" | nc 127.0.0.1 2181

生成数据：（在其中一个各节点生成数据，在其他节点查询此数据）
# /usr/local/zookeeper/bin/zkCli.sh -server 192.168.172.91:2181
create /test "hello"

其他节点验证数据
# /usr/local/zookeeper/bin/zkCli.sh -server 192.168.172.92:2181
get /test
```


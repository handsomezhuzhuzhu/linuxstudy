# Kafka

## kafka组成：

- broker

  一个kafka集群包含一个或多个服务器，这种服务器被称为broker

- topic

  每条发布到kafka集群中的消息都有一个类别，被称为topic（物理上不同topic的消息分开存储，逻辑上一个topic的消息虽然保存于一个或多个broker上，但用户只需指定消息的topic即可生产或消费数据，而不必关心数据存于何处）

- partition

  partition是物理上的概念，每个topic包含一个或多个partition，创建topic时可指定partition数量，每个partition对应于一个文件夹，该文件夹下存储该partition的数据和索引文件

- producer

  负责发布消息到kafka broker

- consumer

  消费消息，每个consumer属于一个特定的consumer group（可为每个consumer指定groupname，若不指定groupname则属于默认的group）。使用consumer high level API时，同一topic的一条消息只能被同一个consumer group内的一个consumer消费，但多个consumer group可同时消费这一条消息

## 安装：

下载地址：http://kafka.apache.org/downloads

```bash
# pwd
/usr/local/src
# tar xf kafka_2.12-2.1.0.tgz
# ln -sv /usr/local/src/kafka_2.12-2.1.0 /usr/local/kafka

# vim /usr/local/kafka/config/server.properties
21 broker.id=1  #设置每个代理全局唯一的整数ID
31 listeners=PLAINTEXT://192.168.172.91:9092
103 log.retention.hours=24  #保留指定小时的日志内容
123 zookeeper.connect=192.168.172.91:2181,192.168.172.92:2181,192.168.172.93:2181 #所有的zookeeper地址
```

## 使用：

```bash
# /usr/local/kafka/bin/kafka-server-start.sh -daemon /usr/local/kafka/config/server.properties  #以守护进程的方式启动

# tail -f /usr/local/kafka/logs/server.log
...
[2019-08-21 19:44:14,325] INFO [KafkaServer id=1] started (kafka.server.KafkaServer)
```

- 分别在主机1、2、3上验证进程

```bash
# jps
2241 QuorumPeerMain
3159 Jps
3071 Kafka

# jps
2182 QuorumPeerMain
2764 Kafka
2828 Jps

# jps
2677 Jps
2613 Kafka
2122 QuorumPeerMain
```

- 测试创建topic

```bash
创建名为logstash，partition为3，replication为3的topic（在任意服务器操作）：
# /usr/local/kafka/bin/kafka-topics.sh --create --zookeeper 192.168.172.91:2181,192.168.172.92:2181,192.168.172.93:2181 --partitions 3 --replication-factor 3 --topic logstash
Created topic "logstash".
```

- 测试获取topic

```bash
在任意一台服务器上测试获取：
# /usr/local/kafka/bin/kafka-topics.sh --describe --zookeeper 192.168.172.91:2181,192.168.172.92:2181,192.168.172.93:2181 --topic logstash
Topic:logstash	PartitionCount:3	ReplicationFactor:3	Configs:
	Topic: logstash	Partition: 0	Leader: 2	Replicas: 2,3,1	Isr: 2,3,1
	Topic: logstash	Partition: 1	Leader: 3	Replicas: 3,1,2	Isr: 3,1,2
	Topic: logstash	Partition: 2	Leader: 1	Replicas: 1,2,3	Isr: 1,2,3
#状态说明：logstash有三个分区分别为0、1、2，分区0的leader是2（broker.id），分区0有三个副本，并且状态都为Isr（In-sync，表示可以参加选举成为leader）
```

- 测试删除topic

```bash
# usr/local/kafka/bin/kafka-topics.sh --delete --zookeeper 192.168.172.91:2181,192.168.172.92:2181,192.168.172.93:2181 --topic logstash
Topic logstash is marked for deletion.
Note: This will have no impact if delete.topic.enable is not set to true.

#查询是否删除
# /usr/local/kafka/bin/kafka-topics.sh --describe --zookeeper 192.168.172.91:2181,192.168.172.92:2181,192.168.172.93:2181 --topic logstash
```

- 获取所有的topic

```bash
# /usr/local/kafka/bin/kafka-topics.sh --list --zookeeper 192.168.172.91:2181,192.168.172.92:2181,192.168.172.93:2181
```

- kafka命令测试消息发送

```bash
#创建topic
# /usr/local/kafka/bin/kafka-topics.sh --create --zookeeper 192.168.172.91:2181,192.168.172.92:2181,192.168.172.93:2181 --partitions 3 --replication-factor 3 --topic messagetest
Created topic "messagetest".

#发送消息
# /usr/local/kafka/bin/kafka-console-producer.sh  --broker-list  192.168.172.91:9092,192.168.172.92:9092,192.168.172.93:9092  --topic messagetest

#其他kafka服务器上获取数据
# /usr/local/kafka/bin/kafka-console-consumer.sh  --topic messagetest  --bootstrap-server 192.168.172.91:9092 --from-beginning
```

 


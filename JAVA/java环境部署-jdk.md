# java环境部署-jdk

下载地址：https://www.oracle.com/technetwork/java/javase/downloads/index.html

安装步骤：

```bash
# pwd
/usr/local/src
# tar xf jdk-8u162-linux-x64.tar.gz
# ln -sv ln -sv /usr/local/src/jdk1.8.0_162 /usr/local/jdk
# ln -sv /usr/local/jdk/bin/java /usr/bin/

# vim /etc/profile
export HISTTIMEFORMAT="%F %T `whoami` "
export export LANG="en_US.utf-8"
export JAVA_HOME=/usr/local/jdk
export CLASSPATH=.:$JAVA_HOME/jre/lib/rt.jar:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
export PATH=$PATH:$JAVA_HOME/bin

# source /etc/profile

# java -version
java version "1.8.0_162"
Java(TM) SE Runtime Environment (build 1.8.0_162-b12)
Java HotSpot(TM) 64-Bit Server VM (build 25.162-b12, mixed mode)
```


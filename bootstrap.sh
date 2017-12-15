#!/bin/bash

: ${HADOOP_PREFIX:=/usr/local/hadoop}

$HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

rm /tmp/*.pid

# installing libraries if any - (resource urls added comma separated to the ACP system variable)
cd $HADOOP_PREFIX/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

sed s/HOSTNAME/$HOSTNAME/ /usr/local/hadoop/etc/hadoop/core-site.xml.template > /usr/local/hadoop/etc/hadoop/core-site.xml

service sshd start
$HADOOP_PREFIX/sbin/start-dfs.sh
$HADOOP_PREFIX/sbin/start-yarn.sh

# Replace included Hive version with user provided
[ -d /usr/local/custom-hive ] && cd /usr/local && ln -sfn /usr/local/custom-hive hive && echo "RUNNING CUSTOM VERSION!"

# Link config to /etc/hive where we've added hive-site.xml
rm -rf $HIVE_HOME/conf
ln -s /etc/hive $HIVE_HOME/conf

$HADOOP_PREFIX/bin/hdfs dfsadmin -safemode leave \
  && $HADOOP_PREFIX/bin/hdfs dfs -put $HIVE_HOME/lib/hive-exec*.jar /user/hive/hive-exec.jar \
  && cd $HIVE_HOME \
  && rm -rf metastore_db \
  && bin/schematool -dbType derby -initSchema \
  && rm metastore_db/*.lck

echo "beeline -u 'jdbc:hive2://localhost:10000' -n root" > ~/.bash_history

mkdir -p /tmp/root
$HIVE_HOME/bin/hiveserver2 > /tmp/root/hive.out 2> /tmp/root/hive.err &
while ! netstat -anp | grep 10000; do sleep 0.1; done
/bin/bash

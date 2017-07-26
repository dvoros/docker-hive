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

$HADOOP_PREFIX/bin/hdfs dfsadmin -safemode leave

cd $HIVE_HOME
if [[ $1 == "-d" ]]; then
  bin/hiveserver2 > /tmp/root/hive.out 2> /tmp/root/hive.err
  exit $?
fi

bin/hiveserver2 > /tmp/root/hive.out 2> /tmp/root/hive.err &
/bin/bash

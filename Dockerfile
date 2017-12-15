FROM dvoros/tez:HDP-2.6.0.3-hive1

RUN curl -s http://s3.amazonaws.com/public-repo-1.hortonworks.com/HDP/centos6/2.x/updates/2.6.0.3/tars/hive/apache-hive-1.2.1000.2.6.0.3-8-bin.tar.gz | tar -xz -C /usr/local
RUN cd /usr/local && ln -s apache-hive-1.2.1000.2.6.0.3-8-bin hive

ENV HIVE_HOME /usr/local/hive

RUN $BOOTSTRAP && $HADOOP_PREFIX/bin/hdfs dfsadmin -safemode leave \
  && $HADOOP_PREFIX/bin/hdfs dfs -mkdir -p    /tmp \
  && $HADOOP_PREFIX/bin/hdfs dfs -mkdir -p    /user/hive/warehouse \
  && $HADOOP_PREFIX/bin/hdfs dfs -chmod g+w   /tmp \
  && $HADOOP_PREFIX/bin/hdfs dfs -chmod g+w   /user/hive/warehouse

ENV PATH $PATH:$HIVE_HOME/bin:$HADOOP_PREFIX/bin

ADD hive-site.xml /etc/hive/
ADD core-site.xml.template $HADOOP_PREFIX/etc/hadoop/

ENV HADOOP_CLIENT_OPTS $HADOOP_CLIENT_OPTS -XX:MaxPermSize=256m

COPY bootstrap.sh /etc/bootstrap.sh
RUN chown root.root /etc/bootstrap.sh
RUN chmod 700 /etc/bootstrap.sh

CMD ["/etc/bootstrap.sh"]

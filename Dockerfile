FROM dvoros/tez:0.8.4

RUN curl -s http://www.eu.apache.org/dist/hive/hive-2.3.0/apache-hive-2.3.0-bin.tar.gz | tar -xz -C /usr/local
RUN cd /usr/local && ln -s apache-hive-2.3.0-bin hive

ENV HIVE_HOME /usr/local/hive

RUN $BOOTSTRAP && $HADOOP_PREFIX/bin/hdfs dfsadmin -safemode leave \
  && $HADOOP_PREFIX/bin/hdfs dfs -mkdir -p    /tmp \
  && $HADOOP_PREFIX/bin/hdfs dfs -mkdir -p    /user/hive/warehouse \
  && $HADOOP_PREFIX/bin/hdfs dfs -chmod g+w   /tmp \
  && $HADOOP_PREFIX/bin/hdfs dfs -chmod g+w   /user/hive/warehouse

ENV PATH $PATH:$HIVE_HOME/bin:$HADOOP_PREFIX/bin

ADD hive-site.xml $HIVE_HOME/conf/
ADD core-site.xml.template $HADOOP_PREFIX/etc/hadoop/

ENV HADOOP_CLIENT_OPTS $HADOOP_CLIENT_OPTS -XX:MaxPermSize=256m

COPY bootstrap.sh /etc/bootstrap.sh
RUN chown root.root /etc/bootstrap.sh
RUN chmod 700 /etc/bootstrap.sh

CMD ["/etc/bootstrap.sh"]

FROM sequenceiq/hadoop-docker:2.7.1

RUN curl -s http://xenia.sote.hu/ftp/mirrors/www.apache.org/hive/hive-2.3.0/apache-hive-2.3.0-bin.tar.gz | tar -xz -C /usr/local
RUN cd /usr/local && ln -s apache-hive-2.3.0-bin hive

ENV HIVE_HOME /usr/local/hive

RUN $BOOTSTRAP && $HADOOP_PREFIX/bin/hdfs dfsadmin -safemode leave \
  && $HADOOP_PREFIX/bin/hdfs dfs -mkdir       /tmp \
  && $HADOOP_PREFIX/bin/hdfs dfs -mkdir -p    /user/hive/warehouse \
  && $HADOOP_PREFIX/bin/hdfs dfs -chmod g+w   /tmp \
  && $HADOOP_PREFIX/bin/hdfs dfs -chmod g+w   /user/hive/warehouse \
  && cd $HIVE_HOME \
  && bin/schematool -dbType derby -initSchema \
  && rm metastore_db/*.lck

ENV PATH $PATH:$HIVE_HOME/bin:$HADOOP_PREFIX/bin

ADD hive-site.xml $HIVE_HOME/conf/
ADD core-site.xml.template $HADOOP_PREFIX/etc/hadoop/

ENV HADOOP_CLIENT_OPTS $HADOOP_CLIENT_OPTS -XX:MaxPermSize=256m

COPY bootstrap.sh /etc/bootstrap.sh
RUN chown root.root /etc/bootstrap.sh
RUN chmod 700 /etc/bootstrap.sh

CMD ["/etc/bootstrap.sh"]

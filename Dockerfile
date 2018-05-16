FROM dvoros/tez:0.8.5

RUN curl -s http://www.eu.apache.org/dist/hive/hive-2.3.3/apache-hive-2.3.3-bin.tar.gz | tar -xz -C /usr/local
RUN cd /usr/local && ln -s apache-hive-2.3.3-bin hive

ENV HIVE_HOME /usr/local/hive

RUN $BOOTSTRAP && hdfs dfsadmin -safemode leave \
  && hdfs dfs -mkdir -p    /tmp \
  && hdfs dfs -mkdir -p    /user/hive/warehouse \
  && hdfs dfs -chmod g+w   /tmp \
  && hdfs dfs -chmod g+w   /user/hive/warehouse

ENV PATH $PATH:$HIVE_HOME/bin

ADD hive-site.xml /etc/hive/
ADD core-site.xml.template $HADOOP_HOME/etc/hadoop/

ENV HADOOP_CLIENT_OPTS $HADOOP_CLIENT_OPTS -XX:MaxPermSize=256m

COPY hive-bootstrap.sh /etc/docker-startup/hive-bootstrap.sh
COPY entrypoint.sh /etc/docker-startup/entrypoint.sh
RUN chown -R root:root /etc/docker-startup
RUN chmod -R 700 /etc/docker-startup

# Downstream images can use this too start Hadoop and Hive services
ENV BOOTSTRAP /etc/docker-startup/hive-bootstrap.sh

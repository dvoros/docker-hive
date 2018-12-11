FROM dvoros/tez:0.9.1

RUN curl -s https://www-eu.apache.org/dist/hive/hive-3.1.1/apache-hive-3.1.1-bin.tar.gz | tar -xz -C /usr/local
RUN cd /usr/local && ln -s /usr/local/apache-hive-3.1.1-bin hive
ENV HIVE_HOME /usr/local/hive

RUN curl -s https://www-eu.apache.org/dist/db/derby/db-derby-10.14.2.0/db-derby-10.14.2.0-bin.tar.gz | tar -xz -C /usr/local
RUN ln -s /usr/local/db-derby-10.14.2.0-bin /usr/local/derby
ENV DERBY_HOME /usr/local/derby
ENV DERBY_INSTALL /usr/local/derby

ENV PATH $PATH:$HIVE_HOME/bin:$DERBY_HOME/bin

RUN $BOOTSTRAP && hdfs dfsadmin -safemode leave \
  && hdfs dfs -mkdir -p    /tmp \
  && hdfs dfs -mkdir -p    /user/hive/warehouse \
  && hdfs dfs -chmod g+w   /tmp \
  && hdfs dfs -chmod g+w   /user/hive/warehouse

ADD hive-site.xml /etc/hive/
ADD core-site.xml.template $HADOOP_HOME/etc/hadoop/

ENV HADOOP_CLIENT_OPTS $HADOOP_CLIENT_OPTS -XX:MaxPermSize=256m

COPY hive-bootstrap.sh /etc/docker-startup/hive-bootstrap.sh
COPY entrypoint.sh /etc/docker-startup/entrypoint.sh
RUN chown -R root:root /etc/docker-startup
RUN chmod -R 700 /etc/docker-startup

# Downstream images can use this too start Hadoop and Hive services
ENV BOOTSTRAP /etc/docker-startup/hive-bootstrap.sh

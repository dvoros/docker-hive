# Apache Hive Docker image

[![DockerPulls](https://img.shields.io/docker/pulls/dvoros/hive.svg)](https://registry.hub.docker.com/u/dvoros/hive/)
[![DockerStars](https://img.shields.io/docker/stars/dvoros/hive.svg)](https://registry.hub.docker.com/u/dvoros/hive/)

_Note: this is the master branch - for a particular Hive version always check the related branch_

With Oracle JDK8 and Hadoop 2.7.4 and Tez 0.8.4.

## Usage

```
docker run -it dvoros/hive:latest
```

This will leave you with a bash prompt where a default beeline command to connect to
Hiveserver2 is added to the history:

```
beeline -u 'jdbc:hive2://localhost:10000' -n root
```

You should wait a few seconds for Hiveserver2 to initialize before connecting.

## Custom Hive version

Build Hive with:

```
mvn clean install -Pdist -DskipTests -Dmaven.javadoc.skip=true -DcreateChecksum=true
```

Provide the built artifacts as a volume:

```
docker run -v /path/to/hive/packaging/target/apache-hive-XXX-bin/apache-hive-XXX-bin:/usr/local/custom-hive -it dvoros/hive:latest
```


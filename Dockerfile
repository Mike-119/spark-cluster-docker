FROM ubuntu:14.04

MAINTAINER KiwenLau <kiwenlau@gmail.com>

WORKDIR /root

# install openssh-server, openjdk and wget
RUN apt-get update && apt-get install -y openssh-server openjdk-7-jdk wget

# install hadoop 2.7.2
RUN wget https://github.com/kiwenlau/compile-hadoop/releases/download/2.7.2/hadoop-2.7.2.tar.gz && \
    tar -xzvf hadoop-2.7.2.tar.gz && \
    mv hadoop-2.7.2 /usr/local/hadoop && \
    rm hadoop-2.7.2.tar.gz
	
# Install dependencies  -mike
RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install \
    -yq --no-install-recommends  \
      python python3 \
  && apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# Install Spark-2.0.1 -mike
RUN wget https://mirrors.ocf.berkeley.edu/apache/spark/spark-2.0.1/spark-2.0.1-bin-hadoop2.7.tgz && \
    tar -xzvf spark-2.0.1-bin-hadoop2.7.tgz && \
	mv spark-2.0.1-bin-hadoop2.7 /usr/local/spark && \
	rm spark-2.0.1-bin-hadoop2.7.tgz

# set environment variable
ENV JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64 
ENV HADOOP_HOME=/usr/local/hadoop
ENV SPARK_HOME=/usr/local/spark 
ENV PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin:/usr/local/spark/bin:/usr/local/spark/sbin

# ssh without key
RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

RUN mkdir -p ~/hdfs/namenode && \ 
    mkdir -p ~/hdfs/datanode && \
    mkdir $HADOOP_HOME/logs

COPY config/* /tmp/

RUN mv /tmp/ssh_config ~/.ssh/config && \
    mv /tmp/hadoop-env.sh /usr/local/hadoop/etc/hadoop/hadoop-env.sh && \
	rm -f /usr/local/spark/conf/hadoop-env.sh && \
	mv /tmp/spark-env.sh /usr/local/spark/conf/hadoop-env.sh && \
    mv /tmp/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \ 
    mv /tmp/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml && \
    mv /tmp/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml && \
    mv /tmp/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    mv /tmp/slaves $HADOOP_HOME/etc/hadoop/slaves && \
	rm -f /tmp/slaves $SPARK_HOME/conf/slaves && \
	mv /tmp/slaves $SPARK_HOME/conf/slaves && \
    mv /tmp/start-hadoop.sh ~/start-hadoop.sh && \
	mv /tmp/start-spark.sh ~/start-spark.sh && \
    mv /tmp/run-wordcount.sh ~/run-wordcount.sh

RUN chmod +x ~/start-hadoop.sh && \
    chmod +x ~/run-wordcount.sh && \
    chmod +x $HADOOP_HOME/sbin/start-dfs.sh && \
    chmod +x $HADOOP_HOME/sbin/start-yarn.sh && \
	chmod +x ~/start-spark.sh && \
	chmod +x $SPARK_HOME/sbin/start-all.sh

# format namenode
RUN /usr/local/hadoop/bin/hdfs namenode -format

CMD [ "sh", "-c", "service ssh start; bash"]


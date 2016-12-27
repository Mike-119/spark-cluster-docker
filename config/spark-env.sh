#!/usr/bin/env bash

# The java implementation to use.
export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64

export HADOOP_HOME=/usr/local/hadoop

export HADOOP_CONF_DIR=${HADOOP_CONF_DIR:-"/etc/hadoop"}

export SCALA_HOME=/usr/local/scala

export SPARK_MASTER_IP=hadoop-master
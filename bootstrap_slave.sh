#!/bin/bash

export JAVA_HOME=/usr/java/default
export SPARK_HOME=/usr/local/spark

export PATH=$PATH:$JAVA_HOME/bin

$SPARK_HOME/sbin/start-slave.sh spark://spark-master:7077

/usr/sbin/sshd -D

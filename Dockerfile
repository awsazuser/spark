FROM centos:latest
MAINTAINER testing

USER root

# install dev tools
RUN yum clean all; \
    rpm --rebuilddb; \
    yum install -y wget curl which tar sudo openssh-server openssh-clients rsync
# update libselinux. see https://github.com/sequenceiq/hadoop-docker/issues/14
RUN yum update -y libselinux

# java
RUN curl -LO 'http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.rpm' -H 'Cookie: oraclelicense=accept-securebackup-cookie'
RUN rpm -i jdk-8u131-linux-x64.rpm
RUN rm jdk-8u131-linux-x64.rpm

#sala
RUN wget https://downloads.lightbend.com/scala/2.12.2/scala-2.12.2.rpm
RUN rpm -Uvh scala-2.12.2.rpm
RUN rm scala-2.12.2.rpm

# spark
RUN wget https://d3kbcqa49mib13.cloudfront.net/spark-2.1.1-bin-hadoop2.7.tgz
RUN tar -xvzf spark-2.1.1-bin-hadoop2.7.tgz -C /usr/local/
RUN cd /usr/local && ln -s ./spark-2.1.1-bin-hadoop2.7 spark


ENV SPARK_HOME /usr/local/spark
ENV JAVA_HOME /usr/java/default
ENV PATH $PATH:$JAVA_HOME/bin:$SPARK_HOME/bin:$PATH
RUN rm /usr/bin/java && ln -s $JAVA_HOME/bin/java /usr/bin/java

# pseudo distributed
ADD slaves $SPARK_HOME/conf/slaves

ADD bootstrap_master.sh /usr/local/bootstrap_master.sh
ADD bootstrap_slave.sh /usr/local/bootstrap_slave.sh
RUN chmod 700 /usr/local/bootstrap_master.sh
RUN chmod 700 /usr/local/bootstrap_slave.sh
ADD hadoop-azure-2.7.1.jar /usr/local/spark/hadoop-azure-2.7.1.jar
ADD azure-storage-2.0.0.jar /usr/local/spark/azure-storage-2.0.0.jar
ADD sqljdbc4.jar /usr/local/spark/sqljdbc4.jar

ADD core-site.xml /usr/local/spark/conf/core-site.xml
ADD spark-defaults.conf /usr/local/spark/conf/spark-defaults.conf

# spark ports
EXPOSE 7077 8080 6066

CMD ["/usr/sbin/sshd", "-D"]

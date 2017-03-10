#/bin/bash
#download the package and move the configuration documents to some file
export http_proxy=http://16.153.99.11:8080 &&
cd /usr/local/src/ &&
wget http://mirrors.hust.edu.cn/apache/maven/maven-3/3.1.1/binaries/apache-maven-3.1.1-bin.tar.gz &&
tar zxf apache-maven-3.1.1-bin.tar.gz &&
mv apache-maven-3.1.1 /usr/local/maven3 &&

#set evn
sed -i 'N;78i\export JAVA_HOME=\/usr\/lib\/jvm\/java-1.8.0-openjdk-1.8.0.65-3.b17.el7.x86_64\/jre' /etc/profile &&
sed -i 'N;78i\export M2_HOME=\/usr\/local\/maven3' /etc/profile  &&
sed -i '/export PATH=$PATH:${K8S_HOME}\/bin/s/$/:$JAVA_HOME\/bin:$M2_HOME\/bin/' /etc/profile &&

source /etc/profile &&

#
mkdir ~/.m2



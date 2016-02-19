# Ubuntu 14.04 LTS
# Oracle Java 1.8.0_11 64 bit
# Maven 3.2.2
# git 1.9.1

# extend the most recent long term support Ubuntu version
FROM phusion/baseimage:0.9.17

MAINTAINER Hiroki Gota

# this is a non-interactive automated build - avoid some warning messages
ENV DEBIAN_FRONTEND noninteractive

# update dpkg repositories
RUN apt-get update 

# install wget
RUN apt-get install -y wget

# get maven 3.2.2
RUN wget --no-verbose -O /tmp/apache-maven-3.2.2.tar.gz http://archive.apache.org/dist/maven/maven-3/3.2.2/binaries/apache-maven-3.2.2-bin.tar.gz

# verify checksum
RUN echo "87e5cc81bc4ab9b83986b3e77e6b3095 /tmp/apache-maven-3.2.2.tar.gz" | md5sum -c

# install maven
ENV MAVEN apache-maven-3.2.2
RUN tar xzf /tmp/apache-maven-3.2.2.tar.gz -C /opt/
RUN ln -s /opt/apache-maven-3.2.2 /opt/maven
RUN ln -s /opt/maven/bin/mvn /usr/local/bin
RUN rm -f /tmp/apache-maven-3.2.2.tar.gz
ENV MAVEN_HOME /opt/maven

ADD conf/settings.xml /opy/$MAVEN/

# install git
RUN apt-get install -y git

# remove download archive files
RUN apt-get clean

# set shell variables for java installation
ENV java_version 1.8.0_11
ENV filename jdk-8u11-linux-x64.tar.gz
ENV downloadlink http://download.oracle.com/otn-pub/java/jdk/8u11-b12/$filename

# download java, accepting the license agreement
RUN wget --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" -O /tmp/$filename $downloadlink 

# unpack java
RUN mkdir /opt/java-oracle && tar -zxf /tmp/$filename -C /opt/java-oracle/
ENV JAVA_HOME /opt/java-oracle/jdk$java_version
ENV PATH $JAVA_HOME/bin:$PATH

# configure symbolic links for the java and javac executables
RUN update-alternatives --install /usr/bin/java java $JAVA_HOME/bin/java 20000 && update-alternatives --install /usr/bin/javac javac $JAVA_HOME/bin/javac 20000

# download tomcat
ENV TOMCAT_VERSION=7.0.65
RUN wget --no-verbose -O /tmp/apache-tomcat-$TOMCAT_VERSION.tar.gz http://ftp.wayne.edu/apache/tomcat/tomcat-7/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz

# install tomcat
RUN tar xzf /tmp/apache-tomcat-$TOMCAT_VERSION.tar.gz -C /opt/

ENV CATALINA_HOME /opt/apache-tomcat-$TOMCAT_VERSION
RUN mkdir -p ADD /$CATALINA_HOME/conf/Catalina/localhost
ADD ../tomcat/tomcat-users.xml  /$CATALINA_HOME/conf/
ADD ../tomcat/ROOT.xml  /$CATALINA_HOME/conf/Catalina/localhost


RUN cd/api && mvn -Pprod install

CMD $CATALINA_HOME/bin/startup.sh

# configure the container to run jenkins, mapping container port 8080 to that host port
#ENTRYPOINT ["java", "-jar", "/opt/jenkins.war"]
#EXPOSE 8080
#CMD [""]



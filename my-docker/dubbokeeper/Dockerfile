FROM java:8

RUN mkdir -p /app /usr/share/fonts/myfonts

########################
# system basic config
########################
COPY sys/sources.list /etc/apt/sources.list
COPY sys/fonts/* /usr/share/fonts/myfonts/

# Microsoft fonts install
RUN apt-get update && apt-get install -y ttf-mscorefonts-installer git zip unzip

RUN cd /usr/share/fonts/myfonts && \
    mkfontscale && mkfontdir && fc-cache -fv \
    cd /app


########################
# install and config dubbokeeper
########################

# compile dubbokeeper
RUN apt-get install -y maven
RUN cd /app && wget https://github.com/dubboclub/dubbokeeper/archive/master.zip &&\
    unzip master.zip && ls -l
COPY dubbokeeper/pom.xml /app/dubbokeeper-master/pom.xml
RUN cd /app/dubbokeeper-master && sh install-mongodb.sh && ls -l target

# install monitor-ui
RUN mkdir /app/mongodb-dubbokeeper-server && \
    tar -zxvf /app/dubbokeeper-master/target/mongodb-dubbokeeper-server.tar.gz -C /app/mongodb-dubbokeeper-server &&\
    chmod +x /app/mongodb-dubbokeeper-server/bin/start-mongodb.sh

# install mongodb-monitor, dependence tomcat
RUN cd /app && wget http://mirrors.hust.edu.cn/apache/tomcat/tomcat-8/v8.5.20/bin/apache-tomcat-8.5.20.tar.gz &&\
    tar -zxf apache-tomcat-8.5.20.tar.gz && mv /app/apache-tomcat-8.5.20 /app/tomcat && rm -rf /app/tomcat/webapps/* &&\
    unzip /app/dubbokeeper-master/target/mongodb-dubbokeeper-ui/dubbokeeper-ui-1.0.1.war -d /app/tomcat/webapps/ROOT/

# config zookeeper and mongodb
COPY dubbokeeper/dubbo.properties /app/tomcat/webapps/ROOT/WEB-INF/classes/
COPY dubbokeeper/dubbo-mongodb.properties /app/mongodb-dubbokeeper-server/conf/

# clear install
RUN cd /app && rm -rf master.zip apache-tomcat-8.5.20.tar.gz

COPY dubbokeeper/run.sh /app/run.sh

WORKDIR /app

EXPOSE 8080
EXPOSE 7070

CMD sh /app/run.sh

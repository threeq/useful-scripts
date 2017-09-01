FROM java:8

RUN mkdir -p /app /usr/share/fonts/myfonts
WORKDIR /app

########################
# system basic config
########################
ADD sys/sources.list /etc/apt/sources.list
ADD sys/fonts/* /usr/share/fonts/myfonts/

# Microsoft fonts install
RUN apt-get update && apt-get install -y ttf-mscorefonts-installer git

RUN cd /usr/share/fonts/myfonts && \
    mkfontscale && mkfontdir && fc-cache -fv \
    cd /app

########################
# install and config javamelody
########################
RUN wget https://github.com/javamelody/javamelody/releases/download/javamelody-core-1.69.0/javamelody-collector-server-1.69.0.war

EXPOSE 8081
EXPOSE 8089

CMD java -server -Xmx512m -Djavamelody.authorized-users=root:root@javamelody -jar javamelody-collector-server-1.69.0.war --httpPort=8081 --ajp13Port=8089 2>&1 >>javamelody.log

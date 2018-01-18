FROM java:8-jre-alpine
MAINTAINER threeq@foxmail.com

ENV VERSION=1.70.0
ARG URL=https://github.com/javamelody/javamelody/releases/download

RUN mkdir -p /app
WORKDIR /app

RUN apk add --no-cache --update ca-certificates openssl bash && update-ca-certificates
RUN wget -O /app/javamelody.war $URL/javamelody-core-$VERSION/javamelody-collector-server-$VERSION.war

# update fonts
RUN mkdir -p /usr/share/fonts/
RUN wget -O /usr/share/fonts/MSYH.TTC https://github.com/threeq/useful-scripts/raw/master/my-docker/sys/fonts/MSYH.TTC
RUN wget -O /usr/share/fonts/MSYHBD.TTC https://github.com/threeq/useful-scripts/raw/master/my-docker/sys/fonts/MSYHBD.TTC
RUN wget -O /usr/share/fonts/MSYHL.TTC https://github.com/threeq/useful-scripts/raw/master/my-docker/sys/fonts/MSYHL.TTC

RUN apk add --no-cache --update fontconfig
RUN fc-cache -f -v

RUN ls -al /app

EXPOSE 8080
EXPOSE 8009

CMD java -server -Xmx512m -Djavamelody.authorized-users=root:root@javamelody -jar /app/javamelody.war --httpPort=8081 --ajp13Port=8089

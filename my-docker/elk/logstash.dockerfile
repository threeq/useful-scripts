FROM docker.elastic.co/logstash/logstash:6.0.0
#FROM logstash:5.6.4

USER root

RUN mkdir -p /app/config
COPY logstash.conf /app/config/

ENV X_PACK_VERSION=6.0.0

#ADD x-pack-${X_PACK_VERSION}.zip /x-pack-${X_PACK_VERSION}.zip
#RUN /usr/share/logstash/bin/logstash-plugin install file:///x-pack-${X_PACK_VERSION}.zip

ADD logstash.yml /etc/logstash/logstash.yml

CMD ["-f", "/app/config/logstash.conf"]

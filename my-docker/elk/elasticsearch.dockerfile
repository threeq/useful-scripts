FROM docker.elastic.co/elasticsearch/elasticsearch:6.0.0
#FROM elasticsearch:5.6.4

# RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install x-pack

ENV X_PACK_VERSION=6.0.0

#ADD x-pack-${X_PACK_VERSION}.zip /x-pack-${X_PACK_VERSION}.zip
#RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install file:///x-pack-${X_PACK_VERSION}.zip

ADD elasticsearch.yml /etc/elasticsearch/elasticsearch.yml

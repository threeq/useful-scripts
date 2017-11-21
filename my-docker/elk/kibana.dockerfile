FROM docker.elastic.co/kibana/kibana:6.0.0
#FROM kibana:5.6.4

#RUN /usr/share/kibana/bin/kibana-plugin install x-pack

ENV X_PACK_VERSION=6.0.0

#ADD x-pack-${X_PACK_VERSION}.zip /x-pack-${X_PACK_VERSION}.zip
#RUN /usr/share/kibana/bin/kibana-plugin install file:///x-pack-${X_PACK_VERSION}.zip

ADD kibana.yml /opt/kibana/config/kibana.yml

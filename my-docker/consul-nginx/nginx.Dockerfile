FROM nginx

ADD sources.list /etc/apt/sources.list

#Install Curl
RUN apt-get update -qq && apt-get -y install wget

ENV VERSION 0.19.3

#Download and Install Consul Template
RUN wget -L https://releases.hashicorp.com/consul-template/${VERSION}/consul-template_${VERSION}_linux_amd64.tgz
RUN tar -C /usr/local/bin -zxf consul-template_${VERSION}_linux_amd64.tgz

RUN ls -al /usr/local/bin

#Setup Consul Template Files
RUN mkdir /etc/consul-templates
ENV CT_FILE /etc/consul-templates/apps.tpl

#Setup Nginx File
ENV NX_FILE /etc/nginx/conf.d/apps.conf

#Default Variables
ENV CONSUL 172.19.133.38:8500

# Command will
# 1. Write Consul Template File
# 2. Start Nginx
# 3. Start Consul Template

ADD apps.tpl ${CT_FILE}
ADD default.conf /etc/nginx/conf.d/default.conf

CMD /usr/sbin/nginx -c /etc/nginx/nginx.conf && \
  CONSUL_TEMPLATE_LOG=debug consul-template \
  -consul-addr=$CONSUL \
  -template "$CT_FILE:$NX_FILE:/usr/sbin/nginx -s reload";
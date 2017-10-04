ødocker run -d \
    --name=registrator \
    --restart=always \
    --volume=/var/run/docker.sock:/tmp/docker.sock \
    gliderlabs/registrator:latest \
      -ip="172.19.133.38" \
      consul://172.19.133.38:8500

docker run -d \
    -p 8400:8400 \
    -p 8500:8500 \
    -p 8600:53 \
    -p 8600:53/udp \
    -h consul \
    --restart=always \
    --name=consul \
    -e "SERVICE_8500_NAME=consul-xxx-com" \
    -e "SERVICE_8500_TAGS=open_web" \
    -e "SERVICE_8400_IGNORE=true" \
    -e "SERVICE_53_IGNORE=true" \
    progrium/consul \
    -server \
    -bootstrap \
    -ui-dir=/ui \
    -advertise 172.19.133.38 \
    -client 0.0.0.0


docker run -d \
    -p 8400:8400 \
    -p 8500:8500 \
    -p 8600:53 \
    -p 8600:53/udp \
    -h consul \
    --restart=always \
    --name=consul \
    -e "SERVICE_8500_NAME=consul-xxx-com" \
    -e "SERVICE_8500_TAGS=open_web" \
    progrium/consul \
    -server \
    -bootstrap \
    -ui-dir=/ui \
    -advertise 172.19.133.38 \
    -client 0.0.0.0

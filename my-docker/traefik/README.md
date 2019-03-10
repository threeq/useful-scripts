# traefix consul

使用 traefix + consul 搭建可扩展 web 框架

## 启动 consul 和 traefik

```bash
docker-compose up -d
```

> 由于 consul 使用的是开发环境，这个脚本不能用于生产环境。生产环境请自行构建高可用 consul 集群。

## 启动 consul 注册器

```bash
cd consul-registrator
docker-compose up -d
```
> 注册器在你的后端服务器上启动

## 启动测试服务

```bash
cd traefix-example
docker-compose up --scale web_go=3```

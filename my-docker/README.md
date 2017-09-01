# my-docker

自己用的 docker 脚本记录

## 上传脚本到服务器

```bash
$ ./deploy.sh root@localhost 
# 或者
$ ./deploy.sh root@localhost dubbo
```

## dubbokeeper

我自己使用的 dubbo 版本是 2.8.4 所以这个地方对 dubbokeeper 的依赖包做了些修改。
dubbo 2.8.4 版本没有放到 maven 中心仓库，所以需要自己搭建私服。

1. 修改 `dubbo/pom.xml` 中 `{ private_url }` 为自己的私服地址
2. 修改 zookeeper 地址为你的注册中心地址，
3. 执行 

```bash
# 默认使用 monggodb 存储
$ docker-compose -f docker-compose-dubbokeeper.yml -f docker-compose-mongo.yml up -d
```

## javamelody

```bash
$ docker-compose -f docker-compose-javamelody.yml up -d
```

#!/bin/sh

redis_uri="http://download.redis.io/releases/redis-3.2.9.tar.gz"
redis_BN=$(basename $redis_uri)
redis_FN=$(basename $redis_BN .tar.gz)
source_basedir="/usr/local/src"
$RETVAL=0

#判断/usr/local/src下是否存在redis源码包,没有就下载
cd $source_basedir
if [ -s $redis_BN ];then
	echo "$redis_BN [found] ..."
else
	echo "Error: $redis_BN not found!!!download now ......"
	wget -c $redis_uri
fi

#编译安装redis
tar xf $redis_BN
cd $redis_FN
make && make PREFIX=/usr/local/redis install

#PATH变量中添加redis的路径
echo 'export PATH=$PATH:/usr/local/redis/bin' > /etc/profile.d/redis.sh
source /etc/profile.d/redis.sh

#定义随机密码,redis监听端口
RPASS=$(date +%s | sha256sum | head -c 20;echo)
RPORT=7777

#复制配置文件
cp redis.conf /usr/local/redis/${RPORT}.conf

#编辑配置文件
sed -i "s/port 6379/port $RPORT/" /usr/local/redis/${RPORT}.conf
sed -i 's/daemonize no/daemonize yes/' /usr/local/redis/${RPORT}.conf
sed -i "s#pidfile /var/run/redis_6379.pid#pidfile /var/run/redis_${RPORT}.pid#" /usr/local/redis/${RPORT}.conf
sed -i 's#logfile ""#logfile "/var/log/redis_7777.log"#' /usr/local/redis/${RPORT}.conf
sed -i 's#dir ./#dir /data/redis#' /usr/local/redis/${RPORT}.conf
sed -i "s/# requirepass foobared/requirepass $RPASS/" /usr/local/redis/${RPORT}.conf

#创建redis工作目录
[ -d /data/redis ] || mkdir -p /data/redis

FINALPASS=`awk '/^requirepass/{print $2}' /usr/local/redis/${RPORT}.conf`

cat > /etc/init.d/redis << 'EOF'
#!/bin/bash
# chkconfig: - 85 15

REDISPORT=7777
EXEC=/usr/local/redis/bin/redis-server
CLIEXEC=/usr/local/redis/bin/redis-cli

PIDFILE=/var/run/redis_${REDISPORT}.pid
CONF="/usr/local/redis/${REDISPORT}.conf"

case "$1" in
    start)
        if [ -f $PIDFILE ]
        then
            echo "$PIDFILE exists, process is already running or crashed"
        else
            echo "Starting Redis server..."
            $EXEC $CONF
        fi
        ;;
    stop)
        if [ ! -f $PIDFILE ]
        then
            echo "$PIDFILE does not exist, process is not running"
        else
            PID=$(cat $PIDFILE)
            echo "Stopping ..."
            $CLIEXEC -p $REDISPORT -a FINALPASS shutdown
            while [ -x /proc/${PID} ]
            do
                echo "Waiting for Redis to shutdown ..."
                sleep 1
            done
            echo "Redis stopped"
        fi
        ;;
    status)
        PID=$(cat $PIDFILE)
        if [ ! -x /proc/${PID} ]
        then
            echo 'Redis is not running'
        else
            echo "Redis is running ($PID)"
        fi
        ;;
    restart)
        $0 stop
        $0 start
        ;;
    *)
        echo "Please use start, stop, restart or status as first argument"
        ;;
esac

EOF

sed -i "s/FINALPASS/$FINALPASS/" /etc/init.d/redis


#加入开机启动列表
chmod 700 /etc/init.d/redis
chkconfig --add redis
chkconfig redis --level 3 on

#启动redis服务
service redis start

RETVAL=$?
if [ $RETVAL -eq 0 ];then
	echo "all done"
	echo "The FINALPASS is $FINALPASS"
else
	echo "The redis server is no ok"
	exit 7
fi



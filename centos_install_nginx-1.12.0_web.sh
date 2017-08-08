#!/bin/sh

#定义nginx下载路径,安装路径,抓取CPU核心数量信息
nginx_version="1.12.0"
nginx_url="http://nginx.org/download/nginx-${nginx_version}.tar.gz"
source_basedir="/usr/local/src"
nginx_basedir="/usr/local/nginx"
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)
RETVAL=0

# 预安装编译nginx需要的组件
yum install -y gcc gcc-c++ pcre-devel openssl-devel vim wget make libxml2-devel libxslt-devel gd-devel perl-ExtUtils-Embed geoip-devel libunwind-devel gperftools-devel

# 判断/usr/local/src下是否存在nginx源码包,没有则下载
cd $source_basedir
if [ -s $(basename $nginx_url) ];then
	echo "$(basename $nginx_url) [found]...."
else
	echo "Error: $(basename $nginx_url) not found!!!download now ......"
	wget $nginx_url
fi

# 判断是否存在www用户,如果不存在，则创建www用户
id www > /dev/null 2>&1
RETVAL=$?
if [ $RETVAL -ne 0 ];then
groupadd www
useradd -s /sbin/nologin -g www www
fi

# 定义nginx的安装等路径
nginx_BN=$(basename $nginx_url)
nginx_FN=$(basename $nginx_BN .tar.gz)

# 编译安装nginx
tar xf $nginx_BN
cd $nginx_FN
./configure --prefix=$nginx_basedir --modules-path=$nginx_basedir/modules --user=www --group=www --with-file-aio --with-ipv6 --with-http_ssl_module --with-http_gzip_static_module --with-http_gunzip_module --with-http_v2_module --with-http_realip_module --with-http_stub_status_module --with-http_dav_module --with-http_addition_module --with-http_flv_module --with-http_mp4_module --with-http_secure_link_module --with-http_degradation_module --with-http_slice_module --with-pcre --with-pcre-jit --with-stream_ssl_module --with-google_perftools_module --with-debug --with-http_xslt_module=dynamic --with-http_image_filter_module=dynamic --with-http_geoip_module=dynamic --with-http_perl_module=dynamic --with-stream=dynamic || exit 1

if [ $CPU_NUM -gt 1 ];then
    make -j$CPU_NUM
else
    make
fi
make install

# 判断nginx配置文件目录下是否存在vhosts目录,不存在则创建
[ -d $nginx_basedir/conf/vhosts ] || mkdir -v $nginx_basedir/conf/vhosts 

# nginx的主配置文件
cat > $nginx_basedir/conf/nginx.conf <<'EOF'
user www www;
worker_processes auto;
worker_cpu_affinity auto;
pid /var/run/nginx.pid; 
worker_rlimit_nofile 65535; 

events { 
	use epoll; 
	worker_connections 65535; 
} 

http { 
	include mime.types; 
	default_type application/octet-stream; 
	server_tokens off; 
	server_names_hash_bucket_size 128; 
	client_max_body_size 16m; 
	client_header_buffer_size 128k; 
	large_client_header_buffers 4 64k; 
	sendfile on; 
	tcp_nopush on; 
	tcp_nodelay on; 
	keepalive_timeout 90; 

#	open_file_cache max=65536 inactive=30s;
#	open_file_cache_valid     60s;
#	open_file_cache_min_uses  1;

	fastcgi_connect_timeout 300; 
	fastcgi_send_timeout 300; 
	fastcgi_read_timeout 300; 
	fastcgi_buffer_size 128k; 
	fastcgi_buffers 4 128k; 
	fastcgi_busy_buffers_size 128k; 
	fastcgi_temp_file_write_size 128k;
	fastcgi_hide_header X-Powered-By;

	gzip on; 
	gzip_min_length 1k; 
	gzip_buffers 4 8k; 
	gzip_http_version 1.1; 
	gzip_comp_level 2;
	gzip_types text/plain application/x-javascript text/css application/xml application/javascript; 
	gzip_vary on;
	gzip_disable "MSIE [1-6]\."; 

log_format access '$remote_addr - $remote_user [$time_local] "$request" ' 
'$status $body_bytes_sent "$http_referer" ' 
'"$http_user_agent" $http_x_forwarded_for "$request_time"'; 

	access_log logs/access.log access;
	error_log logs/error.log;

	include vhosts/*.conf; 
} 
EOF

#nginx的虚拟主机配置
cat > $nginx_basedir/conf/vhosts/default.conf<<'EOF'
server 
{ 
	listen 80 default_server; 
	server_name _; 
	index index.html index.htm index.php; 
	root html; 

    location ~ [^/]\.php(/|$) {
            try_files $uri =404;
     #      fastcgi_pass  unix:/tmp/php-cgi5.6.sock;
            fastcgi_pass  127.0.0.1:9000;
            fastcgi_index index.php;
            include fastcgi.conf;
        }

	location ~ .*\.(css|js)$ {
		expires 1h;
	}

	location ~ .*\.(gif|jpg|jpeg|png|ico)$ { 
		access_log off;
		expires 30d;
	} 
} 
EOF

kernel_version=`uname -r | awk -F. '{print $1}'`
if [ $kernel_version -eq 3 ];then
cat > /usr/lib/systemd/system/nginx.service << EOF
[Unit]
Description=The nginx HTTP and reverse proxy server
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/var/run/nginx.pid
# Nginx will fail to start if /run/nginx.pid already exists but has the wrong
# SELinux context. This might happen when running `nginx -t` from the cmdline.
# https://bugzilla.redhat.com/show_bug.cgi?id=1268621
ExecStartPre=/usr/bin/rm -f /var/run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t
ExecStart=/usr/sbin/nginx -c /usr/local/nginx/conf/nginx.conf 
ExecReload=/bin/kill -s HUP $MAINPID
KillSignal=SIGQUIT
TimeoutStopSec=5
KillMode=process
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

else 
# nginx的启动脚本
cat > /etc/init.d/nginx <<'EOF'
#!/bin/bash 
# chkconfig: - 85 15 
# processname: nginx 
# pidfile: /var/run/nginx.pid 
# config: /usr/local/nginx/conf/nginx.conf 
nginxd=/usr/local/nginx/sbin/nginx 
nginx_config=/usr/local/nginx/conf/nginx.conf 
nginx_pid=/var/run/nginx.pid 
RETVAL=0 
prog="nginx" 
# Source function library. 
. /etc/rc.d/init.d/functions 
# Source networking configuration. 
. /etc/sysconfig/network 
# Check that networking is up. 
[ ${NETWORKING} = "no" ] && exit 0 
[ -x $nginxd ] || exit 0 
# Start nginx daemons functions. 
start() { 

if [ -e $nginx_pid ];then 
echo "nginx already running...." 
exit 1 
fi 

echo -n $"Starting $prog: " 
daemon $nginxd -c ${nginx_config} 
RETVAL=$? 
echo 
[ $RETVAL = 0 ] && touch /var/lock/subsys/nginx 
return $RETVAL 
} 
# Stop nginx daemons functions. 
stop() { 
echo -n $"Stopping $prog: " 
killproc $nginxd 
RETVAL=$? 
echo 
[ $RETVAL = 0 ] && rm -f /var/lock/subsys/nginx /var/run/nginx.pid 
} 
# reload nginx service functions. 
reload() { 
echo -n $"Reloading $prog: " 
#kill -HUP `cat ${nginx_pid}` 
killproc $nginxd -HUP 
RETVAL=$? 
echo 
} 
# See how we were called. 
case "$1" in 
start) 
start 
;; 
stop) 
stop 
;; 
reload) 
reload 
;; 
restart) 
stop 
start 
;; 
status) 
status $prog 
RETVAL=$? 
;; 
*) 
echo $"Usage: $prog {start|stop|restart|reload|status|help}" 
exit 1 
esac 
exit $RETVAL 
EOF

chmod u+x /etc/init.d/nginx 
echo "running after package installed..." 
# 把nginx加入开机启动列表中
/sbin/chkconfig nginx --level 3 on 

fi

#给nginx命令做软链
ln -sv /usr/local/nginx/sbin/nginx /usr/sbin/

# nginx配置文件高亮配置
mkdir -pv /root/.vim/syntax/
cp contrib/vim/syntax/nginx.vim /root/.vim/syntax/
echo "au BufRead,BufNewFile /etc/nginx/*,/usr/local/nginx/conf/* if &ft == '' | setfiletype nginx | endif" > /root/.vim/filetype.vim

# nginx配置日志切割
cat > /etc/logrotate.d/nginx << EOF
/usr/local/nginx/logs/*log {
    create 0644 www www
    monthly
    rotate 5
    missingok
    notifempty
    compress
    sharedscripts
    postrotate
        /bin/kill -USR1 `cat /var/run/nginx.pid 2>/dev/null` 2>/dev/null || true
    endscript
}
EOF

# 启动nginx服务
if [ -f /var/run/nginx.pid ]; then 
/sbin/service nginx restart 
else 
/sbin/service nginx start 
fi 
echo "all done"

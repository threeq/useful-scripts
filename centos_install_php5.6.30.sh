#!/bin/bash

source_basedir="/usr/local/src"
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l) 
php_url="http://cn2.php.net/distributions/php-5.6.30.tar.gz"
RETVAL=0

#判断用户www是否存在，如果不存在，则创建该用户,此用户禁止登陆
id www > /dev/null 2>&1
RETVAL=$?
if [ $RETVAL -ne 0 ];then
    groupadd www
    useradd -s /sbin/nologin -M www
fi

#预安装php编译需要的组件
yum -y install wget make gcc gcc-c++ autoconf openssl-devel libxml2-devel libcurl-devel libjpeg-devel libpng-devel freetype-devel libmcrypt-devel
#yum -y install wget gcc gcc-c++ cmake autoconf automake zlib-devel openssl-devel pcre-devel ncurses-devel libpng-devel freetype-devel libxml2-devel glibc-devel glib2-devel bzip2-devel curl-devel libjpeg-devel e2fsprogs-devel libidn-devel libmcrypt-devel

#判断libmcrypt和libmcrypt-devel组件是否安装，如果没有则下载并安装
yum list libmcrypt libmcrypt-devel
RETVAL=$?
if [ $RETVAL -ne 0 ];then
	rpm -ivh 'http://dl.fedoraproject.org/pub/epel/6/x86_64/libmcrypt-2.5.8-9.el6.x86_64.rpm'
	rpm -ivh 'http://dl.fedoraproject.org/pub/epel/6/x86_64/libmcrypt-devel-2.5.8-9.el6.x86_64.rpm'
fi

#判断php的源码是否存在于/usr/local/src,如果不存在则下载
cd $source_basedir
if [ -s $(basename $php_url) ];then
	echo "$(basename $php_url) [found]"
else
	echo  "Error: $(basename $php_url) not found!!!download now......"
	wget -c $php_url
fi

#编译安装php
php_BN=$(basename $php_url)
php_FN=$(basename $php_url .tar.gz)
tar xf $php_BN
RETVAL=$?
if [ $RETVAL -ne 0 ];then
	echo "$(basename $php_url) upack error ABORT"
	exit
else
	cd $php_FN
	./configure --prefix=/usr/local/php \
	--with-config-file-path=/usr/local/php/etc \
	--with-mysql \
	--with-pdo-mysql \
	--with-mysqli \
	--with-iconv-dir \
	--with-freetype-dir \
	--with-jpeg-dir \
	--with-png-dir \
	--with-zlib \
	--with-libxml-dir \
	--disable-rpath \
	--enable-bcmath \
	--enable-shmop \
	--enable-sysvsem \
	--enable-opcache \
	--enable-inline-optimization \
	--with-curl \
	--enable-mbregex \
	--enable-fpm \
	--enable-mbstring \
	--with-mcrypt \
	--enable-ftp \
	--with-gd \
	--enable-gd-native-ttf \
	--with-openssl \
	--with-mhash \
	--enable-pcntl \
	--enable-sockets \
	--with-xmlrpc \
	--enable-zip \
	--enable-soap \
	--with-pear \
	--with-gettext
	make -j$CPU_NUM
	RETVAL=$?
	if [ $RETVAL -ne 0 ];then
	    make ZEND_EXTRA_LIBS='-liconv' -j$CPU_NUM
	else
	    make install
	fi
fi

#修改配置文件/usr/local/php/etc/php.ini
\cp php.ini-production /usr/local/php/etc/php.ini

sed -i 's/post_max_size =.*/post_max_size = 50M/g' /usr/local/php/etc/php.ini
sed -i 's/upload_max_filesize =.*/upload_max_filesize = 50M/g' /usr/local/php/etc/php.ini
sed -i 's/;date.timezone =.*/date.timezone = PRC/g' /usr/local/php/etc/php.ini
sed -i 's/short_open_tag =.*/short_open_tag = On/g' /usr/local/php/etc/php.ini
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
sed -i 's/max_execution_time =.*/max_execution_time = 300/g' /usr/local/php/etc/php.ini
sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,scandir,chgrp,chown,shell_exec,proc_open,proc_get_status,popen,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server/g' /usr/local/php/etc/php.ini
sed -i 's#;error_log = php_errors.log#error_log = php_errors.log#' /usr/local/php/etc/php.ini

#开启opcache加速器
sed -i 's#; Determines if Zend OPCache is enabled$#zend_extension = "/usr/local/php/lib/php/extensions/no-debug-non-zts-20131226/opcache.so"#' /usr/local/php/etc/php.ini
sed -i 's/;opcache.enable=0/opcache.enable=1/' /usr/local/php/etc/php.ini
sed -i 's/;opcache.enable_cli=0/opcache.enable_cli=1/' /usr/local/php/etc/php.ini
sed -i 's/;opcache.memory_consumption=64/opcache.memory_consumption=128/' /usr/local/php/etc/php.ini
sed -i 's/;opcache.interned_strings_buffer=4/opcache.interned_strings_buffer=8/' /usr/local/php/etc/php.ini
sed -i 's/;opcache.max_accelerated_files=2000/opcache.max_accelerated_files=4000/' /usr/local/php/etc/php.ini
sed -i 's/;opcache.revalidate_freq=2/opcache.revalidate_freq=60/' /usr/local/php/etc/php.ini
sed -i 's/;opcache.fast_shutdown=0/opcache.fast_shutdown=1/' /usr/local/php/etc/php.ini

cat > /usr/local/php/etc/php-fpm.conf << EOF
[global]
pid = run/php-fpm.pid
error_log = log/php-fpm.log
log_level = notice

[www]
listen = 127.0.0.1:9000
listen.backlog = 65535
listen.owner = www
listen.group = www
listen.mode = 0660
user = www
group = www
pm = dynamic
pm.max_children = 100
pm.start_servers = 20
pm.min_spare_servers = 10
pm.max_spare_servers = 30
request_terminate_timeout = 300
request_slowlog_timeout = 5
slowlog = var/log/slow.log
EOF

#创建软链接
ln -sf /usr/local/php/bin/php /usr/bin/php
ln -sf /usr/local/php/bin/phpize /usr/bin/phpize
ln -sf /usr/local/php/bin/pear /usr/bin/pear
ln -sf /usr/local/php/bin/pecl /usr/bin/pecl
ln -sf /usr/local/php/sbin/php-fpm /usr/sbin/php-fpm

#将php-fpm加入开机启动列表
install -v -m755 sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm 
/sbin/chkconfig --add php-fpm 
/sbin/chkconfig php-fpm --level 3 on

/etc/init.d/php-fpm start
echo "PHP install all done ....ok"

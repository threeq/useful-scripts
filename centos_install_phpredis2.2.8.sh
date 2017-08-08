#!/bin/bash

PHPREDIS_URL="https://pecl.php.net/get/redis-2.2.8.tgz"
PHP_HOME="/usr/local/php"
PHP_CONFIG="$PHP_HOME/etc/php.ini"
PHPREDIS=$(basename $PHPREDIS_URL)

cd /usr/local/src
if [ -s $PHPREDIS ];then
    echo "$PHPREDIS [found]"
else
    echo "Error: $PHPREDIS not found!!!download now......" 
    wget -c $PHPREDIS_URL
fi

tar xf $PHPREDIS
cd $(basename $PHPREDIS_URL .tgz)
$PHP_HOME/bin/phpize
./configure --with-php-config=$PHP_HOME/bin/php-config && make && make install

cat >> $PHP_CONFIG << EOF
extension = "/usr/local/php/lib/php/extensions/no-debug-non-zts-20131226/redis.so"
EOF


#!/bin/bash

### 手动启动
#  supervisord --pidfile /var/run/supervisord.pid -c /etc/supervisord.conf
###

SV_CONFIG = "/etc/supervisord.conf"
SV_CONF_DIR = "/etc/supervisord"

# 安装 supervisor
easy_install pip
pip install supervisor

# 配置 supervisor
echo_supervisord_conf > $SV_CONFIG
mkdir -p $SV_CONF_DIR

cat >> $SV_CONFIG << EOF
[include]
files = $SV_CONF_DIR/*.ini
EOF

# 设置系统服务
touch /etc/rc.d/init.d/supervisord

cat > /etc/rc.d/init.d/supervisord << EOF
#!/bin/sh
#
# /etc/rc.d/init.d/supervisord
#
# Supervisor is a client/server system that
# allows its users to monitor and control a
# number of processes on UNIX-like operating
# systems.
#
# chkconfig: - 64 36
# description: Supervisor Server
# processname: supervisord

# Source init functions
. /etc/rc.d/init.d/functions

prog="supervisord"

prefix="/usr/"
exec_prefix="${prefix}"
prog_bin="${exec_prefix}/bin/supervisord"
PIDFILE="/var/run/$prog.pid"

start()
{
       echo -n $"Starting $prog: "
       daemon $prog_bin --pidfile $PIDFILE -c $SV_CONFIG
       [ -f $PIDFILE ] && success $"$prog startup" || failure $"$prog startup"
       echo
}

stop()
{
       echo -n $"Shutting down $prog: "
       [ -f $PIDFILE ] && killproc $prog || success $"$prog shutdown"
       echo
}

case "$1" in

 start)
   start
 ;;

 stop)
   stop
 ;;

 status)
       status $prog
 ;;

 restart)
   stop
   start
 ;;

 *)
   echo "Usage: $0 {start|stop|restart|status}"
 ;;

esac
EOF

chmod +x /etc/rc.d/init.d/supervisord
chkconfig --add supervisord
chkconfig supervisord on
service supervisord start

#!/bin/bash

echo "I'm running ... "
sh /app/tomcat/bin/startup.sh

sh /app/mongodb-dubbokeeper-server/bin/start-mongodb.sh
echo "I'm stopped ... "

#j=0
#while true
#do
#    sleep 1
#    j=$(expr $j + 1)
#    echo "I'm running ... (${j}) s"
#done
#!/bin/bash


cd /mnt/mqm-data
tar xvfz setup.tar.gz


chmod +x *.sh
chmod +x blast
echo "alter qmgr CHLAUTH(DISABLED)" | runmqsc mq02ha > /dev/null 2>&1
echo "define chl(MQ.QS.SVRCONN) type(SVRCONN)" | runmqsc mq02ha > /dev/null 2>&1
echo "refresh security type (CONNAUTH)" | runmqsc mq02ha > /dev/null 2>&1



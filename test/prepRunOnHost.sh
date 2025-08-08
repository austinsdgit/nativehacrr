#!/bin/bash


cd /mnt/mqm-data
tar xvfz setup.tar.gz
#mv fullTestEnhanced2.sh fullTestEnhanced.sh
#mv ccdt_generated2.json ccdt_generated.json
chmod +x *.sh
echo "alter qmgr CHLAUTH(DISABLED)" | runmqsc mq02ha > /dev/null 2>&1
echo "refresh security type (CONNAUTH)" | runmqsc mq02ha > /dev/null 2>&1



#!/bin/bash

kubectl cp setup.tar.gz occmq2-mq02ha-ibm-mq-2:/mnt/mqm-data/setup.tar.gz
kubectl cp prepRunOnHost.sh occmq2-mq02ha-ibm-mq-2:/mnt/mqm-data/prepRunOnHost.sh

kubectl exec -it occmq2-mq02ha-ibm-mq-2 -- chmod +x /mnt/mqm-data/prepRunOnHost.sh
kubectl exec -it occmq2-mq02ha-ibm-mq-2 -- /mnt/mqm-data/prepRunOnHost.sh


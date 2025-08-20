#!/bin/bash
#occmq2-mq02ha-ibm-mq-2
targetPod=$1
kubectl cp setup.tar.gz $targetPod:/mnt/mqm-data/setup.tar.gz
kubectl cp prepRunOnHost.sh $targetPod:/mnt/mqm-data/prepRunOnHost.sh

kubectl exec -it $targetPod -- chmod +x /mnt/mqm-data/prepRunOnHost.sh
kubectl exec -it $targetPod -- /mnt/mqm-data/prepRunOnHost.sh


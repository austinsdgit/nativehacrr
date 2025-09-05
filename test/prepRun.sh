#!/bin/bash

source ../setup.properties

echo "Logging into Cluster 1 to get recovery HOST Name"
oc login $OCP_CLUSTER1 -u $OCP_CLUSTER_USER1 -p $OCP_CLUSTER_PASSWORD1 > /dev/null 2>&1



targetPod=$(kubectl get pods | awk '$2 == "1/1" {print $1}')
tar cvfz setup.tar.gz ccdt_generated.json loopFull.sh fullTestEnhanced.sh sendPersistentMessage.sh sendMultiPersistentMessages.sh blast
kubectl cp setup.tar.gz $targetPod:/mnt/mqm-data/setup.tar.gz
kubectl cp prepRunOnHost.sh $targetPod:/mnt/mqm-data/prepRunOnHost.sh

kubectl exec -it $targetPod -- chmod +x /mnt/mqm-data/prepRunOnHost.sh
kubectl exec -it $targetPod -- /mnt/mqm-data/prepRunOnHost.sh


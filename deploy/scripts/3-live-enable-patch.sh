#! /bin/bash
#
# This script will get the host name for the Recovery cluster and will patch the live Cluster 
# to connect to the Recovery cluster.
#
source ../../setup.properties
export QMInstance=$1

# Logon to the Recovery cluster to get the HOST name 
#oc login https://api.67c20883d1ee7bb0b5beada0.am1.techzone.ibm.com:6443 -u student8 -p welcometoFSMpot
echo "Logging into Cluster 2 to get recovery HOST Name"
#oc login $OCP_CLUSTER2 -u $OCP_CLUSTER_USER2 -p $OCP_CLUSTER_PASSWORD2 > /dev/null 2>&1
#oc login --token=sha256~ljv7dRx1Aw2xU_IEJhukjskje9cGpDDxYnGvr3GTWvM --server=https://api.itz-znevd1.osv.techzone.ibm.com:6443 > /dev/null 2>&1
oc login --token=sha256~yQ_s5cIz9-Eum7yxGQp9oDa4mpB9e87ZqHX4GlltvVo --server=https://api.itz-rdwaa0.infra01-lb.dal14.techzone.ibm.com:6443 > /dev/null 2>&1


export HOST=$(oc get route $QMInstance-ibm-mq-nhacrr -o jsonpath='{.spec.host}')

( echo "cat <<EOF" ; cat 3-live-enable-crr-template.yaml ; echo EOF ) | sh > 3-live-enable-crr.yaml

#oc login $OCP_CLUSTER1 -u $OCP_CLUSTER_USER1 -p $OCP_CLUSTER_PASSWORD1
#oc login --token=sha256~ZsxPzwRBuWqe07Di6ee2JP2wCJEdLLiqYZvQqYoQe-Y --server=https://api.itz-g9fw33.infra01-lb.fra02.techzone.ibm.com:6443
oc login --token=sha256~5MZVih7BfTZdlMI7qS7mYBtbZDPAe-SF_CVuY7ByB8s --server=https://api.itz-c7lcfw.infra01-lb.dal14.techzone.ibm.com:6443 > /dev/null 2>&1

oc patch QueueManager $QMInstance --type merge --patch "$(cat 3-live-enable-crr.yaml)"

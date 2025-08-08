#! /bin/bash
##
# This template will get the host for Live cluster to enable the nativeha CRR deploy script
#
source ../../setup.properties

export HA_DIR_DEPLOY="nativeha-crr/deploy"
export TARGET_NAMESPACE=occmq2
export QMInstance=occmq2-mq02ha
export QMpre=mq02
export QMname=mq02ha

# Logon to the active cluster
#oc login https://api.67c20883d1ee7bb0b5beada0.am1.techzone.ibm.com:6443 -u student8 -p welcometoFSMpot

echo "Logging into Cluster 2 to get recovery route to patch live QMgr"
oc login https://api.itz-rdwaa0.infra01-lb.dal14.techzone.ibm.com:6443 -u kubeadmin -p gtpom-ZjSJq-7IJLS-M2E9x
oc project occmq2

( echo "cat <<EOF" ; cat 3-live-enable-crr-template.yaml ; echo EOF ) | sh > 3-live-enable-crr.yaml

./scripts/3-live-enable-patch.sh occmq2-mq02ha

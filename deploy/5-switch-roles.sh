#! /bin/bash
#
# provide needed variables to pass to the switch patch script to switch roles
#
source ../setup.properties


export HA_DIR_DEPLOY="nativehacrr/deploy"
export TARGET_NAMESPACE=occmq2
export QMInstance=occmq2-mq02ha
export QMpre=mq02
export QMname=mq02ha

# Logon to the active cluster
#oc login https://api.67c20883d1ee7bb0b5beada0.am1.techzone.ibm.com:6443 -u student8 -p welcometoFSMpot
oc login https://api.itz-c7lcfw.infra01-lb.dal14.techzone.ibm.com:6443 -u kubeadmin -p GmWaQ-hTPsQ-SoGmY-ks8dw
oc project occmq2

( echo "cat <<EOF" ; cat 5-switch-roles-template.yaml ; echo EOF ) | sh > 5-switch-roles.yaml

./scripts/5-switch-patch.sh occmq2-mq02ha occmq2

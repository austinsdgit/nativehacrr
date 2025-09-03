#!/bin/bash

read -p "Enter the live cluster URL: " LIVE_URL

read -p "Enter the live cluster password: " LIVE_PASSWORD

read -p "Enter the recovery cluster URL: " RECOVERY_URL

read -p "Enter the recovery cluster password: " RECOVERY_PASSWORD

read -p "Enter the namespace: " TARGET_NAMESPACE

export TARGET_NAMESPACE=$TARGET_NAMESPACE
export LIVE_URL=$LIVE_URL
export LIVE_PASSWORD=$LIVE_PASSWORD
export RECOVERY_URL=$RECOVERY_URL
export RECOVERY_PASSWORD=$RECOVERY_PASSWORD

echo "[INFO] Update ${bold}setup.properties${normal} with your target namespace"
( echo 'cat <<EOF' ; cat setup.properties_template ; echo EOF ) | sh > setup.properties
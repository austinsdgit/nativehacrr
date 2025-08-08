#!/bin/bash

THREADS=$1
NUMQUEUES=$2
NUMPERFITER=$3
NUMMSGS=$4
executions=$5

for ((i=1; i<=executions; i++)); do
    /mnt/mqm-data/fullTestEnhanced.sh $THREADS $NUMQUEUES $NUMPERFITER $NUMMSGS
        
done
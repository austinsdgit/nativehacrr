#!/bin/bash

# Set the MQ environment variables (adjust these values)
export MQ_SERVER="occmq-mq02ha-ibm-mq.occmq.svc.cluster.local"
export MQ_PORT="1414"
export MQ_CHANNEL="MQ.QS.SVRCONN"
export MQ_QUEUE="GREG.TEST"
export MQ_QMGR="mq02ha"
export MQCHLLIB="/mnt/mqm-data"
export MQCHLTAB="ccdt_generated.json"
#export MQ_USER="YOUR_MQ_USER"
#export MQ_PASS="YOUR_MQ_PASS"

# Number of parallel threads
THREADS=$1
NUMQUEUES=$2
NUM_MESSAGES=$3


# Function to read messages from the MQ queue (simulating a worker thread)
function write_messages() {
    local thread_id=$1
    local num_messages=$2
    
    local queueIdentifier=$((thread_id % $NUMQUEUES))
    echo "thread == $thread_id and num_messages == $num_messages"

    for ((i=1; i<=num_messages; i++)); do
        echo "about to put messages i == $i"
        echo "MQCHLTAB == $MQCHLLIB/$MQCHLTAB"
        echo "putting message to $MQ_QUEUE$queueIdentifier"
        /opt/mqm/samp/bin/amqsblstc "$MQ_QMGR" "$MQ_QUEUE$queueIdentifier" -W -c 1000
    done
    
}

# Function to start multiple threads and calculate the aggregate TPS
function start_threads() {
    local total_tps=0
    local total_threads=$1
    local num_messages=$2
    # Start the threads
    for ((i=1; i<=total_threads; i++)); do
        write_messages $i $num_messages &
        
    done
    wait
    
}

# Main script execution
start_threads $THREADS $NUM_MESSAGES

echo "Writes completed."

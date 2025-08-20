#!/bin/bash


# Set the MQ environment variables (adjust these values)
export MQ_SERVER="occmq-mq02ha-ibm-mq.occmq.svc.cluster.local"
export MQ_PORT="1414"
export MQ_CHANNEL="MQ.QS.SVRCONN"
export MQ_QUEUE="DEV.QUEUE."
export MQ_QMGR="mq02ha"
export MQCHLLIB="/mnt/mqm-data"
export MQCHLTAB="ccdt_generated.json"


THREADS=$1
NUMQUEUES=$2
AGGR_FILE="/mnt/mqm-data/historical_runs.csv"
NUMPERFITER=$3
NUMMSGS=$4
PER_QUEUE_NUM_MSGS=0
TOT_MSGS=0

# Function to read messages from the MQ queue (simulating a worker thread)
function write_messages() {
    local thread_id=$1
    local num_messages=$2
    
    #local queueIdentifier=$thread_id
    local queueIdentifier=$((thread_id % $NUMQUEUES))
    echo "thread == $thread_id and num_messages == $num_messages"

    #for ((i=1; i<=num_messages; i++)); do
        #echo "about to put messages i == $i"
        #echo "MQCHLTAB == $MQCHLLIB/$MQCHLTAB"
        echo "putting message to $MQ_QUEUE$queueIdentifier"
        #/opt/mqm/samp/bin/amqsblstc "$MQ_QMGR" "$MQ_QUEUE$queueIdentifier" -W -c 1000
        /mnt/mqm-data/blast -m "$MQ_QMGR" -q "$MQ_QUEUE$queueIdentifier" -W -n $num_messages -p
    #done
    #/mnt/mqm-data/blast -m "$MQ_QMGR" -q "$MQ_QUEUE$queueIdentifier" -W -n $num_messages -p
    
}

# Function to calculate the per queue msgs count

function calc_per_queue_msgs() {

    PER_QUEUE_NUM_MSGS=$(echo "dis q(DEV.QUEUE.1) curdepth" | runmqsc mq02ha | grep -i "curdepth(" | awk -F'[()]' '{print $2}')
}

# Function to start multiple threads and calculate the aggregate TPS
function start_write_threads() {
    local total_tps=0
    local total_threads=$1
    local num_messages=$2
    # Start the threads
    for ((i=0; i<=total_threads; i++)); do
        write_messages $i $num_messages &
        
    done
    wait

    calc_per_queue_msgs
    TOT_MSGS=$((PER_QUEUE_NUM_MSGS*NUM_QUEUES))
    
}

function start_perfck() {
    if [[ $2 -eq "0" ]]; then
        return 0
    fi
    local total_queues=$1-1
    local queueParams=""
    for ((i=0; i<=total_queues; i++)); do
        
        queueParams="$queueParams -q DEV.QUEUE.$i"
    done

    /opt/mqm/bin/mqperfck -m $MQ_QMGR$queueParams -d "/mnt/mqm-data/" -n $2 &
}

# Function to read messages from the MQ queue (simulating a worker thread)
function read_messages() {
    local thread_id=$1
    local count=0
    local start_time=$(date +%s%3N)
    local numMessages=$2

    #echo "Thread $thread_id: Started reading messages..."

    # Simulate reading messages
    #local loopCondition="true"
    #local transTime=$(date +%s%3N)
    #local queueIdentifier=1
    #if [ $thread_id -ge $NUMQUEUES ]; then
    local queueIdentifier=$((thread_id % $NUMQUEUES))
    #local queueIdentifier=$thread_id
    #fi
    
    #count=$(/opt/mqm/samp/bin/amqsblstc "$MQ_QMGR" "$MQ_QUEUE$queueIdentifier" -R -r 1000  | grep -i "messages have been got" | awk '{print $2}')
    #count=$(/mnt/mqm-data/blast -m "$MQ_QMGR" -q "$MQ_QUEUE$queueIdentifier" -R -w 1 | grep -i "messages successfully read." | awk '{print $2}')
    #duration=$(/mnt/mqm-data/blast -m "$MQ_QMGR" -q "$MQ_QUEUE$queueIdentifier" -R -n $numMessages -w 1 | grep -i "Elapsed" | awk '{print $5}')
    /mnt/mqm-data/blast -m "$MQ_QMGR" -q "$MQ_QUEUE$queueIdentifier" -R -n $numMessages -w 1 > /tmp/thread$thread_id.txt
    duration=$(grep -i "Elapsed" /tmp/thread$thread_id.txt | awk '{print $5}')
    #echo "grep \"message\" /tmp/thread$thread_id.txt | awk '{print $2}')"
    numCount=$(grep "message" /tmp/thread$thread_id.txt | awk '{print $2}')
    #count=$(/opt/mqm/samp/bin/amqsblstc "$MQ_QMGR" "$MQ_QUEUE$queueIdentifier" -R -r 1000  | grep -i "messages" | wc -l)
    #count=$((count*100))
    

    #local end_time=$(date +%s%3N)
    #echo "end_time == $end_time and transTime == $transTime and start_time == $start_time"
    #local duration=$(((end_time - start_time) - (end_time - transTime)))
    #local duration=$(($end_time - $start_time -1))
    #local duration=$(($elapsedTime -1))
    #echo "duration == $duration"

    # Calculate transactions per second (TPS)
    #duration=$(echo "scale=2; $duration - 1" | bc)
    #intDur=$(printf "%.0f" "$duration")
    intDur=$(echo "scale=4; $duration" | bc -l) 
    #echo "intDur == $intDur"
    #if [ $intDur -gt 0 ]; then
        #echo "duration is greater than 0 and count == $count"
        #local tps=$(echo "scale=2; $numMessages / ($duration / 1000)" | bc)
        local tps=$(echo "scale=2; $numCount / $duration" | bc)
        #local tps=$(echo "scale=2; $count / ($duration / 1000)" | bc)
        echo "$tps"
        #echo "Thread $thread_id: Read $count messages in $duration milliseconds"
        #echo "Thread $thread_id: Transactions per second (TPS): $tps"
    #else
     #   echo "Thread $thread_id: Error: Duration is 0 milliseconds. Check queue and connection."
    #fi
    
}

function getQueueDepth() {

    #local testQueue=$((NUMQUEUES+1))
    PER_QUEUE_NUM_MSGS=$(echo "dis q(DEV.QUEUE.1) curdepth" | runmqsc mq02ha | grep -i "curdepth(" | awk -F'[()]' '{print $2}')
    echo "per_queue_num_msgs = $PER_QUEUE_NUM_MSGS"
}

# Function to start multiple threads and calculate the aggregate TPS
function start_read_threads() {
    local total_tps=0
    local total_threads=$1
    local thread_tps=()

    getQueueDepth
    echo "queueDepth==$PER_QUEUE_NUM_MSGS"

    # Start the threads
    for ((i=0; i<=total_threads; i++)); do
        echo "thread_id == $i"
        #count=$(read_messages $i &)
        #echo "total count from thread == $count"
        read_messages $i $PER_QUEUE_NUM_MSGS > /tmp/tmpFile$i.txt &
        #read_messages $i > /tmp/tmpFile$i.txt &
        #thread_tps[$i]=$(read_messages $i) &
        #echo "$count" > tmpFile$i.txt
        
        
        
    done
    wait
    for ((i=0; i<=total_threads; i++)); do
        thread_tps[$i]=$(cat /tmp/tmpFile$i.txt)
        #rm -f /tmp/tmpFile$i.txt
        echo "thread_tps[$i] == ${thread_tps[$i]}"
    done

    # Calculate the total aggregate TPS
    for tps in "${thread_tps[@]}"; do
        echo "tps == $tps"
        total_tps=$(echo "$total_tps + $tps" | bc)
    done

    # Aggregate TPS across all threads
    echo "Total Aggregate Transactions per Second (TPS) from $total_threads threads: $total_tps"
    CURRENT_DATE=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "\n$total_threads,$NUMQUEUES,$total_tps,$PER_QUEUE_NUM_MSGS,$TOT_MSGS,$CURRENT_DATE" >> "$AGGR_FILE"
}

function create_queues() {

    QMGR="$1"
    BASE_QUEUE_NAME="$2"
    NUM_QUEUES="$3"

    # Validate input
    if [[ -z "$QMGR" || -z "$BASE_QUEUE_NAME" || -z "$NUM_QUEUES" ]]; then
    echo "Usage: $0 <queue_manager_name> <base_queue_name> <number_of_queues>"
    exit 1
    fi

    # Check that NUM_QUEUES is a positive integer
    if ! [[ "$NUM_QUEUES" =~ ^[0-9]+$ ]] || [[ "$NUM_QUEUES" -lt 1 ]]; then
    echo "Error: <number_of_queues> must be a positive integer"
    exit 1
    fi

    for (( i=0; i<=NUM_QUEUES; i++ ))
    do
    QUEUE_NAME="${BASE_QUEUE_NAME}.${i}"
    echo "Checking if queue '$QUEUE_NAME' exists on '$QMGR'..."

    EXISTS=$(echo "DISPLAY QLOCAL('$QUEUE_NAME')" | runmqsc "$QMGR" | grep -i "QUEUE($QUEUE_NAME)")

    if [[ -n "$EXISTS" ]]; then
        echo "Queue '$QUEUE_NAME' already exists. Skipping..."
        continue
    fi

    echo "Creating queue '$QUEUE_NAME'..."

    runmqsc "$QMGR" <<EOF
DEFINE QLOCAL('$QUEUE_NAME') +
    DEFPSIST(YES) +
    DEFREADA(DISABLED) +
    MAXDEPTH(5000000)
EOF

    echo "Queue '$QUEUE_NAME' created successfully."
    done

    echo "All queue creation steps completed."

}


function delete_queues() {

    for q_name in $(echo "DISPLAY QLOCAL(DEV.QUEUE*) ALL" | runmqsc $MQ_QMGR | grep -o -P "(?<=QUEUE)\\(.+?\\)" | sed -e 's/[(|)]//g'); do
        echo "DELETE QLOCAL(${q_name}) PURGE" | runmqsc $MQ_QMGR > /dev/null 2>&1
    done
}


 



# create the queues
create_queues $MQ_QMGR "DEV.QUEUE" $NUMQUEUES

# load the queues
start_write_threads $THREADS $NUMMSGS
echo "writes completed"
# read the queues

start_perfck $NUMQUEUES $NUMPERFITER

# Main script execution
echo "Starting MQ Transaction Per Second Test with $THREADS Threads..."

start_read_threads $THREADS


# delete the queues

delete_queues
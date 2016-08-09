#!/bin/bash

if [ `date +%Z` != "UTC" ]; then
    echo "Invalid timezone set on this server, it must be UTC."
    exit -1
fi


if [[ -z "$KAFKA_ADVERTISED_HOST_NAME" ]]; then
    export KAFKA_ADVERTISED_HOST_NAME=$HOSTNAME
fi
if [[ -z "$KAFKA_ADVERTISED_PORT" ]]; then
    export KAFKA_ADVERTISED_PORT=9092
fi
if [[ -z "$KAFKA_PORT" ]]; then
    export KAFKA_PORT=9092
fi
if [[ -z "$KAFKA_BROKER_ID" ]]; then
    # By default auto allocate broker ID
    export KAFKA_BROKER_ID=-1
fi
if [[ -z "$KAFKA_LOG_DIRS" ]]; then
    export KAFKA_LOG_DIRS="/kafka/logs"
fi
if [[ -z "$KAFKA_ZOOKEEPER_CONNECT" ]]; then
    export KAFKA_ZOOKEEPER_CONNECT=$(env | grep PORT_2181_TCP= | sed -e 's|.*tcp://||' | paste -sd ,)
fi

if [[ -n "$KAFKA_HEAP_OPTS" ]]; then
    sed -r -i "s/(export KAFKA_HEAP_OPTS)=\"(.*)\"/\1=\"$KAFKA_HEAP_OPTS\"/g" $KAFKA_HOME/bin/kafka-server-start.sh
    unset KAFKA_HEAP_OPTS
fi

for VAR in `env`
do
  if [[ $VAR =~ ^KAFKA_ && ! $VAR =~ ^KAFKA_HOME && ! $VAR =~ ^KAFKA_VERSION ]]; then
    kafka_name=`echo "$VAR" | sed -r "s/KAFKA_(.*)=.*/\1/g" | tr '[:upper:]' '[:lower:]' | tr _ .`
    env_var=`echo "$VAR" | sed -r "s/(.*)=.*/\1/g"`
    if egrep -q "(^|^#)$kafka_name=" $KAFKA_HOME/config/server.properties; then
        sed -r -i "s@(^|^#)($kafka_name)=(.*)@\2=${!env_var}@g" $KAFKA_HOME/config/server.properties #note that no config values may contain an '@' char
    else
        echo "$kafka_name=${!env_var}" >> $KAFKA_HOME/config/server.properties
    fi
  fi
done

# Capture kill requests to stop properly
trap "$KAFKA_HOME/bin/kafka-server-stop.sh; echo 'Kafka stopped.'; exit" SIGHUP SIGINT SIGTERM

# Delay start
sleep 3

$KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties

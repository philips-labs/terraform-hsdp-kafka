#!/bin/bash

usage() {
    cat <<-EOF
usage: bootstrap-cluster.sh
      -n node1,node2,...
      -c cluster
      -i index
      -d docker
      -z zookeeper_connect
EOF
}

kill_kafka() {
  docker kill kafka
  docker rm kafka
}

kafka_servers() {
  local index=$1
  local nodes=$2
  local servers=""

  IFS=','
  read -ra SERVERS <<< "$nodes"
  count=1

  for i in "${SERVERS[@]}";do
    current=$i:6066:7077
    if ((index == count)); then
      current=0.0.0.0:2888:3888
    fi
    if [ "$servers" == "" ]; then
      servers=$current
    else
      servers=$servers,$current
    fi
    ((count+=1))
  done

  echo "$servers"
}

start_kafka() {
  local index="$1"
  local nodes="$2"
  local zookeeper_connect="$4"

  servers="$(kafka_servers "$index" "$nodes")"
  echo KAFKA_SERVERS="$servers"
  docker run -d -v kafka:/bitnami/kafka \
    --restart always \
    --name kafka \
    --env ALLOW_PLAINTEXT_LISTENER=yes \
    --env KAFKA_CFG_ZOOKEEPER_CONNECT="$zookeeper_connect" \
    --env KAFKA_SERVERS="$servers"  \
    -p 9200:9092 \
    -p 6066:2888 \
    -p 7077:3888 \
    "$3"
}

##### Main

nodes=
cluster=
image=
index=
zookeeper_connect=

while [ "$1" != "" ]; do
    case $1 in
        -z | --zookeeper )      shift
                                zookeeper_connect=$1
                                ;;
        -n | --nodes )          shift
                                nodes=$1
                                ;;
        -c | --cluster )        shift
                                cluster=$1
                                ;;
        -d | --docker )         shift
                                image=$1
                                ;;
        -i | --index )          shift
                                index=$1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

echo Bootstrapping node "$index" in cluster "$cluster" with image "$image"

kill_kafka
start_kafka "$index" "$nodes" "$image" "$zookeeper_connect"


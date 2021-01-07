#!/bin/bash

usage() {
    cat <<-EOF
usage: bootstrap-cluster.sh
      -n node1,node2,...
      -c cluster
      -i index
      -d docker
      -z zookeeper_connect
      -x external_ip
      -r retention_hours
      -p kafka_certificate_password
      -t zookeeper_trust_store_password
      -k zookeeper_key_store_password
      -R default_replication_factor
      -a auto_create_topics_enable
EOF
}

kill_kafka() {
  echo Killing kafka...
  docker kill $kafka_broker_name
  docker rm $kafka_broker_name
}

kill_monitoring() {
  echo Killing monitoring tools...
  docker kill jmx_exporter 2&>1
  docker rm -f jmx_exporter 2&>1
  docker kill kafka_prometheus_exporter 2&>1
  docker rm -f kafka_prometheus_exporter 2&>1
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

create_network() {
  docker network rm $kafka_network 2&>1
  docker network create $kafka_network
}

create_volume() {
  docker volume rm kafkacert
  docker volume create kafkacert
}

start_kafka() {
  local index="$1"
  local nodes="$2"
  local image="$3"
  local zookeeper_connect="$4"
  local external_ip="$5"
  local retention_hours="$6"
  local cert_pass="$7"
  local zoo_key_pass="$8"
  local zoo_trust_pass="$9"
  local default_replication_factor="${10}"
  local auto_create_topics_enable="${11}"

  servers="$(kafka_servers "$index" "$nodes")"
  echo KAFKA_SERVERS="$servers"
  echo RETENTION_HOURS=$retention_hours
  docker run -d -v $kafka_broker_name:/bitnami/kafka \
    --restart always \
    --name $kafka_broker_name \
    --env KAFKA_CFG_ZOOKEEPER_CONNECT="$zookeeper_connect" \
    --env KAFKA_CFG_LISTENERS="CLIENT://:9092,EXTERNAL://:8282" \
    --env KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP="CLIENT:SSL,EXTERNAL:SSL" \
    --env KAFKA_CFG_ADVERTISED_LISTENERS="CLIENT://$kafka_broker_name:9092,EXTERNAL://$external_ip:8282" \
    --env KAFKA_CFG_INTER_BROKER_LISTENER_NAME=EXTERNAL \
    --env KAFKA_CFG_LOG_RETENTION_HOURS=$retention_hours \
    --env KAFKA_SERVERS="$servers"  \
    --env KAFKA_ZOOKEEPER_PROTOCOL="SSL" \
    --env KAFKA_ZOOKEEPER_TLS_VERIFY_HOSTNAME="no" \
    --env KAFKA_CERTIFICATE_PASSWORD="$cert_pass" \
    --env KAFKA_CFG_SSL_ENDPOINT_IDENTIFICATION_ALGORITHM=" " \
    --env KAFKA_ZOOKEEPER_TLS_KEYSTORE_PASSWORD="$zoo_key_pass" \
    --env KAFKA_ZOOKEEPER_TLS_TRUSTSTORE_PASSWORD="$zoo_trust_pass" \
    --env KAFKA_OPTS="" \
    --env JMX_PORT=5555 \
    --env KAFKA_CFG_DEFAULT_REPLICATION_FACTOR=$default_replication_factor \
    --env KAFKA_CFG_AUTO_CREATE_TOPICS_ENABLE=$auto_create_topics_enable \
    --network $kafka_network \
    -v 'kafkacert:/bitnami/kafka/config/certs/' \
    -p 8282:8282 \
    -p 6066:2888 \
    -p 7077:3888 \
    "$image"
}

load_certificates_and_restart(){
  docker cp ./kafka.truststore.jks $kafka_broker_name:/bitnami/kafka/config/certs/
  docker cp ./kafka.keystore.jks $kafka_broker_name:/bitnami/kafka/config/certs/
  docker cp ./zookeeper.truststore.jks $kafka_broker_name:/bitnami/kafka/config/certs/
  docker cp ./zookeeper.keystore.jks $kafka_broker_name:/bitnami/kafka/config/certs/
  docker exec $kafka_broker_name ls -laR /bitnami/kafka/config/certs
  docker restart $kafka_broker_name -t 10
}

start_jmx_exporter(){
  # create dir to contain jmx config file
  mkdir -p jmx

  # remove any left-over volume(s)
  docker rm -fv jmx_exporter 2&>1
  docker volume rm jmx_config_volume

  # Substitute container name in jmx config and move it
  export container_name=$kafka_broker_name
  envsubst < jmxconfig.yml.tmpl > ./jmx/config.yml
  
  # create jmx volume mapping the jmx config file
  docker volume create --driver local --name jmx_config_volume --opt type=none --opt device=`pwd`/jmx --opt o=uid=root,gid=root --opt o=bind

  # start jmx exporter
  docker run -d -p 10001:5556 \
  --name jmx_exporter \
  --network $kafka_network \
  -v jmx_config_volume:/opt/bitnami/jmx-exporter/example_configs \
  bitnami/jmx-exporter:latest 5556 example_configs/config.yml
}

start_kafka_prometheus_exporter(){

  # store these files somewhere
  mkdir -p pem

  # move cert files
  mv ./ca.pem ./public.pem ./private.pem ./pem

  docker rm -fv kafka_prometheus_exporter
  docker volume rm kafka_prometheus_volume
  docker volume create --driver local --name kafka_prometheus_volume --opt type=none --opt device=`pwd`/pem --opt o=uid=root,gid=root --opt o=bind

  #---- Run kafka prometheus exporter (https://github.com/danielqsj/kafka_exporter)
  docker run -d -p 10000:9308 \
  --name kafka_prometheus_exporter \
  --network $kafka_network \
  -v kafka_prometheus_volume:/etc/certs \
  danielqsj/kafka-exporter \
  --kafka.server=$external_ip:8282 \
  --web.telemetry-path=/metrics \
  --tls.enabled \
  --tls.ca-file=/etc/certs/ca.pem \
  --tls.cert-file=/etc/certs/public.pem \
  --tls.key-file=/etc/certs/private.pem \
  --tls.insecure-skip-tls-verify
}

##### Main

nodes=
cluster=
image=
index=
zookeeper_connect=
external_ip=
retention_hours=
kafka_cert_pass=
zoo_key_store_pass=
zoo_trust_store_pass=
default_replication_factor=
auto_create_topics_enable=

while [ "$1" != "" ]; do
    case $1 in
        -z | --zookeeper )      shift
                                zookeeper_connect=$1
                                ;;
        -x | --externalip )     shift
                                external_ip=$1
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
        -r | --retention )      shift
                                retention_hours=$1
                                ;;
        -R | --replication )    shift
                                default_replication_factor=$1
                                ;;
        -p | --cert-pass )      shift
                                kafka_cert_pass=$1
                                ;;
        -k | --zoo-key-pass )   shift
                                zoo_key_store_pass=$1
                                ;;
        -t | --zoo-trust-pass ) shift
                                zoo_trust_store_pass=$1
                                ;;
        -a | --auto-create-topics ) shift
                                auto_create_topics_enable=$1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

echo Bootstrapping node "$external_ip" "$index" in cluster "$cluster" with image "$image", retention "$retention_hours"
kafka_broker_name="kafka-${index}"
kafka_network="kafka-${index}-network"

kill_monitoring
kill_kafka
create_volume
create_network
start_kafka "$index" "$nodes" "$image" "$zookeeper_connect" "$external_ip" "$retention_hours" "$kafka_cert_pass" "$zoo_key_store_pass" "$zoo_trust_store_pass" "$default_replication_factor" "$auto_create_topics_enable"
load_certificates_and_restart
start_jmx_exporter
start_kafka_prometheus_exporter
sleep 30 # wait for 5 seconds to print out docker status
docker ps -a
docker start kafka_prometheus_exporter
sleep 15
docker ps -a
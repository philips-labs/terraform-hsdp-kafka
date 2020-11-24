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
      -v jmx_exporter_version
EOF
}

kill_kafka() {
  echo Killing kafka...
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

  servers="$(kafka_servers "$index" "$nodes")"
  echo KAFKA_SERVERS="$servers"
  echo RETENTION_HOURS=$retention_hours
  docker run -d -v kafka:/bitnami/kafka \
    --restart always \
    --name kafka \
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
    --env KAFKA_OPTS='-javaagent:/bitnami/prometheus/jmx_export_agent.jar=10001:/bitnami/prometheus/config.yml' \
    --env JMXPORT=5555 \
    -v $(pwd):/bitnami/prometheus \
    -v 'kafkacert:/bitnami/kafka/config/certs/' \
    -p 8282:8282 \
    -p 6066:2888 \
    -p 7077:3888 \
    "$image"
}

load_certificates_and_restart(){
  docker cp ./kafka.truststore.jks kafka:/bitnami/kafka/config/certs/
  docker cp ./kafka.keystore.jks kafka:/bitnami/kafka/config/certs/
  docker cp ./zookeeper.truststore.jks kafka:/bitnami/kafka/config/certs/
  docker cp ./zookeeper.keystore.jks kafka:/bitnami/kafka/config/certs/
  docker exec kafka ls -laR /bitnami/kafka/config/certs
  docker restart kafka -t 10
}

download_jmx_agent(){
  local version="$1"
  echo "Download JMX Prometheus JavaAgent ${version}"
  curl -s -o jmx_export_agent.jar "https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/${version}/jmx_prometheus_javaagent-${version}.jar"
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
        -p | --cert-pass )      shift
                                kafka_cert_pass=$1
                                ;;
        -k | --zoo-key-pass )   shift
                                zoo_key_store_pass=$1
                                ;;
        -t | --zoo-trust-pass ) shift
                                zoo_trust_store_pass=$1
                                ;;
        -v | --jmx-exporter-version ) shift
                                jmx_exporter_version=$1
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

kill_kafka
create_volume
download_jmx_agent "$jmx_exporter_version"
start_kafka "$index" "$nodes" "$image" "$zookeeper_connect" "$external_ip" "$retention_hours" "$kafka_cert_pass" "$zoo_key_store_pass" "$zoo_trust_store_pass"
load_certificates_and_restart

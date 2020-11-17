docker rm -fv cadvisor_exporter
docker rm -fv node_exporter

docker run -d --name=cadvisor_exporter --device=/dev/kmsg -p 9102:8080 \
-v /:/rootfs:ro -v /var/run:/var/run:ro -v /sys:/sys:ro \
-v /var/lib/docker/:/var/lib/docker:ro -v /dev/disk/:/dev/disk:ro \
gcr.io/cadvisor/cadvisor:v0.38.1

docker run -d --name node_exporter -p 9101:9100 bitnami/node-exporter:latest

docker run -d --name merge_exporter \
-e MERGER_PORT=8888 \
-e MERGER_URLS="http://`hostname`:9101/metrics http://`hostname`:9102/metrics http://`hostname`:9103" \
-p 10001:8888 apentsak/exporter-merger

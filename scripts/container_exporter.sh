docker rm -fv cadvisor_exporter
docker rm -fv node_exporter

#port 8080
docker run -d --name=cadvisor_exporter --privileged --device=/dev/kmsg \
-v /:/rootfs:ro -v /var/run:/var/run:ro -v /sys:/sys:ro \
-v /var/lib/docker/:/var/lib/docker:ro -v /dev/disk/:/dev/disk:ro \
gcr.io/cadvisor/cadvisor:v0.38.1

#port 9100
docker run -d --name node_exporter bitnami/node-exporter:latest
resource "random_id" "id" {
  byte_length = 8
}

resource "hsdp_container_host" "kafka" {
  count         = var.nodes
  name          = var.host_name == "" ? "kafka-${random_id.id.hex}-${count.index}.dev" : "kafka-${var.host_name}-${count.index}.${var.tld}"
  iops          = var.iops
  volumes       = 1
  volume_size   = var.volume_size
  instance_type = var.instance_type

  user_groups     = var.user_groups
  security_groups = ["analytics"]
  subnet_type     = var.subnet_type

  lifecycle {
    ignore_changes = [
      volumes,
      volume_size,
      instance_type,
      iops
    ]
  }

  bastion_host = var.bastion_host
  user         = var.user
  private_key  = var.private_key

  commands = [
  ]
}

resource "ssh_resource" "cluster" {
  count = var.nodes

  triggers = {
    cluster_instance_ids = join(",", hsdp_container_host.kafka.*.id)
    bash                 = file("${path.module}/scripts/bootstrap-cluster.sh")
  }

  bastion_host = var.bastion_host
  host         = element(hsdp_container_host.kafka.*.private_ip, count.index)
  user         = var.user
  private_key  = var.private_key

  file {
    source      = "${path.module}/scripts/bootstrap-cluster.sh"
    destination = "/home/${var.user}/bootstrap-cluster.sh"
  }

  file {
    source      = "${path.module}/scripts/jmxconfig.yml.tmpl"
    destination = "/home/${var.user}/jmxconfig.yml.tmpl"
  }

  file {
    source      = var.kafka_trust_store.truststore
    destination = "/home/${var.user}/kafka.truststore.jks"
  }

  file {
    source      = var.kafka_key_store.keystore
    destination = "/home/${var.user}/kafka.keystore.jks"
  }

  file {
    source      = var.zoo_trust_store.truststore
    destination = "/home/${var.user}/zookeeper.truststore.jks"
  }

  file {
    source      = var.zoo_key_store.keystore
    destination = "/home/${var.user}/zookeeper.keystore.jks"
  }

  dynamic "file" {
    for_each = var.enable_exporters ? [var.kafka_ca_root] : []
    content {
      source      = file.value
      destination = "/home/${var.user}/ca.pem"
    }
  }

  dynamic "file" {
    for_each = var.enable_exporters ? [var.kafka_public_key] : []
    content {
      source      = file.value
      destination = "/home/${var.user}/public.pem"
    }
  }

  dynamic "file" {
    for_each = var.enable_exporters ? [var.kafka_private_key] : []
    content {
      source      = file.value
      destination = "/home/${var.user}/private.pem"
    }
  }

  # Bootstrap script called with private_ip of each node in the cluster
  commands = [
    "docker volume create kafka || true",
    "chmod +x /home/${var.user}/bootstrap-cluster.sh",
    "chmod 755 /home/${var.user}/jmxconfig.yml.tmpl",
    "/home/${var.user}/bootstrap-cluster.sh -n ${join(",", hsdp_container_host.kafka.*.private_ip)} -c ${random_id.id.hex} -d ${var.image} -i ${count.index + 1} -z ${var.zookeeper_connect} -x ${element(hsdp_container_host.kafka.*.private_ip, count.index)} -r \"${var.retention_hours}\" -p ${var.kafka_key_store.password} -t ${var.zoo_trust_store.password} -k ${var.zoo_key_store.password} -R ${var.default_replication_factor} -a ${var.auto_create_topics_enable} -e ${var.enable_exporters} -m ${var.message_max_bytes} -f ${var.max_partition_fetch_bytes}"
  ]
}

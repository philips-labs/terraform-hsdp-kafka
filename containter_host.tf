resource "random_id" "id" {
  byte_length = 8
}

resource "hsdp_container_host" "kafka" {
  count         = var.nodes
  name          = "kafka-${random_id.id.hex}-${count.index}.dev"
  volumes       = 1
  volume_size   = var.volume_size
  instance_type = var.instance_type

  user_groups     = var.user_groups
  security_groups = ["analytics"]

  connection {
    bastion_host = var.bastion_host
    host         = self.private_ip
    user         = var.user
    private_key  = var.private_key
    script_path  = "/home/${var.user}/bootstrap.bash"
  }

  provisioner "remote-exec" {
    inline = [
      "docker volume create kafka",
    ]
  }
}

resource "null_resource" "cluster" {
  count = var.nodes

  triggers = {
    cluster_instance_ids = join(",", hsdp_container_host.kafka.*.id)
  }

  connection {
    bastion_host = var.bastion_host
    host         = element(hsdp_container_host.kafka.*.private_ip, count.index)
    user         = var.user
    private_key  = var.private_key
    script_path  = "/home/${var.user}/cluster.bash"
  }

  provisioner "file" {
    source = "${path.module}/scripts/bootstrap-cluster.sh"
    destination = "/home/${var.user}/bootstrap-cluster.sh"
  }

  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the cluster
    inline = [
       "chmod +x /home/${var.user}/bootstrap-cluster.sh",
       "/home/${var.user}/bootstrap-cluster.sh -n ${join(",", hsdp_container_host.kafka.*.private_ip)} -c ${random_id.id.hex} -d ${var.image} -i ${count.index+1} -k ${var.zookeeper}"
    ]
  }
}

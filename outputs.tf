output "kafka_nodes" {
  description = "Container Host IP addresses of Kafka instances"
  value       = hsdp_container_host.kafka.*.private_ip
}

output "kafka_name_nodes" {
  description = "Container Host DNS names of Kafka instances"
  value       = hsdp_container_host.kafka.*.name
}

output "kafka_port" {
  description = "Port where you can reach Kafka"
  value       = "8282"
}

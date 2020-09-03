output "private_ips" {
  description = "Private IP addresses of Kafka instances"
  value       = [hsdp_container_host.kafka.*.private_ip]
}

variable "instance_type" {
  description = "The instance type to use"
  type        = string
  default     = "t3.large"
}

variable "host_name" {
  type        = string
  default     = ""
  description = "The middlename for your host default is a random number"
}

variable "tld" {
  type        = string
  default     = "dev"
  description = "The tld for your host default is a dev"
}

variable "volume_size" {
  description = "The volume size to use in GB"
  type        = number
  default     = 50
}

variable "iops" {
  description = "IOPS to provision for EBS storage"
  type        = number
  default     = 500
}

variable "image" {
  description = "The docker image to use"
  type        = string
  default     = "bitnami/kafka:latest"
}

variable "nodes" {
  description = "Number of nodes"
  type        = number
  default     = 1
}

variable "zookeeper_connect" {
  description = "Zookeeper connect string to use"
  type        = string
}

variable "user_groups" {
  description = "User groups to assign to cluster"
  type        = list(string)
  default     = []
}

variable "user" {
  description = "LDAP user to use for connections"
  type        = string
}

variable "bastion_host" {
  description = "Bastion host to use for SSH connections"
  type        = string
}

variable "private_key" {
  description = "Private key for SSH access"
  type        = string
}

variable "retention_hours" {
  type        = string
  description = "Retention hours for Kakfa topics"
  default     = "-1"
}

variable "default_replication_factor" {
  description = "default kafka server replication factor"
  type        = number
  default     = 1
}

variable "auto_create_topics_enable" {
  description = "turn on or off auto-create-topics, defaults to true"
  type        = bool
  default     = true
}

variable "kafka_trust_store" {
  description = "Trust store for SSL"
  type = object(
    { truststore = string,
    password = string }
  )
}

variable "kafka_key_store" {
  description = "A list of key stores one for each nore"
  type = object(
    { keystore = string,
    password = string }
  )
}

variable "zoo_trust_store" {
  description = "Zookeeper Trust store for SSL"
  type = object(
    { truststore = string,
    password = string }
  )
}

variable "zoo_key_store" {
  description = "Zookeeper Key store for SSL"
  type = object(
    { keystore = string,
    password = string }
  )
}

variable "kafka_ca_root" {
  description = "CA root store for SSL (only applicable when exporter is required, so only when 'enable_exporters==true')"
  default     = ""
  type        = string
}

variable "kafka_public_key" {
  description = "Public Key for SSL (only applicable when exporter is required, so only when 'enable_exporters==true')"
  default     = ""
  type        = string
}

variable "kafka_private_key" {
  description = "Private Key for SSL (only applicable when exporter is required, so only when 'enable_exporters==true')"
  default     = ""
  type        = string
}

variable "enable_exporters" {
  description = "Indicates whether jmx exporter and kafka exporter is enabled or not"
  default     = false
  type        = bool
}

variable "message_max_bytes" {
  description = "The maximum size of a message accepted at broker in bytes"
  default     = 1048576
  type        = number
}

variable "max_partition_fetch_bytes" {
  description = "The maximum amount of data per-partition the server will return"
  default     = 1048576
  type        = number
}

variable "subnet_type" {
  type        = string
  description = "The subnet type to provision Kafka instances in. Can be 'public' or 'private'"
  default     = "private"
}

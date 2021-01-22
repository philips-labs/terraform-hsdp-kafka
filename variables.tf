variable "instance_type" {
  description = "The instance type to use"
  type        = string
  default     = "t3.large"
}

variable "host_name" {
  type = string
  default = ""
  description = "The middlename for your host default is a random number"
}

variable "tld" {
  type = string
  default = "dev"
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
  type        = object (
    { truststore  = string ,
      password    = string }
  )
}

variable "kafka_key_store" {
  description = "A list of key stores one for each nore"
  type        = object(
    { keystore  = string ,
      password  = string }
  )
}

variable "zoo_trust_store" {
  description = "Zookeeper Trust store for SSL"
  type        = object (
    { truststore = string ,
      password   = string }
  )
}

variable "zoo_key_store" {
  description = "Zookeeper Trust store for SSL"
  type        = object (
    { keystore  = string ,
      password  = string }
  )
}

variable "kafka_ca_root" {
  description = "CA root store for SSL"
  type        = string
}
variable "kafka_public_key" {
  description = "Public Key for SSL"
  type        = string
}
variable "kafka_private_key" {
  description = "Private Key for SSL"
  type        = string
}

variable "proxy_host" {
  description = "Proxy host which can be used to ssh via proxy"
  default     = "" 
  type        = string
}

variable "proxy_port" {
  description = "Proxy port which can be used to ssh via proxy"
  default     = ""
  type        = string
}

variable "proxy_user_name" {
  description = "Proxy username which can be used to authenticate for the given proxy"
  default     = ""
  type        = string
}

variable "proxy_user_password" {
  description = "Proxy password which can be used to authenticate for the given proxy"
  default     = ""
  type        = string
}

    

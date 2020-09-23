variable "instance_type" {
  description = "The instance type to use"
  type        = string
  default     = "t3.large"
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
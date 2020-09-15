<img src="https://cdn.rawgit.com/hashicorp/terraform-website/master/content/source/assets/images/logo-hashicorp.svg" width="500px">

# HSDP Kafka module

Module to create an Apache kafka cluster deployed
on the HSDP Container Host infrastructure. This module serves as a 
blueprint for future HSDP Container Host modules. Example usage

```hcl
module "kafka" {
  source = "github.com/philips-labs/terraform-hsdp-kafka"

  nodes             = 3
  bastion_host      = "bastion.host"
  user              = "ronswanson"
  private_key       = file("~/.ssh/dec.key")
  user_groups       = ["ronswanson", "poc"]a
  zookeeper_connect = "zookeeper-server:2181"
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.0 |
| hsdp | >= 0.6.1 |
| null | >= 2.1.1 |
| random | >= 2.2.1 |

## Providers

| Name | Version |
|------|---------|
| hsdp | >= 0.6.1 |
| null | >= 2.1.1 |
| random | >= 2.2.1 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bastion\_host | Bastion host to use for SSH connections | `string` | n/a | yes |
| image | The docker image to use | `string` | `"bitnami/kafka:latest"` | no |
| instance\_type | The instance type to use | `string` | `"t3.large"` | no |
| iops | IOPS to provision for EBS storage | `number` | `500` | no |
| nodes | Number of nodes | `number` | `1` | no |
| private\_key | Private key for SSH access | `string` | n/a | yes |
| user | LDAP user to use for connections | `string` | n/a | yes |
| user\_groups | User groups to assign to cluster | `list(string)` | `[]` | no |
| volume\_size | The volume size to use in GB | `number` | `50` | no |
| zookeeper\_connect | Zookeeper connect string to use | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| kafka\_nodes | Container Host IP addresses of Kafka instances |
| kafka\_port | Port where you can reach Kafka |

# Contact / Getting help

Andy Lo-A-Foe <andy.lo-a-foe@philips.com>

# License

License is MIT

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
  user_groups       = ["ronswanson", "poc"]
  zookeeper_connect = "zookeeper-server:2181"
  kafka_trust_store   = {
    truststore = "./kafkatruststore.jks"
    password   = "somepass"
  }
  kafka_key_store     = {
    keystore   = "./kafkakeystore.jks"
    password   = "somepass"
  }
  zoo_trust_store   = {
    truststore = "./zootruststore.jks"
    password   = "somepass"
  }
  zoo_key_store     = {
    keystore   = "./zookeystore.jks"
    password   = "somepass"
  }    
}
```

__IMPORTANT SECURITY INFORMATION__
> This module currently **enables** only mTLS-SSL
> between Kafka, Zookeeper or any connecting client apps.
> Operating and maintaining applications on Container Host is always
> your responsibility. This includes ensuring any security 
> measures are in place in case you need them.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.0 |
| hsdp | >= 0.9.1 |
| random | >= 2.2.1 |

## Providers

| Name | Version |
|------|---------|
| hsdp | >= 0.9.1 |
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
| kafka\_trust\_store| The trust store object for kafka (see below for more details) | `object` | none | yes |
| kafka\_key\_store | The key store object for kafka(see below for more details) | `object` | none | yes |
| zoo\_trust\_store| The trust store object for zookeeper (see below for more details) | `object` | none | yes |
| zoo\_key\_store | The key store object for zookeeper (see below for more details) | `object` | none | yes |

Incase you are wondering why we need zookeeper key store, its required by bitnami please refer to bitnami documentation.


## Key Store object
This object has two properties that needs to be filled
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| keystore | The path of the keystore file in JKS format| `string` | none | yes |
| password | The password to be used for the key store | `string` | none | yes |

## trust Store object
This object has two properties that needs to be filled
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| truststore | The path of the truststore file in JKS format| `string` | none | yes |
| password | The password to be used for the trust store | `string` | none | yes |

## Outputs

| Name | Description |
|------|-------------|
| kafka\_nodes | Container Host IP addresses of Kafka instances |
| kafka\_port | Port where you can reach Kafka |

# Contact / Getting help

Andy Lo-A-Foe <andy.lo-a-foe@philips.com>

# License

License is MIT

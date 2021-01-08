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
| hsdp | >= 0.6.6 |
| null | >= 2.1.1 |
| random | >= 2.2.1 |

## Providers

| Name | Version |
|------|---------|
| hsdp | >= 0.6.6 |
| null | >= 2.1.1 |
| random | >= 2.2.1 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| auto\_create\_topics\_enable | turn on or off auto-create-topics, defaults to true | `bool` | `true` | no |
| bastion\_host | Bastion host to use for SSH connections | `string` | n/a | yes |
| default\_replication\_factor | default kafka server replication factor | `number` | `1` | no |
| host\_name | The middlename for your host default is a random number | `string` | `""` | no |
| image | The docker image to use | `string` | `"bitnami/kafka:latest"` | no |
| instance\_type | The instance type to use | `string` | `"t3.large"` | no |
| iops | IOPS to provision for EBS storage | `number` | `500` | no |
| kafka\_ca\_root | CA root store for SSL | `string` | n/a | yes |
| kafka\_key\_store | A list of key stores one for each nore | <pre>object(<br>    { keystore  = string ,<br>      password  = string }<br>  )</pre> | n/a | yes |
| kafka\_private\_key | Private Key for SSL | `string` | n/a | yes |
| kafka\_public\_key | Public Key for SSL | `string` | n/a | yes |
| kafka\_trust\_store | Trust store for SSL | <pre>object (<br>    { truststore  = string ,<br>      password    = string }<br>  )</pre> | n/a | yes |
| nodes | Number of nodes | `number` | `1` | no |
| private\_key | Private key for SSH access | `string` | n/a | yes |
| retention\_hours | Retention hours for Kakfa topics | `string` | `"-1"` | no |
| tld | The tld for your host default is a dev | `string` | `"dev"` | no |
| user | LDAP user to use for connections | `string` | n/a | yes |
| user\_groups | User groups to assign to cluster | `list(string)` | `[]` | no |
| volume\_size | The volume size to use in GB | `number` | `50` | no |
| zoo\_key\_store | Zookeeper Trust store for SSL | <pre>object (<br>    { keystore  = string ,<br>      password  = string }<br>  )</pre> | n/a | yes |
| zoo\_trust\_store | Zookeeper Trust store for SSL | <pre>object (<br>    { truststore = string ,<br>      password   = string }<br>  )</pre> | n/a | yes |
| zookeeper\_connect | Zookeeper connect string to use | `string` | n/a | yes |

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


## Generate caroot (PEM format)
Kafka exporter needs a caroot file. This can be extracted from the truststore file. In order to that use the following script:
```
inputJksFilename=$1
outputPublicKeyFilename=$2
inputKeyStorePassword=$3

# Exports the pub cert from the truststore
keytool -export  -rfc -alias caroot -keystore $inputJksFilename -file $outputPublicKeyFilename -storepass $inputKeyStorePassword -noprompt
```

## Generate public/private keys (PEM format)
Kafka exporter needs the certificate in PEM format. In order to get these files use the following script:

```
inputJksFilename=$1
outputPublicKeyFilename=$2
outputPrivateKeyFilename=$3
inputKeyStorePassword=$4

#Export the public key with the certificate format
openssl pkcs12 -in $inputJksFilename -out $outputPublicKeyFilename -clcerts -nokeys -passin pass:$inputKeyStorePassword

#Export the private key with the PEM format
keytool -importkeystore -srckeystore $inputJksFilename -destkeystore tempKeyStore.p12 -deststoretype PKCS12 -srcstorepass $inputKeyStorePassword -deststorepass $inputKeyStorePassword -noprompt
openssl pkcs12 -in tempKeyStore.p12 -nodes -nocerts -out $outputPrivateKeyFilename  -passin pass:$inputKeyStorePassword -passout pass:$inputKeyStorePassword 
```


## Outputs

| Name | Description |
|------|-------------|
| kafka\_name\_nodes | Container Host DNS names of Kafka instances |
| kafka\_nodes | Container Host IP addresses of Kafka instances |
| kafka\_port | Port where you can reach Kafka |

# Contact / Getting help

Andy Lo-A-Foe <andy.lo-a-foe@philips.com>

# License

License is MIT

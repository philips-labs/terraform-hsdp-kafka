terraform {
  required_version = ">= 0.13.0"

  required_providers {
    cloudfoundry = {
      source  = "cloudfoundry-community/cloudfoundry"
      version = ">= 0.12.4"
    }
    random = {
      source  = "random"
      version = ">= 2.2.1"
    }
    null = {
      source  = "null"
      version = ">= 2.2.1"
    }
  }
}

terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.26.0"
    }
    shell = {
      source  = "scottwinkler/shell"
      version = "1.7.7"
    }
  }
  required_version = ">= 0.13"
}

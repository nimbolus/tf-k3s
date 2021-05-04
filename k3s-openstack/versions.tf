terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = ">= 1.37.0"
    }
    shell = {
      source  = "scottwinkler/shell"
      version = "1.7.7"
    }
  }
  required_version = ">= 0.13"
}

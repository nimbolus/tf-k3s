terraform {
  required_providers {
    k8sbootstrap = {
      source  = "nimbolus/k8sbootstrap"
      version = ">= 0.1.1"
    }
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = ">= 1.37.0"
    }
  }
  required_version = ">= 0.13"
}

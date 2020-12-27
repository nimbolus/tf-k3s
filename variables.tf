variable "name" {
  type = string
}

variable "image_name" {
  default = "ubuntu-20.04"
}

variable "flavor_name" {
  default = "m1.small"
}

variable "availability_zone" {
  default = "nova"
}

variable "keypair_name" {
  type = string
}

variable "network_name" {
  type = string
}

variable "subnet_name" {
  type = string
}

variable "k3s_master" {
  default = true
}

variable "k3s_token" {
  type = string
}

variable "k3s_url" {
  default = ""
}

variable "install_k3s_exec" {
  default = ""
}

variable "additional_port_ids" {
  default = []
}

output "k3s_url" {
  value = var.k3s_master ? "https://${openstack_compute_instance_v2.k3s_node.network.0.fixed_ip_v4}:6443" : var.k3s_url
}

variable "availability_zone" {
  default = "nova"
}

variable "network_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "image_name" {
  default = "ubuntu-20.04-ansible"
}

variable "floating_ip_pool" {
  type    = string
  default = null
}

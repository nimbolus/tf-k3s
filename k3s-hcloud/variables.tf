variable "image_name" {
  default = "ubuntu-20.04"
}

variable "server_type" {
  default = "cx11"
}

variable "location" {
  default = "fsn1"
}

variable "keypair_name" {
  type    = string
  default = null
}

variable "labels" {
  type    = map(string)
  default = {}
}

variable "firewall_ids" {
  type    = list(number)
  default = []
}

variable "network_id" {
  type = string
}

variable "network_range" {
  type = string
}

variable "data_volume_size" {
  default = 10
}

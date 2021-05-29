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
  type    = string
  default = null
}

variable "network_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}

variable "config_drive" {
  default = false
}

variable "additional_port_ids" {
  default = []
}

variable "data_volume_type" {
  default = "__DEFAULT__"
}

variable "data_volume_size" {
  default = 10
}

variable "data_volume_enable_online_resize" {
  default = true
}

variable "server_properties" {
  type        = map(string)
  description = "additional metadata properties for instance"
  default     = {}
}

variable "server_ip_address" {
  default     = null
  description = "fixed ip address for instance"
}

variable "server_stop_before_destroy" {
  default     = true
  description = "shutdown instance gracefully before destroying"
}

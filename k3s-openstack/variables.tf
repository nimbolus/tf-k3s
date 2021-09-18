variable "image_name" {
  default = "ubuntu-20.04"
}

variable "image_id" {
  type        = string
  default     = null
  description = "instead of a image name, the id can be given"
}

variable "flavor_name" {
  default = "m1.small"
}

variable "flavor_id" {
  type        = string
  default     = null
  description = "instead of a flavor name, the id can be given"
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

variable "server_stop_before_destroy" {
  default     = false
  description = "shutdown instance gracefully before destroying"
}

variable "floating_ip_pool" {
  type        = string
  default     = null
  description = "if defined a floating ip will be assigned to the node and registered as k3s_external_ip"
}

variable "server_group_id" {
  default = null
}

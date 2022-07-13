variable "image_name" {
  default = "ubuntu-20.04"
}

variable "image_id" {
  type        = string
  default     = null
  description = "instead of a image name, the id can be given"
}

variable "image_scsi_bus" {
  default = false
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

variable "allowed_address_cidrs" {
  type        = list(string)
  default     = []
  description = "list of CIDRs which will be whitelisted by the anti-spoofing rules"
}

variable "config_drive" {
  default = false
}

variable "additional_port_ids" {
  default = []
}

variable "ephemeral_data_volume" {
  default     = false
  description = "use an ephemeral disk for data, which will be deleted on instance termination"
}

variable "data_volume_type" {
  default = "__DEFAULT__"
}

variable "data_volume_size" {
  default     = 10
  description = "data volume size in GB, can be set to 0 to omit data volume creation"
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

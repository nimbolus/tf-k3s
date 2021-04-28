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
  type    = string
  default = null
}

variable "network_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "security_group_id" {
  type    = string
  default = null
}

variable "allow_remote_prefix" {
  default = "0.0.0.0/0"
}

variable "additional_security_group_ids" {
  type    = list(string)
  default = []
}

variable "config_drive" {
  default = false
}

variable "k3s_join" {
  default = false
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

variable "bootstrap_token_id" {
  default = ""
}

variable "bootstrap_token_secret" {
  default   = ""
  sensitive = true
}

variable "additional_port_ids" {
  default = []
}

variable "custom_cloud_config_write_files" {
  default = ""
}

variable "custom_cloud_config_runcmd" {
  default = ""
}

variable "data_volume_type" {
  default = "__DEFAULT__"
}

variable "data_volume_size" {
  default = 10
}

variable "server_properties" {
  type        = map(string)
  description = "additional metadata properties for instance"
  default     = {}
}

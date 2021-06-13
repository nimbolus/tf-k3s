variable "name" {
  type = string
}

variable "k3s_join_existing" {
  default = false
}

variable "cluster_token" {
  type    = string
  default = null
}

variable "k3s_ip" {
  type        = string
  default     = null
  description = "ip the k3s node uses cluster-internally"
}

variable "k3s_url" {
  default     = ""
  description = "api url of the existing cluster this node should join to"
}

variable "k3s_external_ip" {
  type        = string
  default     = null
  description = "external ip address of the k3s node"
}

variable "install_k3s_exec" {
  default = ""
}

variable "bootstrap_token_enabled" {
  default = true
}

variable "bootstrap_token_id" {
  type    = string
  default = null
}

variable "bootstrap_token_secret" {
  type      = string
  default   = null
  sensitive = true
}

variable "custom_cloud_config_write_files" {
  default = ""
}

variable "custom_cloud_config_runcmd" {
  default = ""
}

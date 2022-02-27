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

variable "k3s_version" {
  type        = string
  default     = null
  description = "version of k3s to download. If not defined stable channel is used"
}

variable "k3s_channel" {
  default     = "stable"
  description = "channel to use for fetching k3s download URL, could be stable, latest or testing (overridden by k3s_version)"
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

variable "k3s_args" {
  default     = []
  description = "command line flags for launching k3s in the service"
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

variable "persistent_volume_dev" {
  default     = ""
  description = "optional device for persistent data (e.g. /dev/vdb)"
}

variable "cni_plugins_version" {
  default = "v0.9.0"
}

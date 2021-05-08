variable "name" {
  type = string
}

variable "k3s_join_existing" {
  default = false
}

variable "k3s_token" {
  type = string
}

variable "k3s_ip" {
  default     = ""
  description = "ip the k8s api will be available on"
}

variable "k3s_url" {
  default     = ""
  description = "api url of the existing cluster this node should join to"
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

variable "custom_cloud_config_write_files" {
  default = ""
}

variable "custom_cloud_config_runcmd" {
  default = ""
}

variable "ca_shell_script_timeout" {
  default = 300
}

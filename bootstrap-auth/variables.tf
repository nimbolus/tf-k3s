variable "k3s_url" {
  type        = string
  description = "api url of the existing cluster whose ca cert should be retrieved"

  validation {
    condition     = can(regex("^http(s)?://[a-zA-Z0-9.-]*(:[0-9]{1,5})?(/[a-zA-Z0-9._-]+)*$", var.k3s_url))
    error_message = "The k3s_url must be a valid url including the scheme (http/https)."
  }
}

variable "token" {
  type        = string
  description = "bootstrap token to use for retrieval of ca cert"
  sensitive   = true

  validation {
    condition     = can(regex("^[a-zA-Z0-9./_-]*$", var.token))
    error_message = "The token must not use characters other than alphanumerical characters, dots, dashes, slashes and underscores."
  }
}

variable "ca_shell_script_timeout" {
  type    = number
  default = 300
}

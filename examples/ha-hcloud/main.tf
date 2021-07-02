resource "random_password" "cluster_token" {
  length  = 64
  special = false
}

resource "random_password" "bootstrap_token_id" {
  length  = 6
  upper   = false
  special = false
}

resource "random_password" "bootstrap_token_secret" {
  length  = 16
  upper   = false
  special = false
}

locals {
  token                  = "${random_password.bootstrap_token_id.result}.${random_password.bootstrap_token_secret.result}"
  common_k3s_server_exec = "--kube-apiserver-arg=\"enable-bootstrap-token-auth\" --disable traefik --node-label az=ex1"
}

data "k8sbootstrap_auth" "auth" {
  server = module.server1.k3s_external_url
  token  = local.token
}

module "server1" {
  source = "../../k3s-hcloud"

  name          = "k3s-server-1"
  keypair_name  = hcloud_ssh_key.k3s.name
  network_id    = hcloud_network_subnet.k3s.network_id
  network_range = hcloud_network.k3s.ip_range

  cluster_token          = random_password.cluster_token.result
  install_k3s_exec       = "server --cluster-init ${local.common_k3s_server_exec}"
  bootstrap_token_id     = random_password.bootstrap_token_id.result
  bootstrap_token_secret = random_password.bootstrap_token_secret.result
}

module "servers" {
  source = "../../k3s-hcloud"

  count = 2

  name          = "k3s-server-${count.index + 2}"
  keypair_name  = hcloud_ssh_key.k3s.name
  network_id    = hcloud_network_subnet.k3s.network_id
  network_range = hcloud_network.k3s.ip_range

  k3s_join_existing = true
  k3s_url           = module.server1.k3s_url
  cluster_token     = random_password.cluster_token.result
  install_k3s_exec  = "server ${local.common_k3s_server_exec}"
}

module "agent" {
  source = "../../k3s-hcloud"

  count = 1

  name          = "k3s-agent-${count.index + 1}"
  keypair_name  = hcloud_ssh_key.k3s.name
  network_id    = hcloud_network_subnet.k3s.network_id
  network_range = hcloud_network.k3s.ip_range

  k3s_join_existing = true
  k3s_url           = module.server1.k3s_url
  cluster_token     = random_password.cluster_token.result
  install_k3s_exec  = "agent --node-label az=ex1"
}

output "cluster_token" {
  value     = random_password.cluster_token.result
  sensitive = true
}

output "k3s_url" {
  value = module.server1.k3s_url
}

output "k3s_external_url" {
  value = module.server1.k3s_external_url
}

output "server_ip" {
  value = module.server1.node_ip
}

output "server_external_ip" {
  value = module.server1.node_external_ip
}

output "server_user_data" {
  value     = module.server1.user_data
  sensitive = true
}

output "token" {
  value     = local.token
  sensitive = true
}

output "ca_crt" {
  value = data.k8sbootstrap_auth.auth.ca_crt
}

output "kubeconfig" {
  value     = data.k8sbootstrap_auth.auth.kubeconfig
  sensitive = true
}

provider "kubernetes" {
  host                   = module.server1.k3s_url
  token                  = local.token
  cluster_ca_certificate = data.k8sbootstrap_auth.auth.ca_crt
}

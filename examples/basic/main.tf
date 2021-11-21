# This will only template the user_data. You need to create the virtual machines
# yourself using this data. You can also use the k3s-openstack or k3s-hcloud
# modules which bundle this functionality for the respective providers.

resource "random_password" "cluster_token" {
  length  = 64
  special = false
}

module "k3s_server" {
  source = "../../k3s"

  name          = "k3s-server"
  cluster_token = random_password.cluster_token.result
  k3s_ip        = var.server_ip
  k3s_args = [
    "server",
    "--disable", "traefik",
    "--node-label", "az=ex1",
  ]
}

locals {
  k3s_url = "https://${var.server_ip}:6443"
}

module "k3s_agent" {
  source = "../../k3s"

  name              = "k3s-agent"
  k3s_join_existing = true
  k3s_url           = local.k3s_url
  cluster_token     = random_password.cluster_token.result
  k3s_ip            = var.agent_ip
  k3s_args = [
    "agent",
    "--node-label", "az=ex1",
  ]
}

output "cluster_token" {
  value     = random_password.cluster_token.result
  sensitive = true
}

output "k3s_url" {
  value = local.k3s_url
}

output "server_user_data" {
  value     = module.k3s_server.user_data
  sensitive = true
}

output "agent_user_data" {
  value     = module.k3s_agent.user_data
  sensitive = true
}

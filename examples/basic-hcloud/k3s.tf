resource "random_password" "cluster_token" {
  length  = 64
  special = false
}

module "server" {
  source = "../../k3s-hcloud"

  name          = "k3s-server"
  keypair_name  = hcloud_ssh_key.k3s.name
  network_id    = hcloud_network.k3s.id
  network_range = hcloud_network.k3s.ip_range

  cluster_token    = random_password.cluster_token.result
  install_k3s_exec = "server --disable traefik --node-label az=ex1"
}

module "agent" {
  source = "../../k3s-hcloud"

  name          = "k3s-agent"
  keypair_name  = hcloud_ssh_key.k3s.name
  network_id    = hcloud_network.k3s.id
  network_range = hcloud_network.k3s.ip_range

  k3s_join_existing = true
  k3s_url           = module.server.k3s_url
  cluster_token     = random_password.cluster_token.result
  install_k3s_exec  = "agent --node-label az=ex1"
}

output "cluster_token" {
  value     = random_password.cluster_token.result
  sensitive = true
}

output "k3s_url" {
  value = module.server.k3s_url
}

output "k3s_external_url" {
  value = module.server.k3s_external_url
}

output "server_ip" {
  value = module.server.node_ip
}

output "server_external_ip" {
  value = module.server.node_external_ip
}

output "agent_ip" {
  value = module.agent.node_ip
}

output "agent_external_ip" {
  value = module.agent.node_external_ip
}

output "server_user_data" {
  value     = module.server.user_data
  sensitive = true
}

output "agent_user_data" {
  value     = module.agent.user_data
  sensitive = true
}

resource "random_password" "cluster_token" {
  length  = 64
  special = false
}

module "server" {
  source = "../../k3s-hcloud"

  name         = "k3s-server"
  keypair_name = "example-keypair"
  network_id   = "example-id"

  cluster_token    = random_password.cluster_token.result
  install_k3s_exec = "server --disable traefik --node-label az=ex1"
}

module "agent" {
  source = "../../k3s-hcloud"

  name         = "k3s-agent"
  keypair_name = "example-keypair"
  network_id   = "example-id"

  k3s_join_existing = true
  k3s_url           = module.server.k3s_url
  cluster_token     = random_password.cluster_token.result
  install_k3s_exec  = "agent --node-label az=ex1"
}

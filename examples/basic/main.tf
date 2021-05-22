# This will only template the user_data. You need to create the virtual machines
# yourself using this data. You can also use the k3s-openstack or k3s-hcloud
# modules which bundle this functionality for the respective providers.

resource "random_password" "cluster_token" {
  length  = 64
  special = false
}

module "k3s_server" {
  source = "github.com/nimbolus/tf-k3s/k3s"

  name             = "k3s-server"
  k3s_token        = random_password.cluster_token.result
  install_k3s_exec = "server --disable traefik --node-label az=ex1"
}

module "k3s_agent" {
  source = "github.com/nimbolus/tf-k3s/k3s"

  name              = "k3s-agent"
  k3s_join_existing = true
  k3s_url           = module.k3s_server.k3s_url
  k3s_token         = random_password.cluster_token.result
  install_k3s_exec  = "agent --node-label az=ex1"
}

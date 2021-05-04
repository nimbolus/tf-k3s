resource "random_password" "cluster_token" {
  length  = 64
  special = false
}

module "k3s_master" {
  source = "github.com/nimbolus/tf-k3s/k3s"

  name             = "k3s-master"
  k3s_token        = random_password.cluster_token.result
  install_k3s_exec = "server --disable traefik --node-label az=ex1"
}

module "k3s_worker" {
  source = "github.com/nimbolus/tf-k3s/k3s"

  name              = "k3s-worker"
  k3s_join_existing = true
  k3s_url           = module.k3s_master.k3s_url
  k3s_token         = random_password.cluster_token.result
  install_k3s_exec  = "agent --node-label az=ex1"
}

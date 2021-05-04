resource "random_password" "hcloud_cluster_token" {
  length  = 64
  special = false
}

module "hcloud_master" {
  source = "github.com/nimbolus/tf-k3s/k3s-hcloud"

  name         = "k3s-master"
  keypair_name = "pubkey"
  network_id   = "example-id"

  k3s_token        = random_password.hcloud_cluster_token.result
  install_k3s_exec = "server --disable traefik --node-label az=ex1"
}

module "hcloud_worker" {
  source = "github.com/nimbolus/tf-k3s/k3s-hcloud"

  name         = "k3s-worker"
  keypair_name = hcloud_ssh_key.yubikey.name
  network_id   = hcloud_network.k3s.id

  k3s_join_existing = true
  k3s_url           = module.hcloud_master.k3s_url
  k3s_token         = random_password.hcloud_cluster_token.result
  install_k3s_exec  = "agent --node-label az=ex1"
}

resource "local_file" "hcloud_kubeconfig" {
  filename = "hcloud-kubeconfig.yaml"
  content  = module.hcloud_master.kubeconfig
}

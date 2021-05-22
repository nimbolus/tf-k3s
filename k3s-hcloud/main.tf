resource "hcloud_volume" "node" {
  name     = "${var.name}-data"
  location = var.location
  size     = var.data_volume_size
}

module "k3s" {
  source = "../k3s"

  name                            = var.name
  k3s_join_existing               = var.k3s_join_existing
  cluster_token                   = var.cluster_token
  k3s_ip                          = var.k3s_join_existing ? var.k3s_ip : hcloud_server.node.ipv4_address
  k3s_url                         = var.k3s_url
  install_k3s_exec                = var.install_k3s_exec
  custom_cloud_config_write_files = var.custom_cloud_config_write_files
  custom_cloud_config_runcmd      = var.custom_cloud_config_runcmd
  bootstrap_token_id              = var.bootstrap_token_id
  bootstrap_token_secret          = var.bootstrap_token_secret
}

resource "hcloud_server" "node" {
  name        = var.name
  image       = var.image_name
  server_type = var.server_type
  location    = var.location
  ssh_keys    = [var.keypair_name]
  user_data   = module.k3s.user_data
}

resource "hcloud_volume_attachment" "node" {
  volume_id = hcloud_volume.node.id
  server_id = hcloud_server.node.id
  automount = true
}

resource "hcloud_server_network" "node" {
  server_id  = hcloud_server.node.id
  network_id = var.network_id
}

locals {
  node_ip = hcloud_server.node.ipv4_address
}

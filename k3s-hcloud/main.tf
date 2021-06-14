resource "hcloud_volume" "node" {
  name     = "${var.name}-data"
  location = var.location
  size     = var.data_volume_size
}

locals {
  internal_route_target = split("/", var.network_range)[0]
  internal_ip_command   = "$(while ! ip r | grep -q '${var.network_range}'; do sleep 1; done; ip -o r get ${local.internal_route_target} | sed -n 's/.*src \\([0-9.]\\+\\).*/\\1/p')"
  external_ip_command   = "$(ip -o r get 1.1.1.1 | sed -n 's/.*src \\([0-9.]\\+\\).*/\\1/p')"
}

module "k3s" {
  source = "../k3s"

  name                            = var.name
  k3s_join_existing               = var.k3s_join_existing
  cluster_token                   = var.cluster_token
  k3s_ip                          = var.k3s_ip != null ? var.k3s_ip : local.internal_ip_command
  k3s_url                         = var.k3s_url
  k3s_external_ip                 = var.k3s_external_ip != null ? var.k3s_external_ip : local.external_ip_command
  install_k3s_exec                = var.install_k3s_exec
  custom_cloud_config_write_files = var.custom_cloud_config_write_files
  custom_cloud_config_runcmd      = var.custom_cloud_config_runcmd
  bootstrap_token_id              = var.bootstrap_token_id
  bootstrap_token_secret          = var.bootstrap_token_secret
  persistent_volume_dev           = "/dev/disk/by-id/scsi-0HC_Volume_${hcloud_volume.node.id}"
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
  ip         = var.k3s_ip
}

locals {
  node_ip          = hcloud_server_network.node.ip
  node_external_ip = hcloud_server.node.ipv4_address
  k3s_url          = var.k3s_join_existing ? var.k3s_url : "https://${local.node_ip}:6443"
  k3s_external_url = var.k3s_join_existing ? "" : "https://${local.node_external_ip}:6443"
}

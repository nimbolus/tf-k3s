locals {
  create_data_volume = var.data_volume_size > 0
  data_volume_name   = var.ephemeral_data_volume ? "ephemeral0" : (var.image_scsi_bus ? "/dev/sdb" : "/dev/vdb")
}

data "openstack_compute_flavor_v2" "k3s" {
  count = var.flavor_id == null ? 1 : 0

  name = var.flavor_name
}

data "openstack_images_image_v2" "k3s" {
  count = var.image_id == null ? 1 : 0

  name        = var.image_name
  most_recent = true
}

resource "openstack_blockstorage_volume_v3" "data" {
  count = local.create_data_volume && !var.ephemeral_data_volume ? 1 : 0

  name                 = "${var.name}-data"
  availability_zone    = var.availability_zone
  volume_type          = var.data_volume_type
  size                 = var.data_volume_size
  enable_online_resize = var.data_volume_enable_online_resize
}

module "k3s" {
  source = "../k3s"

  name                            = var.name
  k3s_join_existing               = var.k3s_join_existing
  cluster_token                   = var.cluster_token
  k3s_version                     = var.k3s_version
  k3s_channel                     = var.k3s_channel
  k3s_install_url                 = var.k3s_install_url
  k3s_ip                          = openstack_networking_port_v2.mgmt.all_fixed_ips[0]
  k3s_url                         = var.k3s_url
  k3s_external_ip                 = var.k3s_external_ip != null ? var.k3s_external_ip : local.node_external_ip
  k3s_args                        = var.k3s_args
  bootstrap_token_id              = var.bootstrap_token_id
  bootstrap_token_secret          = var.bootstrap_token_secret
  persistent_volume_dev           = local.create_data_volume ? local.data_volume_name : ""
  persistent_volume_label         = var.ephemeral_data_volume ? "ephemeral0" : "k3s-data"
  custom_cloud_config_write_files = var.custom_cloud_config_write_files
  custom_cloud_config_runcmd      = var.custom_cloud_config_runcmd
  custom_cloud_config_overrides = concat(
    var.server_properties_fetch_k3s_version ? ["export INSTALL_K3S_VERSION=$(curl -s http://169.254.169.254/openstack/latest/meta_data.json | sed -r 's/.*\"k3s_version\": \"([^\"]*)\".*/\\1/')"] : [],
    var.server_properties_fetch_k3s_channel ? ["export INSTALL_K3S_CHANNEL=$(curl -s http://169.254.169.254/openstack/latest/meta_data.json | sed -r 's/.*\"k3s_channel\": \"([^\"]*)\".*/\\1/')"] : [],
  )
}

resource "openstack_compute_instance_v2" "node" {
  name                = var.name
  image_id            = var.image_id == null ? data.openstack_images_image_v2.k3s.0.id : var.image_id
  flavor_id           = var.flavor_id == null ? data.openstack_compute_flavor_v2.k3s.0.id : var.flavor_id
  key_pair            = var.keypair_name
  metadata            = var.server_properties
  config_drive        = var.config_drive
  availability_zone   = var.availability_zone
  user_data           = module.k3s.user_data
  stop_before_destroy = var.server_stop_before_destroy

  scheduler_hints {
    group = var.server_group_id
  }

  network {
    port           = openstack_networking_port_v2.mgmt.id
    access_network = true
  }

  dynamic "network" {
    for_each = var.additional_port_ids
    content {
      port = network["value"]
    }
  }

  block_device {
    boot_index            = 0
    uuid                  = var.image_id == null ? data.openstack_images_image_v2.k3s.0.id : var.image_id
    delete_on_termination = true
    destination_type      = "local"
    source_type           = "image"
  }

  dynamic "block_device" {
    for_each = local.create_data_volume && var.ephemeral_data_volume ? { "data" = { "size" = var.data_volume_size } } : {}
    content {
      boot_index            = -1
      source_type           = "blank"
      destination_type      = "local"
      delete_on_termination = true
      volume_size           = block_device.value["size"]
    }
  }

  dynamic "block_device" {
    for_each = openstack_blockstorage_volume_v3.data
    content {
      boot_index            = -1
      uuid                  = block_device.value["id"]
      source_type           = "volume"
      destination_type      = "volume"
      delete_on_termination = false
    }
  }

  lifecycle {
    ignore_changes = [
      block_device.0.uuid
    ]
  }
}

resource "openstack_networking_port_v2" "mgmt" {
  name                  = var.name
  network_id            = var.network_id
  admin_state_up        = true
  security_group_ids    = var.security_group_ids
  port_security_enabled = true

  fixed_ip {
    subnet_id  = var.subnet_id
    ip_address = var.k3s_ip
  }

  dynamic "allowed_address_pairs" {
    for_each = var.allowed_address_cidrs
    content {
      ip_address = allowed_address_pairs.value
    }
  }
}

resource "openstack_networking_floatingip_v2" "node" {
  count = var.floating_ip_pool == null ? 0 : 1
  pool  = var.floating_ip_pool
}

resource "openstack_compute_floatingip_associate_v2" "node" {
  count       = length(openstack_networking_floatingip_v2.node) > 0 ? 1 : 0
  floating_ip = openstack_networking_floatingip_v2.node[0].address
  instance_id = openstack_compute_instance_v2.node.id
}

locals {
  node_ip          = openstack_compute_instance_v2.node.network.0.fixed_ip_v4
  node_ipv6        = openstack_compute_instance_v2.node.network.0.fixed_ip_v6
  node_external_ip = length(openstack_networking_floatingip_v2.node) > 0 ? openstack_networking_floatingip_v2.node[0].address : null
  k3s_url          = var.k3s_join_existing ? var.k3s_url : "https://${local.node_ip}:6443"
  k3s_external_url = (var.k3s_join_existing || local.node_external_ip == null) ? "" : "https://${local.node_external_ip}:6443"
}

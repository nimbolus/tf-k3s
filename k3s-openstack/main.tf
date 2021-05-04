data "openstack_compute_flavor_v2" "k3s" {
  name = var.flavor_name
}

data "openstack_images_image_v2" "k3s" {
  name        = var.image_name
  most_recent = true
}

resource "openstack_blockstorage_volume_v3" "data" {
  name              = "${var.name}-data"
  availability_zone = var.availability_zone
  volume_type       = var.data_volume_type
  size              = var.data_volume_size
}

module "k3s" {
  source = "../k3s"

  name                   = var.name
  k3s_join_existing      = var.k3s_join_existing
  k3s_token              = var.k3s_token
  k3s_ip                 = var.k3s_join_existing ? var.k3s_ip : openstack_networking_port_v2.mgmt.all_fixed_ips[0]
  k3s_url                = var.k3s_url
  install_k3s_exec       = var.install_k3s_exec
  bootstrap_token_id     = var.bootstrap_token_id
  bootstrap_token_secret = var.bootstrap_token_secret
}

resource "openstack_compute_instance_v2" "node" {
  name              = var.name
  image_id          = data.openstack_images_image_v2.k3s.id
  flavor_id         = data.openstack_compute_flavor_v2.k3s.id
  key_pair          = var.keypair_name
  metadata          = var.server_properties
  config_drive      = var.config_drive
  availability_zone = var.availability_zone
  user_data         = module.k3s.user_data

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
    uuid                  = data.openstack_images_image_v2.k3s.id
    delete_on_termination = true
    destination_type      = "local"
    source_type           = "image"
  }

  block_device {
    boot_index            = -1
    uuid                  = openstack_blockstorage_volume_v3.data.id
    source_type           = "volume"
    destination_type      = "volume"
    delete_on_termination = false
  }
}
data "openstack_compute_flavor_v2" "k3s" {
  name = var.flavor_name
}

data "openstack_images_image_v2" "k3s" {
  name        = var.image_name
  most_recent = true
}

resource "openstack_blockstorage_volume_v3" "k3s_data" {
  name              = "${var.name}-data"
  availability_zone = var.availability_zone
  size              = 10
}

resource "openstack_compute_instance_v2" "k3s_node" {
  name      = var.name
  image_id  = data.openstack_images_image_v2.k3s.id
  flavor_id = data.openstack_compute_flavor_v2.k3s.id
  key_pair  = var.keypair_name

  availability_zone = var.availability_zone

  user_data = var.k3s_master ? templatefile("${path.module}/cloud-init/k3s.yml", {
    k3s_config = base64encode(<<EOF
K3S_TOKEN=${var.k3s_token}
INSTALL_K3S_EXEC="${var.install_k3s_exec}"
EOF
    )
    }) : templatefile("${path.module}/cloud-init/k3s.yml", {
    k3s_config = base64encode(<<EOF
K3S_TOKEN=${var.k3s_token}
K3S_URL=${var.k3s_url}
INSTALL_K3S_EXEC="${var.install_k3s_exec}"
EOF
    )
  })

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
    uuid                  = openstack_blockstorage_volume_v3.k3s_data.id
    source_type           = "volume"
    destination_type      = "volume"
    delete_on_termination = false
  }
}

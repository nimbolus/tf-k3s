resource "openstack_networking_secgroup_v2" "k3s" {
  name        = "allow-k3s-${var.name}"
  description = "allow k3s services"
}

resource "openstack_networking_secgroup_rule_v2" "ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.k3s.id
}

resource "openstack_networking_secgroup_rule_v2" "kubernetes_api" {
  count = var.k3s_master ? 1 : 0

  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 6443
  port_range_max    = 6443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.k3s.id
}

resource "openstack_networking_secgroup_rule_v2" "kubelet_metrics" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 10250
  port_range_max    = 10250
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.k3s.id
}

resource "openstack_networking_secgroup_rule_v2" "flannel_vxlan" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 8472
  port_range_max    = 8472
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.k3s.id
}

data "openstack_networking_network_v2" "mgmt" {
  name = var.network_name
}

data "openstack_networking_subnet_v2" "mgmt" {
  name       = var.subnet_name
  network_id = data.openstack_networking_network_v2.mgmt.id
}

resource "openstack_networking_port_v2" "mgmt" {
  name               = var.name
  network_id         = data.openstack_networking_network_v2.mgmt.id
  admin_state_up     = true
  security_group_ids = [openstack_networking_secgroup_v2.k3s.id]
  port_security_enabled = true

  fixed_ip {
    subnet_id = data.openstack_networking_subnet_v2.mgmt.id
  }

}

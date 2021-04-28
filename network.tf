resource "openstack_networking_secgroup_v2" "k3s" {
  count       = var.security_group_id == null ? 1 : 0
  name        = "allow-k3s-${var.name}"
  description = "allow k3s services"
}

locals {
  security_group_id = var.security_group_id == null ? openstack_networking_secgroup_v2.k3s[0].id : var.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "internal_tcp" {
  count             = var.security_group_id == null ? 1 : 0
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_group_id   = local.security_group_id
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "internal_udp" {
  count             = var.security_group_id == null ? 1 : 0
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  remote_group_id   = local.security_group_id
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "ssh" {
  count             = var.security_group_id == null ? 1 : 0
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.allow_remote_prefix
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "kubernetes_api" {
  count             = var.security_group_id == null ? 1 : 0
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 6443
  port_range_max    = 6443
  remote_ip_prefix  = var.allow_remote_prefix
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "kubernetes_node_ports_tcp" {
  count             = var.security_group_id == null ? 1 : 0
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 30000
  port_range_max    = 32767
  remote_ip_prefix  = var.allow_remote_prefix
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "kubernetes_node_ports_udp" {
  count             = var.security_group_id == null ? 1 : 0
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 30000
  port_range_max    = 32767
  remote_ip_prefix  = var.allow_remote_prefix
  security_group_id = local.security_group_id
}

resource "openstack_networking_port_v2" "mgmt" {
  name                  = var.name
  network_id            = var.network_id
  admin_state_up        = true
  security_group_ids    = concat([local.security_group_id], var.additional_security_group_ids)
  port_security_enabled = true

  fixed_ip {
    subnet_id = var.subnet_id
  }

}

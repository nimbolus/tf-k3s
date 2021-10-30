resource "openstack_networking_secgroup_v2" "k3s" {
  count       = var.security_group_id == null ? 1 : 0
  name        = var.security_group_name
  description = "allow k3s services"
}

locals {
  security_group_id = var.security_group_id == null ? openstack_networking_secgroup_v2.k3s[0].id : var.security_group_id
}

output "id" {
  value = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "internal_tcp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_group_id   = local.security_group_id
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "internal_udp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  remote_group_id   = local.security_group_id
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "internal_icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_group_id   = local.security_group_id
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.port_ssh
  port_range_max    = var.port_ssh
  remote_ip_prefix  = var.allow_remote_prefix
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "kubernetes_api" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.port_api
  port_range_max    = var.port_api
  remote_ip_prefix  = var.allow_remote_prefix
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "kubernetes_node_ports_tcp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.port_node_tcp_min
  port_range_max    = var.port_node_tcp_max
  remote_ip_prefix  = var.allow_remote_prefix
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "kubernetes_node_ports_udp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = var.port_node_udp_min
  port_range_max    = var.port_node_udp_max
  remote_ip_prefix  = var.allow_remote_prefix
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "internal_tcp_v6" {
  count = var.enable_ipv6 ? 1 : 0

  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "tcp"
  remote_group_id   = local.security_group_id
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "internal_udp_v6" {
  count = var.enable_ipv6 ? 1 : 0

  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "udp"
  remote_group_id   = local.security_group_id
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "internal_icmp_v6" {
  count = var.enable_ipv6 ? 1 : 0

  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "ipv6-icmp"
  remote_group_id   = local.security_group_id
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "ssh_v6" {
  count = var.enable_ipv6 ? 1 : 0

  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "tcp"
  port_range_min    = var.port_ssh
  port_range_max    = var.port_ssh
  remote_ip_prefix  = var.allow_remote_prefix_v6
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "kubernetes_api_v6" {
  count = var.enable_ipv6 ? 1 : 0

  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "tcp"
  port_range_min    = var.port_api
  port_range_max    = var.port_api
  remote_ip_prefix  = var.allow_remote_prefix_v6
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "kubernetes_node_ports_tcp_v6" {
  count = var.enable_ipv6 ? 1 : 0

  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "tcp"
  port_range_min    = var.port_node_tcp_min
  port_range_max    = var.port_node_tcp_max
  remote_ip_prefix  = var.allow_remote_prefix_v6
  security_group_id = local.security_group_id
}

resource "openstack_networking_secgroup_rule_v2" "kubernetes_node_ports_udp_v6" {
  count = var.enable_ipv6 ? 1 : 0

  direction         = "ingress"
  ethertype         = "IPv6"
  protocol          = "udp"
  port_range_min    = var.port_node_udp_min
  port_range_max    = var.port_node_udp_max
  remote_ip_prefix  = var.allow_remote_prefix_v6
  security_group_id = local.security_group_id
}

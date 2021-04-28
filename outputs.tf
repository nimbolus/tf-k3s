output "k3s_node_ip_address" {
  value = openstack_compute_instance_v2.k3s_node.network.0.fixed_ip_v4
}

output "k3s_url" {
  value = var.k3s_join ? var.k3s_url : "https://${openstack_compute_instance_v2.k3s_node.network.0.fixed_ip_v4}:6443"
}

output "security_group_id" {
  value = local.security_group_id
}

output "bootstrap_token_id" {
  value = var.bootstrap_token_id
}

output "bootstrap_token_secret" {
  value     = var.bootstrap_token_secret
  sensitive = true
}

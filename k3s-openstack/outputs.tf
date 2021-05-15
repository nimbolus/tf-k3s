output "node_ip" {
  value = openstack_compute_instance_v2.node.network.0.fixed_ip_v4
}

output "security_group_id" {
  value = local.security_group_id
}

output "k3s_url" {
  value = module.k3s.k3s_url
}

output "bootstrap_token_id" {
  value = module.k3s.bootstrap_token_id
}

output "bootstrap_token_secret" {
  value     = module.k3s.bootstrap_token_secret
  sensitive = true
}

output "ca_crt" {
  value = module.k3s.ca_crt
}

output "kubeconfig" {
  sensitive = true
  value     = module.k3s.kubeconfig
}

output "user_data" {
  sensitive = true
  value     = module.k3s.user_data
}

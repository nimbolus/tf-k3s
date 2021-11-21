output "node_ip" {
  value = local.node_ip
}

output "node_ipv6" {
  value = local.node_ipv6
}

output "node_external_ip" {
  value = local.node_external_ip
}

output "k3s_url" {
  value = local.k3s_url
}

output "k3s_external_url" {
  value = local.k3s_external_url
}

output "user_data" {
  value     = module.k3s.user_data
  sensitive = true
}

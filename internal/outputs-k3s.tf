output "node_ip" {
  value = local.node_ip
}

output "k3s_url" {
  value = module.k3s.k3s_url
}

output "user_data" {
  value     = module.k3s.user_data
  sensitive = true
}

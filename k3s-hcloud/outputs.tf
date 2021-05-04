output "node_ip" {
  value = hcloud_server.node.ipv4_address
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

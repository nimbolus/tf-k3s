locals {
  k3s_url = var.k3s_join_existing ? var.k3s_url : "https://${var.k3s_ip}:6443"
}

output "k3s_url" {
  value = local.k3s_url
}

output "user_data" {
  value = templatefile("${path.module}/cloud-init/k3s.yml", {
    custom_cloud_config_write_files = var.custom_cloud_config_write_files
    custom_cloud_config_runcmd      = var.custom_cloud_config_runcmd
    k3s_config = base64encode(<<EOT
K3S_TOKEN=${var.cluster_token}
K3S_URL=${var.k3s_url}
INSTALL_K3S_EXEC="${var.install_k3s_exec}"
EOT
    )
    k3s_bootstrap_manifest_b64 = var.bootstrap_token_id != null ? base64encode(
      templatefile("${path.module}/cloud-init/bootstrap-token.yaml", {
        token_id     = var.bootstrap_token_id
        token_secret = var.bootstrap_token_secret
    })) : ""
  })
  sensitive = true
}

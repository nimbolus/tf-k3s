locals {
  k3s_bootstrap_manifest_b64 = var.bootstrap_token_id != null ? base64encode(
    templatefile("${path.module}/cloud-init/bootstrap-token.yaml", {
      token_id     = var.bootstrap_token_id
      token_secret = var.bootstrap_token_secret
  })) : ""
}

output "user_data" {
  value = templatefile("${path.module}/cloud-init/k3s.yml", {
    custom_cloud_config_write_files = var.custom_cloud_config_write_files
    custom_cloud_config_runcmd      = var.custom_cloud_config_runcmd
    ip                              = var.k3s_ip
    external_ip                     = var.k3s_external_ip
    persistent_volume_dev           = var.persistent_volume_dev
    k3s_config = base64encode(<<-EOT
      K3S_TOKEN=${var.cluster_token}
      K3S_URL=${var.k3s_url}
      INSTALL_K3S_EXEC="${join(" ", var.k3s_args)}"
      %{ if var.k3s_version != null ~}
      INSTALL_K3S_VERSION=${var.k3s_version}
      %{ endif ~}
      EOT
    )
    k3s_bootstrap_manifest_b64 = local.k3s_bootstrap_manifest_b64
    cni_plugins_version        = var.cni_plugins_version
  })
  sensitive = true
}

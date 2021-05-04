output "user_data" {
  value = templatefile("${path.module}/cloud-init/k3s.yml", {
    custom_cloud_config_write_files = var.custom_cloud_config_write_files
    custom_cloud_config_runcmd      = var.custom_cloud_config_runcmd
    k3s_config = base64encode(<<EOF
K3S_TOKEN=${var.k3s_token}
K3S_URL=${var.k3s_url}
INSTALL_K3S_EXEC="${var.install_k3s_exec}"
EOF
    )
    k3s_bootstrap_manifest_b64 = var.bootstrap_token_id != "" ? base64encode(
      templatefile("${path.module}/cloud-init/bootstrap-token.yaml", {
        token_id     = var.bootstrap_token_id
        token_secret = var.bootstrap_token_secret
    })) : ""
  })
  sensitive = true
}

locals {
  k3s_url = var.k3s_join_existing ? var.k3s_url : "https://${var.k3s_ip}:6443"
}
output "k3s_url" {
  value = local.k3s_url
}

output "bootstrap_token_id" {
  value = var.bootstrap_token_id
}

output "bootstrap_token_secret" {
  value     = var.bootstrap_token_secret
  sensitive = true
}

data "shell_script" "ca" {
  count = var.k3s_join_existing ? 0 : 1
  lifecycle_commands {
    read = <<-EOF
until kubectl --server ${local.k3s_url} --token ${var.bootstrap_token_id}.${var.bootstrap_token_secret} --insecure-skip-tls-verify get secret -o jsonpath="{.items[?(@.type==\"kubernetes.io/service-account-token\")].data}" ; do sleep 1; done
EOF
  }
}

output "ca_crt" {
  value = var.k3s_join_existing ? "" : data.shell_script.ca[0].output["ca.crt"]
}

output "kubeconfig" {
  sensitive = true
  value     = var.k3s_join_existing ? "" : <<EOF
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${data.shell_script.ca[0].output["ca.crt"]}
    server: ${local.k3s_url}
  name: default
contexts:
- context:
    cluster: default
    user: default
  name: default
current-context: default
kind: Config
preferences: {}
users:
- name: default
  user:
    token: ${var.bootstrap_token_id}.${var.bootstrap_token_secret}
EOF
}

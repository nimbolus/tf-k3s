data "shell_script" "ca" {
  lifecycle_commands {
    read = <<-EOT
timeout "${var.ca_shell_script_timeout}" bash -c ' \
  until \
    kubectl --server "${var.k3s_url}" --insecure-skip-tls-verify --token "${var.token}" --namespace default \
      get secret -o jsonpath="{.items[?(@.type==\"kubernetes.io/service-account-token\")].data}" | grep "ca.crt"
  do
    sleep 1
  done'
EOT
  }
}

output "ca_crt" {
  value = base64decode(data.shell_script.ca.output["ca.crt"])
}

output "kubeconfig" {
  sensitive = true
  value     = <<EOT
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${data.shell_script.ca.output["ca.crt"]}
    server: ${var.k3s_url}
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
    token: ${var.token}
EOT
}

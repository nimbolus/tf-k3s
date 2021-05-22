resource "random_password" "cluster_token" {
  length  = 64
  special = false
}

resource "random_password" "bootstrap_token_id" {
  length  = 6
  upper   = false
  special = false
}

resource "random_password" "bootstrap_token_secret" {
  length  = 16
  upper   = false
  special = false
}

module "secgroup" {
  source = "../../k3s-openstack/security-group"
}

locals {
  token = "${random_password.bootstrap_token_id.result}.${random_password.bootstrap_token_secret.result}"
}

module "bootstrap_auth" {
  source = "../../bootstrap-auth"

  k3s_url = module.server1.k3s_url
  token   = local.token
}

module "server1" {
  source = "../../k3s-openstack"

  name               = "k3s-server-1"
  image_name         = "ubuntu-20.04-ansible"
  flavor_name        = "m1.small"
  availability_zone  = "ex"
  keypair_name       = "example-keypair"
  network_id         = "example-id"
  subnet_id          = "example-id"
  security_group_ids = [module.secgroup.id]

  cluster_token          = random_password.cluster_token.result
  install_k3s_exec       = "server --cluster-init --kube-apiserver-arg=\"enable-bootstrap-token-auth\" --node-label az=ex"
  bootstrap_token_id     = random_password.bootstrap_token_id.result
  bootstrap_token_secret = random_password.bootstrap_token_secret.result
}

module "servers" {
  source = "../../k3s-openstack"

  count = 2

  name               = "k3s-server-${count.index + 2}"
  image_name         = "ubuntu-20.04-ansible"
  flavor_name        = "m1.small"
  availability_zone  = "ex"
  keypair_name       = "example-keypair"
  network_id         = "example-id"
  subnet_id          = "example-id"
  security_group_ids = [module.secgroup.id]

  k3s_join_existing = true
  k3s_url           = module.server1.k3s_url
  cluster_token     = random_password.cluster_token.result
  install_k3s_exec  = "server --kube-apiserver-arg=\"enable-bootstrap-token-auth\" --node-label az=ex"
}

module "agents" {
  source = "../../k3s-openstack"

  count = 3

  name               = "k3s-agent-${count.index + 1}"
  image_name         = "ubuntu-20.04-ansible"
  flavor_name        = "m1.small"
  availability_zone  = "ex"
  keypair_name       = "example-keypair"
  network_id         = "example-id"
  subnet_id          = "example-id"
  security_group_ids = [module.secgroup.id]

  k3s_join_existing = true
  k3s_url           = module.server1.k3s_url
  cluster_token     = random_password.cluster_token.result
  install_k3s_exec  = "agent --node-label az=ex"
}

output "k3s_url" {
  value = module.server1.k3s_url
}

output "token" {
  value     = local.token
  sensitive = true
}

output "ca_crt" {
  value = module.bootstrap_auth.ca_crt
}

output "kubeconfig" {
  value     = module.bootstrap_auth.kubeconfig
  sensitive = true
}

provider "kubernetes" {
  host                   = module.server1.k3s_url
  token                  = local.token
  cluster_ca_certificate = module.bootstrap_auth.ca_crt
}

resource "random_password" "ha_cluster_token" {
  length  = 64
  special = false
}

resource "random_password" "ha_bootstrap_token_id" {
  length  = 6
  special = false
}

resource "random_password" "ha_bootstrap_token_secret" {
  length  = 16
  special = false
}

module "master1" {
  source = "github.com/nimbolus/tf-k3s/k3s-openstack"

  name              = "k3s-master1"
  image_name        = "ubuntu-20.04"
  flavor_name       = "m1.small"
  availability_zone = "ex1"
  keypair_name      = "example-keypair"
  network_id        = "example-id"
  subnet_id         = "example-id"

  k3s_token              = random_password.ha_cluster_token.result
  install_k3s_exec       = "server --cluster-init --kube-apiserver-arg=\"enable-bootstrap-token-auth\" --node-label az=ex1"
  bootstrap_token_id     = nonsensitive(random_password.ha_bootstrap_token_id.result)
  bootstrap_token_secret = random_password.ha_bootstrap_token_secret.result
}

output "k3s_url" {
  value = module.master1.k3s_url
}

resource "local_file" "kubeconfig" {
  filename = "kubeconfig.yaml"
  content  = module.master1.kubeconfig
}

module "master2" {
  source = "github.com/nimbolus/tf-k3s/k3s-openstack"

  name              = "k3s-master2"
  image_name        = "ubuntu-20.04"
  flavor_name       = "m1.small"
  availability_zone = "ex1"
  keypair_name      = "example-keypair"
  network_id        = "example-id"
  subnet_id         = "example-id"
  security_group_id = module.master1.security_group_id

  k3s_join_existing = true
  k3s_url           = module.master1.k3s_url
  k3s_token         = random_password.ha_cluster_token.result
  install_k3s_exec  = "server --kube-apiserver-arg=\"enable-bootstrap-token-auth\" --node-label az=ex1"
}

module "master3" {
  source = "github.com/nimbolus/tf-k3s/k3s-openstack"

  name              = "k3s-master3"
  image_name        = "ubuntu-20.04"
  flavor_name       = "m1.small"
  availability_zone = "ex1"
  keypair_name      = "example-keypair"
  network_id        = "example-id"
  subnet_id         = "example-id"
  security_group_id = module.master1.security_group_id

  k3s_join_existing = true
  k3s_url           = module.master1.k3s_url
  k3s_token         = random_password.ha_cluster_token.result
  install_k3s_exec  = "server --kube-apiserver-arg=\"enable-bootstrap-token-auth\" --node-label az=ex1"
}

module "worker1" {
  source = "github.com/nimbolus/tf-k3s/k3s-openstack"

  name              = "k3s-worker1"
  image_name        = "ubuntu-20.04"
  flavor_name       = "m1.small"
  availability_zone = "ex1"
  keypair_name      = "example-keypair"
  network_id        = "example-id"
  subnet_id         = "example-id"
  security_group_id = module.master1.security_group_id

  k3s_join_existing = true
  k3s_url           = module.master1.k3s_url
  k3s_token         = random_password.ha_cluster_token.result
  install_k3s_exec  = "agent --node-label az=ex1"
}

provider "kubernetes" {
  host                   = module.master1.k3s_url
  token                  = "${module.master1.bootstrap_token_id}.${module.master1.bootstrap_token_secret}"
  cluster_ca_certificate = base64decode(module.master1.ca_crt)
}

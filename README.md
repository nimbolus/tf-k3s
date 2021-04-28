# terraform module - k3s

Sets up a k3s instance on top of OpenStack, which can be used multiple times to create a cluster.

For an overview of the options, checkout [variables.tf](./variables.tf)

## Examples

Note that network, subnet and key pair needs to be created beforehand.

### Single Master
```hcl
resource "random_password" "cluster_token" {
  length  = 64
  special = false
}

module "k3s_master" {
  source = "github.com/nimbolus/tf-k3s"

  name              = "k3s-master"
  image_name        = "ubuntu-20.04"
  flavor_name       = "m1.small"
  availability_zone = "ex1"
  keypair_name      = "example-keypair"
  network_id        = data.example_network.id
  subnet_id         = data.example_subnet.id
  k3s_token         = random_password.cluster_token.result
  install_k3s_exec  = "server --disable traefik --node-label az=ex1"
}

module "k3s_worker" {
  source = "github.com/nimbolus/tf-k3s"

  name              = "k3s-worker"
  image_name        = "ubuntu-20.04"
  flavor_name       = "m1.small"
  availability_zone = "ex1"
  keypair_name      = "example-keypair"
  network_id        = data.example_network.id
  subnet_id         = data.example_subnet.id
  k3s_join          = true
  k3s_url           = module.k3s_master.k3s_url
  k3s_token         = random_password.cluster_token.result
  install_k3s_exec  = "agent --node-label az=ex1"
}
```

### HA-Master and bootstrap token
```hcl
resource "random_password" "cluster_token" {
  length  = 64
  special = false
}

resource "random_password" "bootstrap_token_id" {
  length  = 6
  special = false
}

resource "random_password" "bootstrap_token_secret" {
  length  = 16
  special = false
}

module "k3s_master1" {
  source = "github.com/nimbolus/tf-k3s"

  name                   = "k3s-master1"
  image_name             = "ubuntu-20.04"
  flavor_name            = "m1.small"
  availability_zone      = "ex1"
  keypair_name           = "example-keypair"
  network_id             = data.example_network.id
  subnet_id              = data.example_subnet.id
  k3s_token              = random_password.cluster_token.result
  install_k3s_exec       = "server --cluster-init --kube-apiserver-arg=\"enable-bootstrap-token-auth\" --node-label az=ex1"
  bootstrap_token_id     = nonsensitive(random_password.bootstrap_token_id.result)
  bootstrap_token_secret = random_password.bootstrap_token_secret.result
}

module "k3s_master2" {
  source = "github.com/nimbolus/tf-k3s"

  name              = "k3s-master2"
  image_name        = "ubuntu-20.04"
  flavor_name       = "m1.small"
  availability_zone = "ex1"
  keypair_name      = "example-keypair"
  network_id        = data.example_network.id
  subnet_id         = data.example_subnet.id
  security_group_id = module.k3s_master1.security_group_id
  k3s_join          = true
  k3s_url           = module.k3s_master1.k3s_url
  k3s_token         = random_password.cluster_token.result
  install_k3s_exec  = "server --server ${module.k3s_master1.k3s_url} --kube-apiserver-arg=\"enable-bootstrap-token-auth\" --node-label az=ex1"
}

module "k3s_master3" {
  source = "github.com/nimbolus/tf-k3s"

  name              = "k3s-master3"
  image_name        = "ubuntu-20.04"
  flavor_name       = "m1.small"
  availability_zone = "ex1"
  keypair_name      = "example-keypair"
  network_id        = data.example_network.id
  subnet_id         = data.example_subnet.id
  security_group_id = module.k3s_master1.security_group_id
  k3s_join          = true
  k3s_url           = module.k3s_master1.k3s_url
  k3s_token         = random_password.cluster_token.result
  install_k3s_exec  = "server --server ${module.k3s_master1.k3s_url} --kube-apiserver-arg=\"enable-bootstrap-token-auth\" --node-label az=ex1"
}

module "k3s_worker1" {
  source = "github.com/nimbolus/tf-k3s"

  name              = "k3s-worker1"
  image_name        = "ubuntu-20.04"
  flavor_name       = "m1.small"
  availability_zone = "ex1"
  keypair_name      = "example-keypair"
  network_id        = data.example_network.id
  subnet_id         = data.example_subnet.id
  security_group_id = module.k3s_master1.security_group_id
  k3s_join          = true
  k3s_url           = module.k3s_master1.k3s_url
  k3s_token         = random_password.cluster_token.result
  install_k3s_exec  = "agent --node-label az=ex1"
}

output "kubeconfig" {
  sensitive = true
  value     = <<EOF
apiVersion: v1
clusters:
- cluster:
    server: ${module.k3s_master1.k3s_url}
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
    token: ${module.k3s_master1.bootstrap_token_id}.${module.k3s_master1.bootstrap_token_secret}
EOF
}
```

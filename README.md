# terraform module - k3s

Sets up a k3s instance on top of OpenStack, which can be used multiple times to create a cluster.

For an overview of the options, checkout [variables.tf](./variables.tf)

## Example

Note that network, subnet and key pair needs to be created beforehand.

```hcl
resource "random_password" "monitoring_cluster_token" {
  length  = 64
  special = false
}

module "test_master" {
  source = "github.com/nimbolus/tf-k3s"

  name              = "test-master"
  image_name        = "ubuntu-20.04"
  flavor_name       = "m1.small"
  availability_zone = "ex1"
  keypair_name      = "example-keypair"
  network_name      = "example-network"
  subnet_name       = "example-subnet"
  k3s_token         = random_password.monitoring_cluster_token.result
  install_k3s_exec  = "--disable traefik --node-label az=ex1"
}

module "test_master" {
  source = "github.com/nimbolus/tf-k3s"

  name              = "test-node"
  image_name        = "ubuntu-20.04"
  flavor_name       = "m1.small"
  availability_zone = "ex1"
  keypair_name      = "example-keypair"
  network_name      = "example-network"
  subnet_name       = "example-subnet"
  k3s_master        = false
  k3s_url           = module.test_master.k3s_url
  k3s_token         = random_password.monitoring_cluster_token.result
  install_k3s_exec  = "--node-label az=ex1"
}
```

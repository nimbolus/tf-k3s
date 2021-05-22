# terraform modules for k3s

Provisions k3s nodes and is able to build a cluster from multiple nodes.

You can use the [k3s](./k3s) module to template the necessary cloudinit files for creating a k3s cluster node.
Modules for [OpenStack](./k3s-openstack) and [Hetzner hcloud](./k3s-hcloud) that bundle all necessary resources are available.

## Supported Cloud Providers
- OpenStack
- Hetzner Cloud (hcloud)

## Modules
### k3s
This module provides the templating of the user_data for use with cloud-init.

### k3s-openstack
With this module a single K3s node can be deployed with OpenStack. It internally uses the k3s module. Depending on the supplied parameters the node will initialize a new cluster or join an existing cluster as a server or agent.

### k3s-openstack/security-group
The necessary security-group for the K3s cluster can be deployed with this module.

### k3s-hcloud
With this module a single K3s node can be deployed with hcloud. It internally uses the k3s module. Depending on the supplied parameters the node will initialize a new cluster or join an existing cluster as a server or agent.

### bootstrap-auth
To access the cluster an optional bootstrap token can be installed on the cluster. To install the token specify the parameters `bootstrap_token_id` and `bootstrap_token_secret` on the server that initializes the cluster.
For ease of use this module can be used to retrieve the CA certificate from the cluster. The module also outputs a kubeconfig with the bootstrap token.
Please keep in mind that the connection to retrieve the CA certificate cannot be secure as the certificate cannot be verified. Additionally this module makes use of the [scottwinkler/shell](https://github.com/scottwinkler/terraform-provider-shell) provider. Please make sure only supply trusted values to the module.

## Examples
Note that network, subnet and key pair need to be created beforehand.

- [basic](examples/basic/main.tf): basic usage of the k3s module with one server and one agent node
- [basic-hcloud](examples/basic-hcloud/main.tf): Single Master and Worker with hcloud
- [ha-openstack](examples/ha-openstack/main.tf): HA-Master and bootstrap token with OpenStack

## Requirements

MacOS users need to install `coreutils` for the `timeout` command:

```sh
brew install coreutils
```

# terraform modules for k3s

Provisions k3s nodes and is able to build a cluster from multiple nodes.

You can use the [k3s](./k3s) module to template the necessary cloudinit files for creating a k3s cluster node.
Modules for [OpenStack](./k3s-openstack) and [Hetzner hcloud](./k3s-hcloud) that bundle all necessary resources are available.

## Examples

Note that network, subnet and key pair needs to be created beforehand.

- [Simple Module for templating cloudinit user_data](./example-simple.tf)
- [HA-Master and bootstrap token with OpenStack](./example-ha-openstack.tf)
- [Single Master and Worker with hcloud](./example-simple-hcloud.tf)

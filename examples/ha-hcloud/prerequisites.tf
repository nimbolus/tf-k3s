resource "hcloud_network" "k3s" {
  name     = "k3s"
  ip_range = "10.0.0.0/8"
}

resource "hcloud_network_subnet" "k3s" {
  network_id   = hcloud_network.k3s.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}

resource "tls_private_key" "k3s" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "hcloud_ssh_key" "k3s" {
  name       = "k3s"
  public_key = tls_private_key.k3s.public_key_openssh
}

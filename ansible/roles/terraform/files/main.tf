# Required by Terraform 0.13+
terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.3.0"
    }
  }
}

#### Digital Ocean ####

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_ssh_key" "default" {
  name       = "Homelab Server (created with Terraform)"
  public_key = file("${var.openssh_keypair_path}.pub")
}

#### Provision ####

resource "digitalocean_droplet" "bastion2" {
  image = "ubuntu-18-04-x64"
  name = "bastion2"
  region = "sfo2"
  size = "s-1vcpu-1gb"
  ssh_keys = [
    digitalocean_ssh_key.default.fingerprint
  ]

  connection {
    host = digitalocean_droplet.bastion2.ipv4_address
    user = "root"
    type = "ssh"
    private_key = file(var.openssh_keypair_path)
    timeout = "1m"
  }
}

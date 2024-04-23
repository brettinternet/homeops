terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~>2.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~>3"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~>1.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~>2"
    }
  }
}

data "sops_file" "digitalocean_secrets" {
  source_file = "secret.sops.yaml"
}

provider "digitalocean" {
  token = data.sops_file.digitalocean_secrets.data["digitalocean_token"]
}

resource "digitalocean_ssh_key" "default" {
  name       = "${var.ssh_key_name} (created with Terraform)"
  public_key = file("${var.openssh_keypair_path}.pub")
}

resource "digitalocean_droplet" "bastion" {
  image  = var.droplet_image
  name   = "bastion"
  region = var.droplet_region
  size   = var.droplet_size
  ssh_keys = [
    digitalocean_ssh_key.default.fingerprint
  ]

  connection {
    host        = digitalocean_droplet.bastion.ipv4_address
    user        = "root"
    type        = "ssh"
    private_key = file(var.openssh_keypair_path)
    timeout     = "1m"
  }
}

resource "local_file" "host_vars" {
  filename = var.BASTION_HOST_VARS_PATH
  content = templatefile(
    "host_vars.tpl",
    {
      ipv4_address       = digitalocean_droplet.bastion.ipv4_address
      dns_address        = data.sops_file.digitalocean_secrets.data["dns_address"]
      peers              = data.sops_file.digitalocean_secrets.data["peers"]
      cloudflare_api_key = data.sops_file.digitalocean_secrets.data["cloudflare_api_key"]
      cloudflare_zone    = data.sops_file.digitalocean_secrets.data["cloudflare_zone"]
    }
  )

  provisioner "local-exec" {
    command = "sops --encrypt --in-place ${var.BASTION_HOST_VARS_PATH}"
  }
}

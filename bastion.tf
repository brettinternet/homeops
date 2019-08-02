#### Variables ####

variable "do_token" {}
variable "pub_key" {
  default = "~/.ssh/id_rsa.pub"
}
variable "pvt_key" {
  default = "~/.ssh/id_rsa"
}
variable "wireguard_port" {
  default = "51820"
}
variable "wireguard_client_pub_key" {
  default = ""
}

#### Digital Ocean ####

provider "digitalocean" {
  token = "${ var.do_token }"
}

resource "digitalocean_ssh_key" "default" {
  name       = "Homelab Server (managed via Terraform)"
  public_key = "${file(var.pub_key)}"
}

#### Setup ####

resource "digitalocean_droplet" "bastion" {
  image = "ubuntu-18-04-x64"
  name = "bastion"
  region = "sfo2"
  size = "s-1vcpu-1gb"
  ssh_keys = [
    "${digitalocean_ssh_key.default.fingerprint}"
  ]

  connection {
    host = "${digitalocean_droplet.bastion.ipv4_address}"
    user = "root"
    type = "ssh"
    private_key = "${file(var.pvt_key)}"
    timeout = "1m"
  }

  provisioner "file" {
    source      = "scripts/wireguard_install.sh"
    destination = "/tmp/wireguard_install.sh"
  }

  provisioner "file" {
    source      = "scripts/vpn_setup.sh"
    destination = "/tmp/vpn_setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/vpn_setup.sh",
      "/tmp/vpn_setup.sh ${var.wireguard_port} ${var.wireguard_client_pub_key}",
    ]
  }

  provisioner "local-exec" {
    command = <<CMD
      scp \
        -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        -i ${var.pvt_key} \
        root@${digitalocean_droplet.bastion.ipv4_address}:/tmp/wg0-client.conf .
    CMD
  }
}
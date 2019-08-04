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
    source      = "scripts/wireguard"
    destination = "/root"
  }

  provisioner "remote-exec" {
    inline = [
      "find /root/wireguard/ -type f -iname \"*.sh\" -exec chmod +x {} \\;",
      "PORT=${var.wireguard_port} /root/wireguard/install.sh",
    ]
  }

  provisioner "local-exec" {
    command = <<CMD
      scp \
        -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        -i ${var.pvt_key} \
        root@${digitalocean_droplet.bastion.ipv4_address}:/root/wireguard/wg0-client.conf \
        /etc/wireguard/wg0.conf
    CMD
  }

  provisioner "local-exec" {
    command = "systemctl is-active --quiet wg-quick@wg0 || systemctl start wg-quick@wg0"
  }
}
variable "do_token" {
  description = "Digital Ocean token (https://www.digitalocean.com/docs/apis-clis/api/create-personal-access-token/)"
}

variable "openssh_keypair_path" {
  default = "~/.ssh/id_rsa"
  description = "Directory containing the public and private key. The file containing the public key will have the extension .pub."
}

variable "ssh_key_name" {
  default = "Homelab Server"
}

# Get image slug by selecting a distribution on https://cloud.digitalocean.com/droplets/new
variable "droplet_image" {
  default = "debian-10-x64"
}

variable "droplet_region" {
  default = "sfo2"
}

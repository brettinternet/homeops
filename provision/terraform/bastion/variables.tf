### SSH ###
variable "openssh_keypair_path" {
  type        = string
  default     = "~/.ssh/id_rsa"
  description = "Directory containing the public and private key. The file containing the public key will have the extension .pub."
}

variable "ssh_key_name" {
  type    = string
  default = "Homelab Server"
}

### Digital Ocean ###
# Get image slug by selecting a distribution on https://cloud.digitalocean.com/droplets/new
variable "droplet_image" {
  type    = string
  default = "debian-11-x64"
}

variable "droplet_region" {
  type    = string
  default = "sfo3"
}

# https://docs.digitalocean.com/reference/api/api-reference/#operation/sizes_list
variable "droplet_size" {
  type    = string
  default = "s-1vcpu-512mb-10gb"
}

variable "BASTION_HOST_VARS_PATH" {
  type    = string
  default = ""
}

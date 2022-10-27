# Managed by Terraform
kind: Secret
ansible_host: ${ipv4_address}
wg_peers: "{{ '${peers}'.split(',') }}"
compose_env_vars:
  - WIREGUARD_SERVERURL=${dns_address}
  - WIREGUARD_PEERS=${peers}
  - CLOUDFLARE_API_KEY=${cloudflare_api_key}
  - CLOUDFLARE_ZONE=${cloudflare_zone}
  - CLOUDFLARE_SUBDOMAIN=${dns_address}

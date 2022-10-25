# Managed by Terraform
kind: Secret
ansible_host: ${ipv4_address}
wg_peers: "{{ '${peers}'.split(',') }}"
wireguard_env_vars:
  - SERVERURL=${dns_address}
  - PEERS=${peers}

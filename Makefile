.PHONY: setup requirements install_podman

inventory.yml:
	@cp example.inventory.yml inventory.yml
	@printf "\x1B[01;93m✔ inventory.yml file created\n\x1B[0m"

podman_install_dir := ~/.ansible/collections/ansible_collections/containers/podman
install_podman: $(podman_install_dir)
$(podman_install_dir):
	@mkdir -p ~/.ansible/collections/ansible_collections/containers
	@git clone https://github.com/containers/ansible-podman-collections.git ~/.ansible/collections/ansible_collections/containers/podman

requirements: $(podman_install_dir)
	@ansible-galaxy install -r requirements.yml
	@printf "\x1B[01;93m✔ Galaxy collections installed\n\x1B[0m"

setup: inventory.yml requirements
	@printf "\x1B[01;93m✔ Setup complete\n\x1B[0m"

.PHONY: setup requirements install_podman lint

inventory.yml:
	@cp example.inventory.yml inventory.yml
	@printf "\x1B[01;93m✔ inventory.yml file created\n\x1B[0m"

podman_install_dir := ~/.ansible/collections/ansible_collections/containers/podman
install_podman: $(podman_install_dir)
$(podman_install_dir):
	@mkdir -p ~/.ansible/collections/ansible_collections/containers
	@git clone https://github.com/containers/ansible-podman-collections.git ~/.ansible/collections/ansible_collections/containers/podman

requirements: install_podman
	@ansible-galaxy install -r requirements.yml
	@printf "\x1B[01;93m✔ Galaxy collections installed\n\x1B[0m"

setup: inventory.yml requirements
	@printf "\x1B[01;93m✔ Setup complete\n\x1B[0m"

# ansible-lint:
# workon linux
# pip3 install -r requirements.txt
# shellcheck: https://github.com/koalaman/shellcheck/wiki/Recursiveness
lint:
	@ansible-lint --offline
	@find -type f \( -name '*.sh' -o -name '*.bash' -o -name '*.ksh' -o -name '*.bashrc' -o -name '*.bash_profile' -o -name '*.bash_login' -o -name '*.bash_logout' \) | xargs shellcheck

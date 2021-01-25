.PHONY: setup deploy

inventory:
	@cp example.inventory inventory
	@printf "\x1B[01;93m✔ inventory file created\n\x1B[0m"

vars/secret.yml:
	@cp vars/example.secret.yml vars/secret.yml
	@printf "\x1B[01;93m✔ vars/secret.yml created\n\x1B[0m"

setup: inventory vars/secret.yml
	@printf "\x1B[01;93m✔ Setup complete\n\x1B[0m"

ansible_facts:
	@cd ansible; \
		ansible-playbook facts.yml

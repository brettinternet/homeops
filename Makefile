.PHONY: setup galaxy ansible_facts

inventory.yml:
	@cp example.inventory.yml inventory.yml
	@printf "\x1B[01;93m✔ inventory.yml file created\n\x1B[0m"

vars/secret.yml:
	@cp vars/example.secret.yml vars/secret.yml
	@printf "\x1B[01;93m✔ vars/secret.yml created\n\x1B[0m"

setup: inventory.yml vars/secret.yml
	@printf "\x1B[01;93m✔ Setup complete\n\x1B[0m"

galaxy:
	@ansible-galaxy install kewlfft.aur

ansible_facts:
	@cd ansible; \
		ansible-playbook facts.yml

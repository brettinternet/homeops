.PHONY: setup deploy

ansible/inventory:
	@cp ansible/example.inventory ansible/inventory
	@printf "\x1B[01;93m✔ ansible/inventory file created\n\x1B[0m"

ansible/vars/secret.yml:
	@cp ansible/vars/example.secret.yml ansible/vars/secret.yml
	@printf "\x1B[01;93m✔ ansible/vars/secret.yml created\n\x1B[0m"

setup: ansible/inventory ansible/vars/secret.yml
	@printf "\x1B[01;93m✔ Setup complete\n\x1B[0m"

ansible_facts:
	@cd ansible; \
		ansible-playbook facts.yml

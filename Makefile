.PHONY: setup requirements

inventory.yml:
	@cp example.inventory.yml inventory.yml
	@printf "\x1B[01;93m✔ inventory.yml file created\n\x1B[0m"

vars/secret.yml:
	@cp vars/example.secret.yml vars/secret.yml
	@printf "\x1B[01;93m✔ vars/secret.yml created\n\x1B[0m"

requirements:
	@ansible-galaxy install -r requirements.yml
	@printf "\x1B[01;93m✔ Galaxy collections installed\n\x1B[0m"

setup: inventory.yml vars/secret.yml requirements
	@printf "\x1B[01;93m✔ Setup complete\n\x1B[0m"

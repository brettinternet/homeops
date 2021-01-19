.PHONY: setup deploy

ansible/inventory:
	@cp ansible/example.inventory ansible/inventory
	@printf "\x1B[01;93m✔ ansible/inventory file created\n\x1B[0m"

ansible/vars/secret.yml:
	@cp ansible/vars/example.secret.yml ansible/vars/secret.yml
	@printf "\x1B[01;93m✔ ansible/vars/secret.yml created\n\x1B[0m"

setup: ansible/inventory ansible/vars/secret.yml
	@printf "\x1B[01;93m✔ Setup complete\n\x1B[0m"

deploy:
	@printf "\x1B[01;93m✔ Deploy complete\n\x1B[0m"

.env:
	@cp example.env .env
	@printf "\x1B[01;93m✔ .env created\n\x1B[0m"

ansible_bastion:
	@cd ansible; \
		ansible-playbook bastion.yml

terraform_bastion_apply: .env
	@do_token=$(grep DO_TOKEN .env | xargs) TF_VAR_do_token=${do_token#*=} terraform apply -auto-approve terraform

terraform_bastion_destroy: .env
	@do_token=$(grep DO_TOKEN .env | xargs) TF_VAR_do_token=${do_token#*=} terraform destroy -auto-approve terraform

echo:
	@cd ansible; \
		ansible-playbook --version

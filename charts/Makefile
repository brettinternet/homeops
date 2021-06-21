.PHONY: build setup format lint

build: format lint homelab.png
	@printf "\x1B[01;93m✔ Build complete\n\x1B[0m"

setup:
	@poetry install
	@printf "\x1B[01;93m✔ Setup complete\n\x1B[0m"

format:
	@black -q .

lint:
	@bandit -qr .
	@flake8 .

.PHONY: homelab.png
homelab.png:
	@python homelab.py

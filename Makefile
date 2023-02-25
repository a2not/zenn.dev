.PHONY: article
article:
	npx zenn new:article

.PHONY: preview
preview:
	npx zenn preview

.PHONY: update-zenn-cli
update-zenn-cli:
	npm install zenn-cli@latest


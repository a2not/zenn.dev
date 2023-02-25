title=''

.PHONY: article
article:
	npx zenn new:article --slug $(title)

.PHONY: preview
preview:
	npx zenn preview

.PHONY: update-zenn-cli
update-zenn-cli:
	npm install zenn-cli@latest


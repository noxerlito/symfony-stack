# Executables (local)
DOCKER_COMP = docker compose

# Docker containers
PHP_CONT = $(DOCKER_COMP) exec php

# Executables
PHP      = $(PHP_CONT) php
COMPOSER = $(PHP_CONT) composer
SYMFONY  = $(PHP_CONT) bin/console
YARN = $(DOCKER_COMP) exec node yarn

# Misc
.DEFAULT_GOAL = help
.PHONY        = help build up start down logs sh composer vendor sf cc

# Executables: vendors
PHPUNIT       = $(PHP) vendor/bin/phpunit
PHPSTAN       = $(PHP) vendor/bin/phpstan
PHP_CS_FIXER  = $(PHP) vendor/bin/php-cs-fixer

## —— 🎵 🐳 The Symfony Docker Makefile 🐳 🎵 ——————————————————————————————————
help: ## Outputs this help screen
	@grep -E '(^[a-zA-Z0-9_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

## —— Docker 🐳 ————————————————————————————————————————————————————————————————
build: ## Builds the Docker images
	@$(DOCKER_COMP) build --pull --no-cache

up: ## Start the docker hub in detached mode (with logs)
	@$(DOCKER_COMP) up

upd: ## Start the docker hub in detached mode (no logs)
	@$(DOCKER_COMP) up --detach

start: build upd ## Build and start the containers

down: ## Stop the docker hub
	@$(DOCKER_COMP) down --remove-orphans

sh: ## Connect to the PHP FPM container
	@$(PHP_CONT) sh

## —— Composer 🧙 ——————————————————————————————————————————————————————————————
composer: ## Run composer, pass the parameter "c=" to run a given command, example: make composer c='req symfony/orm-pack'
	@$(eval c ?=)
	@$(COMPOSER) $(c)

vendor: ## Install vendors according to the current composer.lock file
vendor: c=install --prefer-dist --no-dev --no-progress --no-scripts --no-interaction
vendor: composer

## —— Symfony 🎵 ———————————————————————————————————————————————————————————————
sf: ## List all Symfony commands or pass the parameter "c=" to run a given command, example: make sf c=about
	@$(eval c ?=)
	@$(SYMFONY) $(c)

cc: c=c:c ## Clear the cache
cc: sf

fixtures: ## Load fixtures
	@$(SYMFONY) doctrine:fixtures:load

migrations: ## Generate migrations
	@$(SYMFONY) doctrine:migrations:diff --formatted

migrate: ## Load migrations
	@$(SYMFONY) doctrine:migrations:migrate

## —— Yarn  ———————————————————————————————————————————————————————————————
yarn: ## Pass the parameter "c=" to run a given command, example: make sf c=about
	@$(eval c ?=)
	@$(YARN) $(c)

## Webpack ———————————————————————————————————————————————————————————————————
watch: ## Start webpack
	@$(YARN) --cwd /srv/app watch

## —— Tests ✅ ————————————————————————————————————————————————————————————————
test: ## Unit Tests
	@$(PHPUNIT) --stop-on-failure

## —— Coding standards ✨ —————————————————————————————————————————————————————
stan: ## Run PHPStan
	@$(PHPSTAN) analyse -c phpstan.neon --memory-limit 1G

fix: ## Fix files with php-cs-fixer
	@$(PHP_CS_FIXER) fix --allow-risky=yes

twigcs: ## Check twig coding standards
	@(PHP) twigcs /tempates/

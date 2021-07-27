MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
PROJECT_PATH := $(patsubst %/,%,$(dir $(MKFILE_PATH)))
PROJECT = $(subst @,,$(notdir $(subst /workspace,,$(PROJECT_PATH))))

export PROJECT

TMP = tmp/capybara tmp/junit tmp/codeclimate coverage log/test.searchd.log

DB ?= mysql


RUBY_ENV += RUBY_GC_HEAP_INIT_SLOTS=479708
RUBY_ENV += RUBY_GC_HEAP_FREE_SLOTS=47431584
RUBY_ENV += RUBY_GC_HEAP_GROWTH_FACTOR=1.03
RUBY_ENV += RUBY_GC_HEAP_GROWTH_MAX_SLOTS=472324
RUBY_ENV += RUBY_GC_HEAP_OLDOBJECT_LIMIT_FACTOR=1.2
RUBY_ENV += RUBY_GC_MALLOC_LIMIT=40265318
RUBY_ENV += RUBY_GC_MALLOC_LIMIT_MAX=72477572
RUBY_ENV += RUBY_GC_MALLOC_LIMIT_GROWTH_FACTOR=1.32
RUBY_ENV += RUBY_GC_OLDMALLOC_LIMIT=40125988
RUBY_ENV += RUBY_GC_OLDMALLOC_LIMIT_MAX=72226778
RUBY_ENV += RUBY_GC_OLDMALLOC_LIMIT_GROWTH_FACTOR=1.2



default: all

## This image is private and cannot be accessed by another third party than redhat.com employees
## You will need to build your own image as instructed in https://github.com/oracle/docker-images/tree/master/OracleDatabase/SingleInstance
ORACLE_DB_IMAGE := quay.io/3scale/oracle:19.3.0-ee-ci-prebuilt

include wget.mk
include openshift.mk

.PHONY: assets bash build bundle clean database dev-setup dev-start dev-stop help oracle-database oracle-db-setup run schema yarn
.DEFAULT_GOAL := help

# From here on, only phony targets to manage docker compose
all: clean dev-start

assets: ## Create assets volumes
assets: yarn
assets: CMD = rake assets:precompile
yarn: ## Install JS dependencies
yarn: CMD = yarn install

run: ## Starts containers and runs command $(CMD) inside the container in a non-interactive shell
run: MASTER_PASSWORD ?= "p"
run: USER_PASSWORD ?= "p"
assets run yarn:
	@echo "======= Run target: $@ ======="
	@echo
	@docker-compose run -e MASTER_PASSWORD=$(MASTER_PASSWORD) -e USER_PASSWORD=$(USER_PASSWORD) --rm system $(CMD)

dev-setup: MASTER_PASSWORD ?= "p"
dev-setup: USER_PASSWORD ?= "p"
dev-setup: ## Makes the initial setup for the application ##
dev-setup: CMD=rake db:create db:deploy
dev-setup: database run

dev-start: ## Starts the application with all dependencies using Docker ##
dev-start: dev-setup assets
	@docker-compose up -d

dev-stop: ## Stops all started containers ##
dev-stop:
	@docker-compose stop

database:
	@docker-compose up --no-start
	@docker-compose start mysql
	@echo "===== Sleeping to wait for database readiness ====="
	sleep 20

bash: ## Opens up shell on the container
bash: dev-setup assets
	@echo
	@echo "======= Bash ======="
	@echo
	@docker-compose up -d
	@docker-compose exec system /bin/bash

build: ## Build the container image using one of the docker-compose file set by $(COMPOSE_FILE) env var
build:
	@DB=$(DB) docker-compose build system

clean: ## Remove all components and volumes
clean:
	-docker-compose down 2>/dev/null
	-docker volume rm $$(docker volume ls -q -f 'name=porta_') 2> /dev/null


oracle-db-setup: ## Creates databases in Oracle
oracle-db-setup: oracle-database
	MASTER_PASSWORD=p USER_PASSWORD=p ORACLE_SYSTEM_PASSWORD=threescalepass NLS_LANG='AMERICAN_AMERICA.UTF8' DATABASE_URL="oracle-enhanced://rails:railspass@127.0.0.1:1521/systempdb" bundle exec rake db:drop db:create db:setup

schema: ## Runs db schema migrations. Run this when you have changes to your database schema that you have added as new migrations.
schema: POSTGRES_DATABASE_URL ?= "postgresql://postgres:@localhost:5432/3scale_system_development"
schema:
	bundle exec rake db:migrate db:schema:dump
	MASTER_PASSWORD=p USER_PASSWORD=p ORACLE_SYSTEM_PASSWORD=threescalepass NLS_LANG='AMERICAN_AMERICA.UTF8' DATABASE_URL="oracle-enhanced://rails:railspass@127.0.0.1:1521/systempdb" bundle exec rake db:migrate db:schema:dump
	DATABASE_URL=$(POSTGRES_DATABASE_URL) bundle exec rake db:migrate

oracle-database: ## Starts Oracle database container
oracle-database: ORACLE_DATA_DIR ?= $(HOME)
oracle-database:
	[ "$(shell docker inspect -f '{{.State.Running}}' oracle-database 2>/dev/null)" = "true" ] || docker start oracle-database || docker run \
		--shm-size=6gb \
		--security-opt apparmor=docker-default \
		-p 1521:1521 -p 5500:5500 \
		--name oracle-database \
		-v $(ORACLE_DATA_DIR)/oracle-database:/opt/oracle/oradata \
		-e ORACLE_PDB=systempdb \
		-e ORACLE_SID=threescale \
		-e ORACLE_PWD=threescalepass \
		-e ORACLE_CHARACTERSET=AL32UTF8 \
		$(ORACLE_DB_IMAGE)

# Check http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help: ## Print this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

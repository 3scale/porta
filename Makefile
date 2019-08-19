MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
PROJECT_PATH := $(patsubst %/,%,$(dir $(MKFILE_PATH)))
PROJECT = $(subst @,,$(notdir $(subst /workspace,,$(PROJECT_PATH))))

export PROJECT

BUNDLE_GEMFILE ?= Gemfile

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

COMPOSE_PROJECT_NAME := $(PROJECT)
COMPOSE_FILE := docker-compose.yml
COMPOSE_TEST_FILE := docker-compose.test-$(DB).yml

## This image is private and cannot be accessed by another third party than redhat.com employees
## You will need to build your own image as instructed in https://github.com/oracle/docker-images/tree/master/OracleDatabase/SingleInstance
ORACLE_DB_IMAGE := quay.io/3scale/oracle:12.2.0.1-ee

include wget.mk
include openshift.mk

.PHONY: default all clean build test info docker test-run tmp-export run test-bash clean-cache clean-tmp compose help
.DEFAULT_GOAL := help

# From here on, only phony targets to manage docker compose
all: clean-tmp dev-setup dev-start

info: docker # Prints relevant environment info

docker: ## Prints docker version and info
	@echo
	@echo "======= Docker ======="
	@echo
	@docker version
	@echo
	@docker info
	@echo

#test: ## Runs tests inside container build environment
#test: COMPOSE_FILE = $(COMPOSE_TEST_FILE)
#test: $(DOCKER_COMPOSE) info
#	@echo
#	@echo "======= Tests ======="
#	@echo
#	$(MAKE) test-run tmp-export --keep-going

test-run: ## Runs test inside container
test-run: COMPOSE_FILE = $(COMPOSE_TEST_FILE)
test-run: $(DOCKER_COMPOSE) clean-tmp cache
	$(DOCKER_COMPOSE) run --name $(PROJECT)-build $(DOCKER_ENV) build $(CMD)

tmp-export: ## Copies files from inside docker container to local tmp folder.
tmp-export: IMAGE ?= $(PROJECT)-build
tmp-export: clean-tmp
	-@ $(foreach dir,$(TMP),docker cp $(IMAGE):/opt/system/$(dir) $(dir) 2>/dev/null;)

clean-tmp: ## Removes temporary files
	-@ $(foreach dir,$(TMP),rm -rf $(dir);)

run: ## Starts containers and runs command $(CMD) inside the container in a non-interactive shell
run: MASTER_PASSWORD ?= "p"
run: USER_PASSWORD ?= "p"
run:
	@echo "======= Run ======="
	@echo
	@docker-compose run -e MASTER_PASSWORD=$(MASTER_PASSWORD) -e USER_PASSWORD=$(USER_PASSWORD) --rm system $(CMD)

dev-setup: ## Makes the initial setup for the application ##
dev-setup: CMD=rake db:setup
dev-setup: run

dev-start: ## Starts the application with all dependencies using Docker ##
dev-start:
	@docker-compose up -d

dev-stop: ## Stops all started containers ##
dev-stop:
	@docker-compose stop

# bash: ## Opens up shell on the container
bash:
	@echo
	@echo "======= Bash ======="
	@echo
	@docker-compose up -d
	@docker-compose exec system /bin/bash

build: ## Build the container image using one of the docker-compose file set by $(COMPOSE_FILE) env var
build: COMPOSE_FILE = $(COMPOSE_TEST_FILE)
build: $(DOCKER_COMPOSE)
	$(DOCKER_COMPOSE) build

clean: ## Cleaning docker-compose services
clean: SERVICES ?= database build
ifeq ($(CACHE),false)
clean: clean-cache
endif
clean: COMPOSE_FILE = $(COMPOSE_TEST_FILE)
clean: $(DOCKER_COMPOSE)
	- $(DOCKER_COMPOSE) stop $(SERVICES)
	- $(DOCKER_COMPOSE) rm --force -v $(SERVICES)
	- docker rm --force --volumes $(PROJECT)-build $(PROJECT)-build-run 2> /dev/null
	- $(foreach service,$(SERVICES),docker rm --force --volumes $(PROJECT)-$(service) 2> /dev/null;)

clean-cache: ## Only clean up the cache container
clean-cache: export SERVICES = cache
clean-cache: export CACHE = true
clean-cache:
	$(MAKE) clean

bundle: ## Installs dependencies using bundler. Run this after you make some changes to Gemfile.
bundle: gemfiles/prod/Gemfile Gemfile
	BUNDLE_GEMFILE=Gemfile bundle lock
	cp Gemfile.lock gemfiles/prod/Gemfile.lock
	BUNDLE_GEMFILE=gemfiles/prod/Gemfile bundle lock

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
		-p 1521:1521 -p 5500:5500 \
		--name oracle-database \
		-e ORACLE_PDB=systempdb \
		-e ORACLE_SID=threescale \
		-e ORACLE_PWD=threescalepass \
		-e ORACLE_CHARACTERSET=AL32UTF8 \
		-v $(ORACLE_DATA_DIR)/oracle-database:/opt/oracle/oradata \
		-v $(PWD)/script/oracle:/opt/oracle/scripts/setup \
		quay.io/3scale/oracle:12.2.0.1-ee

# Check http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help: ## Print this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

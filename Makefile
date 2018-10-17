MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
PROJECT_PATH := $(patsubst %/,%,$(dir $(MKFILE_PATH)))
PROJECT = $(subst @,,$(notdir $(subst /workspace,,$(PROJECT_PATH))))

export PROJECT

BUNDLE_GEMFILE ?= Gemfile

TMP = tmp/capybara tmp/junit tmp/codeclimate coverage log/test.searchd.log tmp/jspm

DB ?= mysql

JENKINS_ENV = JENKINS_URL BUILD_TAG BUILD_NUMBER BUILD_URL
JENKINS_ENV += GIT_BRANCH GIT_COMMIT GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_COMMITTER_EMAIL GIT_COMMITTER_NAME PERCY_ENABLE
JENKINS_ENV += BUNDLE_GEMFILE BUNDLE_GEMS__CONTRIBSYS__COM
JENKINS_ENV += PARALLEL_TEST_PROCESSORS
JENKINS_ENV += CIRCLE_BUILD_NUM \
			   CIRCLE_BUILD_URL \
			   CIRCLE_COMPARE_URL \
			   CIRCLE_INTERNAL_CONFIG \
			   CIRCLE_INTERNAL_SCRATCH \
			   CIRCLE_INTERNAL_TASK_DATA \
			   CIRCLE_JOB \
			   CIRCLE_JOB \
			   CIRCLE_NODE_INDEX \
			   CIRCLE_NODE_TOTAL \
			   CIRCLE_PR_NUMBER \
			   CIRCLE_PREVIOUS_BUILD_NUM \
			   CIRCLE_PROJECT_REPONAME \
			   CIRCLE_PROJECT_USERNAME \
			   CIRCLE_REPOSITORY_URL \
			   CIRCLE_SHA1 \
			   CIRCLE_SHELL_ENV \
			   CIRCLE_STAGE \
			   CIRCLE_STAGE \
			   CIRCLE_USERNAME \
			   CIRCLE_WORKFLOW_ID \
			   CIRCLE_WORKFLOW_JOB_ID \
			   CIRCLE_WORKFLOW_WORKSPACE_ID \
			   CIRCLE_WORKING_DIRECTORY \
			   CIRCLECI \
			   CIRCLECI_PKG_DIR

JENKINS_ENV += MULTIJOB_KIND PERCY_ENABLE PERCY_TOKEN COVERAGE PROXY_ENABLED
JENKINS_ENV += DB

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
include docker-compose.mk
include openshift.mk

.PHONY: default all clean build test info jenkins-env docker test-run tmp-export run test-bash clean-cache clean-tmp compose help
.DEFAULT_GOAL := help

# From here on, only phony targets to manage docker compose
all: clean clean-tmp build test ## Cleans environment, builds docker image and runs tests

info: docker jenkins-env # Prints relevant environment info

jenkins-env: ## Prints env vars
	@echo
	@echo "======= Jenkins environment ======="
	@echo
	@env
	@echo

docker: ## Prints docker version and info
	@echo
	@echo "======= Docker ======="
	@echo
	@docker version
	@echo
	@docker info
	@echo

test: ## Runs tests inside container build environment
test: COMPOSE_FILE = $(COMPOSE_TEST_FILE)
test: $(DOCKER_COMPOSE) info
	@echo
	@echo "======= Tests ======="
	@echo
	$(MAKE) test-run tmp-export --keep-going


cache: ## Starts only cache service from docker-compose file
cache: COMPOSE_FILE = $(COMPOSE_TEST_FILE)
cache: $(DOCKER_COMPOSE)
	$(DOCKER_COMPOSE) up --remove-orphans -d cache || $(MAKE) clean-cache $@

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
run: COMPOSE_FILE = $(COMPOSE_TEST_FILE)
run: $(DOCKER_COMPOSE)
	@echo
	@echo "======= Run ======="
	@echo
	$(DOCKER_COMPOSE) run --rm --name $(PROJECT)-build-run $(DOCKER_ENV) build bash -c "$(CMD)"

bash: ## Opens up shell to environment where tests can be ran
bash: CMD = script/docker.sh && bundle exec rake db:create db:test:load && bundle exec bash
bash: run

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
bundle: Gemfile.prod Gemfile
	bundle install --gemfile=Gemfile.prod
	cp Gemfile.prod.lock Gemfile.lock
	bundle install --gemfile=Gemfile

oracle-db-setup: ## Creates databases in Oracle
oracle-db-setup: oracle-database
	MASTER_PASSWORD=p USER_PASSWORD=p ORACLE_SYSTEM_PASSWORD=threescalepass NLS_LANG='AMERICAN_AMERICA.UTF8' DISABLE_SPRING=true DB=oracle bundle exec rake db:drop db:create db:setup

schema: ## Runs db schema migrations. Run this when you have changes to your database schema that you have added as new migrations.
	bundle exec rake db:migrate db:schema:dump
	MASTER_PASSWORD=p USER_PASSWORD=p ORACLE_SYSTEM_PASSWORD=threescalepass NLS_LANG='AMERICAN_AMERICA.UTF8' DISABLE_SPRING=true DB=oracle bundle exec rake db:migrate db:schema:dump

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

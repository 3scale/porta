
DOCKER_COMPOSE_VERSION := 1.21.0
DOCKER_COMPOSE := $(BIN_PATH)/docker-compose
DOCKER_COMPOSE_BIN := $(DOCKER_COMPOSE)-$(DOCKER_COMPOSE_VERSION)

COMPOSE_PROJECT_NAME := $(PROJECT)
COMPOSE_FILE := docker-compose.yml
COMPOSE_TEST_FILE := docker-compose.test-$(DB).yml

ifeq ($(CI),true)
DOCKER_ENV = CI=true
else
DOCKER_ENV = CI=jenkins
endif

DOCKER_ENV += $(foreach env,$(JENKINS_ENV),$(env)=$(value $(env)))
DOCKER_ENV += GIT_TIMESTAMP=$(shell git log -1 --pretty=format:%ct)
DOCKER_ENV += PERCY_PROJECT=3scale/porta PERCY_BRANCH=$(subst origin/,,$(GIT_BRANCH)) PERCY_COMMIT=$(GIT_COMMIT)
DOCKER_ENV += $(RUBY_ENV)
DOCKER_ENV += BUNDLE_GEMFILE=$(BUNDLE_GEMFILE)

DOCKER_ENV := $(addprefix -e ,$(DOCKER_ENV))
DOCKER_ENV += -e GIT_COMMIT_MESSAGE='$(subst ','\'',$(shell git log -1 --pretty=format:%B))'
DOCKER_ENV += -e GIT_COMMITTED_DATE="$(shell git log -1 --pretty=format:%ai)"

ifndef COMPOSE_PROJECT_NAME
$(error missing COMPOSE_PROJECT_NAME)
endif

ifndef COMPOSE_FILE
$(error missing COMPOSE_FILE)
endif

export COMPOSE_PROJECT_NAME
export COMPOSE_FILE


all: clean clean-tmp build test ## Cleans environment, builds docker image and runs tests

$(DOCKER_COMPOSE): $(DOCKER_COMPOSE_BIN)
	@ln -sf $(realpath $(DOCKER_COMPOSE_BIN)) $(DOCKER_COMPOSE)

$(DOCKER_COMPOSE_BIN): $(BIN_PATH) | wget
	@wget --no-verbose https://github.com/docker/compose/releases/download/$(DOCKER_COMPOSE_VERSION)/docker-compose-`uname -s`-`uname -m` -O $(DOCKER_COMPOSE_BIN)
	@chmod +x $(DOCKER_COMPOSE_BIN)
	@touch $(DOCKER_COMPOSE_BIN)

compose: $(DOCKER_COMPOSE)
	@$(MAKE) $(DOCKER_COMPOSE) > /dev/null
	@echo $(DOCKER_COMPOSE) --file $(COMPOSE_FILE) --project-name $(COMPOSE_PROJECT_NAME)



build: ## Build the container image using one of the docker-compose file set by $(COMPOSE_FILE) env var
build: COMPOSE_FILE = $(COMPOSE_TEST_FILE)
build: $(DOCKER_COMPOSE)
	$(DOCKER_COMPOSE) build

clean: ## Cleaning docker-compose services
clean: SERVICES ?= database build redis memcached dnsmasq
clean: COMPOSE_FILE = $(COMPOSE_TEST_FILE)
clean: $(DOCKER_COMPOSE)
	- $(DOCKER_COMPOSE) stop $(SERVICES)
	- $(DOCKER_COMPOSE) rm --force -v $(SERVICES)
	- docker rm --force --volumes $(PROJECT)-build $(PROJECT)-build-run 2> /dev/null
	- $(foreach service,$(SERVICES),docker rm --force --volumes $(PROJECT)-$(service) 2> /dev/null;)
	- rm precompile-assets init_db || true


docker: ## Prints docker version and info
	@echo
	@echo "======= Docker ======="
	@echo
	@docker version
	@echo
	@docker info
	@echo

info: docker jenkins-env # Prints relevant environment info

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

oracle-db-setup: ## Creates databases in Oracle
oracle-db-setup: oracle-database
oracle-db-setup: CMD = MASTER_PASSWORD=p USER_PASSWORD=p ORACLE_SYSTEM_PASSWORD=threescalepass NLS_LANG='AMERICAN_AMERICA.UTF8' DISABLE_SPRING=true DB=oracle bundle exec rake db:drop db:create db:setup
oracle-db-setup: run


run: ## Starts containers and runs command $(CMD) inside the container in a non-interactive shell
run: COMPOSE_FILE = $(COMPOSE_TEST_FILE)
run: $(DOCKER_COMPOSE)
	@echo
	@echo "======= Run ======="
	@echo
	$(DOCKER_COMPOSE) run --rm --name $(PROJECT)-build-run $(DOCKER_ENV) build bash -c "cp config/examples/*.yml config/ && echo \"$(CMD)\" && $(CMD)"

schema: ## Runs db schema migrations. Run this when you have changes to your database schema that you have added as new migrations.
schema: CMD = bundle exec rake db:migrate db:schema:dump && MASTER_PASSWORD=p USER_PASSWORD=p ORACLE_SYSTEM_PASSWORD=threescalepass NLS_LANG='AMERICAN_AMERICA.UTF8' DISABLE_SPRING=true DB=oracle bundle exec rake db:migrate db:schema:dump
schema: run


test-run: # Runs test inside container
test-run: COMPOSE_FILE = $(COMPOSE_TEST_FILE)
test-run: $(DOCKER_COMPOSE) clean-tmp
	$(DOCKER_COMPOSE) run --rm --name $(PROJECT)-build $(DOCKER_ENV) build bash -c "$(CMD)"

test-with-info: $(DOCKER_COMPOSE) info
	@echo
	@echo "======= Tests ======="
	@echo
	$(MAKE) test-run tmp-export --keep-going CMD="${CMD}"

tmp-export: # Copies files from inside docker container to local tmp folder.
tmp-export: IMAGE ?= $(PROJECT)-build
tmp-export: clean-tmp
	-@ $(foreach dir,$(TMP),docker cp $(IMAGE):/opt/system/$(dir) $(dir) 2>/dev/null;)


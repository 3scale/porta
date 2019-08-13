MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
PROJECT_PATH := $(patsubst %/,%,$(dir $(MKFILE_PATH)))

DOCKER_COMPOSE_VERSION := 1.21.0
DOCKER_COMPOSE := $(BIN_PATH)/docker-compose
DOCKER_COMPOSE_BIN := $(DOCKER_COMPOSE)-$(DOCKER_COMPOSE_VERSION)

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

$(DOCKER_COMPOSE): $(DOCKER_COMPOSE_BIN)
	@ln -sf $(realpath $(DOCKER_COMPOSE_BIN)) $(DOCKER_COMPOSE)

$(DOCKER_COMPOSE_BIN): $(BIN_PATH) | wget
	@wget --no-verbose https://github.com/docker/compose/releases/download/$(DOCKER_COMPOSE_VERSION)/docker-compose-`uname -s`-`uname -m` -O $(DOCKER_COMPOSE_BIN)
	@chmod +x $(DOCKER_COMPOSE_BIN)
	@touch $(DOCKER_COMPOSE_BIN)

compose: $(DOCKER_COMPOSE)
	@$(MAKE) $(DOCKER_COMPOSE) > /dev/null
	@echo $(DOCKER_COMPOSE) --file $(COMPOSE_FILE) --project-name $(COMPOSE_PROJECT_NAME)


MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
PROJECT_PATH := $(patsubst %/,%,$(dir $(MKFILE_PATH)))
PROJECT = $(subst @,,$(notdir $(subst /workspace,,$(PROJECT_PATH))))

NAME=system-os
NAMESPACE=quay.io/3scale
SYSTEM_VERSION ?= 0.0.5
RAILS_ENV=production
PORT=3000
VERSION := $(SYSTEM_VERSION)
LOCAL_IMAGE := $(NAME):$(VERSION)
REMOTE_IMAGE := $(NAMESPACE)/$(LOCAL_IMAGE)

DOCKERFILE := Dockerfile.on_prem

BUNDLE_GEMS__CONTRIBSYS__COM := $(shell bundle config gems.contribsys.com | awk 'END {} match($$0, /".*"/) {print substr($$0, RSTART+1, RLENGTH-2)}')
BUNDLER_ENVIRONMENTS += BUNDLE_GEMS__CONTRIBSYS__COM
BUNDLER_ENV += $(foreach env,$(BUNDLER_ENVIRONMENTS),$(env)=$(value $(env)))

all: help

COMPOSE_PROJECT_NAME := openshift-$(PROJECT)
COMPOSE_FILE := $(PROJECT_PATH)/docker-compose.yml

include ../../wget.mk
include ../../docker-compose.mk

build: export LOCAL_IMAGE := $(LOCAL_IMAGE)
build: ## Build docker image. Accepts DOCKERFILE parameter. Name will be LOCAL_IMAGE=$(NAME):$(VERSION)
	# Docker Compose now does support nested wildcards in .dockerignore file.
	# That makes build to not recompile assets on every build.
	# https://github.com/docker/docker-py/issues/1117
	# But also mistakenly matches `**/.*` as any file with a dot anywhere.
	# https://github.com/docker/docker-py/issues/1471
	# @$(DOCKER_COMPOSE) build --pull system
ifeq ($(DOCKERFILE), Dockerfile)
ifeq ($(strip $(BUNDLE_GEMS__CONTRIBSYS__COM)),)
	$(error missing environment `BUNDLE_GEMS__CONTRIBSYS__COM`. Please set `bundle config gems.contribsys.com "user:password"`)
endif
endif
	docker build --build-arg BUNDLER_ENV="$(BUNDLER_ENV)" --file "$(DOCKERFILE)" --tag $(LOCAL_IMAGE) --pull ../..

run: export LOCAL_IMAGE := $(LOCAL_IMAGE)
run: export DOCKERFILE := $(DOCKERFILE)
run: export BUNDLER_ENV := $(BUNDLER_ENV)
run: $(DOCKER_COMPOSE)
	$(DOCKER_COMPOSE) run --user=1002 --rm system $(CMD)

up: export LOCAL_IMAGE := $(LOCAL_IMAGE)
up: export DOCKERFILE := $(DOCKERFILE)
up: export BUNDLER_ENV := $(BUNDLER_ENV)
up: $(DOCKER_COMPOSE)
up: ## Start everything
	$(DOCKER_COMPOSE) up --abort-on-container-exit system

setup: export LOCAL_IMAGE := $(LOCAL_IMAGE)
setup: export DOCKERFILE := $(DOCKERFILE)
setup: export BUNDLER_ENV := $(BUNDLER_ENV)
setup: ## Run the database setup
	$(DOCKER_COMPOSE) run --rm -e RAILS_LOG_LEVEL=error system rake db:drop db:setup

test: setup
test: ## Test the built image
	$(MAKE) run CMD='rails server --daemon'
	$(MAKE) run CMD='unicorn --config-file config/unicorn.rb --daemonize'
	$(MAKE) run CMD='rake ts:configure ts:rebuild THINKING_SPHINX_CONFIGURATION_FILE=/tmp/sphinx.conf'

	# I would like to use `rake assets:clean` but it seems that non-stupid-digest gem does not reference
	# them in `manifest.assets` so they stay in the public/assets directory
	$(MAKE) run CMD='bash -c "rm -fRv public/assets/* && rake assets:precompile RAILS_ENV=preview"'

bash: CMD='bash'
bash: run ## Open bash inside the built image

console: CMD='rails console'
console: run ## Open Rails console inside the built image

tag: ## Tag IMAGE_NAME in the docker registry
	docker tag $(LOCAL_IMAGE) $(REMOTE_IMAGE)

push: ## Push to the docker registry
	docker push $(REMOTE_IMAGE)

clean: export LOCAL_IMAGE := $(LOCAL_IMAGE)
clean: $(DOCKER_COMPOSE)
clean: ## Clean all containers
	$(DOCKER_COMPOSE) down --volumes --remove-orphans
	$(DOCKER_COMPOSE) rm --force

# Check http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help: ## Print this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)


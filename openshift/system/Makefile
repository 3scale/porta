NAME=system-os
NAMESPACE=quay.io/3scale
SYSTEM_VERSION ?= 0.0.5
VERSION := $(SYSTEM_VERSION)
LOCAL_IMAGE := $(NAME):$(VERSION)
REMOTE_IMAGE := $(NAMESPACE)/$(LOCAL_IMAGE)

DOCKERFILE := Dockerfile.on_prem

BUNDLE_GEMS__CONTRIBSYS__COM := $(shell bundle config gems.contribsys.com | awk 'END {} match($$0, /".*"/) {print substr($$0, RSTART+1, RLENGTH-2)}')
BUNDLER_ENVIRONMENTS += BUNDLE_GEMS__CONTRIBSYS__COM
BUNDLER_ENV += $(foreach env,$(BUNDLER_ENVIRONMENTS),$(env)=$(value $(env)))

all: help

build: export LOCAL_IMAGE := $(LOCAL_IMAGE)
build: ## Build docker image. Accepts DOCKERFILE parameter. Name will be LOCAL_IMAGE=$(NAME):$(VERSION)
	# Docker Compose now does support nested wildcards in .dockerignore file.
	# That makes build to not recompile assets on every build.
	# https://github.com/docker/docker-py/issues/1117
	# But also mistakenly matches `**/.*` as any file with a dot anywhere.
	# https://github.com/docker/docker-py/issues/1471
	# @docker-compose build --pull system
ifeq ($(DOCKERFILE), Dockerfile)
ifeq ($(strip $(BUNDLE_GEMS__CONTRIBSYS__COM)),)
	$(error missing environment `BUNDLE_GEMS__CONTRIBSYS__COM`. Please set `bundle config gems.contribsys.com "user:password"`)
endif
endif
	docker build --build-arg BUNDLER_ENV="$(BUNDLER_ENV)" --file "$(DOCKERFILE)" --tag $(LOCAL_IMAGE) --pull ../..

tag: ## Tag IMAGE_NAME in the docker registry
	docker tag $(LOCAL_IMAGE) $(REMOTE_IMAGE)

push: ## Push to the docker registry
	docker push $(REMOTE_IMAGE)

clean: export LOCAL_IMAGE := $(LOCAL_IMAGE)
clean: ## Clean all containers
	docker-compose down --volumes --remove-orphans
	docker-compose rm --force
# Check http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help: ## Print this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)


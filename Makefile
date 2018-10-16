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


SCRIPT_PRECOMPILE_ASSETS = bundle config && bundle exec rake assets:precompile RAILS_GROUPS=assets RAILS_ENV=production WEBPACKER_PRECOMPILE=false && bundle exec rake assets:precompile RAILS_GROUPS=assets RAILS_ENV=test WEBPACKER_PRECOMPILE=false
SCRIPT_TEST = make dnsmasq_set && script/jenkins.sh || make dnsmasq_unset

default: all


## This image is private and cannot be accessed by another third party than redhat.com employees
## You will need to build your own image as instructed in https://github.com/oracle/docker-images/tree/master/OracleDatabase/SingleInstance
ORACLE_DB_IMAGE := quay.io/3scale/oracle:12.2.0.1-ee

include wget.mk
ifndef CIRCLECI
include docker-compose.mk
else
	include container.mk
endif
include openshift.mk
include dependencies.mk

.PHONY: default all clean build test info jenkins-env docker test-run tmp-export run test-bash clean-cache clean-tmp compose help bundle-in-container apicast-dependencies-in-container npm-install-in-container test-no-deps
.DEFAULT_GOAL := help

# From here on, only phony targets to manage docker compose

test: ## Runs tests inside container build environment
test: CMD = $(SCRIPT_TEST)
test: provision precompile-assets test-with-info

jenkins-env: # Prints env vars
	@echo
	@echo "======= Jenkins environment ======="
	@echo
	@env
	@echo

precompile-assets: ## Precompiles static assets
precompile-assets: CMD = $(SCRIPT_PRECOMPILE_ASSETS)
precompile-assets:
	@echo
	@echo "======= Assets Precompile ======="
	@echo
	$(MAKE) run CMD="${CMD}"
	touch precompile-assets

clean-tmp: ## Removes temporary files
	-@ $(foreach dir,$(TMP),rm -rf $(dir);)

bash: ## Opens up shell to environment where tests can be ran
bash: CMD = bundle exec bash
bash: provision
	$(MAKE) run CMD="${CMD}"

boot_database:
	until bin/rake boot:database TEST_ENV_NUMBER=8 ; do \
		sleep 1 ; \
		echo -n "." ; \
	done
	if [ "x$$DB" = "xoracle" ]; then \
		echo "Waiting for 60 seconds for the DB to be ready" ; \
		sleep 60 ; \
	fi

dnsmasq_set:
	echo "nameserver $$DNSMASQ_PORT_53_TCP_ADDR" > resolv.conf.dnsmasq && sudo cp /etc/resolv.conf /etc/resolv.conf.dist && sudo cp resolv.conf.dnsmasq /etc/resolv.conf

dnsmasq_unset:
	sudo cp /etc/resolv.conf.dist /etc/resolv.conf

# Check http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help: ## Print this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

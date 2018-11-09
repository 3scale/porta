MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
PROJECT_PATH := $(patsubst %/,%,$(dir $(MKFILE_PATH)))
PROJECT = $(subst @,,$(notdir $(subst /workspace,,$(PROJECT_PATH))))

export PROJECT

BUNDLE_GEMFILE ?= Gemfile

TMP = tmp/capybara tmp/junit tmp/codeclimate coverage log/test.searchd.log tmp/jspm precompile-assets init_db

DB ?= mysql

JENKINS_ENV = DB
ifdef JENKINS_URL # if actually running on jenkins
JENKINS_ENV += JENKINS_URL BUILD_TAG BUILD_NUMBER BUILD_URL
endif
JENKINS_ENV += GIT_BRANCH GIT_COMMIT GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_COMMITTER_EMAIL GIT_COMMITTER_NAME PERCY_ENABLE
JENKINS_ENV += BUNDLE_GEMFILE BUNDLE_GEMS__CONTRIBSYS__COM
JENKINS_ENV += PARALLEL_TEST_PROCESSORS

JENKINS_ENV += MULTIJOB_KIND PERCY_ENABLE PERCY_TOKEN COVERAGE PROXY_ENABLED

RUBY_ENGINE_VERSION = ruby
RUBY_API_VERSION = 2.3.0

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
ORACLE_DB_IMAGE := quay.io/3scale/oracle:12.2.0.1-ee

include wget.mk
ifdef CI
	include container.mk
else
include docker-compose.mk
endif
include openshift.mk
include dependencies.mk

.PHONY: default all clean build test info jenkins-env docker test-run tmp-export run clean-tmp compose help bundle-in-container apicast-dependencies-in-container npm-install-in-container test-no-deps
.DEFAULT_GOAL := help

# From here on, only phony targets to manage docker compose
test-prep: init_db test-with-info
#test-prep: bundle npm-install test-with-info

ifeq ($(PROXY_ENABLED),true)
test-rake: CMD = make dnsmasq_set && bundle exec rake $${JOB} --verbose --trace && make dnsmasq_unset
else
test-rake: CMD = bundle exec rake $${JOB} --verbose --trace
endif
test-rake: test-prep

test-unit: JOB = integrate:unit
test-unit:
	$(MAKE) test-rake JOB="${JOB}"

test-functional: JOB = integrate:functional
test-functional:
	$(MAKE) test-rake JOB="${JOB}"

test-integration: JOB = integrate:integration
test-integration:
	$(MAKE) test-rake JOB="${JOB}"

test-rspec: JOB = integrate:rspec
test-rspec:
	$(MAKE) test-rake JOB="${JOB}"

test-licenses: JOB = ci:license_finder:run
test-licenses:
	$(MAKE) test-rake JOB="${JOB}"

test-swaggerdocs: JOB = doc:swagger:validate:all doc:swagger:generate:all
test-swaggerdocs:
	$(MAKE) test-rake JOB="${JOB}"

test-jspm: JOB = ci:jspm
test-jspm:
	$(MAKE) test-rake JOB="${JOB}"

test-yarn: JOB = integrate:frontend
test-yarn:
	$(MAKE) test-rake JOB="${JOB}"


test-cucumber: CMD = make dnsmasq_set && bundle exec rake integrate:cucumber && make dnsmasq_unset
test-cucumber: test-prep

test-lint: bundle test-licenses test-swaggerdocs test-jspm test-yarn

test: ## Runs tests inside container build environment
test: bundle npm-install test-lint test-unit test-functional test-integration test-rspec test-cucumber

jenkins-env: # Prints env vars
	@echo
	@echo "======= Jenkins environment ======="
	@echo
	@env
	@echo

precompile-assets: ## Precompiles static assets
precompile-assets: CMD = bundle exec rake integrate:precompile_assets
precompile-assets: bundle
	@echo
	@echo "======= Assets Precompile ======="
	@echo
	$(MAKE) run CMD="${CMD}"
	touch precompile-assets


bash: ## Opens up shell to environment where tests can be ran
bash: CMD = bundle exec bash
bash: init_db
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

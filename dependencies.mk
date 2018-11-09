SCRIPT_BUNDLER = bundle check --path=vendor/bundle || bundle install && bundle clean && rm -rf "$(BUNDLE_PATH)/$(RUBY_ENGINE_VERSION)/$(RUBY_API_VERSION)"/gems/capybara-webkit-*/src
SCRIPT_NPM = yarn --version && yarn install --frozen-lockfile --link-duplicates && jspm -v && jspm install --quick || (jspm dl-loader && jspm install --lock || jspm install --force)
SCRIPT_APICAST_DEPENDENCIES = cd vendor/docker-gateway && ls -al && make dependencies && cd ../../

bundle: ## Installs dependencies using bundler, inside the build container. Run this after you make some changes to Gemfile.
bundle: CMD = $(SCRIPT_BUNDLER)
bundle: Gemfile.lock
	@echo
	@echo "======= Bundler ======="
	@echo
	$(MAKE) run CMD="${CMD}"

apicast-dependencies: ## Fetches APICast dependencies by invoking `dependencies` target on apicast submodule.
apicast-dependencies: CMD = $(SCRIPT_APICAST_DEPENDENCIES)
apicast-dependencies:
	@echo
	@echo "======= APIcast ======="
	@echo
	$(MAKE) run CMD="${CMD}"

npm-install: ## Installs NPM & JSPM dependencies in development environment inside container.
npm-install: CMD = $(SCRIPT_NPM)
npm-install: package.json
	@echo
	@echo "======= NPM ======="
	@echo
	$(MAKE) run CMD="${CMD}"

init_db_with_deps: JOB = db:create db:test:prepare
init_db_with_deps:
	$(MAKE) bundle npm-install
	$(MAKE) rake_wrapper JOB="${JOB}"
	touch init_db_with_deps

SCRIPT_BUNDLER = bundle check --path=vendor/bundle || bundle install
SCRIPT_NPM = yarn --version && yarn install --frozen-lockfile --link-duplicates && jspm -v && jspm install --quick || (jspm dl-loader && ${PROXY_ENV} jspm install --lock || ${PROXY_ENV} jspm install --force)
SCRIPT_APICAST_DEPENDENCIES = cd vendor/docker-gateway && ls -al && make dependencies && cd ../../
SCRIPT_PROVISION_DB = time bundle exec rake db:create db:test:load --verbose --trace

bundle-info:

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

provision: CMD = $(SCRIPT_PROVISION_DB)
provision:
	$(MAKE) bundle npm-install
	$(MAKE) run CMD="${CMD}"
	touch provision

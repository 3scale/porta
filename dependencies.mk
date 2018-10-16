SCRIPT_BUNDLER = bundle check --path=vendor/bundle --gemfile=Gemfile || ${PROXY_ENV} bundle install --deployment --retry=5 --gemfile=Gemfile && bundle config
SCRIPT_NPM = yarn --version && yarn global dir && ${PROXY_ENV} yarn install --frozen-lockfile --link-duplicates && jspm -v && ${PROXY_ENV} jspm dl-loader && ${PROXY_ENV} jspm install --lock || ${PROXY_ENV} jspm install --force
SCRIPT_APICAST_DEPENDENCIES = cd vendor/docker-gateway && ls -al && ${PROXY_ENV} make dependencies && cd ../../

bundle-info:
	@echo
	@echo "======= Bundler ======="
	@echo

bundle: ## Installs dependencies using bundler, inside the build container. Run this after you make some changes to Gemfile.
bundle: Gemfile
bundle: CMD = $(SCRIPT_BUNDLER)
bundle: bundle-info run


apicast-dependencies-info:
	@echo
	@echo "======= APIcast ======="
	@echo

apicast-dependencies: ## Fetches APICast dependencies by invoking `dependencies` target on apicast submodule.
apicast-dependencies: CMD = $(SCRIPT_APICAST_DEPENDENCIES)
apicast-dependencies: apicast-dependencies-info run

npm-install-info:
	@echo
	@echo "======= NPM ======="
	@echo

npm-install: ## Installs NPM & JSPM dependencies in development environment inside container.
npm-install: CMD = $(SCRIPT_NPM)
npm-install: npm-install-info run

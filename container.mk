
all: clean-tmp test ## Cleans environment, builds docker image and runs tests

info: jenkins-env # Prints relevant environment info

oracle-db-setup: ## Creates databases in Oracle
oracle-db-setup: oracle-database
	MASTER_PASSWORD=p USER_PASSWORD=p ORACLE_SYSTEM_PASSWORD=threescalepass NLS_LANG='AMERICAN_AMERICA.UTF8' DISABLE_SPRING=true DB=oracle bundle exec rake db:drop db:create db:setup

run: ## Runs command $(CMD) without starting any containers.
run:
	bash -c "cp config/examples/*.yml config/ && echo \"$(CMD)\" && $(CMD)"

schema: ## Runs db schema migrations. Run this when you have changes to your database schema that you have added as new migrations.
	bundle exec rake db:migrate db:schema:dump
	MASTER_PASSWORD=p USER_PASSWORD=p ORACLE_SYSTEM_PASSWORD=threescalepass NLS_LANG='AMERICAN_AMERICA.UTF8' DISABLE_SPRING=true DB=oracle bundle exec rake db:migrate db:schema:dump


test-run: ## Runs tests
test-run: clean-tmp
	$(CMD)

test-with-info: info
	@echo
	@echo "======= Tests ======="
	@echo
	$(MAKE) test-run --keep-going CMD="${CMD}"

all: clean-tmp test ## Cleans environment, builds docker image and runs tests

boot_database:
	until bin/rake boot:database TEST_ENV_NUMBER=8 ; do \
		sleep 1 ; \
		echo -n "." ; \
	done
	if [ "x$$DB" = "xoracle" ]; then \
		echo "Waiting for 60 seconds for the DB to be ready" ; \
		sleep 60 ; \
	fi

clean-tmp: ## Removes temporary files
	-@ $(foreach dir,$(TMP),rm -rf $(dir);)

dnsmasq_set:
	echo "nameserver $$DNSMASQ_PORT_53_TCP_ADDR" > resolv.conf.dnsmasq && sudo cp /etc/resolv.conf /etc/resolv.conf.dist && sudo cp resolv.conf.dnsmasq /etc/resolv.conf

dnsmasq_unset:
	sudo cp /etc/resolv.conf.dist /etc/resolv.conf

info: jenkins-env # Prints relevant environment info

oracle-db-setup: ## Creates databases in Oracle
oracle-db-setup:
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
	@echo "======= Tests: ${CMD} ======="
	@echo
	$(MAKE) test-run --keep-going CMD="${CMD}"
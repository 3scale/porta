#test-prep:
#	$(MAKE) init_db_with_deps test-with-info CMD="#{CMD}"
#test-prep: bundle npm-install test-with-info

ifeq ($(PROXY_ENABLED),true)
rake_wrapper: CMD = make dnsmasq_set; bundle exec rake $${JOB} --verbose --trace; export TEST_EXIT_CODE=$$? && echo 'tests exit code: $$TEST_EXIT_CODE'; make dnsmasq_unset; exit $$TEST_EXIT_CODE
else
rake_wrapper: CMD = bundle exec rake $${JOB} --verbose --trace
endif
rake_wrapper:
	$(MAKE) test-with-info CMD="${CMD}"

test-rake:
	$(MAKE) bundle npm-install rake_wrapper JOB="${JOB}"

test-cucumber: JOB = integrate:cucumber
test-cucumber: PROXY_ENABLED = true
test-cucumber:
	$(MAKE) bundle npm-install test-rake JOB="${JOB}"

test-lint: bundle
	$(MAKE) test-rake JOB="ci:license_finder:run doc:swagger:validate:all doc:swagger:generate:all ci:jspm integrate:frontend"


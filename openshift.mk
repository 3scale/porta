OPENSHIFT_VERSION := v1.3.0
OPENSHIFT_VERSION_COMMIT := 3ab7af3d097b57f933eccef684a714f2368804e7
OPENSHIFT_PLATFORM := $(shell uname -s)
OPENSHIFT_PLATFORM_CPU := $(shell uname -m) 

OPENSHIFT := $(BIN_PATH)/oc
OPENSHIFT_BIN := $(OPENSHIFT)-$(OPENSHIFT_VERSION)

$(OPENSHIFT): $(OPENSHIFT_BIN)
	@ln -sf $(realpath $(OPENSHIFT_BIN)) $(OPENSHIFT)

$(OPENSHIFT_BIN): $(BIN_PATH) | wget unzip
ifeq ($(OPENSHIFT_PLATFORM),Darwin)
	@wget --no-verbose -c https://github.com/openshift/origin/releases/download/$(OPENSHIFT_VERSION)/openshift-origin-client-tools-$(OPENSHIFT_VERSION)-$(OPENSHIFT_VERSION_COMMIT)-mac.zip -O $(OPENSHIFT_BIN).zip
endif
	@rm -f $(OPENSHIFT)
	@unzip $(OPENSHIFT_BIN).zip oc -d $(BIN_PATH)
	@mv $(OPENSHIFT) $(OPENSHIFT_BIN)

	@chmod +x $(OPENSHIFT_BIN)
	@rm -f $(OPENSHIFT_BIN).zip

	@touch $(OPENSHIFT_BIN)

oc: $(OPENSHIFT)
	@$(MAKE) $(OPENSHIFT) > /dev/null
	@echo $(OPENSHIFT)

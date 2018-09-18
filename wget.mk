MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
PROJECT_PATH := $(patsubst %/,%,$(dir $(MKFILE_PATH)))

BIN_PATH := $(PROJECT_PATH)/.bin

WGET := $(shell which wget 2> /dev/null)
UNZIP := $(shell which unzip 2> /dev/null)

wget:
ifndef WGET
	$(error missing wget to download utilities)
endif

unzip:
ifndef UNZIP
	$(error missing unzip to extract utilities)
endif

$(BIN_PATH):
	@mkdir -p $@

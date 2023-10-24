VERAISON_ROOT := .veraison-services
THIS_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

# The command line can override VERAISON_BRANCH to point to a branch other than
# main
VERAISON_BRANCH ?= main

$(VERAISON_ROOT):
	git clone --branch $(VERAISON_BRANCH) https://github.com/veraison/services $@

.PHONY: veraison-build-containers
veraison-build-containers: $(VERAISON_ROOT)
	@docker network rm veraison-net || true
	cp $(THIS_DIR)/veraison_deployment.cfg.yml $(VERAISON_ROOT)/deployments/docker/src/config.yaml.template
	$(MAKE) -C "$</deployments/docker" deploy services

.PHONY: veraison-destroy-containers
veraison-destroy-containers:
	$(MAKE) -C "$(VERAISON_ROOT)/deployments/docker" really-clean
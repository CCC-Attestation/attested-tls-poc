# TODO(tho) clone and build

VERAISON_ROOT := .veraison-services

$(VERAISON_ROOT):
	git clone https://github.com/veraison/services $@

.PHONY: veraison-build-containers
veraison-build-containers: $(VERAISON_ROOT)
	@docker network rm veraison-net || true
	$(MAKE) -C "$</deployments/docker" deploy services

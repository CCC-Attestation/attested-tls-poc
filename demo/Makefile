.DEFAULT_GOAL := help

# command line can override this
ENV_FILE ?= demo.env

DC := docker-compose --env-file $(ENV_FILE)

NODES := $(shell $(DC) config --services | sed -e 's/_/-/g' | xargs)

define interactive_shell_template
sh-$(1): start ; docker exec -ti $(1) bash
endef

$(foreach node,$(NODES),$(eval $(call interactive_shell_template,$(node))))

define logs
logs-$(1): start ; $(DC) logs $(1)
endef

ifdef BUILD
	BUILD_FLAGS := --build
endif

$(foreach node,$(NODES),$(eval $(call logs,$(node))))

start: veraison-build-containers
	$(DC) up -d $(BUILD_FLAGS)

stop:
	$(DC) down --remove-orphans

show-logs:
	$(DC) logs

top:
	$(DC) top

endorse: start
	$(DC) exec attester /root/endorse.sh

handshake: start
	$(DC) exec attester /root/handshake.sh

help:
	@echo "available targets:"
	@echo
	@echo "  start      start the demo environment (containers, network, volumes, etc.)"
	@echo "             do \"make BUILD=true start\" to force building the containers"
	@echo "  endorse    collect keys and reference values from the attester and provision the verifier"
	@echo "  handshake  run an attested TLS handshake and exchange minimal application data between attester and verifier"
	@echo "  stop       tear down the demo environment"
	@echo "  show-logs  show logs for all the containers"
	@echo "  log-<node> show logs for the specific container"
	@echo "  sh-<node>  start an interactive shell in the container"
	@echo
	@echo "nodes: $(NODES)"

include build/veraison.mk
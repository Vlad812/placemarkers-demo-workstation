PROJECT_ROOT := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
include $(PROJECT_ROOT)/config.mk
include common-services/common-services.mk
include main-services/main-services.mk

.PHONY: create-network remove-network app-setup app-up app-down app-clear clone-repos jwt-setup

app-setup: create-network ms-all-build ms-all-init cs-all-init jwt-setup
app-up: create-network cs-all-up ms-all-up
app-down: ms-all-down cs-all-down
app-clear: ms-all-down cs-all-down remove-network

create-network:
	docker network inspect $(NETWORK_NAME) >/dev/null 2>&1 || docker network create $(NETWORK_NAME)

remove-network:
	docker network rm $(NETWORK_NAME) 2>/dev/null || true

clone-repos:
	bash util/clone-repo.sh

jwt-setup: auth-service-jwt-generate
	bash util/distribute-jwt-keys.sh


COMMON_SERVICES_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
PROJECT_ROOT := $(abspath $(COMMON_SERVICES_DIR)/..)
include $(PROJECT_ROOT)/config.mk

.PHONY: cs-traefik-up cs-traefik-down

cs-traefik-up:
	@echo up traefik
	docker compose -f $(COMMON_SERVICES_DIR)/traefik/compose.yaml -p $(PROJECT_GROUP_COMMON_SERVICE) up -d

cs-traefik-down:
	@echo down traefik
	docker compose -f $(COMMON_SERVICES_DIR)/traefik/compose.yaml -p $(PROJECT_GROUP_COMMON_SERVICE) down -v

.PHONY: cs-buggregator-up cs-buggregator-down

cs-buggregator-up:
	@echo up buggregator
	docker compose -f $(COMMON_SERVICES_DIR)/buggregator/compose.yaml -p $(PROJECT_GROUP_COMMON_SERVICE) up -d

cs-buggregator-down:
	@echo down buggregator
	docker compose -f $(COMMON_SERVICES_DIR)/buggregator/compose.yaml -p $(PROJECT_GROUP_COMMON_SERVICE) down -v

.PHONY: cs-postgresql-up cs-postgresql-down


.PHONY: cs-pg-placemarkers-init cs-pg-auth-init

cs-pg-placemarkers-init:
	@echo init cs-pg-placemarkers
	docker compose -f $(COMMON_SERVICES_DIR)/postgresql/compose.yaml -p $(PROJECT_GROUP_COMMON_SERVICE) up -d cs-pg-placemarkers-primary
	@until docker compose -f $(COMMON_SERVICES_DIR)/postgresql/compose.yaml -p $(PROJECT_GROUP_COMMON_SERVICE) exec -T cs-pg-placemarkers-primary pg_isready -U my_postgres -d placemarkers_db 2>/dev/null; do \
		echo "Waiting..."; \
		sleep 1; \
	done
	@echo "cs-pg-placemarkers initialized, stopping container..."
	docker compose -f $(COMMON_SERVICES_DIR)/postgresql/compose.yaml -p $(PROJECT_GROUP_COMMON_SERVICE) stop cs-pg-placemarkers-primary

cs-pg-auth-init:
	@echo init cs-pg-auth
	docker compose -f $(COMMON_SERVICES_DIR)/postgresql/compose.yaml -p $(PROJECT_GROUP_COMMON_SERVICE) up -d cs-pg-auth
	@until docker compose -f $(COMMON_SERVICES_DIR)/postgresql/compose.yaml -p $(PROJECT_GROUP_COMMON_SERVICE) exec -T cs-pg-auth pg_isready -U my_postgres -d placemarkers_user_db 2>/dev/null; do \
		echo "Waiting..."; \
		sleep 1; \
	done
	@echo "cs-pg-auth initialized, stopping container..."
	docker compose -f $(COMMON_SERVICES_DIR)/postgresql/compose.yaml -p $(PROJECT_GROUP_COMMON_SERVICE) stop cs-pg-auth

cs-postgresql-up:
	@echo up postgresql
	docker compose -f $(COMMON_SERVICES_DIR)/postgresql/compose.yaml -p $(PROJECT_GROUP_COMMON_SERVICE) up -d

cs-postgresql-down:
	@echo down postgresql
	docker compose -f $(COMMON_SERVICES_DIR)/postgresql/compose.yaml -p $(PROJECT_GROUP_COMMON_SERVICE) down -v

.PHONY: cs-all-up cs-all-down cs-all-init

cs-all-init: cs-pg-placemarkers-init cs-pg-auth-init

cs-all-up: cs-traefik-up cs-buggregator-up cs-postgresql-up

cs-all-down: cs-buggregator-down cs-traefik-down cs-postgresql-down

MAIN_SERVICES_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
PROJECT_ROOT := $(abspath $(MAIN_SERVICES_DIR)/..)
include $(PROJECT_ROOT)/config.mk

include $(MAIN_SERVICES_DIR)/app-frontend/Makefile
include $(MAIN_SERVICES_DIR)/api-placemarkers-database/Makefile
include $(MAIN_SERVICES_DIR)/api-placemarkers-search/Makefile
include $(MAIN_SERVICES_DIR)/api-placemarkers-collection/Makefile
include $(MAIN_SERVICES_DIR)/auth-service/Makefile
include $(MAIN_SERVICES_DIR)/notification-provider/Makefile

.PHONY: ms-all-init ms-all-build ms-all-up ms-all-down ms-all-test-unit

ms-all-build: app-frontend-build api-placemarkers-database-build api-placemarkers-search-build api-placemarkers-collection-build auth-service-build notification-provider-build

ms-all-init: app-frontend-init api-placemarkers-database-init api-placemarkers-search-init api-placemarkers-collection-init auth-service-init notification-provider-init

ms-all-up: app-frontend-up api-placemarkers-database-up api-placemarkers-search-up api-placemarkers-collection-up auth-service-up notification-provider-up

ms-all-down: app-frontend-down api-placemarkers-database-down api-placemarkers-search-down api-placemarkers-collection-down auth-service-down notification-provider-down

ms-all-test-unit: api-placemarkers-database-test-unit api-placemarkers-search-test-unit api-placemarkers-collection-test-unit auth-service-test-unit notification-provider-test-unit


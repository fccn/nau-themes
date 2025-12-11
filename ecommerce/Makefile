########################################################################################################################
# NAU Themes - Ecommerce
# Manages translations for ecommerce themes using Django's makemessages
########################################################################################################################

# Default target
.DEFAULT_GOAL := help

# Execute everything on same shell so venv activation persists
.ONESHELL:

# Shell settings for better error handling
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

########################################################################################################################
# Variables
########################################################################################################################

# Project root directory
ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

# Use parent venv by default, but allow override
VENV_DIR ?= ../venv
VENV_BIN := $(VENV_DIR)/bin
VENV_ACTIVATE := . $(VENV_BIN)/activate

# Theme configuration
THEME := nau

# Translation languages
LANG_TARGETS := en pt_PT

# Colors for output
COLOR_RESET := \033[0m
COLOR_INFO := \033[36m
COLOR_SUCCESS := \033[32m
COLOR_WARNING := \033[33m
COLOR_ERROR := \033[31m

########################################################################################################################
# Utility Targets
########################################################################################################################

help: ## Display this help message
	@printf "$(COLOR_INFO)Ecommerce Theme - Available targets:$(COLOR_RESET)\n"
	@perl -nle'print $$& if m{^[\.a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(COLOR_INFO)  %-30s$(COLOR_RESET) %s\n", $$1, $$2}'
.PHONY: help

check-venv: ## Verify virtual environment exists
	@if [ ! -d "$(VENV_DIR)" ]; then \
		printf "$(COLOR_ERROR)Error: Virtual environment not found at $(VENV_DIR)$(COLOR_RESET)\n" >&2; \
		printf "$(COLOR_INFO)Run 'make venv' from project root first.$(COLOR_RESET)\n" >&2; \
		exit 1; \
	fi
.PHONY: check-venv

check-gettext: ## Verify gettext tools are installed
	@if ! command -v msgfmt >/dev/null 2>&1; then \
		printf "$(COLOR_ERROR)Error: gettext tools not found$(COLOR_RESET)\n" >&2; \
		printf "$(COLOR_INFO)Install with: sudo apt install gettext (Debian/Ubuntu)$(COLOR_RESET)\n" >&2; \
		printf "$(COLOR_INFO)           or: brew install gettext (macOS)$(COLOR_RESET)\n" >&2; \
		exit 1; \
	fi
	@printf "$(COLOR_SUCCESS)✓ gettext tools available$(COLOR_RESET)\n"
.PHONY: check-gettext

########################################################################################################################
# Translation Targets
########################################################################################################################

translations_extract: check-venv check-gettext ## Extract translations from source code
	@printf "$(COLOR_INFO)Extracting translations from $(THEME)...$(COLOR_RESET)\n"
	@$(VENV_ACTIVATE) && \
	for lang in $(LANG_TARGETS); do \
		printf "  Extracting for $$lang...\n"; \
		cd $(ROOT_DIR)/$(THEME) && DJANGO_SETTINGS_MODULE="" django-admin makemessages --locale $$lang -d django; \
		cd $(ROOT_DIR)/$(THEME) && DJANGO_SETTINGS_MODULE="" django-admin makemessages --locale $$lang -d djangojs; \
	done
	@printf "$(COLOR_SUCCESS)✓ Translations extracted$(COLOR_RESET)\n"
.PHONY: translations_extract

translations_compile: check-venv check-gettext ## Compile the extracted translations
	@printf "$(COLOR_INFO)Compiling translations for $(THEME)...$(COLOR_RESET)\n"
	@$(VENV_ACTIVATE) && \
	cd $(ROOT_DIR)/$(THEME) && DJANGO_SETTINGS_MODULE="" django-admin compilemessages
	@printf "$(COLOR_SUCCESS)✓ Translations compiled$(COLOR_RESET)\n"
.PHONY: translations_compile

translations_detect_changed_source: ## Detect if source translations have changed
	@printf "$(COLOR_INFO)Checking for changed source translations...$(COLOR_RESET)\n"
	@cd $(ROOT_DIR)/$(THEME) && \
	test $$(git diff --exit-code -G "^(msgid|msgstr)" | wc -l) -eq 0 || \
	( printf "$(COLOR_WARNING)Detected changed source translations!$(COLOR_RESET)\n" ; exit 1 )
.PHONY: translations_detect_changed_source

translations_is_missing: translations_extract ## Check if translations need updating
	@printf "$(COLOR_INFO)Checking for missing translations in $(THEME)...$(COLOR_RESET)\n"
	@cd $(ROOT_DIR)/$(THEME) && git diff --numstat *.po | awk '{if ($$1>1 || $$2>1) { exit 1 } else { exit 0 }}'
.PHONY: translations_is_missing

translations: translations_extract translations_compile ## Full translation workflow: extract and compile
	@printf "$(COLOR_SUCCESS)✓ Ecommerce translation workflow complete$(COLOR_RESET)\n"
.PHONY: translations

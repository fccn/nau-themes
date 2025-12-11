########################################################################################################################
# NAU Themes - EdX Platform
# Manages translations for edx-platform themes using pybabel
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

# Use parent venv by default, but allow override
VENV_DIR ?= ../venv
VENV_BIN := $(VENV_DIR)/bin
VENV_ACTIVATE := . $(VENV_BIN)/activate

# Theme configuration (can be overridden via environment)
THEME ?= nau-basic

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
	@printf "$(COLOR_INFO)EdX Platform Theme - Available targets:$(COLOR_RESET)\n"
	@perl -nle'print $$& if m{^[\.a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(COLOR_INFO)  %-30s$(COLOR_RESET) %s\n", $$1, $$2}'
.PHONY: help

check-venv: ## Verify virtual environment exists
	@if [ ! -d "$(VENV_DIR)" ]; then \
		printf "$(COLOR_ERROR)Error: Virtual environment not found at $(VENV_DIR)$(COLOR_RESET)\n" >&2; \
		printf "$(COLOR_INFO)Run 'make venv' from project root first.$(COLOR_RESET)\n" >&2; \
		exit 1; \
	fi
.PHONY: check-venv

########################################################################################################################
# Translation Targets
########################################################################################################################

translations_create_catalogs: check-venv translations_extract ## Create initial translation catalogs for all languages
	@printf "$(COLOR_INFO)Creating translation catalogs for $(THEME)...$(COLOR_RESET)\n"
	@$(VENV_ACTIVATE) && \
	for lang in $(LANG_TARGETS); do \
		printf "  Creating catalog for $$lang...\n"; \
		$(VENV_BIN)/pybabel init -i $(THEME)/conf/locale/django.pot -D django -d $(THEME)/conf/locale/ -l $$lang || true; \
		$(VENV_BIN)/pybabel init -i $(THEME)/conf/locale/djangojs.pot -D djangojs -d $(THEME)/conf/locale/ -l $$lang || true; \
	done
	@printf "$(COLOR_SUCCESS)✓ Catalogs created$(COLOR_RESET)\n"
.PHONY: translations_create_catalogs

translations_extract: check-venv ## Extract translatable strings from source files
	@printf "$(COLOR_INFO)Extracting translatable strings from $(THEME)...$(COLOR_RESET)\n"
	@$(VENV_ACTIVATE) && \
	$(VENV_BIN)/pybabel extract -F $(THEME)/conf/locale/babel_mako.cfg -o $(THEME)/conf/locale/django.pot \
		--msgid-bugs-address=ajuda@nau.edu.pt --copyright-holder=FCT-FCCN -c Translators $(THEME)/* && \
	$(VENV_BIN)/pybabel extract -F $(THEME)/conf/locale/babel_underscore.cfg -o $(THEME)/conf/locale/djangojs.pot \
		--msgid-bugs-address=ajuda@nau.edu.pt --copyright-holder=FCT-FCCN -c Translators $(THEME)/*
	@printf "$(COLOR_SUCCESS)✓ Strings extracted$(COLOR_RESET)\n"
.PHONY: translations_extract

translations_po_files: check-venv ## Update .po files from .pot templates
	@printf "$(COLOR_INFO)Updating .po files for $(THEME)...$(COLOR_RESET)\n"
	@$(VENV_ACTIVATE) && \
	$(VENV_BIN)/pybabel update -N -D django -i $(THEME)/conf/locale/django.pot -d $(THEME)/conf/locale/ && \
	$(VENV_BIN)/pybabel update -N -D djangojs -i $(THEME)/conf/locale/djangojs.pot -d $(THEME)/conf/locale/
	@printf "$(COLOR_SUCCESS)✓ .po files updated$(COLOR_RESET)\n"
.PHONY: translations_po_files

translations_compile: check-venv ## Compile .po files to .mo files
	@printf "$(COLOR_INFO)Compiling translations for $(THEME)...$(COLOR_RESET)\n"
	@$(VENV_ACTIVATE) && \
	$(VENV_BIN)/pybabel compile -f -D django -d $(THEME)/conf/locale/ && \
	$(VENV_BIN)/pybabel compile -f -D djangojs -d $(THEME)/conf/locale/
	@printf "$(COLOR_SUCCESS)✓ Translations compiled$(COLOR_RESET)\n"
.PHONY: translations_compile

translations_clean_intermediate: ## Remove intermediate .pot files
	@rm -f $(THEME)/conf/locale/django.pot
	@rm -f $(THEME)/conf/locale/djangojs.pot
.PHONY: translations_clean_intermediate

translations: check-venv translations_extract translations_po_files translations_clean_intermediate translations_compile ## Full translation workflow: extract, update, and compile
	@printf "$(COLOR_SUCCESS)✓ EdX Platform translation workflow complete$(COLOR_RESET)\n"
.PHONY: translations

translations_is_missing: check-venv translations_extract translations_po_files translations_clean_intermediate ## Check if translations need updating
	@printf "$(COLOR_INFO)Checking for missing translations in $(THEME)...$(COLOR_RESET)\n"
	@cd $(THEME) && git diff --numstat *.po | awk '{if ($$1>1 || $$2>1) { exit 1 } else { exit 0 }}'
.PHONY: translations_is_missing

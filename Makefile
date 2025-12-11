########################################################################################################################
# NAU Themes - Master Makefile
# Manages shared infrastructure and orchestrates subdirectory builds
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

# Python configuration - require Python 3.11+
REQUIRED_PYTHON_VERSION := 3.11
PYTHON := python

# Virtual environment paths
VENV_DIR := venv
VENV_BIN := $(VENV_DIR)/bin
VENV_PYTHON := $(VENV_BIN)/python
VENV_PIP := $(VENV_BIN)/pip
VENV_ACTIVATE := . $(VENV_BIN)/activate

# Subdirectories with Makefiles
EDX_PLATFORM_DIR := edx-platform
ECOMMERCE_DIR := ecommerce

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
	@printf "$(COLOR_INFO)NAU Themes - Master Build System$(COLOR_RESET)\n"
	@printf "\n"
	@printf "$(COLOR_INFO)Shared Infrastructure:$(COLOR_RESET)\n"
	@perl -nle'print $$& if m{^[\.a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | grep -E "^(venv|virtual_environment|check-python|check-venv|requirements|clean):" | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-30s %s\n", $$1, $$2}'
	@printf "\n"
	@printf "$(COLOR_INFO)Translation Orchestration:$(COLOR_RESET)\n"
	@perl -nle'print $$& if m{^[\.a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | grep -E "^translations" | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-30s %s\n", $$1, $$2}'
	@printf "\n"
	@printf "$(COLOR_WARNING)For component-specific targets, cd into $(EDX_PLATFORM_DIR)/ or $(ECOMMERCE_DIR)/ and run 'make help'$(COLOR_RESET)\n"
.PHONY: help

check-python: ## Verify Python 3.11+ is available
	@printf "$(COLOR_INFO)Checking Python version...$(COLOR_RESET)\n"
	@if [ -z "$(PYTHON)" ]; then \
		printf "$(COLOR_ERROR)Error: Python 3 not found$(COLOR_RESET)\n" >&2; \
		exit 1; \
	fi
	@PYTHON_VERSION=$$($(PYTHON) -c 'import sys; print(".".join(map(str, sys.version_info[:2])))'); \
	REQUIRED_VERSION="$(REQUIRED_PYTHON_VERSION)"; \
	if [ "$$(printf '%s\n' "$$REQUIRED_VERSION" "$$PYTHON_VERSION" | sort -V | head -n1)" != "$$REQUIRED_VERSION" ]; then \
		printf "$(COLOR_ERROR)Error: Python $$PYTHON_VERSION found, but Python $(REQUIRED_PYTHON_VERSION)+ is required$(COLOR_RESET)\n" >&2; \
		exit 1; \
	fi; \
	printf "$(COLOR_SUCCESS)✓ Python $$PYTHON_VERSION detected$(COLOR_RESET)\n"
.PHONY: check-python

check-venv: ## Verify virtual environment exists
	@if [ ! -d "$(VENV_DIR)" ]; then \
		printf "$(COLOR_ERROR)Error: Virtual environment not found. Run 'make venv' first.$(COLOR_RESET)\n" >&2; \
		exit 1; \
	fi
.PHONY: check-venv

########################################################################################################################
# Environment Setup
########################################################################################################################

venv: check-python requirements.txt ## Create virtual environment with Python 3.11+
	@printf "$(COLOR_INFO)Creating virtual environment...$(COLOR_RESET)\n"
	@test -d $(VENV_DIR) || $(PYTHON) -m venv $(VENV_DIR)
	@$(VENV_ACTIVATE) && \
		$(VENV_PIP) install --upgrade pip setuptools wheel && \
		$(VENV_PIP) install -r requirements.txt
	@printf "$(COLOR_SUCCESS)✓ Virtual environment ready$(COLOR_RESET)\n"
	@printf "$(COLOR_INFO)To activate manually, run: . $(VENV_BIN)/activate$(COLOR_RESET)\n"
.PHONY: venv

# Alias for backward compatibility
virtual_environment: venv ## Alias for 'venv' target
.PHONY: virtual_environment

requirements: check-venv ## Install/update requirements in existing venv
	@printf "$(COLOR_INFO)Installing requirements...$(COLOR_RESET)\n"
	@$(VENV_ACTIVATE) && $(VENV_PIP) install -r requirements.txt
	@printf "$(COLOR_SUCCESS)✓ Requirements installed$(COLOR_RESET)\n"
.PHONY: requirements

clean: ## Remove virtual environment
	@printf "$(COLOR_WARNING)Removing virtual environment...$(COLOR_RESET)\n"
	@rm -rf $(VENV_DIR)
	@printf "$(COLOR_SUCCESS)✓ Cleanup complete$(COLOR_RESET)\n"
.PHONY: clean

########################################################################################################################
# Translation Orchestration Targets
########################################################################################################################

translations-edx: check-venv ## Run translation workflow for edx-platform theme
	@printf "$(COLOR_INFO)Running edx-platform translations...$(COLOR_RESET)\n"
	@$(MAKE) -C $(EDX_PLATFORM_DIR) translations VENV_DIR=../$(VENV_DIR)
	@printf "$(COLOR_SUCCESS)✓ EdX Platform translations complete$(COLOR_RESET)\n"
.PHONY: translations-edx

translations-ecommerce: check-venv ## Run translation workflow for ecommerce theme
	@printf "$(COLOR_INFO)Running ecommerce translations...$(COLOR_RESET)\n"
	@$(MAKE) -C $(ECOMMERCE_DIR) translations VENV_DIR=../$(VENV_DIR)
	@printf "$(COLOR_SUCCESS)✓ Ecommerce translations complete$(COLOR_RESET)\n"
.PHONY: translations-ecommerce

translations-all: translations-edx translations-ecommerce ## Run translation workflow for all themes
	@printf "$(COLOR_SUCCESS)✓ All translations complete$(COLOR_RESET)\n"
.PHONY: translations-all

# Default translations target runs all
translations: translations-all ## Alias for translations-all
.PHONY: translations

translations-extract-edx: check-venv ## Extract translatable strings from edx-platform theme
	@$(MAKE) -C $(EDX_PLATFORM_DIR) translations_extract VENV_DIR=../$(VENV_DIR)
.PHONY: translations-extract-edx

translations-extract-ecommerce: check-venv ## Extract translatable strings from ecommerce theme
	@$(MAKE) -C $(ECOMMERCE_DIR) translations_extract VENV_DIR=../$(VENV_DIR)
.PHONY: translations-extract-ecommerce

translations-extract-all: translations-extract-edx translations-extract-ecommerce ## Extract strings from all themes
.PHONY: translations-extract-all

translations-compile-edx: check-venv ## Compile translations for edx-platform theme
	@$(MAKE) -C $(EDX_PLATFORM_DIR) translations_compile VENV_DIR=../$(VENV_DIR)
.PHONY: translations-compile-edx

translations-compile-ecommerce: check-venv ## Compile translations for ecommerce theme
	@$(MAKE) -C $(ECOMMERCE_DIR) translations_compile VENV_DIR=../$(VENV_DIR)
.PHONY: translations-compile-ecommerce

translations-compile-all: translations-compile-edx translations-compile-ecommerce ## Compile all translations
.PHONY: translations-compile-all

translations-is-missing-edx: check-venv ## Check if edx-platform translations need updating
	@$(MAKE) -C $(EDX_PLATFORM_DIR) translations_is_missing VENV_DIR=../$(VENV_DIR)
.PHONY: translations-is-missing-edx

translations-is-missing-ecommerce: check-venv ## Check if ecommerce translations need updating
	@$(MAKE) -C $(ECOMMERCE_DIR) translations_is_missing VENV_DIR=../$(VENV_DIR)
.PHONY: translations-is-missing-ecommerce

translations-is-missing: translations-is-missing-edx translations-is-missing-ecommerce ## Check if any translations need updating
.PHONY: translations-is-missing

ci: check-venv translations-is-missing ## CI target to verify translations are up to date
	@printf "$(COLOR_SUCCESS)✓ CI translation check complete$(COLOR_RESET)\n"
.PHONY: ci

########################################################################################################################
#
# Ecommerce nau theme
#
########################################################################################################################
.DEFAULT_GOAL := help
ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

lang_targets = en pt_PT
theme = nau

# Generates a help message. Borrowed from https://github.com/pydanny/cookiecutter-djangopackage.
help: ## Display this help message
	@echo "Please use \`make <target>' where <target> is one of"
	@perl -nle'print $& if m{^[\.a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m  %-25s\033[0m %s\n", $$1, $$2}'

virtual_environment: ../requirements.txt ## create a virtual environment to run other commands
	test -d venv || virtualenv venv --python=python3
	. venv/bin/activate && python -m pip install -Ur ../requirements.txt
	touch venv/touchfile
	@echo "Run on your shell to activate the new virtual environment:"
	@echo "  . venv/bin/activate"

clean: ## clean
	rm -rf venv
.PHONY: clean

extract_translations:  ## Extract translations from source code
	@for lang in $(lang_targets) ; do \
		cd $(ROOT_DIR)/$(theme) && DJANGO_SETTINGS_MODULE="" django-admin makemessages --locale $$lang -d django ; \
	done
.PHONY: extract_translations

compile_translations:  ## Compiles the extracted translations
	@cd $(ROOT_DIR)/$(theme) && DJANGO_SETTINGS_MODULE="" django-admin compilemessages
.PHONY: compile_translations

detect_changed_source_translations:
	@test $$(git diff --exit-code -G "^(msgid|msgstr)" | wc -l) -eq 0 || ( echo "Detected a changed source translations!" ; exit 1 )
.PHONY: detect_changed_source_translations

translations: | extract_translations compile_translations ## Extract and compile translations
.PHONY: translations

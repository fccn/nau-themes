########################################################################################################################
#
#
########################################################################################################################
.DEFAULT_GOAL := help

# Execute everything on same shell, so the active of the virtualenv works on the next command
#.ONESHELL:

.PHONY: install

#SHELL=./make-venv

# include *.mk

virtual_environment: requirements.txt ## create a virtual environment to run other commands
	test -d venv || python3 -m venv venv
	. venv/bin/activate && python -m pip install -Ur requirements.txt
	touch venv/touchfile
	@echo "Run on your shell to activate the new virtual environment:"
	@echo "  . venv/bin/activate"

requirements: ## Install requirements
	@python -m pip install -Ur requirements.txt

clean: ## clean
	rm -rf venv

# TODO: make dynamic
theme = edx-platform/nau-basic

# TODO: define somewhere else
lang_targets = en pt_PT

translations_create_catalogs: | translations_extract
	for lang in $(lang_targets) ; do \
        pybabel init -i $(theme)/conf/locale/django.pot -D django -d $(theme)/conf/locale/ -l $$lang ; \
		pybabel init -i $(theme)/conf/locale/djangojs.pot -D djangojs -d $(theme)/conf/locale/ -l $$lang ; \
    done

translations_extract:
	pybabel extract -F $(theme)/conf/locale/babel_mako.cfg -o $(theme)/conf/locale/django.pot --msgid-bugs-address=ajuda@nau.edu.pt --copyright-holder=FCT-FCCN -c Translators $(theme)/*
	pybabel extract -F $(theme)/conf/locale/babel_underscore.cfg -o $(theme)/conf/locale/djangojs.pot --msgid-bugs-address=ajuda@nau.edu.pt --copyright-holder=FCT-FCCN -c Translators $(theme)/*

translations: | translations_extract translations_po_files translations_clean_intermediate translations_compile ## update strings to be translated

translations_clean_intermediate:
	rm -f $(theme)/conf/locale/django.pot
	rm -f $(theme)/conf/locale/djangojs.pot

translations_po_files:
	pybabel update -N -D django -i $(theme)/conf/locale/django.pot -d $(theme)/conf/locale/
	pybabel update -N -D djangojs -i $(theme)/conf/locale/djangojs.pot -d $(theme)/conf/locale/

translations_compile:
	pybabel compile -f -D django -d $(theme)/conf/locale/
	pybabel compile -f -D djangojs -d $(theme)/conf/locale/

translations_is_missing: | translations_extract translations_po_files translations_clean_intermediate ## Check if `make translations` should be run
	git diff --numstat *.po | awk '{if ($$1>1 || $$2>1) { exit 1 } else { exit 0 }}'

# Generates a help message. Borrowed from https://github.com/pydanny/cookiecutter-djangopackage.
help: ## Display this help message
	@echo "Please use \`make <target>' where <target> is one of"
	@perl -nle'print $& if m{^[\.a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m  %-25s\033[0m %s\n", $$1, $$2}'

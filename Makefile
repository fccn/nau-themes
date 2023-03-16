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
	test -d venv || virtualenv venv --python=python3
	. venv/bin/activate && python -m pip install -Ur requirements.txt
	touch venv/touchfile
	@echo "Run on your shell to activate the new virtual environment:"
	@echo "  . venv/bin/activate"

clean: ## clean
	rm -rf venv

# TODO: make dynamic
theme = edx-platform/nau-basic
COMPOSE_PROJECT_NAME= nau-juniper-devstack

# TODO: define somewhere else
lang_targets = en pt_PT

create_translations_catalogs: | extract_translations
	for lang in $(lang_targets) ; do \
        pybabel init -i $(theme)/conf/locale/django.pot -D django -d $(theme)/conf/locale/ -l $$lang ; \
		pybabel init -i $(theme)/conf/locale/djangojs.pot -D djangojs -d $(theme)/conf/locale/ -l $$lang ; \
    done

extract_translations:
	pybabel extract -F $(theme)/conf/locale/babel_mako.cfg -o $(theme)/conf/locale/django.pot --msgid-bugs-address=ajuda@nau.edu.pt --copyright-holder=FCT-FCCN -c Translators $(theme)/*
	pybabel extract -F $(theme)/conf/locale/babel_underscore.cfg -o $(theme)/conf/locale/djangojs.pot --msgid-bugs-address=ajuda@nau.edu.pt --copyright-holder=FCT-FCCN -c Translators $(theme)/*

update_translations: | extract_translations update_translations_po_files clean_translations_intermediate compile_translations ## update strings to be translated

clean_translations_intermediate:
	rm -f $(theme)/conf/locale/django.pot
	rm -f $(theme)/conf/locale/djangojs.pot

update_translations_po_files:
	pybabel update -N -D django -i $(theme)/conf/locale/django.pot -d $(theme)/conf/locale/
	pybabel update -N -D djangojs -i $(theme)/conf/locale/djangojs.pot -d $(theme)/conf/locale/

compile_translations:
	pybabel compile -f -D django -d $(theme)/conf/locale/
	pybabel compile -f -D djangojs -d $(theme)/conf/locale/

check_miss_run_update_translations: | extract_translations update_translations_po_files clean_translations_intermediate ## Check if `make update_translations` should be run
	git diff --numstat *.po | awk '{if ($$1>1 || $$2>1) { exit 1 } else { exit 0 }}'

publish_lms_devstack: | update_translations ## Publish changes to LMS devstack
	@echo "Running compilejsi18n && collectstatic at lms"
	@docker exec -t edx.$(COMPOSE_PROJECT_NAME).lms bash -c 'source /edx/app/edxapp/edxapp_env && cd /edx/app/edxapp/edx-platform/ && python manage.py lms compilejsi18n --locale pt-pt'
	@docker exec -t edx.$(COMPOSE_PROJECT_NAME).lms bash -c 'source /edx/app/edxapp/edxapp_env && cd /edx/app/edxapp/edx-platform/ && python manage.py lms compilejsi18n --locale en'
	@docker exec -t edx.$(COMPOSE_PROJECT_NAME).lms bash -c 'source /edx/app/edxapp/edxapp_env && cd /edx/app/edxapp/edx-platform/ && python manage.py lms collectstatic -i *css -i templates -i vendor --noinput -v2 | grep Copying | grep i18n'
	@docker exec -t edx.$(COMPOSE_PROJECT_NAME).lms bash -c 'kill $$(ps aux | grep "manage.py lms" | egrep -v "while|grep" | awk "{print \$$2}")'

publish_studio_devstack: | update_translations ## Publish changes to STUDIO devstack
	@echo "Running compilejsi18n && collectstatic at studio"
	@docker exec -t edx.$(COMPOSE_PROJECT_NAME).studio bash -c 'source /edx/app/edxapp/edxapp_env && cd /edx/app/edxapp/edx-platform/ && python manage.py cms compilejsi18n --locale pt-pt'
	@docker exec -t edx.$(COMPOSE_PROJECT_NAME).studio bash -c 'source /edx/app/edxapp/edxapp_env && cd /edx/app/edxapp/edx-platform/ && python manage.py cms compilejsi18n --locale en'
	@docker exec -t edx.$(COMPOSE_PROJECT_NAME).studio bash -c 'source /edx/app/edxapp/edxapp_env && cd /edx/app/edxapp/edx-platform/ && python manage.py cms collectstatic -i *css -i templates -i vendor --noinput -v2 | grep Copying | grep i18n'
	@docker exec -t edx.$(COMPOSE_PROJECT_NAME).studio bash -c 'kill $$(ps aux | grep "manage.py cms" | egrep -v "while|grep" | awk "{print \$$2}")'

# Generates a help message. Borrowed from https://github.com/pydanny/cookiecutter-djangopackage.
help: ## Display this help message
	@echo "Please use \`make <target>' where <target> is one of"
	@perl -nle'print $& if m{^[\.a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m  %-25s\033[0m %s\n", $$1, $$2}'

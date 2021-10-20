.PHONY: help prepare-dev init test

# Python stuff
VENV_NAME?=.venv
PYTHON3 := $(shell command -v python3 2> /dev/null)
VENV_ACTIVATE=$(VENV_NAME)/bin/activate
PYTHON=$(VENV_NAME)/bin/python3

PACKAGE_NAME=co.nimblehq.flutter.template
PROJECT_NAME=flutter_templates
APP_NAME=Flutter Templates

.DEFAULT: help
help:
	@echo "make prepare-dev"
	@echo "        prepare development environment, use only once"
	@echo "make init PACKAGE_NAME=com.example PROJECT_NAME=new_templates"
	@echo "        init project with the new package name and project name"
	@echo "make test"
	@echo "        run the tests for the setup.py script"

prepare-dev:
	@if [ -z $(PYTHON3) ]; then \
		echo "python3 could not be found. Installing..."; \
		brew install python3; \
	fi
	python3 -m pip install pipenv
	python3 -m venv $(VENV_NAME)

init: prepare-dev
	$(PYTHON) ./scripts/setup.py --project_path $(PWD) --package_name $(PACKAGE_NAME) --project_name $(PROJECT_NAME)

test: prepare-dev
	$(PYTHON) ./scripts/test.py

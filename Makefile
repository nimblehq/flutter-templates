.PHONY: help prepare-dev init test run

# Python stuff
VENV_NAME?=.venv
PYTHON3 := $(shell command -v python3 2> /dev/null)
VENV_ACTIVATE=$(VENV_NAME)/bin/activate
PYTHON=$(VENV_NAME)/bin/python3

PACKAGE_NAME=co.nimblehq.flutter.template
PROJECT_NAME=flutter_templates
APP_NAME=Flutter Templates

# Add the variable to env
export PACKAGE_NAME
export PROJECT_NAME
export APP_NAME

.DEFAULT: help
help:
	@echo "make run PACKAGE_NAME=com.your.package PROJECT_NAME=your_project_name APP_NAME=\"Your App Name\""
	@echo "        init the project then run all the test"
	@echo "make prepare-dev"
	@echo "        prepare development environment, use only once"
	@echo "make init PACKAGE_NAME=com.your.package PROJECT_NAME=your_project_name APP_NAME=\"Your App Name\""
	@echo "        init project with the new package name, the new project name and the new app name"
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
	$(PYTHON) ./scripts/setup.py --project_path $(PWD) --package_name $(PACKAGE_NAME) --project_name $(PROJECT_NAME) --app_name "$(APP_NAME)"

test: prepare-dev
	$(PYTHON) ./scripts/test.py

run: init test

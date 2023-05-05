# Makefile to simplify some of the common commands.
# 	Goal: maintain reasonable cross-platform capability between:
# 		- MacOS,
# 		- WSL on Windows and
# 		- native Linux
.DEFAULT_GOAL := help

# General Variables
project := $(shell basename `pwd`)
workspace := "$(env)"
container := $(project)
docker-filecheck := /.dockerenv
docker-warning := ""
env-resources := ""
# AWS Account Profile
export AWS_PROFILE=inves-global

# Docker Warning
ifeq ("$(wildcard $(docker-filecheck))","")
	docker-warning = "⚠️  WARNING: Can't find /.dockerenv - it's strongly recommended that you run this from within the docker container."
endif

# Targets
help:
	@echo "Docker-Helper functions for building & running the the $(project) container(s)"
	@echo "---------------------------------------------------------------------------------------------"
	@echo "Targets:"
	@echo "  Docker Targets (run from local machine)"
	@echo "   - up     : brings up the contaier(s) & attach to the default container ($(default-container))"
	@echo "   - down   : stops the container(s)"
	@echo "   - build  : (re)builds the container(s)"
	@echo "  Service Targets (should only be run inside the docker container)"
	@echo "   - run    : run the service"
	@echo "   - deploy : deploy the service"
	@echo ""
	@echo "Options:"
	@echo " - env    : sets the environment - supported environments are: global | dev | prod"
	@echo ""
	@echo "Examples:"
	@echo " - Start Docker Container            : make up"
	@echo " - Rebuild Docker Container          : make build"
	@echo " - Rebuild & Start Docker Container  : make build up"

set-credentials:
	@echo "🚀 Validating the environment..."
	@# HACK: This is needed for WSL on Windows 10, since WSL has no way to map ~/.aws into a docker container,
	@#       as the ~ folder in WSL seems to be inaccessible to Docker for Windows
	@# TODO: Find a better way.
	@rsync -rup ~/.aws .

up: set-credentials down docker-network-required
	@echo "🚀 Starting containers..."
	@docker compose up -d
	@echo "🚀 Attaching shell..."
	@docker compose exec $(container) bash 
 
shell: set-credentials
	@echo "🚀 Attaching shell..."
	@docker compose exec $(container) bash

down: set-credentials docker-network-required
	@echo "🚀 Stopping containers..."
	@docker compose down

build: set-credentials down
	@echo "🚀 Building containers..."
	@docker compose build

generate: 
	@echo "🚀 (RE)Generating Typedefs..."
	yarn generate

yarn: 
	@echo "🚀 Doing base yarn install..."
	@yarn --ignore-optional

run: yarn
	@echo "🚀 Starting the $(project) service..."
	yarn dev

deploy: yarn lint test compile apply-only
	@echo "🚀 Deployed the $(project) service!"

compile: yarn lint 
	@echo "🚀 Compiling the $(project) service..."
	@yarn compile_esbuild
	@yarn zip

test: yarn 
	@echo "🚀 Testing the $(project) service..."
	@echo "📓 Using -maxWorkers=50% as per https://dev.to/vantanev/make-your-jest-tests-up-to-20-faster-by-changing-a-single-setting-i36"
	yarn jest --maxWorkers=50%

test-watch: yarn 
	@echo "🚀 Testing the $(project) service..."
	@echo "📓 Using -maxWorkers=25% as per https://dev.to/vantanev/make-your-jest-tests-up-to-20-faster-by-changing-a-single-setting-i36"
	yarn jest --watch --maxWorkers=25%

lint: yarn 
	@echo "🚀 Checking Linting..."
	@yarn eslint --max-warnings=0 ./src

plan: 
	$(call check_defined, env, Please set the env to plan for. Supported environments are: global | dev | prod )
	@echo 'Switching to the [$(value workspace)] environment ...'
	terraform -chdir='./infrastructure' workspace select $(value workspace) ; \
	terraform -chdir='./infrastructure' plan -out $(value env).tfplan

apply:
	$(call check_defined, env, Please set the env to plan for. Supported environments are: global | dev | prod )
	@echo 'Switching to the [$(value workspace)] environment ...'
	terraform -chdir='./infrastructure' fmt ; \
	terraform -chdir='./infrastructure' workspace select $(value workspace) ; \
	echo "Applying the following to [$(value env)] environment:" ; \
	terraform -chdir='./infrastructure' show $(value env).tfplan ; \
	terraform -chdir='./infrastructure' apply $(value env).tfplan

apply-only: yarn lint test compile
	$(call check_defined, env, Please set the env to plan for. Supported environments are: global | dev | prod )
	@echo 'Switching to the [$(value workspace)] environment ...'
	terraform -chdir='./infrastructure' fmt ; \
	terraform -chdir='./infrastructure' workspace select $(value workspace) ; \
	terraform -chdir='./infrastructure' apply

destroy:
	$(call check_defined, env, Please set the env to plan for. Supported environments are: global | dev | prod )
	@echo 'Switching to the [$(value workspace)] environment ...'
	terraform -chdir='./infrastructure' fmt ; \
	terraform -chdir='./infrastructure' workspace select $(value workspace) ; \
	terraform -chdir='./infrastructure' destroy 

init:
	@echo "Initialising Terraform"
	@echo ""
	terraform -chdir='./infrastructure' init
	terraform -chdir='./infrastructure' workspace new dev || true
	terraform -chdir='./infrastructure' workspace new prod || true

docker-check:
	$(call assert-file-exists,$(docker-filecheck), This step should only be run from Docker. Please run `make up` first.)

env-check:
	$(call assert, env, No environment set. Supported environments are: [ dev | prod ]. Please set the env variable. e.g. `make env=dev plan`)

docker-network-required:
		@if [ ! "$$(docker network ls | grep inves-global)" ]; then \
			echo "Creating Docker Network inves-global ..." ;\
			docker network create inves-global ;\
		else \
			echo "Docker Network inves-global exists." ;\
		fi


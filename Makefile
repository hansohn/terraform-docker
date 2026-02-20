MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := dev
.DELETE_ON_ERROR:
.SUFFIXES:

# include makefiles
export SELF ?= $(MAKE)
PROJECT_PATH ?= $(shell pwd)
include $(PROJECT_PATH)/Makefile.*

REPO_NAME ?= $(shell basename $(CURDIR))

#-------------------------------------------------------------------------------
# docker
#-------------------------------------------------------------------------------

DOCKER_USER ?= hansohn
DOCKER_REPO ?= terraform
DOCKER_TAG_BASE ?= $(DOCKER_USER)/$(DOCKER_REPO)

DISTRO ?= bookworm-slim
DOCKER_BUILD_PATH ?= ./docker/$(DISTRO)
DOCKER_BUILD_CACHE_PATH ?= /tmp/.buildx-cache/$(REPO_NAME)/$(DISTRO)

TERRAFORM_DOCS_VERSION ?= latest
TERRAFORM_VERSION ?= latest
TERRAGRUNT_VERSION ?= latest
TFGET_VERSION ?= latest
TFLINT_VERSION ?= latest
TFSEC_VERSION ?= latest

GIT_BRANCH ?= $(shell git branch --show-current 2>/dev/null || echo 'unknown')
GIT_HASH := $(shell git rev-parse --short HEAD 2>/dev/null || echo 'pre')

DOCKER_TAGS ?=
DOCKER_TAGS += --tag $(DOCKER_TAG_BASE):$(GIT_HASH)-$(TERRAFORM_VERSION)-$(DISTRO)
ifeq ($(GIT_BRANCH), main)
DOCKER_TAGS += --tag $(DOCKER_TAG_BASE):latest
DOCKER_TAGS += --tag $(DOCKER_TAG_BASE):$(TERRAFORM_VERSION)
DOCKER_TAGS += --tag $(DOCKER_TAG_BASE):$(TERRAFORM_VERSION)-$(DISTRO)
endif

# Platform configuration - default to local platform for single-platform builds with --load
# For multi-platform builds, set DOCKER_PLATFORMS to "linux/amd64,linux/arm64"
DOCKER_LOCAL_PLATFORM ?= $(shell docker version --format '{{.Server.Os}}/{{.Server.Arch}}' 2>/dev/null || echo 'linux/amd64')
DOCKER_PLATFORMS ?= $(DOCKER_LOCAL_PLATFORM)
DOCKER_MULTI_PLATFORM := $(shell echo "$(DOCKER_PLATFORMS)" | grep -q ',' && echo true || echo false)

DOCKER_BUILD_ARGS ?=
DOCKER_BUILD_ARGS += --build-arg TERRAFORM_DOCS_VERSION=$(TERRAFORM_DOCS_VERSION)
DOCKER_BUILD_ARGS += --build-arg TERRAFORM_VERSION=$(TERRAFORM_VERSION)
DOCKER_BUILD_ARGS += --build-arg TERRAGRUNT_VERSION=$(TERRAGRUNT_VERSION)
DOCKER_BUILD_ARGS += --build-arg TFGET_VERSION=$(TFGET_VERSION)
DOCKER_BUILD_ARGS += --build-arg TFLINT_VERSION=$(TFLINT_VERSION)
DOCKER_BUILD_ARGS += --build-arg TFSEC_VERSION=$(TFSEC_VERSION)
DOCKER_BUILD_ARGS += --platform=$(DOCKER_PLATFORMS)
# Only import cache if it exists and has content
ifneq ($(wildcard $(DOCKER_BUILD_CACHE_PATH)/index.json),)
DOCKER_BUILD_ARGS += --cache-from type=local,src=$(DOCKER_BUILD_CACHE_PATH)
endif
DOCKER_BUILD_ARGS += --cache-to type=local,dest=$(DOCKER_BUILD_CACHE_PATH)
# Only add --load for single-platform builds (multi-platform builds require --push)
ifeq ($(DOCKER_MULTI_PLATFORM),false)
DOCKER_BUILD_ARGS += --load
endif
DOCKER_BUILD_ARGS += $(DOCKER_TAGS)

DOCKER_RUN_ARGS ?=
DOCKER_RUN_ARGS += --interactive
DOCKER_RUN_ARGS += --tty
DOCKER_RUN_ARGS += --rm

DOCKER_PUSH_ARGS ?=
DOCKER_PUSH_ARGS += --all-tags
DOCKER_PUSH_ARGS += --platform=$(DOCKER_PLATFORMS)

## Check if Docker daemon is running
docker/check:
	@docker info > /dev/null 2>&1 || (echo "[ERROR] Docker daemon is not running." && exit 1)
.PHONY: docker/check

## Lint Dockerfile
docker/lint: docker/check
	@echo "[INFO] Linting '$(DOCKER_REPO)/Dockerfile'."
	@docker run --rm -i -v $(PWD)/$(DOCKER_BUILD_PATH):/mnt:ro hadolint/hadolint hadolint --failure-threshold error /mnt/Dockerfile
.PHONY: docker/lint

## Docker build image
docker/build: docker/check
	@echo "[INFO] Building '$(DOCKER_USER)/$(DOCKER_REPO)' docker image."
	@docker buildx build $(DOCKER_BUILD_ARGS) $(DOCKER_BUILD_PATH)/
.PHONY: docker/build

## Docker run image
docker/run: docker/check
	@echo "[INFO] Running '$(DOCKER_USER)/$(DOCKER_REPO)' docker image"
	@docker run $(DOCKER_RUN_ARGS) "$(DOCKER_TAG_BASE):$(GIT_HASH)" bash
.PHONY: docker/run

## Docker push image
docker/push: docker/check
	@echo "[INFO] Pushing '$(DOCKER_USER)/$(DOCKER_REPO)' docker image"
	@docker push $(DOCKER_PUSH_ARGS) $(DOCKER_TAG_BASE)
.PHONY: docker/push

## Docker clean build images
docker/clean: docker/check
	@if docker inspect --type=image "$(DOCKER_TAG_BASE):$(GIT_HASH)" > /dev/null 2>&1; then \
		echo "[INFO] Removing docker image '$(DOCKER_USER)/$(DOCKER_REPO)'"; \
		docker rmi -f $$(docker inspect --format='{{ .Id }}' --type=image $(DOCKER_TAG_BASE):$(GIT_HASH)); \
	fi
	@if [ -d "$(DOCKER_BUILD_CACHE_PATH)" ] && [ "$$(ls -A $(DOCKER_BUILD_CACHE_PATH))" ]; then \
		echo "[INFO] Removing docker build cache found at '$(DOCKER_BUILD_CACHE_PATH)'"; \
		rm -rf $(DOCKER_BUILD_CACHE_PATH)/*; \
	fi
.PHONY: docker/clean

## Initialize development environment
dev: dev/up
.PHONY: dev

dev/up: docker/lint docker/build docker/run
.PHONY: dev/up

#-------------------------------------------------------------------------------
# clean
#-------------------------------------------------------------------------------

## Clean everything
clean: docker/clean
.PHONY: clean

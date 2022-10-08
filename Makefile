MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

# include makefiles
export SELF ?= $(MAKE)
PROJECT_PATH ?= $(shell 'pwd')
include $(PROJECT_PATH)/Makefile.*

REPO_NAME ?= $(shell basename $(CURDIR))

#-------------------------------------------------------------------------------
# terraform
#-------------------------------------------------------------------------------

TERRAFORM_VERSION ?= latest

#-------------------------------------------------------------------------------
# git
#-------------------------------------------------------------------------------

GIT_BRANCH ?= $(shell git branch --show-current)
GIT_HASH := $(shell git rev-parse --short HEAD)

#-------------------------------------------------------------------------------
# docker
#-------------------------------------------------------------------------------

DOCKER_USER ?= hansohn
DOCKER_REPO ?= terraform
DOCKER_TAG_BASE ?= $(DOCKER_USER)/$(DOCKER_REPO)

DOCKER_TAGS ?=
DOCKER_TAGS += --tag $(DOCKER_TAG_BASE):$(GIT_HASH)
ifeq ($(GIT_BRANCH), main)
DOCKER_TAGS += --tag $(DOCKER_TAG_BASE):latest
DOCKER_TAGS += --tag $(DOCKER_TAG_BASE):$(TERRAFORM_VERSION)
endif

DOCKER_BUILD_PATH ?= debian
DOCKER_BUILD_ARGS ?=
DOCKER_BUILD_ARGS += $(DOCKER_TAGS)

DOCKER_PUSH_ARGS ?=
DOCKER_PUSH_ARGS += --all-tags

## Lint Dockerfile
docker/lint:
	-@if docker stats --no-stream > /dev/null 2>&1; then \
		echo "[INFO] Linting '$(DOCKER_REPO)/Dockerfile'."; \
		docker run --rm -i hadolint/hadolint < $(DOCKER_BUILD_PATH)/Dockerfile; \
	else \
		echo "[ERROR] Docker 'lint' failed. Docker daemon is not Running."; \
	fi
.PHONY: docker/lint

## Docker build image
docker/build:
	-@if docker stats --no-stream > /dev/null 2>&1; then \
		echo "[INFO] Building '$(DOCKER_USER)/$(DOCKER_REPO)' docker image."; \
		docker build $(DOCKER_BUILD_ARGS) $(DOCKER_BUILD_PATH)/; \
	else \
		echo "[ERROR] Docker 'build' failed. Docker daemon is not Running."; \
	fi
.PHONY: docker/build

## Docker run image
docker/run:
	-@if docker stats --no-stream > /dev/null 2>&1; then \
		echo "[INFO] Running '$(DOCKER_USER)/$(DOCKER_REPO)' docker image"; \
		docker run -it --rm "$(DOCKER_TAG_BASE):$(GIT_HASH)" bash; \
	else \
		echo "[ERROR] Docker 'run' failed. Docker daemon is not Running."; \
	fi
.PHONY: docker/run

## Docker push image
docker/push:
	-@if docker stats --no-stream > /dev/null 2>&1; then \
		echo "[INFO] Pushing '$(DOCKER_USER)/$(DOCKER_REPO)' docker image"; \
		docker push $(DOCKER_PUSH_ARGS) $(DOCKER_TAG_BASE); \
	else \
		echo "[ERROR] Docker 'push' failed. Docker daemon is not Running."; \
	fi
.PHONY: docker/push

## Docker build and run image
docker: docker/lint docker/build docker/run
.PHONY: docker

#-------------------------------------------------------------------------------
# clean
#-------------------------------------------------------------------------------

## Clean docker build images
clean/docker:
	-@if docker stats --no-stream > /dev/null 2>&1; then \
		if docker inspect --type=image "$(DOCKER_TAG_BASE):$(GIT_HASH)" > /dev/null 2>&1; then \
			echo "[INFO] Removing docker image '$(DOCKER_USER)/$(DOCKER_REPO)'"; \
			docker rmi -f $$(docker inspect --format='{{ .Id }}' --type=image $(DOCKER_TAG_BASE):$(GIT_HASH)); \
		fi; \
	fi
.PHONY: clean/docker

## Clean everything
clean: clean/docker
.PHONY: clean

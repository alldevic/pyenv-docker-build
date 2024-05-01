#!/usr/bin/make

.PHONY: build assets clean
.DEFAULT_GOAL := assets

include ./.env

SHELL = /bin/bash

DOCKER_RUN = docker run --rm -it

build:
	docker build -t pyenv \
	--build-arg USER_NAME=$(USER_NAME) \
	--build-arg PYENV_ROOT=$(PYENV_ROOT) \
	--build-arg PYTHON_CONFIGURE_OPTS=$(PYTHON_CONFIGURE_OPTS) \
	--build-arg PYTHON_CFLAGS=$(PYTHON_CFLAGS) \
	--build-arg PROFILE_TASK=$(PROFILE_TASK) \
	--build-arg DEFAULT_PACKAGES=$(DEFAULT_PACKAGES) \
	--progress=plain .

assets: clean build
	$(DOCKER_RUN) \
	-v $(PWD)/assets:/opt/mount \
	--entrypoint cp pyenv:latest /home/$(USER_NAME)/pyenv.tar.gz /opt/mount/pyenv.tar.gz

clean:
	rm -rf assets/*
	touch assets/.gitkeep

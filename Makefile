#
# Copyright 2020, Data61/CSIRO
#
# SPDX-License-Identifier: BSD-2-Clause
#

# Docker-compatible image tool to use (could also be 'podman')
DOCKER ?= docker
DOCKERHUB ?= ghcr.io/sel4-cap/

# Base images
DEBIAN_IMG ?= debian:bullseye
BASETOOLS_IMG ?= base_tools

# Core images
SEL4_IMG ?= sel4
CAMKES_IMG ?= camkes
MICROKIT_IMG ?= microkit
MAAXBOARD_IMG ?= maaxboard

# Interactive images
EXTRAS_IMG := extras
USER_IMG := user_img-$(shell whoami)
HOST_DIR ?= $(shell pwd)

# Volumes
DOCKER_VOLUME_HOME ?= $(shell whoami)-home

# Extra vars
DOCKER_BUILD ?= $(DOCKER) build
DOCKER_FLAGS ?= --force-rm=true
ifndef EXEC
	EXEC := bash --login
	DOCKER_RUN_FLAGS += -it
endif

ETC_LOCALTIME := $(realpath /etc/localtime)

# User in the container.
EXTRA_DOCKER_RUN_ARGS := -u $(shell id -u):$(shell id -g)

################################################
# Default to showing usage.
################################################
.PHONY: usage
usage: 
	@echo "usage: make <target> <options>"
	@echo ""
	@echo "=============================="
	@echo "Use:"
	@echo "=============================="
	@echo "Launch Docker image for use."
	@echo "<target> as one off:"
	@echo "user_sel4"
	@echo "user_camkes"
	@echo "user_microkit"
	@echo "user_maaxboard"
	@echo ""
	@echo "<options> as one or more:"
	@echo "HOST_DIR=<path> (available in container as: /host)"
	@echo ""
	@echo "=============================="
	@echo "Pull:"
	@echo "=============================="
	@echo "Pull images (latest tag) from GitHub Packages into Docker."
	@echo "<target> as one off:"
	@echo "pull_sel4_image"
	@echo "pull_camkes_image"
	@echo "pull_microkit_image"
	@echo "pull_maaxboard_image"
	@echo "pull_all_images (all of the above)"
	@echo ""
	@echo "=============================="
	@echo "Push:"
	@echo "=============================="
	@echo "Push images (latest tag) from Docker into GitHub Packages."
	@echo "<target> as one off:"
	@echo "push_sel4_image"
	@echo "push_camkes_image"
	@echo "push_microkit_image"
	@echo "push_maaxboard_image"
	@echo "push_l4v_image"
	@echo "push_all_images (all of the above)"
	@echo ""
	@echo "=============================="
	@echo "Clean:"
	@echo "=============================="
	@echo "Clean images from Docker."
	@echo "<target> as one off:"
	@echo "clean_home_data"
	@echo "clean_all_datas"
	@echo "clean_user_image"
	@echo "clean_extras_image"
	@echo "clean_sel4_image"
	@echo "clean_camkes_image"
	@echo "clean_microkit_image"
	@echo "clean_maaxboard_image"
	@echo "clean_all_images"
	@echo "clean_all"

################################################
# Pull images.
################################################
.PHONY: pull_sel4_image
pull_sel4_image:
	$(DOCKER) pull $(DOCKERHUB)$(SEL4_IMG)

.PHONY: pull_camkes_image
pull_camkes_image:
	$(DOCKER) pull $(DOCKERHUB)$(CAMKES_IMG)

.PHONY: pull_microkit_image
pull_microkit_image:
	$(DOCKER) pull $(DOCKERHUB)$(MICROKIT_IMG)

.PHONY: pull_maaxboard_image
pull_maaxboard_image:
	$(DOCKER) pull $(DOCKERHUB)$(MAAXBOARD_IMG)

.PHONY: pull_all_images
pull_all_images: pull_sel4_image pull_camkes_image pull_microkit_image pull_maaxboard_image

################################################
# Push images.
################################################
.PHONY: push_sel4_image
push_sel4_image:
	$(DOCKER) push $(DOCKERHUB)$(SEL4_IMG)

.PHONY: push_camkes_image
push_camkes_image:
	$(DOCKER) push $(DOCKERHUB)$(CAMKES_IMG)

.PHONY: push_microkit_image
push_microkit_image:
	$(DOCKER) push $(DOCKERHUB)$(MICROKIT_IMG)

.PHONY: push_maaxboard_image
push_maaxboard_image:
	$(DOCKER) push $(DOCKERHUB)$(MAAXBOARD_IMG)

.PHONY: push_all_images
push_all_images: push_sel4_image push_camkes_image push_microkit_image push_maaxboard_image

################################################
# Making docker easier to use by mapping current
# user into a container.
################################################
.PHONY: user_sel4
user_sel4: build_user_sel4 user_run

.PHONY: user_camkes
user_camkes: EXTRA_DOCKER_RUN_ARGS +=  --group-add stack
user_camkes: build_user_camkes user_run

.PHONY: user_microkit
user_microkit: EXTRA_DOCKER_RUN_ARGS +=  --group-add stack
user_microkit: build_user_microkit user_run

.PHONY: user_maaxboard
user_maaxboard: EXTRA_DOCKER_RUN_ARGS +=  --group-add stack
user_maaxboard: build_user_maaxboard user_run

.PHONY: user_run
user_run:
	$(DOCKER) run \
		$(DOCKER_RUN_FLAGS) \
		--hostname in-container \
		--rm \
		$(EXTRA_DOCKER_RUN_ARGS) \
		--group-add sudo \
		-v $(HOST_DIR):/host:z \
		-v $(DOCKER_VOLUME_HOME):/home/$(shell whoami) \
		-v $(ETC_LOCALTIME):/etc/localtime:ro \
		$(USER_IMG) $(EXEC)

.PHONY: run_checks
run_checks:
ifeq ($(shell id -u),0)
	@echo "You are running this as root (either via sudo, or directly)."
	@echo "This system is designed to run under your own user account."
	@echo "You can add yourself to the docker group to make this work:"
	@echo "    sudo su -c usermod -aG docker your_username"
	@exit 1
endif


.PHONY: build_user
build_user: run_checks
	$(DOCKER_BUILD) $(DOCKER_FLAGS) \
		--build-arg=USER_BASE_IMG=$(DOCKERHUB)$(USER_BASE_IMG) \
		-f dockerfiles/extras.Dockerfile \
		-t $(EXTRAS_IMG) \
		.
	$(DOCKER_BUILD) $(DOCKER_FLAGS) \
		--build-arg=EXTRAS_IMG=$(EXTRAS_IMG) \
		--build-arg=UNAME=$(shell whoami) \
		--build-arg=UID=$(shell id -u) \
		--build-arg=GID=$(shell id -g) \
		--build-arg=GROUP=$(shell id -gn) \
		--build-arg=LOCAL_LANG=$(LANG) \
		-f dockerfiles/user.Dockerfile \
		-t $(USER_IMG) .
build_user_sel4: USER_BASE_IMG = $(SEL4_IMG)
build_user_sel4: build_user
build_user_camkes: USER_BASE_IMG = $(CAMKES_IMG)
build_user_camkes: build_user
build_user_microkit: USER_BASE_IMG = $(MICROKIT_IMG)
build_user_microkit: build_user
build_user_maaxboard: USER_BASE_IMG = $(MAAXBOARD_IMG)
build_user_maaxboard: build_user
build_user_l4v: USER_BASE_IMG = $(L4V_IMG)
build_user_l4v: build_user

.PHONY: clean_home_data
clean_home_data:
	-$(DOCKER) volume rm $(DOCKER_VOLUME_HOME)

.PHONY: clean_all_datas
clean_all_datas: clean_home_data

.PHONY: clean_user_image
clean_user_image:
	-$(DOCKER) rmi $(USER_IMG)

.PHONY: clean_extras_image
clean_extras_image:
	-$(DOCKER) rmi $(EXTRAS_IMG)

.PHONY: clean_sel4_image
clean_sel4_image:
	-$(DOCKER) rmi $(SEL4_IMG)

.PHONY: clean_camkes_image
clean_camkes_image:
	-$(DOCKER) rmi $(CAMKES_IMG)

.PHONY: clean_microkit_image
clean_microkit_image:
	-$(DOCKER) rmi $(MICROKIT_IMG)

.PHONY: clean_maaxboard_image
clean_maaxboard_image:
	-$(DOCKER) rmi $(MAAXBOARD_IMG)

.PHONY: clean_all_images
clean_all_images: clean_user_image clean_extras_image clean_sel4_image clean_camkes_image clean_microkit_image clean_maaxboard_image

.PHONY: clean_all
clean_all: clean_all_datas clean_all_images

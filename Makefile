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
L4V_IMG ?= l4v

# Extra feature images
RUST_IMG ?= sel4-rust
CAMKES_VIS_IMG ?= camkes-vis
PREBUILT_CAKEML_IMG ?= prebuilt_cakeml
BINARY_DECOMP_IMG ?= binary_decomp

# Test images
SEL4_TST_IMG ?= sel4_test
CAMKES_TST_IMG ?= camkes_test
L4V_TST_IMG ?= l4v_test

# Interactive images
EXTRAS_IMG := extras
USER_IMG := user_img-$(shell whoami)
USER_BASE_IMG := $(SEL4_IMG)
HOST_DIR ?= $(shell pwd)

# Volumes
DOCKER_VOLUME_HOME ?= $(shell whoami)-home
DOCKER_VOLUME_ISABELLE ?= $(shell whoami)-isabelle

# Extra vars
DOCKER_BUILD ?= $(DOCKER) build
DOCKER_FLAGS ?= --force-rm=true
ifndef EXEC
	EXEC := bash --login
	DOCKER_RUN_FLAGS += -it
endif

ETC_LOCALTIME := $(realpath /etc/localtime)

# Extra arguments to pass to `docker run` if it is or is not `podman` - these
# are constructed in a very verbose way to be obvious about why we want to do
# certain things under regular `docker` vs` podman`
# Note that `docker --version` will not say "podman" if symlinked.
CHECK_DOCKER_IS_PODMAN  := $(DOCKER) --help 2>&1 | grep -q podman
IF_DOCKER_IS_PODMAN     := $(CHECK_DOCKER_IS_PODMAN) && echo
IF_DOCKER_IS_NOT_PODMAN := $(CHECK_DOCKER_IS_PODMAN) || echo
# If we're not `podman` then we'll use the `-u` and `-g` options to set the
# user in the container
EXTRA_DOCKER_IS_NOT_PODMAN_RUN_ARGS := $(shell $(IF_DOCKER_IS_NOT_PODMAN) \
    "-u $(shell id -u):$(shell id -g)" \
)
# If we are `podman` then we'll prefer to use `--userns=keep-id` to set up and
# use the appropriate sub{u,g}id mappings rather than end up using UID 0 in the
# container
EXTRA_DOCKER_IS_PODMAN_RUN_ARGS     := $(shell $(IF_DOCKER_IS_PODMAN) \
    "--userns=keep-id" \
)
# And we'll jam them into one variable to reduce noise in `docker run` lines
EXTRA_DOCKER_RUN_ARGS   := $(EXTRA_DOCKER_IS_NOT_PODMAN_RUN_ARGS) \
                           $(EXTRA_DOCKER_IS_PODMAN_RUN_ARGS)

###########################
# For 'prebuilt' images, the idea is that for things that take a long
# time to build, and don't change very much, we should build them
# once, and then pull them in as needed.
CAKEML_BASE_DATE ?= 2019_01_13

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
	@echo ""
	@echo ""
	@echo ""
	@echo "HOST_DIR=/home/bellis/l/HOST_DIR"
	@echo ""
	@echo ""
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

.PHONY: pull_l4v_image
pull_l4v_image:
	$(DOCKER) pull $(DOCKERHUB)$(L4V_IMG)

.PHONY: pull_all_images
pull_all_images: pull_sel4_image pull_camkes_image pull_microkit_image pull_maaxboard_image pull_l4v_image

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

.PHONY: push_l4v_image
push_l4v_image:
	$(DOCKER) push $(DOCKERHUB)$(L4V_IMG)

.PHONY: push_all_images
push_all_images: push_sel4_image push_camkes_image push_microkit_image push_maaxboard_image push_l4v_image

################################################
# Making docker easier to use by mapping current
# user into a container.
################################################

.PHONY: user_sel4
user_sel4: build_user_sel4 user_run

.PHONY: user_camkes
user_camkes: user_camkes

.PHONY: user_sel4-riscv
user_sel4-riscv: build_user_sel4-riscv user_run

.PHONY: user_camkes
user_camkes: EXTRA_DOCKER_RUN_ARGS +=  --group-add stack
user_camkes: build_user_camkes user_run

.PHONY: user_microkit
user_microkit: EXTRA_DOCKER_RUN_ARGS +=  --group-add stack
user_microkit: build_user_microkit user_run

.PHONY: user_maaxboard
user_maaxboard: EXTRA_DOCKER_RUN_ARGS +=  --group-add stack
user_maaxboard: build_user_maaxboard user_run

.PHONY: user_camkes-riscv
user_camkes-riscv: EXTRA_DOCKER_RUN_ARGS +=  --group-add stack
user_camkes-riscv: build_user_camkes-riscv user_run

.PHONY: user_l4v
user_l4v: EXTRA_DOCKER_RUN_ARGS +=  --group-add stack
user_l4v: build_user_l4v user_run_l4v

.PHONY: user_l4v-riscv
user_l4v-riscv: EXTRA_DOCKER_RUN_ARGS +=  --group-add stack
user_l4v-riscv: build_user_l4v-riscv user_run_l4v

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

.PHONY: user_run_l4v
user_run_l4v:
	$(DOCKER) run \
		$(DOCKER_RUN_FLAGS) \
		--hostname in-container \
		--rm \
		$(EXTRA_DOCKER_RUN_ARGS) \
		-v $(HOST_DIR):/host:z \
		-v $(DOCKER_VOLUME_HOME):/home/$(shell whoami) \
		-v $(DOCKER_VOLUME_ISABELLE):/isabelle \
		--group-add sudo \
		-v $(ETC_LOCALTIME):/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-e DISPLAY=$(DISPLAY) \
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

	scripts/utils/check_for_old_docker_imgs.sh


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

.PHONY: clean_isabelle
clean_isabelle:
	$(DOCKER) volume rm $(DOCKER_VOLUME_ISABELLE)

.PHONY: clean_home_dir
clean_home_dir:
	$(DOCKER) volume rm $(DOCKER_VOLUME_HOME)

.PHONY: clean_data
clean_data: clean_isabelle clean_home_dir

.PHONY: clean_images
clean_images:
	-$(DOCKER) rmi $(USER_IMG)
	-$(DOCKER) rmi extras
	-$(DOCKER) rmi $(DOCKERHUB)$(L4V_IMG)
	-$(DOCKER) rmi $(DOCKERHUB)$(MAAXBOARD_IMG)
	-$(DOCKER) rmi $(DOCKERHUB)$(MICROKIT_IMG)
	-$(DOCKER) rmi $(DOCKERHUB)$(CAMKES_IMG)
	-$(DOCKER) rmi $(DOCKERHUB)$(SEL4_IMG)

.PHONY: clean
clean: clean_data clean_images

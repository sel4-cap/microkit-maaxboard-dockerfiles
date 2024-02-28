################################################
# Variables.
################################################

# Docker-compatible image tool to use (could also be 'podman')
DOCKERHUB := ghcr.io/sel4-cap

# Username.
USERNAME := $(shell whoami)

# Interactive images.
USER_IMG := user_img-${USERNAME}
HOST_DIR ?= undefined
HOME_DIR ?= undefined
STAMP := $(shell date)

ETC_LOCALTIME := $(realpath /etc/localtime)
EXTRA_DOCKER_RUN_ARGS :=

################################################
# Default to showing usage.
################################################
.PHONY: usage
usage: 
	@echo "usage: make <target> IMAGE=<image> <OPTIONS>"
	@echo ""
	@echo "<target> is one off:"
	@echo "build (build <image> in Docker)"
	@echo "user  (launch <image>, for current user)"
	@echo "pull  (pull <image> from GitHub Packages)"
	@echo "push  (push <image> into GitHub Packages)"
	@echo "clean (removes <image>)"
	@echo ""
	@echo "<image> is one off:"
	@echo "base|sel4|cap|sdk"
	@echo ""
	@echo "<OPTIONS> is one or more off:"
	@echo "HOST_DIR=<path> (mapped as: /host)"
	@echo "HOME_DIR=<path> (mapped as: /home/<username>)"

################################################
# Checks.
################################################
.PHONY: run_checks
run_checks:
ifeq ($(shell id -u),0)
	@echo "You are running this as root (either via sudo, or directly)."
	@echo "This system is designed to run under your own user account."
	@echo "You can add yourself to the docker group to make this work:"
	@echo "    sudo su -c usermod -aG docker your_username"
	@exit 1
endif

################################################
# Build images.
################################################

.PHONY: build
build: run_checks
build:
	ssh-agent bash -c "ssh-add ; \
	                   docker build \
                               --ssh default\
                                --rm\
                                --force-rm\
                                --build-arg STAMP='${STAMP}'\
                                -f 'dockerfiles/${IMAGE}.Dockerfile'\
                                -t '${DOCKERHUB}/${IMAGE}' ."

################################################
# Use images.
################################################

ifneq (${HOST_DIR}, undefined)
EXTRA_DOCKER_RUN_ARGS += --mount type=bind,source="${HOST_DIR}",target="/host"
endif

ifneq (${HOME_DIR}, undefined)
EXTRA_DOCKER_RUN_ARGS += --mount type=bind,source="${HOME_DIR}",target="/home/${USERNAME}"
endif

.PHONY: user
user: run_checks
user: prepare_user launch_user

.PHONY: prepare_user
prepare_user:
	docker build \
	    --rm \
	    --force-rm \
	    --build-arg=USER_BASE_IMG="${DOCKERHUB}/${IMAGE}" \
	    --build-arg=UID="$(shell id -u)" \
	    --build-arg=USER_NAME="$(shell id -un)" \
	    --build-arg=GID="$(shell id -g)" \
	    --build-arg=GROUP_NAME="$(shell id -gn)" \
	    --build-arg=LOCAL_LANG="$(LANG)" \
	    -f dockerfiles/user.Dockerfile \
	    -t ${USER_IMG} .

.PHONY: launch_user
launch_user:
	-docker run \
	    --rm \
	    --interactive --tty \
	    --hostname "container-$(IMAGE)" \
	    $(EXTRA_DOCKER_RUN_ARGS) \
	    --mount type=bind,source="${ETC_LOCALTIME}",target="/etc/localtime,readonly" \
	    ${USER_IMG} /bin/bash --login

################################################
# Pull images.
################################################
.PHONY: pull
pull: run_checks
pull:
	docker pull ${DOCKERHUB}/${IMAGE}

################################################
# Push images.
################################################
.PHONY: push
push: run_checks
push:
	docker push ${DOCKERHUB}/${IMAGE}:latest

################################################
# Clean images.
################################################
.PHONY: clean
clean: run_checks
	docker image remove ${DOCKERHUB}/${IMAGE}

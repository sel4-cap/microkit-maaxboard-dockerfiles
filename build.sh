#!/bin/sh
#
# Copyright 2020, Data61/CSIRO
#
# SPDX-License-Identifier: BSD-2-Clause
#

set -ef

############################################
# env setup

: "${DOCKERHUB:=ghcr.io/sel4-cap/}"

# Base images
: "${DEBIAN_IMG:=debian:bullseye-20210816-slim}"
: "${BASETOOLS_IMG:=base_tools}"

# Core images
: "${SEL4_IMG:=sel4}"
: "${CAMKES_IMG:=camkes}"
: "${MICROKIT_IMG:=microkit}"
: "${MAAXBOARD_IMG:=maaxboard}"

# Allow override of which 'version' (aka tag) of an image to pull in
: "${IMG_POSTFIX:=:latest}"

# Dockerfile directory location
: "${DOCKERFILE_DIR:=dockerfiles}"

# Extra vars
DOCKER_BUILD="docker build"
DOCKER_FLAGS="--force-rm=true"

# Special variables to be passed through Docker to the build scripts
: "${SCM}"


############################################
# builder functions

build_internal_image()
{
    base_img="$1"
    dfile_name="$2"
    img_name="$3"
    shift 3  # any params left over are just injected into the docker command
             # presumably as flags

    build_args_to_pass_to_docker=$(echo "$build_args" | grep "=" | awk '{print "--build-arg", $1}')
    # shellcheck disable=SC2086
    $DOCKER_BUILD $DOCKER_FLAGS \
        --build-arg STAMP="$(date)" \
        --build-arg BASE_IMG="$base_img" \
        --build-arg SCM="$SCM" \
        $build_args_to_pass_to_docker \
        -f "$DOCKERFILE_DIR/$dfile_name" \
        -t "$img_name" \
        "$@" \
        .
}

build_image()
{
    base_img="$1"
    dfile_name="$2"
    img_name="$3"
    shift 3

    build_internal_image "$DOCKERHUB$base_img" "$dfile_name" "$DOCKERHUB$img_name" "$@"
}

apply_software_to_image()
{
    prebuilt_img="$1"
    builder_dfile="$2"
    orig_img="$3"
    new_img="$4"
    shift 4

    # NOTE: it's OK to supply docker build-args that aren't requested in the Dockerfile

    $DOCKER_BUILD $DOCKER_FLAGS \
        --build-arg BASE_BUILDER_IMG="$DOCKERHUB$prebuilt_img" \
        --build-arg BASE_IMG="$DOCKERHUB$orig_img" \
        --build-arg SCM="$SCM" \
        -f "$DOCKERFILE_DIR/$builder_dfile" \
        -t "$DOCKERHUB$new_img" \
        "$@" \
        .
}

############################################
# Recipes for standard images

build_sel4()
{
    # Don't need $IMG_POSTFIX here, because:
    # - debian is just debian
    # - basetools doesn't get pushed out, and is built here anyway
    build_internal_image "$DEBIAN_IMG" base_tools.Dockerfile "$BASETOOLS_IMG"
    build_internal_image "$BASETOOLS_IMG" sel4.Dockerfile "$DOCKERHUB$SEL4_IMG"
}

build_camkes()
{
    build_image "$SEL4_IMG$IMG_POSTFIX" camkes.Dockerfile "$CAMKES_IMG"
}

build_microkit()
{
    build_image "$CAMKES_IMG$IMG_POSTFIX" microkit.Dockerfile "$MICROKIT_IMG"
}

build_maaxboard()
{
    build_image "$MICROKIT_IMG$IMG_POSTFIX" maaxboard.Dockerfile "$MAAXBOARD_IMG"
}

############################################
# Argparsing

show_help()
{
    cat <<EOF
    build.sh [-r] [-v] -b [sel4|camkes|microkit|maaxboard] -e MAKE_CACHES=no -e ...

     -r     Rebuild docker images (don't use the docker cache)
     -v     Verbose mode
     -e     Build arguments (NAME=VALUE) to docker build. Use a -e for each build arg.
EOF

}

# init cmdline vars to nothing
img_to_build=

while getopts "h?pvb:rs:e:" opt
do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    v)  set -x
        ;;
    b)  img_to_build=$OPTARG
        ;;
    r)  DOCKER_FLAGS="$DOCKER_FLAGS --no-cache"
        ;;
    e)  build_args="$build_args\n$OPTARG"
        ;;
    :)  echo "Option -$opt requires an argument." >&2
        exit 1
        ;;
    esac
done

if [ -z "$img_to_build" ]
then
    echo "You need to supply a \`-b\`" >&2
    show_help >&2
    exit 1
fi

############################################
# Processing

# Build as requested.
"build_${img_to_build}"

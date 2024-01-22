#!/bin/bash

set -exuo pipefail

# Source common functions.
source "/tmp/utils/common.sh"

# Fix the snapshot date.
SNAPSHOT_DATE="20211208T025308Z"

# Retain default, and create snapshot.
# May subsequently select the one desired.
as_root cp /etc/apt/sources.list /etc/apt/sources.list.default
as_root tee /etc/apt/sources.list.snapshot << EOF
deb http://snapshot.debian.org/archive/debian/$SNAPSHOT_DATE/ bullseye main
deb http://snapshot.debian.org/archive/debian-security/$SNAPSHOT_DATE/ bullseye-security main
deb http://snapshot.debian.org/archive/debian/$SNAPSHOT_DATE/ bullseye-updates main
EOF

# Snapshot has some rate limiting, so avoid its ire.
# Also avoid refusal to use updates from snapshot.
as_root tee /etc/apt/80snapshot.default << EOF
# Empty.
EOF
as_root tee -a /etc/apt/80snapshot.snapshot << EOF
Acquire::Retries "5";
Acquire::http::Dl-Limit "1000";
Acquire::Check-Valid-Until false;
EOF

# These commands supposedly speed-up and better dockerize apt.
echo "force-unsafe-io" | as_root tee /etc/dpkg/dpkg.cfg.d/02apt-speedup > /dev/null
echo "Acquire::http {No-Cache=True;};" | as_root tee /etc/apt/apt.conf.d/no-cache > /dev/null

# Adopt snapshot.
# Unsure when to avoid snapshot.
adopt_snapshot

# Get wget and curl early.
as_root apt-get install -y --no-install-recommends \
        curl \
        wget \
        # end of list

as_root apt-get install -y --no-install-recommends \
        bc \
        ca-certificates \
        devscripts \
        expect \
        git \
        iproute2 \
        iputils-ping \
        jq \
        locales \
        make \
        python-is-python3 \
        python3-dev \
        python3-pip \
        ssh \
        sudo \
        traceroute \
        # end of list

# Install python dependencies
# Upgrade pip first, then install setuptools (required for other pip packages)
# Install some basic python tools
as_root pip3 install --no-cache-dir \
    setuptools
as_root pip3 install --no-cache-dir \
    gitlint \
    nose \
    reuse \
    # end of list

# Add some symlinks so some programs can find things
as_root ln -s /usr/bin/hg /usr/local/bin/hg

# Skeleton for common user material.
try_nonroot_first mkdir -p "/util" || chown_dir_to_user "/util"
try_nonroot_first mkdir -p "/util/repo" || chown_dir_to_user "/util/repo"
try_nonroot_first mkdir -p "/util/curl_home" || chown_dir_to_user "/util/curl_home"

# Install repo.
wget -O - "https://storage.googleapis.com/git-repo-downloads/repo" > "/util/repo/repo"
chmod a+x "/util/repo/repo"

# Get repo on path.
cat << 'EOF' >> "/etc/profile.d/050-repo_path.sh"
export PATH="${PATH}:/util/repo"
EOF

# Mandate curl use ipv4.
tee "/util/curl_home/.curlrc" << EOF
# Mandate ipv4.
--ipv4
EOF

# Setup sudo for inside the container.
cat << EOF >> /etc/sudoers
Defaults        lecture_file = /etc/sudoers.lecture
Defaults        lecture = always
EOF

cat << EOF > /etc/sudoers.lecture
##################### Warning! #####################################
This is an ephemeral docker container! You can do things to it using
sudo, but when you exit, changes made outside of the /host directory
or home areas will be lost.
If you want your changes to be permanent, add them to the
    extras.dockerfile
in the seL4-CAmkES-L4v dockerfiles repo.
####################################################################
EOF

# Put in some branding and provenance.
cat << 'EOF' >> "/etc/profile.d/500-greeting.sh"
: "${STAMP_BASE:=absent}"
: "${STAMP_SEL4:=absent}"
: "${STAMP_CAMKES:=absent}"
: "${STAMP_MICROKIT:=absent}"
: "${STAMP_MAAXBOARD:=absent}"
echo "============================================================"
echo "Capgemini seL4"
echo "Organisation: https://github.com/sel4-cap"
echo "Images:       https://github.com/orgs/sel4-cap/packages"
echo "Repository:   https://github.com/sel4-cap/microkit-maaxboard-dockerfiles"
echo "Maintainer:   https://github.com/Bill-James-Ellis"
echo ""
echo "Stamps:"
echo "STAMP_BASE:      ${STAMP_BASE}"
echo "STAMP_SEL4:      ${STAMP_SEL4}"
echo "STAMP_CAMKES:    ${STAMP_CAMKES}"
echo "STAMP_MICROKIT:  ${STAMP_MICROKIT}"
echo "STAMP_MAAXBOARD: ${STAMP_MAAXBOARD}"
echo "============================================================"
EOF

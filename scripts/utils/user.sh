#!/bin/bash
#
# Copyright 2020, Data61/CSIRO
#
# SPDX-License-Identifier: BSD-2-Clause
#

set -exuo pipefail

# Source common functions with funky bash, as per: https://stackoverflow.com/a/12694189
DIR="${BASH_SOURCE%/*}"
test -d "$DIR" || DIR=$PWD
# shellcheck source=utils/common.sh
. "$DIR/utils/common.sh"

####################################################################
# Setup user and groups for inside the container

# It seems that clashes with group names or GIDs is more common
# than one might think. Here we attempt to make a matching group
# inside the container, but if it fails, we abandon the attempt.

# Try to create the group to match the GID. If a group already exists
# with that name, but a different GID, no change will be made.
# We therefore run groupmod to ensure the GID does match what was
# requested.
# However, either of these steps could fail - but if they do,
# that's OK.
groupadd -fg "${GID}" "${GROUP}" || true
groupmod -g "${GID}" "${GROUP}" || true

# Split the group info into an array
IFS=":" read -r -a group_info <<< "$(getent group "$GROUP")"
fgroup="${group_info[0]}"
fgid="${group_info[2]}"

GROUP_OK=false
if [ "$fgroup" == "$GROUP" ] && [ "$fgid" == "$GID" ] ; then
    # This means the group creation has gone OK, so make a user
    # with the corresponding group
    GROUP_OK=true
fi

if [ "$GROUP_OK" = true ]; then
    useradd -u "${UID}" -g "${GID}" "${UNAME}"
else
    # If creating the group didn't work well, that's OK, just
    # make the user without the same group as the host. Not as
    # nice, but still works fine.
    useradd -u "${UID}" "${UNAME}"
fi

# Remove the user's password
passwd -d "${UNAME}"


####################################################################
# Set up locales.
echo "${LOCAL_LANG} UTF-8" | as_root tee /etc/locale.gen > /dev/null
as_root dpkg-reconfigure --frontend=noninteractive locales
echo "LANG=${LOCAL_LANG}" | as_root tee -a /etc/default/locale > /dev/null

# Select locale.
cat << EOF >> "/etc/profile.d/010-locale.sh"
export LANG="${LOCAL_LANG}"
EOF


####################################################################
# Setup sudo for inside the container

# Whenever someone uses sudo, be annoying and remind them that
# it won't be permanent
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

####################################################################
# Setup /etc/profile.d

# Default stamps.
: "${STAMP_SEL4:=absent}"
: "${STAMP_CAMKES:=absent}"
: "${STAMP_MICROKIT:=absent}"
: "${STAMP_MAAXBOARD:=absent}"
: "${STAMP_L4V:=absent}"

# Put in some branding and provenance.
# shellcheck disable=SC2129
cat << EOF >> "/etc/profile.d/500-greeting.sh"
echo '============================================================'
echo '___                                   '
echo ' |   _      _ |_      _   _ |_ |_     '
echo ' |  |  |_| _) |_ \)/ (_) |  |_ | ) \/ '
echo '                                   /  '
echo ' __                                   '
echo '(_      _ |_  _  _   _                '
echo '__) \/ _) |_ (- ||| _)                '
echo '    /                                 '
echo 'Hello, welcome to the seL4/CAmkES/L4v docker build environment'
echo ''
echo '------------------------------------------------------------'
echo 'Provenance:'
echo '------------------------------------------------------------'
echo 'Primary source Trustworthy Systems group:'
echo 'Organisation: https://github.com/seL4'
echo 'Images:       https://hub.docker.com/r/trustworthysystems'
echo 'Repository:   https://github.com/seL4/seL4-CAmkES-L4v-dockerfiles'
echo ''
echo 'Secondary fork for Capgemini Build Environment as follows:'
echo 'Organisation: https://github.com/sel4-cap'
echo 'Images:       https://github.com/orgs/sel4-cap/packages'
echo 'Repository:   https://github.com/sel4-cap/microkit-maaxboard-dockerfiles'
echo 'Maintainer:   https://github.com/Bill-James-Ellis'
echo ''
echo 'Stamps (Standard Images):'
echo 'STAMP_SEL4:      ${STAMP_SEL4}'
echo 'STAMP_CAMKES:    ${STAMP_CAMKES}'
echo 'STAMP_MICROKIT:  ${STAMP_MICROKIT}'
echo 'STAMP_MAAXBOARD: ${STAMP_MAAXBOARD}'
echo 'STAMP_L4V:       ${STAMP_L4V}'
echo '============================================================'
EOF

# Drop the user into host.
# shellcheck disable=SC2129
cat << EOF >> "/etc/profile.d/500-start_in_host.sh"
cd /host
EOF

####################################################################
# Setup home dir

# NOTE: the user's home directory is stored in a docker volume.
#       (normally called $UNAME-home on the host)
#       That implies that these instructions will only run if said
#       docker volume does not exist. Therefore, if the below
#       changes, users will only see the effect if they run:
#          docker volume rm $USER-home

mkdir "/home/${UNAME}"

# Set an appropriate chown setting, based on if the group setup
# went OK
chown_setting="${UNAME}"
if [ "$GROUP_OK" = true ]; then
    chown_setting="${UNAME}:${GROUP}"
fi

# Setup isabelle folder, which sits in a volume too.
mkdir -p /isabelle
chown -R "$chown_setting" /isabelle
# Isabelle expects a home dir folder.
ln -s /isabelle "/home/${UNAME}/.isabelle"

# Make sure the user owns their home dir
chown -R "$chown_setting" "/home/${UNAME}"
chmod -R ug+rw "/home/${UNAME}"

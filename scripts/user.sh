#!/bin/bash

set -exuo pipefail

# Source common functions.
source "/tmp/utils/common.sh"

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
    useradd -u "${UID}" -g "${GID}" "${USERNAME}"
else
    # If creating the group didn't work well, that's OK, just
    # make the user without the same group as the host. Not as
    # nice, but still works fine.
    useradd -u "${UID}" "${USERNAME}"
fi

# Remove the user's password
passwd -d "${USERNAME}"

# Set up locales.
echo "${LOCAL_LANG} UTF-8" | as_root tee /etc/locale.gen > /dev/null
as_root dpkg-reconfigure --frontend=noninteractive locales
echo "LANG=${LOCAL_LANG}" | as_root tee -a /etc/default/locale > /dev/null

# Select locale.
cat << EOF >> "/etc/profile.d/010-locale.sh"
export LANG="${LOCAL_LANG}"
EOF

# Drop the user into host.
cat << EOF >> "/etc/profile.d/500-start_in_host.sh"
cd /host
EOF

# Set an appropriate chown setting, based on if the group setup
# went OK
chown_setting="${USERNAME}"
if [ "$GROUP_OK" = true ]; then
    chown_setting="${USERNAME}:${GROUP}"
fi

# Provide default host.
mkdir "/host/"
cat << EOF >> /host/README.txt
User launched without HOST_DIR.
This host will not persistient beyond the execution of this container.
EOF
chown -R "$chown_setting" "/host"
chmod -R ug+rw "/host"

# Provide default home.
mkdir "/home/${USERNAME}"
cat << EOF >> /home/${USERNAME}/README.txt
User launched without HOME_DIR.
This home will not persistient beyond the execution of this container.
EOF
chown -R "$chown_setting" "/home/${USERNAME}"
chmod -R ug+rw "/home/${USERNAME}"

#!/bin/bash

set -exuo pipefail

# Set up locales.
echo "${LOCAL_LANG} UTF-8" | tee /etc/locale.gen > /dev/null
dpkg-reconfigure --frontend=noninteractive locales
echo "LANG=${LOCAL_LANG}" | tee -a /etc/default/locale > /dev/null

# Select locale.
cat << EOF >> "/etc/profile.d/010-locale.sh"
export LANG="${LOCAL_LANG}"
EOF

# Provide default host.
mkdir "/host/"
cat << EOF >> /host/README.txt
User launched without HOST_DIR.
This host will not persistient beyond the execution of this container.
EOF
chown -R "${USER_NAME}:${GROUP_NAME}" "/host"
chmod -R ug+rw "/host"

# Provide default home.
mkdir "/home/${USER_NAME}"
cat << EOF >> /home/${USER_NAME}/README.txt
User launched without HOME_DIR.
This home will not persistient beyond the execution of this container.
EOF
chown -R "${USER_NAME}:${GROUP_NAME}" "/home/${USER_NAME}"
chmod -R ug+rw "/home/${USER_NAME}"

# Drop the user into host.
cat << EOF >> "/etc/profile.d/500-start_in_host.sh"
cd /host
EOF

# seL4 Cap Dockerfiles

Usage:
* `make`

Most normal usage sessions will begin:
* `make user IMAGE=sdk HOST_DIR=~/WORK HOME_DIR=~/`

# Instructions

Instructions are small scripts, used to build an external dependency Package,
in a configured and controlled manner. Each Instruction is built for the SDK.
The Instructions building log is retained in the container as:
`/tmp/instructions.log.txt`

# Git Hub Packages

Our Docker Images are retained in Git Hub Packages.
These are shared Internal to all who are Members of the sel4-cap Orginisation.
They may also be shared with select indviduals on request.

To work with these Images, you need to establish credentials.

Overview:
* https://docs.github.com/en/packages/learn-github-packages/introduction-to-github-packages

Instructions:
* https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-personal-access-token-classic
* https://docs.github.com/en/packages/learn-github-packages/about-permissions-for-github-packages#about-scopes-and-permissions-for-package-registries
* https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-with-a-personal-access-token-classic

Using "creating-a-personal-access-token-classic" create a "personal access
token (classic)" with at least the permissions as described in
"about-scopes-and-permissions-for-package-registries".

Once you have a "personal access token (classic)", using
"authenticating-with-a-personal-access-token-classic" sign in to the Container
registry service at ghcr.io. Mostly, do this:
* docker login ghcr.io --username USERNAME --password PERSONAL_ACCESS_TOKEN

The command shall create the following in your HOME area
".docker/config.json", containing credentials related to the "personal access
token (classic)" which permit you access to our packages.

# Update

For a full update:
* `make build IMAGE=base ; make build IMAGE=sel4 ; make build IMAGE=cap ; make build IMAGE=sdk`
* `make push IMAGE=base ; make push IMAGE=sel4 ; make push IMAGE=cap ; make push IMAGE=sdk`

# Docker

Some handy Docker commands.

List images:
* `docker images --all --no-trunc`

Delete image:
* `docker image remove IMAGE_ID`

Delete all "<none>" images:
* `docker images --all --no-trunc | grep "<none>" | sed -E -e 's/^.*(sha256:[^ ]*) .*$/\1/g' |  xargs -I {} docker image remove {}`

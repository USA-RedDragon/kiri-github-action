#!/bin/bash

# This script is used to parse environment variable from the
# Github Actions workflow and run Kiri.

if [ -n "${KIRI_DEBUG}" ]; then
    set -x
fi

# Get the current ownership of ${GITHUB_WORKSPACE}
# and change it to the current user.
OWNER_ID=$(stat -c '%u' ${GITHUB_WORKSPACE})
GROUP_ID=$(stat -c '%g' ${GITHUB_WORKSPACE})
if [ "${OWNER_ID}" != "${USER}" ]; then
    sudo chown -R ${USER}:${USER} ${GITHUB_WORKSPACE}
fi

. /home/github/.profile

KIRI_ARGS="--no-server --no-error-on-commit-count"

# KIRI_OUTPUT_DIR -> --output-dir
if [ -n "${KIRI_OUTPUT_DIR}" ]; then
    KIRI_ARGS="${KIRI_ARGS} --output-dir ${KIRI_OUTPUT_DIR}"
fi

# KIRI_REMOVE -> --remove
if [ -n "${KIRI_REMOVE}" ]; then
    KIRI_ARGS="${KIRI_ARGS} --remove"
fi

# KIRI_ARCHIVE -> --archive
if [ -n "${KIRI_ARCHIVE}" ]; then
    KIRI_ARGS="${KIRI_ARGS} --archive"
fi

# KIRI_PCB_PAGE_FRAME -> --page-frame
if [ -n "${KIRI_PCB_PAGE_FRAME}" ]; then
    KIRI_ARGS="${KIRI_ARGS} --page-frame"
fi

# KIRI_FORCE_LAYOUT_VIEW -> --layout
if [ -n "${KIRI_FORCE_LAYOUT_VIEW}" ]; then
    KIRI_ARGS="${KIRI_ARGS} --layout"
fi

# KIRI_SKIP_KICAD6_SCHEMATICS -> --skip-kicad6
if [ -n "${KIRI_SKIP_KICAD6_SCHEMATICS}" ]; then
    KIRI_ARGS="${KIRI_ARGS} --skip-kicad6"
fi

# KIRI_SKIP_CACHE -> --skip-cache
if [ -n "${KIRI_SKIP_CACHE}" ]; then
    KIRI_ARGS="${KIRI_ARGS} --skip-cache"
fi

# KIRI_OLDER -> --older
if [ -n "${KIRI_OLDER}" ]; then
    KIRI_ARGS="${KIRI_ARGS} --older ${KIRI_OLDER}"
fi

# KIRI_NEWER -> --newer
if [ -n "${KIRI_NEWER}" ]; then
    KIRI_ARGS="${KIRI_ARGS} --newer ${KIRI_NEWER}"
fi

# KIRI_LAST -> --last
if [ -n "${KIRI_LAST}" ]; then
    KIRI_ARGS="${KIRI_ARGS} --last ${KIRI_LAST}"
fi

# KIRI_ALL -> --all
if [ -n "${KIRI_ALL}" ]; then
    KIRI_ARGS="${KIRI_ARGS} --all"
fi

# Run kiri and passthrough all arguments
kiri ${KIRI_ARGS} $@ ${KIRI_PROJECT_FILE}

# Restore the ownership of ${GITHUB_WORKSPACE}
sudo chown -R ${OWNER_ID}:${GROUP_ID} ${GITHUB_WORKSPACE}

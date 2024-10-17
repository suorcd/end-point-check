#!/bin/bash

EPOCHTIME=$(date +%s)
URL=""
HASH=""
PROTOCOL=80

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --hash) HASH="$2"; shift ;;
        *) URL="$1" ;;
    esac
    shift
done

if [[ -z "${URL}" ]]; then
    echo "Usage: $0 <URL> [--hash HASH]"
    exit 1
fi

# setup tmp dir
WORKDIR="/tmp/epc/${EPOCHTIME}"
mkdir -p "${WORKDIR}"
pushd "${WORKDIR}" || exit

PROTOCOL=$(echo "${URL}" | grep -Eq '^https://' && echo 443)
HOSTNAME=$(echo "${URL}" | awk -F[:/] '{print $4}')

# Obtain the A records for the HOSTNAME using drill
IPS=$(drill -Q "${HOSTNAME}")

# Iterate over each IP address
for IP in ${IPS}; do
  mkdir "${IP}"
  pushd "./${IP}" || exit
  curl --silent --resolve "${HOSTNAME}:${PROTOCOL}:${IP}" -O "${URL}"
# Compute md5sum and compare with provided hash if HASH is provided
if [[ -n "${HASH}" ]]; then
    COMPUTED_HASH=$(find . -type f -exec md5sum {} \; | awk '{print $1}')
    if [[ "${COMPUTED_HASH}" == "${HASH}" ]]; then
        echo "Hash matches."
    else
        echo "Hash does not match."
    fi
else
    find . -type f -exec md5sum {} \;
fi

popd || exit
done

# Compute md5sum and compare with provided hash if HASH is provided
if [[ -n "${HASH}" ]]; then
    COMPUTED_HASH=$(find . -type f -exec md5sum {} \; | awk '{print $1}')
    if [[ "${COMPUTED_HASH}" == "${HASH}" ]]; then
        echo "Hash matches."
    else
        echo "Hash does not match."
    fi
else
    find . -type f -exec md5sum {} \;
fi

popd || exit
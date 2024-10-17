#!/bin/bash

EPOCHTIME=$(date +%s)

HASH=""
PROTOCOL=80
DEBUG=false

function cleanup {
    rm -rf "${WORKDIR}"
}

function CPUSHD {
    if [[ "${DEBUG}" == true ]]; then
        pushd "$1" || exit
    else
        pushd "$1" > /dev/null || exit
    fi

}

function CPOPD {
    if [[ "${DEBUG}" == true ]]; then
        popd || exit
    else
        popd > /dev/null || exit
    fi
}

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --hash) HASH="$2"; shift ;;
        --debug) DEBUG=true ;;
        *) URL="$1" ;;
    esac
    shift
done

if [[ -z "${URL}" ]]; then
    echo "Usage: $0 <URL> [--hash HASH] [--debug]"
    exit 1
fi

# setup tmp dir
WORKDIR="/tmp/epc/${EPOCHTIME}"
mkdir -p "${WORKDIR}"

CPUSHD "${WORKDIR}"

PROTOCOL=$(echo "${URL}" | grep -Eq '^https://' && echo 443)
HOSTNAME=$(echo "${URL}" | awk -F[:/] '{print $4}')

# Debug output
if [[ "${DEBUG}" == true ]]; then
    echo "URL: ${URL}"
    echo "HASH: ${HASH}"
    echo "WORKDIR: ${WORKDIR}"
    echo "PROTOCOL: ${PROTOCOL}"
    echo "HOSTNAME: ${HOSTNAME}"
fi

# Obtain the A records for the HOSTNAME using drill
IPS=$(drill -Q "${HOSTNAME}")

# Debug output
if [[ "${DEBUG}" == true ]]; then
    echo "IPS: ${IPS}"
fi

# Iterate over each IP address
for IP in ${IPS}; do
  mkdir "${IP}"
  CPUSHD "./${IP}"
  curl --silent --resolve "${HOSTNAME}:${PROTOCOL}:${IP}" -O "${URL}"
  
  # Debug output
  if [[ "${DEBUG}" == true ]]; then
      echo "Downloaded content from ${URL} to ${IP} directory"
  fi

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

CPOPD

done

CPOPD
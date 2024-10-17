#!/bin/bash

EPOCHTIME=$(date +%s)
URL=""
HASH=""
FILE=""
HASH_ALG="md5"
PROTOCOL=80
DEBUG=false

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --hash) HASH="$2"; shift ;;
        --file) FILE="$2"; shift ;;
        --hash-alg) HASH_ALG="$2"; shift ;;
        --debug) DEBUG=true ;;
        *) URL="$1" ;;
    esac
    shift
done

if [[ -z "${URL}" ]]; then
    echo "Usage: $0 <URL> [--hash HASH] [--file FILE] [--hash-alg HASH_ALG] [--debug]"
    exit 1
fi

# Compute hash of the file if --file is provided
if [[ -n "${FILE}" ]]; then
    if [[ -f "${FILE}" ]]; then
        HASH=$(eval "${HASH_ALG}sum ${FILE}" | awk '{print $1}')
    else
        echo "File ${FILE} does not exist."
        exit 1
    fi
fi

# setup tmp dir
WORKDIR="/tmp/epc/${EPOCHTIME}"
mkdir -p "${WORKDIR}"
if [[ "${DEBUG}" == true ]]; then
    pushd "${WORKDIR}" || exit
else
    pushd "${WORKDIR}" > /dev/null || exit
fi

PROTOCOL=$(echo "${URL}" | grep -Eq '^https://' && echo 443)
HOSTNAME=$(echo "${URL}" | awk -F[:/] '{print $4}')

# Debug output
if [[ "${DEBUG}" == true ]]; then
    echo "URL: ${URL}"
    echo "HASH: ${HASH}"
    echo "WORKDIR: ${WORKDIR}"
    echo "PROTOCOL: ${PROTOCOL}"
    echo "HOSTNAME: ${HOSTNAME}"
    echo "HASH_ALG: ${HASH_ALG}"
fi

# Obtain the A records for the HOSTNAME using drill
IPS=$(drill -Q "${HOSTNAME}")

# Debug output
if [[ "${DEBUG}" == true ]]; then
    echo "IPS: ${IPS}"
fi

# Define color codes
RED='\033[0;31m'
NC='\033[0m' # No Color

# Iterate over each IP address
for IP in ${IPS}; do
  mkdir "${IP}"
  if [[ "${DEBUG}" == true ]]; then
      pushd "./${IP}" || exit
  else
      pushd "./${IP}" > /dev/null || exit
  fi
  curl --silent --resolve "${HOSTNAME}:${PROTOCOL}:${IP}" -O "${URL}"
  
  # Debug output
  if [[ "${DEBUG}" == true ]]; then
      echo "Downloaded content from ${URL} to ${IP} directory"
  fi

  # Compute hash and compare with provided hash if HASH is provided
  if [[ -n "${HASH}" ]]; then
      COMPUTED_HASH=$(find . -type f -exec ${HASH_ALG}sum {} \; | awk '{print $1}')
      if [[ "${COMPUTED_HASH}" == "${HASH}" ]]; then
          echo "Hash matches || ${IP}"
      else
          echo -e "Hash ${RED}NOT${NC} matches || ${IP}"
      fi
  else
      find . -type f -exec ${HASH_ALG}sum {} \;
  fi

  if [[ "${DEBUG}" == true ]]; then
      popd || exit
  else
      popd > /dev/null || exit
  fi
done

if [[ "${DEBUG}" == true ]]; then
    popd || exit
else
    popd > /dev/null || exit
fi
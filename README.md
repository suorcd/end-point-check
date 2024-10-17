# Endpoint Check Script

This script checks the availability of a given URL by resolving its hostname to IP addresses and downloading the content from each IP address.
It can also compute and compare hash values (e.g., `md5`, `sha512`) of the downloaded content.

## Usage

```shell
./epc.sh <URL> [--hash HASH] [--file FILE] [--hash-alg HASH_ALG] [--debug]
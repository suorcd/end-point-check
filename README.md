# Endpoint Check Script

This script checks the availability of a given URL by resolving its hostname to IP addresses and downloading the content from each IP address.
It can also compute and compare hash values (e.g., `md5`, `sha512`) of the downloaded content.

## Usage

```shell
./epc.sh <URL> [--hash HASH] [--file FILE] [--hash-alg HASH_ALG] [--debug]


## nix Usage

To use the `epc.sh` script, follow the instructions below:

### Building the Package

1. **Build the package using Nix Flakes**:
   ```shell
   nix build
   ```

Examples
Basic Usage:
`./result/bin/epc.sh http://example.com`
With Hash Comparison:
`./result/bin/epc.sh http://example.com --hash d41d8cd98f00b204e9800998ecf8427e`
With File Hash Comparison:
`./result/bin/epc.sh http://example.com --file /path/to/file`
With Custom Hash Algorithm:
`./result/bin/epc.sh http://example.com --hash-alg sha512`
With Debug Mode:
`./result/bin/epc.sh http://example.com --debug`



### nix Explanation

1. **Building the Package**: Instructions to build the package using Nix Flakes.
2. **Running the Script**: Instructions to run the script from the built package.
3. **Arguments**: Detailed explanation of the command-line arguments.
4. **Examples**: Usage examples demonstrating different ways to use the script.
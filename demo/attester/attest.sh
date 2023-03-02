#!/usr/bin/env bash

set -xeuf -o pipefail

# Move to home directory
cd ~/

# Start and initialize TPM server
tpm_server &
tpm2_startup -c -T mssim

# TODO: Initialize PCRs with some data

# Start Parsec service
parsec -c /etc/parsec/config.toml &

# Create key for TLS client
# Note: this key is used by default by the mbedTLS client
# For other use-cases, this specific key might not be needed.
parsec-tool create-ecc-key -k parsec-se-driver-key2147483616

# TODO: Create endorsement bundle
# TODO: Endorse platform
# TODO: Attest

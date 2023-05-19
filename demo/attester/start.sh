#!/usr/bin/env bash

set -xuf -o pipefail

# Start and initialize TPM server
tpm_server &

until tpm2_startup -c -T mssim; do
    sleep 1
done

# TODO: Initialize PCRs with some data

# Start Parsec service
parsec -c /etc/parsec/config.toml

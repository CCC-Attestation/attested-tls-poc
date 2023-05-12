#!/usr/bin/env bash

set -xuf -o pipefail

# Move to state directory
pushd ~/state/

# Start and initialize TPM server
tpm_server &

until tpm2_startup -c -T mssim; do
    sleep 1
done

# TODO: Initialize PCRs with some data

# Start Parsec service
parsec -c /etc/parsec/config.toml &

until parsec-tool ping 2>&1 >/dev/null; do
    sleep 1
done

set -e

ssl_client2 client_att_type=eat server_name=relaying-party server_port=4433

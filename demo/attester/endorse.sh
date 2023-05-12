#!/usr/bin/env bash

set -xuf -o pipefail

ENDORSEMENT_CLASS_ID="D10E4BD6-7E02-4D2C-BF1A-69AE22680478"

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

# Create key for TLS client
# Note: this key is used by default by the mbedTLS client
# For other use-cases, this specific key might not be needed.
parsec-tool create-ecc-key -k parsec-se-driver-key2147483616 || echo "TLS client key already found"

# Create AIK endorsement
mkdir -p endorsement/comid
parsec-tool create-endorsement -c $ENDORSEMENT_CLASS_ID > endorsement/comid-key.json
cp ~/comid-pcr.json ~/corim.json endorsement/

# Create the endorsement bundle and endorse
pushd endorsement
cocli comid create -o comid -t comid-key.json
cocli comid create -o comid -t comid-pcr.json
cocli corim create -t corim.json -M comid -o corim-parsec-tpm.cbor
cocli corim submit -f corim-parsec-tpm.cbor \
                   -s 'http://provisioning-service.veraison-net:8888/endorsement-provisioning/v1/submit' \
                   -m 'application/corim-unsigned+cbor; profile="tag:github.com/parallaxsecond,2023-03-03:tpm"'

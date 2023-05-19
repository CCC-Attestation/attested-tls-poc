#!/usr/bin/env bash

set -xeuf -o pipefail

# Create AIK endorsement
mkdir -p endorsement/comid
parsec-tool create-endorsement -c "D10E4BD6-7E02-4D2C-BF1A-69AE22680478" > endorsement/comid-key.json
cp ~/comid-pcr.json ~/corim.json endorsement/

# Create the endorsement bundle and endorse
pushd endorsement
cocli comid create -o comid -t comid-key.json
cocli comid create -o comid -t comid-pcr.json
cocli corim create -t corim.json -M comid -o corim-parsec-tpm.cbor
cocli corim submit -f corim-parsec-tpm.cbor \
                   -s 'http://pfe:8888/endorsement-provisioning/v1/submit' \
                   -m 'application/corim-unsigned+cbor; profile="tag:github.com/parallaxsecond,2023-03-03:tpm"'

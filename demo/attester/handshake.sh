#!/usr/bin/env bash

set -xuf -o pipefail

ssl_client2 client_att_type=eat server_addr=$(getent hosts relying-party | cut -d ' ' -f1) server_port=4433

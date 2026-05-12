#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
export LAB_DIR="${LAB_DIR:-${WORKSPACE_DIR}/lab}"

ROOT_CONF="${WORKSPACE_DIR}/openssl/root-ca.cnf"
INTERMEDIATE_CONF="${WORKSPACE_DIR}/openssl/intermediate-ca.cnf"

ROOT_KEY="${LAB_DIR}/root/private/root-ca.key.pem"
ROOT_CERT="${LAB_DIR}/root/certs/root-ca.crt.pem"
INTERMEDIATE_KEY="${LAB_DIR}/intermediate/private/intermediate-ca.key.pem"
INTERMEDIATE_CSR="${LAB_DIR}/intermediate/csr/intermediate-ca.csr.pem"
INTERMEDIATE_CERT="${LAB_DIR}/intermediate/certs/intermediate-ca.crt.pem"
CHAIN_CERT="${LAB_DIR}/chain/ca-chain.crt.pem"

SERVER_NAME="${SERVER_NAME:-server.lab.local}"
SERVER_KEY="${LAB_DIR}/server/${SERVER_NAME}.key.pem"
SERVER_CSR="${LAB_DIR}/server/${SERVER_NAME}.csr.pem"
SERVER_CERT="${LAB_DIR}/server/${SERVER_NAME}.crt.pem"

log() {
    printf "\n==> %s\n" "$*"
}

need_file() {
    local path="$1"
    if [[ ! -f "$path" ]]; then
        printf "Missing required file: %s\n" "$path" >&2
        exit 1
    fi
}


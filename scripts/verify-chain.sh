#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

SERVER_NAME="${1:-${SERVER_NAME}}"
SERVER_CERT="${LAB_DIR}/server/${SERVER_NAME}.crt.pem"

need_file "${CHAIN_CERT}"
need_file "${ROOT_CERT}"
need_file "${INTERMEDIATE_CERT}"
need_file "${SERVER_CERT}"

log "Verifying ${SERVER_NAME} against the lab chain"
openssl verify \
    -CAfile "${ROOT_CERT}" \
    -untrusted "${INTERMEDIATE_CERT}" \
    "${SERVER_CERT}"

log "Certificate summary"
openssl x509 \
    -in "${SERVER_CERT}" \
    -noout \
    -subject \
    -issuer \
    -dates \
    -ext subjectAltName \
    -ext keyUsage \
    -ext extendedKeyUsage

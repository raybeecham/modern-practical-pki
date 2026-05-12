#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

"${SCRIPT_DIR}/init-lab.sh"

if [[ -f "${ROOT_CERT}" ]]; then
    log "Root CA already exists"
    openssl x509 -in "${ROOT_CERT}" -noout -subject -issuer -dates
    exit 0
fi

log "Generating root CA private key"
openssl genpkey \
    -algorithm RSA \
    -pkeyopt rsa_keygen_bits:4096 \
    -out "${ROOT_KEY}"
chmod 400 "${ROOT_KEY}" 2>/dev/null || true

log "Creating self-signed root CA certificate"
openssl req \
    -config "${ROOT_CONF}" \
    -key "${ROOT_KEY}" \
    -new \
    -x509 \
    -days 3650 \
    -sha384 \
    -extensions root_ca_ext \
    -out "${ROOT_CERT}"
chmod 444 "${ROOT_CERT}" 2>/dev/null || true

openssl x509 -in "${ROOT_CERT}" -noout -subject -issuer -dates -fingerprint -sha256

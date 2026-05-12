#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

"${SCRIPT_DIR}/create-root-ca.sh"

if [[ -f "${INTERMEDIATE_CERT}" ]]; then
    log "Intermediate CA already exists"
    openssl x509 -in "${INTERMEDIATE_CERT}" -noout -subject -issuer -dates
    if [[ ! -f "${CHAIN_CERT}" ]]; then
        cat "${INTERMEDIATE_CERT}" "${ROOT_CERT}" > "${CHAIN_CERT}"
        chmod 444 "${CHAIN_CERT}" 2>/dev/null || true
    fi
    exit 0
fi

log "Generating intermediate CA private key"
openssl genpkey \
    -algorithm RSA \
    -pkeyopt rsa_keygen_bits:4096 \
    -out "${INTERMEDIATE_KEY}"
chmod 400 "${INTERMEDIATE_KEY}" 2>/dev/null || true

log "Creating intermediate CA CSR"
openssl req \
    -config "${INTERMEDIATE_CONF}" \
    -new \
    -sha384 \
    -key "${INTERMEDIATE_KEY}" \
    -out "${INTERMEDIATE_CSR}"

log "Signing intermediate CA with root CA"
openssl ca \
    -batch \
    -config "${ROOT_CONF}" \
    -extensions intermediate_ca_ext \
    -days 1825 \
    -notext \
    -md sha384 \
    -in "${INTERMEDIATE_CSR}" \
    -out "${INTERMEDIATE_CERT}"
chmod 444 "${INTERMEDIATE_CERT}" 2>/dev/null || true

cat "${INTERMEDIATE_CERT}" "${ROOT_CERT}" > "${CHAIN_CERT}"
chmod 444 "${CHAIN_CERT}" 2>/dev/null || true

openssl verify -CAfile "${ROOT_CERT}" "${INTERMEDIATE_CERT}"
openssl x509 -in "${INTERMEDIATE_CERT}" -noout -subject -issuer -dates

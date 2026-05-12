#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

need_file "${INTERMEDIATE_CERT}"

CRL_PATH="${LAB_DIR}/intermediate/crl/intermediate-ca.crl.pem"

log "Generating intermediate CA CRL"
rm -f "${CRL_PATH}"
openssl ca \
    -config "${INTERMEDIATE_CONF}" \
    -gencrl \
    -out "${CRL_PATH}"
chmod 444 "${CRL_PATH}" 2>/dev/null || true

openssl crl -in "${CRL_PATH}" -noout -issuer -lastupdate -nextupdate

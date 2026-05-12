#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

SERVER_NAME="${1:-${SERVER_NAME}}"
SERVER_CERT="${LAB_DIR}/server/${SERVER_NAME}.crt.pem"
CRL_PATH="${LAB_DIR}/intermediate/crl/intermediate-ca.crl.pem"

need_file "${SERVER_CERT}"

serial="$(openssl x509 -in "${SERVER_CERT}" -noout -serial | cut -d= -f2)"
status="$(awk -F '\t' -v serial="${serial}" '$4 == serial { print $1; exit }' "${LAB_DIR}/intermediate/index.txt")"

if [[ "${status}" == "R" ]]; then
    log "Server certificate for ${SERVER_NAME} is already revoked"
else
    log "Revoking server certificate for ${SERVER_NAME}"
    openssl ca \
        -batch \
        -config "${INTERMEDIATE_CONF}" \
        -revoke "${SERVER_CERT}" \
        -crl_reason keyCompromise
fi

"${SCRIPT_DIR}/generate-crl.sh"

log "Checking revocation with CRL. This should fail for a revoked certificate."
if openssl verify \
    -crl_check \
    -CAfile "${ROOT_CERT}" \
    -untrusted "${INTERMEDIATE_CERT}" \
    -CRLfile "${CRL_PATH}" \
    "${SERVER_CERT}"; then
    printf "Unexpected success: certificate did not appear revoked.\n" >&2
    exit 1
fi

printf "Revocation check failed as expected for %s.\n" "${SERVER_NAME}"

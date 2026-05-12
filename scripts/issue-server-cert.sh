#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

"${SCRIPT_DIR}/create-intermediate-ca.sh"

SERVER_NAME="${1:-${SERVER_NAME}}"
SERVER_KEY="${LAB_DIR}/server/${SERVER_NAME}.key.pem"
SERVER_CSR="${LAB_DIR}/server/${SERVER_NAME}.csr.pem"
SERVER_CERT="${LAB_DIR}/server/${SERVER_NAME}.crt.pem"
SERVER_CSR_CONF="${LAB_DIR}/server/${SERVER_NAME}.csr.cnf"
SAN_DNS="${SAN_DNS:-${SERVER_NAME},localhost}"
SAN_IP="${SAN_IP:-127.0.0.1}"

if [[ -f "${SERVER_CERT}" ]]; then
    log "Server certificate already exists for ${SERVER_NAME}"
    openssl x509 -in "${SERVER_CERT}" -noout -subject -issuer -dates
    exit 0
fi

log "Generating server private key for ${SERVER_NAME}"
openssl genpkey \
    -algorithm RSA \
    -pkeyopt rsa_keygen_bits:2048 \
    -out "${SERVER_KEY}"
chmod 400 "${SERVER_KEY}" 2>/dev/null || true

log "Writing CSR config with SANs"
{
    printf "[ req ]\n"
    printf "prompt = no\n"
    printf "distinguished_name = server_dn\n"
    printf "req_extensions = server_req_ext\n"
    printf "default_md = sha256\n\n"
    printf "[ server_dn ]\n"
    printf "C = US\n"
    printf "O = Modern Practical PKI Lab\n"
    printf "CN = %s\n\n" "${SERVER_NAME}"
    printf "[ server_req_ext ]\n"
    printf "subjectAltName = @alt_names\n\n"
    printf "[ alt_names ]\n"

    dns_index=1
    IFS=',' read -ra dns_names <<< "${SAN_DNS}"
    for dns_name in "${dns_names[@]}"; do
        dns_name="${dns_name//[[:space:]]/}"
        [[ -n "${dns_name}" ]] && printf "DNS.%d = %s\n" "${dns_index}" "${dns_name}"
        dns_index=$((dns_index + 1))
    done

    ip_index=1
    IFS=',' read -ra ip_names <<< "${SAN_IP}"
    for ip_name in "${ip_names[@]}"; do
        ip_name="${ip_name//[[:space:]]/}"
        [[ -n "${ip_name}" ]] && printf "IP.%d = %s\n" "${ip_index}" "${ip_name}"
        ip_index=$((ip_index + 1))
    done
} > "${SERVER_CSR_CONF}"

log "Creating server CSR"
openssl req \
    -new \
    -key "${SERVER_KEY}" \
    -out "${SERVER_CSR}" \
    -config "${SERVER_CSR_CONF}"

log "Signing server certificate with intermediate CA"
openssl ca \
    -batch \
    -config "${INTERMEDIATE_CONF}" \
    -extensions server_cert_ext \
    -days 397 \
    -notext \
    -md sha256 \
    -in "${SERVER_CSR}" \
    -out "${SERVER_CERT}"
chmod 444 "${SERVER_CERT}" 2>/dev/null || true

openssl x509 -in "${SERVER_CERT}" -noout -subject -issuer -dates

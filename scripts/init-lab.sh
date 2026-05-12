#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

log "Creating PKI lab directory structure at ${LAB_DIR}"

for ca in root intermediate; do
    mkdir -p "${LAB_DIR}/${ca}/"{certs,crl,csr,newcerts,private}
    chmod 700 "${LAB_DIR}/${ca}/private" 2>/dev/null || true
    touch "${LAB_DIR}/${ca}/index.txt"
    [[ -s "${LAB_DIR}/${ca}/serial" ]] || printf "1000\n" > "${LAB_DIR}/${ca}/serial"
    [[ -s "${LAB_DIR}/${ca}/crlnumber" ]] || printf "1000\n" > "${LAB_DIR}/${ca}/crlnumber"
done

mkdir -p "${LAB_DIR}/"{chain,server}

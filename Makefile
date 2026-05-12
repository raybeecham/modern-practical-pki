SHELL := /bin/bash
.DEFAULT_GOAL := help

.PHONY: help version init root intermediate server verify crl revoke demo clean

help:
	@printf "Modern Practical PKI lab targets:\n"
	@printf "  make version       Show the OpenSSL build in this container\n"
	@printf "  make init          Create CA database folders under ./lab\n"
	@printf "  make root          Create the offline-style root CA\n"
	@printf "  make intermediate  Create and sign the issuing CA\n"
	@printf "  make server        Issue a TLS server certificate\n"
	@printf "  make verify        Verify the server certificate chain\n"
	@printf "  make crl           Generate the intermediate CA CRL\n"
	@printf "  make revoke        Revoke the server certificate and regenerate the CRL\n"
	@printf "  make demo          Run init, CA creation, issuance, and verification\n"
	@printf "  make clean         Remove generated lab material\n"

version:
	@openssl version -a

init:
	@scripts/init-lab.sh

root: init
	@scripts/create-root-ca.sh

intermediate: root
	@scripts/create-intermediate-ca.sh

server: intermediate
	@scripts/issue-server-cert.sh

verify: server
	@scripts/verify-chain.sh

crl: intermediate
	@scripts/generate-crl.sh

revoke: server
	@scripts/revoke-server-cert.sh

demo: server verify crl

clean:
	rm -rf lab

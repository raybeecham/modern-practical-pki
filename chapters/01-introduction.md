# Chapter 1: Introduction

[Back to README](../README.md)

## Goal

Confirm that the lab container has OpenSSL 4.0.0 and understand where its
configuration directory lives.

## Get Inside

From PowerShell:

```powershell
cd "F:\Public Key Infrastructure\modern-practical-pki"
docker compose run --rm pki bash
```

The prompt should look like this:

```text
root@...:/workspace#
```

That means you are inside the Linux container.

## Commands

Run these inside the container, not from the `PS F:\...>` PowerShell prompt:

```bash
openssl version
openssl version -d
openssl version -a
```

Expected highlights:

```text
OpenSSL 4.0.0 14 Apr 2026
OPENSSLDIR: "/opt/openssl/ssl"
```

## Path Note

The original book container reports:

```text
/usr/local/ssl
```

Our lab uses:

```text
/opt/openssl/ssl
```

That keeps the custom OpenSSL build isolated from Ubuntu's system OpenSSL. When
a book command references `/usr/local/ssl`, translate that path to
`/opt/openssl/ssl` in this lab.


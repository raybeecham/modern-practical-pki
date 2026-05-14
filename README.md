# Modern Practical PKI

This is our hands-on PKI lab. It starts slowly, with the same early goals as
the book: get a working OpenSSL environment, learn the encodings, then build up
to keys, certificates, certificate authorities, revocation, and TLS.

This is a learning lab, not production PKI. Some later exercises generate keys
without passphrases so the workflow is repeatable and easy to inspect.

## Getting Inside

From PowerShell:

```powershell
cd "F:\Public Key Infrastructure\modern-practical-pki"
docker compose build
docker compose run --rm pki bash
```

Inside the container, you should land in:

```text
/workspace
```

To leave the container:

```bash
exit
```

## Prompt Check

```text
PS F:\...>
```

means you are in Windows PowerShell.

```text
root@...:/workspace#
```

means you are inside the Linux container. Most book-style commands in this lab
should be run inside the container unless the command is explicitly labeled
PowerShell.

## Chapter Index

| Chapter | Topic | Status |
| --- | --- | --- |
| [Chapter 1](chapters/01-introduction.md) | Introduction | Ready |
| [Chapter 2](chapters/02-encoding.md) | Encoding | Ready |
| [Chapter 3](chapters/03-hashing.md) | Hashing | Ready |
| [Chapter 4](chapters/04-random-number-generation.md) | Random Number Generation | In Progress |
| Chapter 5 | ASN.1 | Planned |
| Chapter 6 | Public and Private Keys | Planned |
| Chapter 7 | Certification Authorities | Planned |
| Chapter 8 | Registration Authorities | Planned |
| Chapter 9 | Certificates | Planned |
| Chapter 10 | Certificate Status | Planned |
| Chapter 11 | Certificate Transparency (CT) | Planned |
| Chapter 12 | Key Stores | Planned |
| Chapter 13 | CMS (Cryptographic Message Syntax) | Planned |
| Chapter 14 | Enrollment Protocols | Planned |
| Chapter 15 | Cross-Certification | Planned |
| Chapter 16 | Transport Layer Security (TLS) | Planned |
| Chapter 17 | S/MIME (Secure MIME) | Planned |
| Chapter 18 | Time Stamping Authority | Planned |
| Chapter 19 | Hardware Security Module (HSM) | Planned |
| Chapter 20 | Trusted Platform Modules (TPM) | Planned |
| Chapter 21 | Security Requirements for Cryptographic Modules | Planned |

## Repo Layout

```text
modern-practical-pki/
  README.md               Front door and chapter index
  chapters/               Chapter notes and exercises
  Dockerfile              OpenSSL 4.0.0 lab image
  compose.yaml            Docker Compose service
  Makefile                Later PKI workflow commands
  openssl/                OpenSSL CA config files
  scripts/                Automation for later chapters
  lab/                    Generated lab output, ignored by git
```

## Later PKI Workflow

The repo already has a fuller workflow ready for later chapters:

- A root certificate authority.
- An intermediate issuing CA.
- A TLS server certificate with DNS and IP subject alternative names.
- A PEM chain file.
- A CRL for revocation practice.
- Verification commands that prove the certificate chains correctly.

When we are ready for those chapters:

```powershell
docker compose run --rm pki make help
docker compose run --rm pki make demo
```

Generated material is written under `lab/`.

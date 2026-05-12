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

Prompt check:

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

To leave the container:

```bash
exit
```

## Chapter 1: Introduction

Goal: confirm that the lab container has OpenSSL 4.0.0 and understand where its
configuration directory lives.

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

The original book container reports `/usr/local/ssl`. Our lab uses
`/opt/openssl/ssl` so the custom OpenSSL build is isolated from Ubuntu's system
OpenSSL. When a book command references `/usr/local/ssl`, translate that path to
`/opt/openssl/ssl` in this lab.

## Chapter 2: Encoding

Goal: understand why binary data is encoded before it is displayed, copied,
stored in text files, or transferred through systems that expect printable
characters.

Binary data is a sequence of bytes. Some byte values map neatly to printable
characters, but many do not. If binary data passes through a text-only system,
those non-printable bytes can be changed or lost. Encoding avoids that by
representing the bytes with printable characters. After transfer or storage, the
encoded text can be decoded back into the original bytes.

### Base-16: Hexadecimal

Base-16, also called hexadecimal or hex, uses:

```text
0 1 2 3 4 5 6 7 8 9 A B C D E F
```

Each byte is 8 bits, so it can be represented by two hex characters:

```text
00 through FF
```

Examples:

```text
0x00 = decimal 0
0x0A = decimal 10
0x10 = decimal 16
0xFF = decimal 255
```

### Base-64

Base-64 represents binary data using 64 printable characters:

- Lowercase letters: `a-z`
- Uppercase letters: `A-Z`
- Digits: `0-9`
- Symbols: `+` and `/`

Base-64 maps every 6 bits of input into one printable character, because
`2^6 = 64`. Since bytes come in 8-bit chunks, Base-64 processes 3 bytes at a
time:

```text
3 bytes = 24 bits = 4 Base-64 characters
```

If the input length is not a multiple of 3 bytes, Base-64 adds padding at the
end with `=`. There can be at most two padding characters.

### Try It

Run these inside the container:

```bash
mkdir -p lab/chapter2
echo -n "Hello World" | base64
echo -n "SGVsbG8gV29ybGQ=" | base64 -d
```

Expected output:

```text
SGVsbG8gV29ybGQ=
Hello World
```

### URL-Safe Base-64

Regular Base-64 can be awkward in URLs and filenames:

- `/` can be interpreted as a path separator.
- `+` can be interpreted as a space in URL query strings.
- `=` has special meaning in URL query parameters.

URL-safe Base-64, described by RFC 4648, uses:

```text
+ becomes -
/ becomes _
```

Padding with `=` is often omitted or percent-encoded as `%3D`, depending on the
protocol or application.

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

## Roadmap

Next useful labs:

- Keys and key formats.
- Certificate signing requests.
- Self-signed certificates.
- Root and intermediate CAs.
- Certificate chains.
- CRLs and OCSP.
- Client certificates and mutual TLS.
- SoftHSM and PKCS#11 provider integration.
- FIPS provider loading and self-test inspection.

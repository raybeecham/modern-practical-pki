# Chapter 6: Public and Private Keys

[Back to README](../README.md)

## Goal

Understand public/private key pairs, how they differ from symmetric keys, and
how key pairs are used for encryption, digital signatures, and authentication.

This chapter is long, so we will build it in sections.

## Chapter Map

1. Encryption algorithm families.
2. Digital signatures.
3. Key pair generation.
4. Key pair authentication.
5. Passkey authentication.
6. DKIM authentication.

The main theme: public/private key pairs are used in several different ways.
Encryption, signatures, key establishment, and authentication are related, but
they are not the same thing.

## Encryption Algorithm Families

There are two major families of encryption algorithms:

- Symmetric key algorithms.
- Asymmetric key algorithms.

### Symmetric Key Algorithms

A symmetric key algorithm uses the same secret key for encryption and
decryption.

```text
same secret key -> encrypt
same secret key -> decrypt
```

Symmetric algorithms are usually fast and are used for bulk data encryption.

The hard part is key sharing. Both sides need the same secret key, but that key
must not be exposed to attackers.

### Hands-On: Symmetric Encryption

This example uses AES-256-CBC with a random key and initialization vector. This
is for learning the mechanics. Modern application protocols usually use
authenticated encryption modes or established libraries instead of raw `enc`
commands.

Run these inside the container:

```bash
mkdir -p lab/chapter6
echo "This is a Chapter 6 message." > lab/chapter6/message.txt

KEY="$(openssl rand -hex 32)"
IV="$(openssl rand -hex 16)"

openssl enc -aes-256-cbc \
  -K "$KEY" \
  -iv "$IV" \
  -in lab/chapter6/message.txt \
  -out lab/chapter6/message.aes256cbc.bin

openssl enc -d -aes-256-cbc \
  -K "$KEY" \
  -iv "$IV" \
  -in lab/chapter6/message.aes256cbc.bin \
  -out lab/chapter6/message.decrypted.txt

cmp lab/chapter6/message.txt lab/chapter6/message.decrypted.txt && echo "same bytes"
```

Expected output:

```text
same bytes
```

The same key and IV were used to decrypt the message. If the key is wrong,
decryption fails or produces useless output.

Important rule: never reuse the same key and IV pair for a different message.

### Asymmetric Key Algorithms

An asymmetric key algorithm uses a key pair:

- Public key.
- Private key.

The public key can be shared. The private key must be protected.

Depending on the algorithm and protocol, asymmetric keys can support different
operations:

- Encryption and decryption.
- Digital signatures and verification.
- Key establishment.
- Authentication.

The important warning: not every public/private key algorithm does every job.
For example, a signature algorithm signs and verifies. A KEM helps establish a
shared secret. These are different tools.

## Digital Signatures

A digital signature provides evidence that data was signed by someone who holds
the private key.

The usual pattern is:

```text
private key -> sign
public key  -> verify
```

Digital signatures can provide:

- Integrity: the signed data was not changed.
- Authentication: the signer had access to the private key.
- Non-repudiation, depending on the legal and operational context.

Digital signatures are not the same as encryption. Signing does not hide the
message. It produces a value that can be checked with the public key.

## Key Pair Generation

This chapter covers several key pair types.

### RSA Key Pairs

RSA is a traditional public-key algorithm. Depending on padding and protocol
usage, RSA can be used for encryption or digital signatures.

Generate an RSA private key and derive the public key:

```bash
openssl genpkey \
  -algorithm RSA \
  -pkeyopt rsa_keygen_bits:2048 \
  -out lab/chapter6/rsa-private.pem

openssl pkey \
  -in lab/chapter6/rsa-private.pem \
  -pubout \
  -out lab/chapter6/rsa-public.pem
```

Inspect the files:

```bash
head -n 5 lab/chapter6/rsa-private.pem
head -n 5 lab/chapter6/rsa-public.pem
```

The private key file must be protected. The public key file can be shared.

Sign the message with the private key:

```bash
openssl dgst -sha256 \
  -sign lab/chapter6/rsa-private.pem \
  -out lab/chapter6/message.rsa.sig \
  lab/chapter6/message.txt
```

Verify the signature with the public key:

```bash
openssl dgst -sha256 \
  -verify lab/chapter6/rsa-public.pem \
  -signature lab/chapter6/message.rsa.sig \
  lab/chapter6/message.txt
```

Expected output:

```text
Verified OK
```

Now tamper with a copy of the message:

```bash
cp lab/chapter6/message.txt lab/chapter6/message-tampered.txt
echo "tampered" >> lab/chapter6/message-tampered.txt

openssl dgst -sha256 \
  -verify lab/chapter6/rsa-public.pem \
  -signature lab/chapter6/message.rsa.sig \
  lab/chapter6/message-tampered.txt
```

Expected output:

```text
Verification failure
```

OpenSSL may also print lower-level error details after the failure. The
important part is that verification did not succeed.

The lesson: the signature verifies the original message, not the modified one.

### EC Key Pairs

Elliptic curve key pairs are widely used for modern public-key cryptography.
They are commonly used with digital signatures and key agreement protocols.

Generate a P-256 elliptic curve private key and derive the public key:

```bash
openssl genpkey \
  -algorithm EC \
  -pkeyopt group:P-256 \
  -out lab/chapter6/ec-private.pem

openssl pkey \
  -in lab/chapter6/ec-private.pem \
  -pubout \
  -out lab/chapter6/ec-public.pem
```

Sign and verify the same message:

```bash
openssl dgst -sha256 \
  -sign lab/chapter6/ec-private.pem \
  -out lab/chapter6/message.ec.sig \
  lab/chapter6/message.txt

openssl dgst -sha256 \
  -verify lab/chapter6/ec-public.pem \
  -signature lab/chapter6/message.ec.sig \
  lab/chapter6/message.txt
```

Expected output:

```text
Verified OK
```

Compare key file sizes:

```bash
ls -lh lab/chapter6/rsa-private.pem lab/chapter6/ec-private.pem
```

The EC private key is much smaller than the RSA private key in this lab.

### ML-DSA Key Pairs

ML-DSA is a post-quantum digital signature algorithm.

It is used for signing and verification, not encryption.

OpenSSL 4.0 supports ML-DSA. Generate an ML-DSA-44 key pair:

```bash
openssl genpkey \
  -algorithm ML-DSA-44 \
  -out lab/chapter6/mldsa-private.pem

openssl pkey \
  -in lab/chapter6/mldsa-private.pem \
  -pubout \
  -out lab/chapter6/mldsa-public.pem
```

Sign and verify with `pkeyutl`:

```bash
openssl pkeyutl \
  -sign \
  -rawin \
  -inkey lab/chapter6/mldsa-private.pem \
  -in lab/chapter6/message.txt \
  -out lab/chapter6/message.mldsa.sig

openssl pkeyutl \
  -verify \
  -rawin \
  -pubin \
  -inkey lab/chapter6/mldsa-public.pem \
  -sigfile lab/chapter6/message.mldsa.sig \
  -in lab/chapter6/message.txt
```

Expected output:

```text
Signature Verified Successfully
```

The lesson: ML-DSA is a signature algorithm. It signs and verifies.

### ML-KEM Key Pairs

ML-KEM is a post-quantum key encapsulation mechanism.

It is used to help establish a shared secret, not to sign messages.

OpenSSL 4.0 supports ML-KEM. Generate an ML-KEM-512 key pair:

```bash
openssl genpkey \
  -algorithm ML-KEM-512 \
  -out lab/chapter6/mlkem-private.pem

openssl pkey \
  -in lab/chapter6/mlkem-private.pem \
  -pubout \
  -out lab/chapter6/mlkem-public.pem
```

Encapsulate a shared secret with the public key:

```bash
openssl pkeyutl \
  -encap \
  -pubin \
  -inkey lab/chapter6/mlkem-public.pem \
  -out lab/chapter6/mlkem-ciphertext.bin \
  -secret lab/chapter6/mlkem-shared-1.bin
```

Decapsulate the shared secret with the private key:

```bash
openssl pkeyutl \
  -decap \
  -inkey lab/chapter6/mlkem-private.pem \
  -in lab/chapter6/mlkem-ciphertext.bin \
  -secret lab/chapter6/mlkem-shared-2.bin

cmp lab/chapter6/mlkem-shared-1.bin lab/chapter6/mlkem-shared-2.bin && echo "same shared secret"
```

Expected output:

```text
same shared secret
```

The lesson: ML-KEM does not sign messages. It helps two parties establish the
same shared secret.

## Key Pair Authentication

Key pairs can also be used for authentication. In that case, the goal is to
prove possession of the private key without revealing the private key.

### SSH Key Authentication

SSH key authentication is a common example.

The server stores or trusts the user's public key. During login, the user proves
they have the matching private key. The private key is not sent to the server.

Generate an SSH key pair:

```bash
ssh-keygen \
  -t ed25519 \
  -f lab/chapter6/ssh-ed25519 \
  -N "" \
  -C "chapter6@example"
```

This creates:

```text
lab/chapter6/ssh-ed25519
lab/chapter6/ssh-ed25519.pub
```

The `.pub` file is the public key:

```bash
cat lab/chapter6/ssh-ed25519.pub
```

Derive the public key again from the private key:

```bash
ssh-keygen -y -f lab/chapter6/ssh-ed25519 > lab/chapter6/ssh-derived.pub
cmp lab/chapter6/ssh-ed25519.pub lab/chapter6/ssh-derived.pub && echo "public key matches"
```

Expected output:

```text
public key matches
```

The lesson: the public key can be derived from the private key, but the private
key cannot be derived from the public key.

## Passkey Authentication

Passkeys use public-key cryptography to replace or reduce reliance on passwords.

At registration time, a device creates a key pair. The service stores the public
key. At login time, the device proves it has the private key.

The private key stays on the user's device or authenticator.

Conceptually:

```text
registration:
  authenticator creates key pair
  service stores public key

login:
  service sends challenge
  authenticator signs challenge with private key
  service verifies signature with public key
```

The lesson: passkeys are passwordless authentication built on public-key
cryptography. The website does not need to store a password.

## DKIM Authentication

DKIM stands for DomainKeys Identified Mail.

DKIM uses digital signatures for email authentication. A sending domain signs
parts of an email message with a private key. The public key is published in DNS
so receiving mail systems can verify the signature.

The basic pattern is:

```text
sender private key -> sign email
DNS public key     -> verify email
```

This is a simplified DKIM-style lab. Real DKIM has canonicalization rules and
specific email headers. Here we only demonstrate the public-key idea.

Generate a DKIM-style RSA key pair:

```bash
openssl genpkey \
  -algorithm RSA \
  -pkeyopt rsa_keygen_bits:2048 \
  -out lab/chapter6/dkim-private.pem

openssl pkey \
  -in lab/chapter6/dkim-private.pem \
  -pubout \
  -out lab/chapter6/dkim-public.pem
```

Create a tiny email-like message:

```bash
cat > lab/chapter6/email.txt <<'EOF'
From: alice@example.com
To: bob@example.net
Subject: Chapter 6 DKIM demo

This is a tiny email body.
EOF
```

Sign it:

```bash
openssl dgst -sha256 \
  -sign lab/chapter6/dkim-private.pem \
  -out lab/chapter6/email.dkim.sig \
  lab/chapter6/email.txt

openssl base64 -A \
  -in lab/chapter6/email.dkim.sig \
  -out lab/chapter6/email.dkim.sig.b64
```

Verify it:

```bash
openssl dgst -sha256 \
  -verify lab/chapter6/dkim-public.pem \
  -signature lab/chapter6/email.dkim.sig \
  lab/chapter6/email.txt
```

Expected output:

```text
Verified OK
```

Create the public-key material that would go into DNS:

```bash
grep -v -- '-----' lab/chapter6/dkim-public.pem | tr -d '\n' > lab/chapter6/dkim-public.b64
printf 'selector1._domainkey.example.com TXT "v=DKIM1; k=rsa; p='
cat lab/chapter6/dkim-public.b64
printf '"\n'
```

The lesson: DKIM lets a receiving mail system find a sender's public key in DNS
and use it to verify a signature on the email.

## Key Takeaway

Public/private keys are not one single trick. They are a foundation used by
different constructions: encryption, signatures, key establishment, and
authentication.

The job of the key pair depends on the algorithm and the protocol using it.

Keep these straight:

- Symmetric encryption uses the same secret key on both sides.
- Digital signatures use a private key to sign and a public key to verify.
- KEMs help establish shared secrets.
- Authentication proves possession of a private key without sending it.

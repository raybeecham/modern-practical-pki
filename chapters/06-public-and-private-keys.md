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

We will add OpenSSL RSA examples in this section.

### EC Key Pairs

Elliptic curve key pairs are widely used for modern public-key cryptography.
They are commonly used with digital signatures and key agreement protocols.

We will add OpenSSL EC examples in this section.

### ML-DSA Key Pairs

ML-DSA is a post-quantum digital signature algorithm.

It is used for signing and verification, not encryption.

We will add examples and notes here as the lab support allows.

### ML-KEM Key Pairs

ML-KEM is a post-quantum key encapsulation mechanism.

It is used to help establish a shared secret, not to sign messages.

We will add examples and notes here as the lab support allows.

## Key Pair Authentication

Key pairs can also be used for authentication. In that case, the goal is to
prove possession of the private key without revealing the private key.

### SSH Key Authentication

SSH key authentication is a common example.

The server stores or trusts the user's public key. During login, the user proves
they have the matching private key. The private key is not sent to the server.

We will add a hands-on SSH key example in this section.

## Passkey Authentication

Passkeys use public-key cryptography to replace or reduce reliance on passwords.

At registration time, a device creates a key pair. The service stores the public
key. At login time, the device proves it has the private key.

The private key stays on the user's device or authenticator.

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

## Key Takeaway

Public/private keys are not one single trick. They are a foundation used by
different constructions: encryption, signatures, key establishment, and
authentication.

The job of the key pair depends on the algorithm and the protocol using it.


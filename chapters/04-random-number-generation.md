# Chapter 4: Random Number Generation

[Back to README](../README.md)

## Goal

Understand why cryptography depends on secure random numbers and how random
bits can be converted into random numbers.

Many cryptographic algorithms rely on cryptographically secure random bit
generators. Key generation is one of the most important examples. If the random
generator is weak, the generated keys may also be weak.

A secure random bit generator should make it computationally infeasible to:

- Discover its internal state.
- Predict its future output.
- Detect useful patterns in its output.

In other words, it must resist prediction and pattern-analysis attacks.

## Deterministic and Non-Deterministic Generators

There are two broad categories of random bit generators:

- Deterministic random bit generators.
- Non-deterministic random bit generators.

A deterministic random bit generator, or DRBG, is an algorithm that produces
random-looking bits from a seed. The seed comes from a randomness source.

Because the output can be predicted if the seed is known, a DRBG is also called
a pseudorandom number generator, or PRNG.

A non-deterministic random bit generator is different. In that model, every bit
comes directly from a randomness source.

The practical idea is simple: if a generator depends on a seed, that seed must
be strong and secret. If an attacker learns or guesses the seed, the generated
output may become predictable.

## Randomness Sources

Entropy is a measure of uncertainty or unpredictability. In this context, it is
a measure of randomness.

Random bit generators need high-entropy randomness sources. These sources can be
physical hardware devices or non-physical system data. In either case, the
source must be tested. Validation tests check whether samples from the source
are independent and whether their distribution is suitable for cryptographic
use.

Physical randomness sources include:

- Metastable latches with feedback loops.
- Ring oscillators.

### Metastable Latches with Feedback Loops

A latch is a basic circuit made from two inverting, or NOT, gates. A normal latch
settles into one of two stable states:

```text
0, 1
```

or:

```text
1, 0
```

A latch in a metastable state is temporarily balanced in an undefined state
between `0` and `1`. Because of thermal noise, the circuit quickly tips into one
of the stable states. That final state can be used as a random bit.

To generate continuous random bits, a feedback loop forces the latch back into a
metastable state. This can be done with transistors acting as switches, loading
both ends of the latch from two capacitors.

The important idea: tiny physical noise affects which stable state the circuit
falls into.

### Ring Oscillators

A ring oscillator is a circular chain with an odd number of inverting, or NOT,
gates.

An electrical signal travels around the loop millions of times per second. The
speed fluctuates because of electrical noise. Those fluctuations can provide an
unpredictable stream of bits.

Systems commonly use multiple ring oscillators. Their loop lengths should be
different and mutually prime. That helps prevent the oscillators from lining up
in a predictable repeating pattern.

The important idea: physical timing noise creates uncertainty that can be
sampled as random data.

## DRBG Algorithms

DRBG algorithms can be built from several cryptographic building blocks,
including:

- Hash functions.
- HMAC.
- Block ciphers.
- Stream ciphers.

NIST SP 800-90A describes DRBG constructions based on hash functions, HMAC, and
block ciphers in counter mode. More recent systems may also use stream ciphers.

Windows uses AES in counter mode for its DRBG. In Microsoft CNG documentation,
the Windows random number generator is described as being based on AES counter
mode from NIST SP 800-90.

Modern Linux systems expose random data through character device files:

```text
/dev/random
/dev/urandom
```

These files provide a stream of random binary data from the kernel. On old Linux
kernels, `/dev/random` could block and was often described as more secure than
the non-blocking `/dev/urandom`. On modern Linux kernels, this distinction is no
longer useful in normal operation. After the kernel random number generator is
initialized, `/dev/random` and `/dev/urandom` use the same cryptographic random
generator. Modern Linux kernels use a ChaCha20-based design.

OpenSSL on Linux gets randomness from the operating system. In this lab
container, OpenSSL can use Linux randomness sources such as `/dev/urandom`.

Try this inside the container:

```bash
ls -al /dev/urandom
```

Example output:

```text
crw-rw-rw- 1 root root 1, 9 ... /dev/urandom
```

The first letter `c` means it is a character device.

## OpenSSL Random Bytes

The `openssl rand` command generates random bytes.

Generate 16 random bytes and encode them as hexadecimal:

```bash
mkdir -p lab/chapter4
openssl rand -hex 16
```

Example output:

```text
e823ba680b71296d81c6f999e276d9c8
```

Because each byte is two hex characters, 16 random bytes produce 32 hex
characters.

Generate 16 random bytes and encode them as Base-64:

```bash
openssl rand -base64 16
```

Example output:

```text
eGYZ4ZmzIz0JS2K5agByQ==
```

Your output should be different each time. That is the point.

## Visualizing Random Bytes

Random bytes should not show obvious patterns.

Generate 1 MiB of random data:

```bash
openssl rand -out lab/chapter4/rand.bin 1048576
```

That is enough data for a `1024 x 1024` grayscale image, where each byte becomes
one pixel:

```text
0   = black
255 = white
```

Everything between `0` and `255` becomes a shade of gray.

Create a simple PGM image from the random bytes:

```bash
{
  printf 'P5\n1024 1024\n255\n'
  cat lab/chapter4/rand.bin
} > lab/chapter4/rand.pgm
```

The generated file is:

```text
lab/chapter4/rand.pgm
```

If you open it with an image viewer that supports PGM files, it should look like
static or white noise from an old analog TV.

The lesson: good random output should not reveal a visible structure.

## Nonces

A nonce is a number used once.

Nonces are commonly used in communication protocols to make each session or
request unique. This helps prevent replay attacks.

Example:

1. A client sends a request with a fresh nonce.
2. The server includes the same nonce in its response.
3. The client checks that the response contains the expected nonce.

If an attacker records an old response and tries to replay it later, the old
nonce will not match the new request. The replayed response can be rejected.

The important rule is in the name: a nonce should not be reused in the same
context.

## From Random Bits to Random Numbers

Random generators usually produce bits or bytes. Applications often need a
random number within a specific range.

For example, an application might need a random number from `0` to `9`.

One simple method is sometimes called the discard method. It works like this:

1. Take enough random bits to represent numbers in the desired range.
2. Convert those bits into a number.
3. If the number is inside the range, use it.
4. If the number is outside the range, discard it and try again with new random
   bits.

This is also called rejection sampling.

Example: to choose a number from `0` to `9`, we need at least 4 bits:

```text
4 bits can represent 16 values: 0 through 15
```

The values `0` through `9` are valid. The values `10` through `15` are outside
the desired range, so they are discarded.

This avoids bias. Bias means some numbers are more likely than others. Good
cryptographic random number generation must avoid predictable patterns and
uneven distributions.

## Key Takeaway

Cryptography needs randomness that attackers cannot predict. Random-looking is
not enough. The random generator must be designed for cryptographic use.

Random bytes are used for keys, nonces, serial numbers, salts, initialization
vectors, and other values where predictability would weaken security.

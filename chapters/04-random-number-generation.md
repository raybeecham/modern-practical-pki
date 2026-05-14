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

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


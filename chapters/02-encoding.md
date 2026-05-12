# Chapter 2: Encoding

[Back to README](../README.md)

## Goal

Understand why binary data is encoded before it is displayed, copied, stored in
text files, or transferred through systems that expect printable characters.

Binary data is a sequence of bytes. Some byte values map neatly to printable
characters, but many do not. If binary data passes through a text-only system,
those non-printable bytes can be changed or lost. Encoding avoids that by
representing the bytes with printable characters. After transfer or storage, the
encoded text can be decoded back into the original bytes.

## Base-16: Hexadecimal

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

## Base-64

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

## Try It

Run these inside the container, not from the `PS F:\...>` PowerShell prompt:

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

## URL-Safe Base-64

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


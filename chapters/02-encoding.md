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

## More Practice

These examples make the chapter more concrete.

### Base-64 Padding

Run:

```bash
echo -n "A" | base64
echo -n "AB" | base64
echo -n "ABC" | base64
echo -n "ABCD" | base64
```

Expected output:

```text
QQ==
QUI=
QUJD
QUJDRA==
```

What this shows:

- `A` is 1 byte, so Base-64 adds `==`.
- `AB` is 2 bytes, so Base-64 adds `=`.
- `ABC` is 3 bytes, so no padding is needed.
- `ABCD` is 4 bytes. The first 3 bytes encode cleanly, then the last 1 byte
  needs `==`.

Base-64 works in 3-byte groups. Padding only appears at the end.

### Non-Printable Bytes

Create a small binary file:

```bash
printf '\x48\x65\x6c\x6c\x6f\x00\xff\x0a' > lab/chapter2/weird.bin
```

Try to display it as text:

```bash
cat lab/chapter2/weird.bin
```

You may see something like `Hello` followed by a strange symbol or blank space:

```text
Hello?
```

That output is strange because the file contains bytes that are not normal
printable text.

Now display the same file as hex:

```bash
xxd lab/chapter2/weird.bin
```

Expected output:

```text
00000000: 4865 6c6c 6f00 ff0a                      Hello...
```

The bytes are:

```text
48 65 6c 6c 6f = Hello
00             = null byte
ff             = non-printable byte
0a             = newline
```

The lesson: `cat` tries to show text, but `xxd` shows the actual bytes.

### Encode and Decode Without Changing Bytes

Encode the binary file:

```bash
base64 lab/chapter2/weird.bin
```

Expected output:

```text
SGVsbG8A/wo=
```

Now save the Base-64 text, decode it, and compare the result:

```bash
base64 lab/chapter2/weird.bin > lab/chapter2/weird.b64
base64 -d lab/chapter2/weird.b64 > lab/chapter2/weird.roundtrip.bin
cmp lab/chapter2/weird.bin lab/chapter2/weird.roundtrip.bin && echo "same bytes"
```

Expected output:

```text
same bytes
```

The lesson: Base-64 changes how bytes are represented. It does not change the
bytes themselves if you decode it correctly.

### URL-Safe Example

Run:

```bash
echo -n "???>>>???" | base64
```

Expected output:

```text
Pz8/Pj4+Pz8/
```

The URL-safe version is:

```text
Pz8_Pj4-Pz8_
```

The only changes are:

```text
/ becomes _
+ becomes -
```

The lesson: URL-safe Base-64 is still Base-64. It just swaps characters that
can cause problems in URLs or filenames.

## Key Takeaway

Base-64 is not encryption. It does not hide data. It only turns bytes into
printable text so they are easier to store or transfer.

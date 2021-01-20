# Description
pek is a command to encrypt and decrypt files using public/private keys.
A secondary feature of pek is signing and verifying files using digital signatures.
Written for python 3.

# Purpose
This program has been designed to be an easy-to-install and simple-to-use tool
for exchanging small encrypted messages via email. The encrypted output was designed to
be cut and pasted from a terminal window into an email message. This program was designed
to be given to someone with minimal technical skills, such that they have a reasonable
chance of getting its dependencies installed and running. I.e. communicating with your parents/siblings.

# Included Code
These three components from other authors have been included into this script:
```
   Elliptic Curve   Jimmy Song, https://github.com/jimmysong/programmingbitcoin.git
   AES              Brandon Sterne, https://gist.github.com/raullenchai/2920069
   SHA256           Thomas Dixon, https://github.com/thomdixon/pysha2
```

# Dependencies
```
   os.urandom
   os.path.isfile
   os.path.exists
   os.getcwd
   os.chdir
   os.listdir
   sys.stdin
   sys.stdout
   sys.stderr
   sys.argv
   io.StringIO
   io.BytesIO
   copy.copy
   copy.deepcopy
   struct.unpack
   struct.pack
   input(), open(), close(), read(), write()
```

# Synopsis
```
    C:\> PEK CREATE
    Public key:  HDiIVl7zm5prDw9CjsGwFagO5iR/+d4WKljeLbWiVWK
    Private key: UczjINLL6k318mjZOAF83XHiqHJERkb2vrUd7YLbOyl

    C:\> PEK ENCRYPT HDiIVl7zm5prDw9CjsGwFagO5iR/+d4WKljeLbWiVWK C:\AUTOEXEC.BAT SECRET.PEK

    C:\> TYPE SECRET.PEK
    qAqk2x6H73km+5egvwik+vKUcMgwrSFV5WRyNA0LBwEDFJIygBdlKOOX4KIOdw
    Khui6zxb4IzjW+smFqkjVNn2Ng8nhYes4+YK6ucTGO/DBHX6jKUVuckN9aiC+es
    B4n0YOb53JeSzrXMa3Cw2+Dtv3CCrSTnQPu5h/9ylx1gP8/CIYi3rgTc2qygnOJ
    csHU8/zdZKgEu5i/wr98uTQrMelQIBsSUyBVYHTSnVoBOjRwxlhxJxWQsw9cdw
    E4J+JnRg

    C:\> PEK DECRYPT UczjINLL6k318mjZOAF83XHiqHJERkb2vrUd7YLbOyl SECRET.PEK -
    @echo off
    SET SOUND=C:\PROGRA~1\CREATIVE\CTSND
    SET BLASTER=A220 I5 D1 H5 P330 E620 T6
    SET PATH=C:\Windows,C:\
    LH C:\Windows\COMMAND\MSCDEX.EXE /D:123

    C:\> PEK SIGN UczjINLL6k318mjZOAF83XHiqHJERkb2vrUd7YLbOyl C:\AUTOEXEC.BAT A.SIG

    C:\> TYPE A.SIG
    rnl+t/pN5lOE7ZsUJjdEc8utQHrhqgLzLVkksu2EXlmC8jbrRnGt7k1xw6lJYQ
    QveDNKUx7rzYHLxTq71oj/pA

    C:\> PEK VERIFY HDiIVl7zm5prDw9CjsGwFagO5iR/+d4WKljeLbWiVWK C:\AUTOEXEC.BAT A.SIG
    GOOD

    C:\> PEK
    1) Create Keys
    2) Encrypt file
    3) Decrypt file
    4) Create Signature
    5) Verify Signature
    6) File Operations
    7) Help
    8) Quit
    Choose 1-8? 8

    C:\> 
```

# Usage
```
Usage:
    pek create
    pek encrypt  <public-key>      <input>        <output>
    pek decrypt  <private-key>     <input>        <output>
    pek sign     <private-key>  <file-or-hash>  <signature-out>
    pek verify   <public-key>   <file-or-hash>  <signature-in>
    pek help
    pek              Interactive Menu!!!

    <public-key>     This is a public key obtained from calling "pek create".
    <private-key>    This is a private key obtained from calling "pek create".
    <input>          This is the filename to read, use "-" to read from standard input.
    <output>         This is the filename to write, use "-" to write to standard output.
    <file-or-hash>   The filename to read and calculate the hash code for. Use "-" for standard input.
                     A hash code can be given instead. This is a 64-character string consisting of hex digits.
    <signature-out>  This is the signature filename to create, use "-" for standard output.
    <signature-in>   This is the signature filename to read.

Examples:
    $ pek create
    Public key:  9ypjamC46AgSmFQtTfS9gxFPzIqz2TRpXT2kczCNDyK
    Private key: m8G/I3s9Qc2KT1w8iT/IhtPNUfVmJbzkBUM0ewkGkTt

    $ pek encrypt 9ypjamC46AgSmFQtTfS9gxFPzIqz2TRpXT2kczCNDyK f1.txt f1.pek
    $ pek decrypt m8G/I3s9Qc2KT1w8iT/IhtPNUfVmJbzkBUM0ewkGkTt f1.pek original.txt

    $ pek sign    m8G/I3s9Qc2KT1w8iT/IhtPNUfVmJbzkBUM0ewkGkTt MANIFESTO.doc  MANIFESTO.sig
    $ pek verify  9ypjamC46AgSmFQtTfS9gxFPzIqz2TRpXT2kczCNDyK MANIFESTO.doc  MANIFESTO.sig
    GOOD

    $ shasum -a 256 MANIFESTO.doc
    6a82de9253f887f88e5a537dc9d8749a66fc28597fd3da60850ba3dd9acf085b

    $ pek sign   lZCBMbLb8GP/IkeKcPVCeoNLju/ynXsC6MZzm3D3ASk 6a82de9253f887f88e5a537...f085b MANIFESTO.sig
    $ pek verify UwcQDXZlP1kWjda3ngcJ4HzWsz+C4Ahth5ieidwu8n4 6a82de9253f887f88e5a537...f085b MANIFESTO.sig
    GOOD
```

# Encryption / Decryption:

The private key is a random 256-bit value (represented by the variable 'd').
The public key is the secp256k1 generator point multiplied by the private key (represented by the variable 'Q').

The shared key (see the 'sk' variable in ENCRYPT() and DECRYPT()) is derived
using ECDH (Elliptic Curve Diffie-Hellman) Key Exchange. An ephemeral private/public key pair is
produced (represented by 'e' and 'E'). The public ephemeral key is included in the encrypted output so
that that the decryption algorithm can derive the shared key 'sk'.

SHA256 is applied to the elliptic curve point to get the 256-bit key 'sk' used for
the AES encryption and decryption. (See the function HASH_POINT())

Once the shared key is obtained the plaintext is encrypted with it using AES-128 (Advanced
Encryption Standard). Cipher block chaining (CBC) is employed. The initialization vector is the shared key 'sk'.

This AES implementation operates on 128-bit blocks (it does use a 256-bit key).
The lower 128-bits and upper 128-bits are encrypted seperatly and then combined
(see AES_ENCRYPT() and AES_DECRYPT()).

The public and private keys are represented by a 43-character BASE64 encoded string.
All 258-bits of this 43-character string are used. The first 256-bits are the private
key or public key. To encode a public key one more bit is needed to indicate
if the y coordinate is even/odd. To capture this information the next and final two
bits are used as follows:

```
  00  Invalid.
  01  This is a private key.
  10  This is a public key, the y-coordinate is even.
  11  This is a public key, the y-coordinate is odd.
```

The encrypted file format is a stream of BASE64 characters with allowance
for whitespace appearing anywhere. The first 33-bytes are the the public ephemeral key.
The remaining data is the encrypted form of the plaintext.

# Signing / Verification:

The ECDSA (Elliptic Curve Digital Signature Algorithm) is used.
The 256-bit hash code is calculated using SHA256.
See the SIGN() and VERIFY() functions. The hash code is represented by the variable 'e'.
The signature file format consists of 512-bits of BASE64 characters representing the tuple (r, s).

## How To Use (Sender)
                                                                                                                                                                 
```
$ vi msg.txt

$ pek encrypt tgfca7q12QA+R97/o77j+KnNd5vup019VSIiharzXvm msg.txt -
9ACImQPzSQZWPbK6dWye8qNUf+pFdjzxIQ5Vn2z+wP4CbWirS6Qw8nIEKTLsKD
26bkCRiQoGNH6ikWXQ/04ygZqxhkUMC5ZcLHD+yjzpIo/QiQcPCBa5nnuuc4w3S
Js4PlHiYQeEtG+3TOUt1LgtZbp17BQZiUxCszDpg4UlzMmnNC5fisnfm1K0MGTq
te6vQNWleEu1kAFWMEckquVrdCfQ8W7T3P65bPd98+o0s3rnnvkFersF13j3o9
pkZWXI+rQqg56c8e6iFdeWGWxFs6cMSnsvjezq2Huht3C1ogOa2v/BnCA6YKQ6B
ILyxpbZyvjZIH2AZ22pf9oR58YsGhvJ/q4M0xRZsyjv4E+Z0tGAfwpa8Mu1wKos
aq6k/VcIJw

$ mail dad@daddomain.com
Hey Dad I hope everything is going well.

I talked to the laywer and we're going to proceed, I've included all the
details in this encrypted message. I used your latest
public key: tgfca7q12QA+R97/o77j+KnNd5vup019VSIiharzXvm

---- cut here ---
9ACImQPzSQZWPbK6dWye8qNUf+pFdjzxIQ5Vn2z+wP4CbWirS6Qw8nIEKTLsKD
26bkCRiQoGNH6ikWXQ/04ygZqxhkUMC5ZcLHD+yjzpIo/QiQcPCBa5nnuuc4w3S
Js4PlHiYQeEtG+3TOUt1LgtZbp17BQZiUxCszDpg4UlzMmnNC5fisnfm1K0MGTq
te6vQNWleEu1kAFWMEckquVrdCfQ8W7T3P65bPd98+o0s3rnnvkFersF13j3o9
pkZWXI+rQqg56c8e6iFdeWGWxFs6cMSnsvjezq2Huht3C1ogOa2v/BnCA6YKQ6B
ILyxpbZyvjZIH2AZ22pf9oR58YsGhvJ/q4M0xRZsyjv4E+Z0tGAfwpa8Mu1wKos
aq6k/VcIJw
---- cut here ---

Later, Derek
.
EOT
```

## How To Use (Recipient)

```
C:\> PEK DECRYPT xm2J9Y6Dt/sXqSTsYVavpoBuHD0/3yWNvL6sfdlTSrN - MSG.TXT
9ACImQPzSQZWPbK6dWye8qNUf+pFdjzxIQ5Vn2z+wP4CbWirS6Qw8nIEKTLsKD
26bkCRiQoGNH6ikWXQ/04ygZqxhkUMC5ZcLHD+yjzpIo/QiQcPCBa5nnuuc4w3S
Js4PlHiYQeEtG+3TOUt1LgtZbp17BQZiUxCszDpg4UlzMmnNC5fisnfm1K0MGTq
te6vQNWleEu1kAFWMEckquVrdCfQ8W7T3P65bPd98+o0s3rnnvkFersF13j3o9
pkZWXI+rQqg56c8e6iFdeWGWxFs6cMSnsvjezq2Huht3C1ogOa2v/BnCA6YKQ6B
ILyxpbZyvjZIH2AZ22pf9oR58YsGhvJ/q4M0xRZsyjv4E+Z0tGAfwpa8Mu1wKos
aq6k/VcIJw
^Z

C:\> TYPE MSG.TXT
Lawyer's name is Bob Filmore. He is at 555-789-1000 (ext. 567).
Use PIN 9019 when accessing the funds. All Debbi's funds are now
in escrow, like the lawyer said. The hearing is to be on January 2nd
in Prescott, AZ. Thanks for everything.

C:\>
```

# Frequently Asked Questions

1. Why does the pek.txt script end in the '.txt' extension instead
of the more conventional '.py'?

The intention of this script was to be sent over email. People I
wanted to communicate securely with would be sent this file via email.
I found that my email applications made it hard to interact with
a file that ended in the '.py' extension, for various reasons:

 1. The .py extension isn't understood so it cannot be viewed.
 2. The .py extension is considered an executable and so won't let
    the user interact with it easily.

By contrast the .txt extension was great to interact with.
The .txt extension was tested on windows, linux, mac and
all the python interpreters handled it without issues.

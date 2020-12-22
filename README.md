# Summary
pek is a python3 script for public key encryption of files

# Description
pek is a command to encrypt and decrypt files using public/private keys.
Written for python3.

# About
This program has been designed to be an easy-to-install and simple-to-use tool
for exchanging small encrypted messages via email. The encrypted output was designed to
be cut and pasted from a terminal window into an email message. This program was designed
to be given to someone with minimal technical skills, such that they have a reasonable
chance of getting its dependencies installed and running. I.e. communicating with your parents/siblings.

See the COMMAND LINE OVERRIDE section at the bottom of this file to override the command line
arguments and manually enter the command line arguments. This is most often needed in
Windows environments.


```
# This program contains code from these other projects:
#   Elliptic Curve   Jimmy Song, https://github.com/jimmysong/programmingbitcoin.git
#   AES              Brandon Sterne, https://gist.github.com/raullenchai/2920069
#   bytes_to_int     brunsgaard, https://stackoverflow.com/questions/21017698/converting-int-to-bytes-in-python-3/30375198#30375198
#
```

# Dependencies:
```
#   os.urandom
#   os.path.isfile
#   os.path.exists
#   os.getcwd
#   sys.stdin
#   sys.stdout
#   sys.stderr
#   sys.argv
#   sys.exit
#   io.StringIO
#   copy(), open(), close(), read(), write()
```

# Synopsis:
```
#    C:\> PEK CREATE
#    Public key:  BfmFN9jG20aH44zyKxsdybJ1LmTRVO9wfbgoRxUU9v4
#    Private key: L9q3va61OaoSVQpQXvN/cajGpaoV0vmdCYpHC3JRYEw
#
#    C:\> PEK ENCRYPT BfmFN9jG20aH44zyKxsdybJ1LmTRVO9wfbgoRxUU9v4 C:\AUTOEXEC.BAT SECRET.PEK
#
#    C:\> TYPE SECRET.PEK
#    F71PzRXjySUtOtsvDv4xf+Xso/FYJ8BLXloVS9pez3ra5gMtxAOyYNIQNiURCL
#    5gdyHHN0+R83hvcBSO9qU5AbDbtfRE5SbxaBuf5Va8kGinT2ye194FSEHzrOW6q
#    1cIfcloKz1Z+Fj4qeqqtw1HBhc+U8u+fObWT7WIo3cKXEGAtCnZ0anrdc5ZRR8k
#    +raIU8RQcatFmAXpMUTX9xXzg3MTKyNSs5pfx/XLhD3qr0dSphECpzl6GGvOy1
#    1mu6Gr
#
#    C:\> PEK DECRYPT L9q3va61OaoSVQpQXvN/cajGpaoV0vmdCYpHC3JRYEw SECRET.PEK -
#    @echo off
#    SET SOUND=C:\PROGRA~1\CREATIVE\CTSND
#    SET BLASTER=A220 I5 D1 H5 P330 E620 T6
#    SET PATH=C:\Windows;C:\
#    LH C:\Windows\COMMAND\MSCDEX.EXE /D:123
#
#    C:\> 
```

# About:

The private key is a random 256-bit value (represented by the variable 'k').
#he public key is the secp256k1 generator point multiplied by the private key (represented by the variable 'P').

The shared key (see the 'sk' variable in ENCRYPT() and DECRYPT()) is derived
using ECDH (Elliptic Curve Diffie-Hellman) Key Exchange. An ephemeral private/public key pair is
produced (represented by 'e' and 'E'). The public ephemeral key is included in the encrypted output so
that that the decryption algorithm can derive the shared key 'sk'.

Once the shared key is obtained the plaintext is encrypted with it using AES 128 (Advanced
Encryption Standard). Cipher block chaining (CBC) is employed. The initialization vector is the shared key 'sk'.

This AES implementation operates on 128-bit blocks (it does use a 256-bit key).
#The lower 128-bits and upper 128-bits are encrypted seperatly and then combined
(see AES_ENCRYPT() and AES_DECRYPT()).

The public and private keys are represented by a 43-character BASE64 encoded string.

The encrypted file format is a stream of BASE64 characters with allowance
for whitespace appearing anywhere. The first 32-bytes are the the public ephemeral key.
The remaining data is the encrypted form of the plaintext.

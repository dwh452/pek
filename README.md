# Description
pek is a command to encrypt and decrypt files using public/private keys.
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
   bytes_to_int     brunsgaard, https://stackoverflow.com/questions/34009653/convert-bytes-to-int
```

# Dependencies
```
   os.urandom
   os.path.isfile
   os.path.exists
   os.getcwd
   sys.stdin
   sys.stdout
   sys.stderr
   sys.argv
   sys.exit
   io.StringIO
   copy(), open(), close(), read(), write()
   input()
```

# Synopsis
```
    C:\> PEK CREATE
    Public key:  BfmFN9jG20aH44zyKxsdybJ1LmTRVO9wfbgoRxUU9v4
    Private key: L9q3va61OaoSVQpQXvN/cajGpaoV0vmdCYpHC3JRYEw

    C:\> PEK ENCRYPT BfmFN9jG20aH44zyKxsdybJ1LmTRVO9wfbgoRxUU9v4 C:\AUTOEXEC.BAT SECRET.PEK

    C:\> TYPE SECRET.PEK
    F71PzRXjySUtOtsvDv4xf+Xso/FYJ8BLXloVS9pez3ra5gMtxAOyYNIQNiURCL
    5gdyHHN0+R83hvcBSO9qU5AbDbtfRE5SbxaBuf5Va8kGinT2ye194FSEHzrOW6q
    1cIfcloKz1Z+Fj4qeqqtw1HBhc+U8u+fObWT7WIo3cKXEGAtCnZ0anrdc5ZRR8k
    +raIU8RQcatFmAXpMUTX9xXzg3MTKyNSs5pfx/XLhD3qr0dSphECpzl6GGvOy1
    1mu6Gr

    C:\> PEK DECRYPT L9q3va61OaoSVQpQXvN/cajGpaoV0vmdCYpHC3JRYEw SECRET.PEK -
    @echo off
    SET SOUND=C:\PROGRA~1\CREATIVE\CTSND
    SET BLASTER=A220 I5 D1 H5 P330 E620 T6
    SET PATH=C:\Windows;C:\
    LH C:\Windows\COMMAND\MSCDEX.EXE /D:123

    C:\> PEK MENU
    1) Create Keys
    2) Encrypt file
    3) Decrypt file
    4) Help
    5) Quit
    Choose 1-5? 5

    C:\>
```

# Usage
```
Usage: pek create
       pek encrypt  <public-key>   <input>  <output>
       pek decrypt  <private-key>  <input>  <output>
       pek menu
       pek help

       <public-key>   this is a public key obtained from calling "pek create"
       <private-key>  this is a private key obtained from calling "pek create"
       <input>        this is the filename to read, use "-" to read from standard input
       <output>       this is the filename to write, use "-" to write to standard output

    Example:
        pek create
        pek encrypt UwcQDXZlP1kWjda3ngcJ4HzWsz+C4Ahth5ieidwu8n4 f1.txt f1.pek
        pek decrypt lZCBMbLb8GP/IkeKcPVCeoNLju/ynXsC6MZzm3D3ASk f1.pek original.txt
```

# About
The private key is a random 256-bit value (represented by the variable 'k').
The public key is the secp256k1 generator point multiplied by the private key (represented by the variable 'P').

The shared key (see the 'sk' variable in ENCRYPT() and DECRYPT()) is derived
using ECDH (Elliptic Curve Diffie-Hellman) Key Exchange. An ephemeral private/public key pair is
produced (represented by 'e' and 'E'). The public ephemeral key is included in the encrypted output so
that that the decryption algorithm can derive the shared key 'sk'.

Once the shared key is obtained the plaintext is encrypted with it using AES 128 (Advanced
Encryption Standard). Cipher block chaining (CBC) is employed. The initialization vector is the shared key 'sk'.

This AES implementation operates on 128-bit blocks (it does use a 256-bit key).
The lower 128-bits and upper 128-bits are encrypted seperatly and then combined
(see AES_ENCRYPT() and AES_DECRYPT()).

The public and private keys are represented by a 43-character BASE64 encoded string.

The encrypted file format is a stream of BASE64 characters with allowance
for whitespace appearing anywhere. The first 32-bytes are the the public ephemeral key.
The remaining data is the encrypted form of the plaintext.

## How To Use (Sender)
                                                                                                                                                                  
```
$ vi msg.txt

$ pek encrypt hH0jrC6XPVAbV58QjZH7zaLiIdVCJzjS7jugO07BhEk msg.txt -
ooxO372Kg/yFG0GqUI54Q8PFLcqfL9HcCbl8BI+O4hmFfL25Eqwy8WVtUPMzGS
Ziu/QOrsnhU4JQzTVeeqrAFNGDEqvbGdQCmhZgQshr8r8EouZgtwLe6M5ST8SBx
i/mRhKdJm+SE7X5YYgpxEA7LfLnroPNS7Q+yF//b0H1Sh5Y6zKHXGrl33XEjY8Q
8eMj3eKqXYZq8eFf6/KADXnYPcUMyEy4eo3aRTjGA6jOQI8e0oMTTbiaQ8xlU7
bRaMCemOMjuF8qAMFF/utYHcaHTcrPg7QFaKQJsSew1gUoSkR93iW9q0gKCoqNw
wVsMf1vr34/T1FH4wD5t7hKPmgvz+fBV0XX4Mk4rArvQVLXoSnI+s/CalL5+l24
F7jouWBsBAeZb39vgBmuYD8esmSHWuZm3Vm3EaRQt/a9yJ5cDrE

$ mail dad@daddomain.com
Hi Dad! I hope everything on the farm is going well. Nice to hear
about roscoe getting better after the porcupine encounter.

I talked to the laywer and we're going to proceed, I've included all the
details in this encrypted message. I used your latest
public key: hH0jrC6XPVAbV58QjZH7zaLiIdVCJzjS7jugO07BhEk

---- cut here ---
ooxO372Kg/yFG0GqUI54Q8PFLcqfL9HcCbl8BI+O4hmFfL25Eqwy8WVtUPMzGS
Ziu/QOrsnhU4JQzTVeeqrAFNGDEqvbGdQCmhZgQshr8r8EouZgtwLe6M5ST8SBx
i/mRhKdJm+SE7X5YYgpxEA7LfLnroPNS7Q+yF//b0H1Sh5Y6zKHXGrl33XEjY8Q
8eMj3eKqXYZq8eFf6/KADXnYPcUMyEy4eo3aRTjGA6jOQI8e0oMTTbiaQ8xlU7
bRaMCemOMjuF8qAMFF/utYHcaHTcrPg7QFaKQJsSew1gUoSkR93iW9q0gKCoqNw
wVsMf1vr34/T1FH4wD5t7hKPmgvz+fBV0XX4Mk4rArvQVLXoSnI+s/CalL5+l24
F7jouWBsBAeZb39vgBmuYD8esmSHWuZm3Vm3EaRQt/a9yJ5cDrE
---- cut here ---

Later, Derek
.
EOT
```

## How To Use (Recipient)

```
C:\> PEK DECRYPT 9tJiRuzFXPIFM0yQMc2o4NFUld6VVTnh6GUYHkogxXI - MSG.TXT
ooxO372Kg/yFG0GqUI54Q8PFLcqfL9HcCbl8BI+O4hmFfL25Eqwy8WVtUPMzGS
Ziu/QOrsnhU4JQzTVeeqrAFNGDEqvbGdQCmhZgQshr8r8EouZgtwLe6M5ST8SBx
i/mRhKdJm+SE7X5YYgpxEA7LfLnroPNS7Q+yF//b0H1Sh5Y6zKHXGrl33XEjY8Q
8eMj3eKqXYZq8eFf6/KADXnYPcUMyEy4eo3aRTjGA6jOQI8e0oMTTbiaQ8xlU7
bRaMCemOMjuF8qAMFF/utYHcaHTcrPg7QFaKQJsSew1gUoSkR93iW9q0gKCoqNw
wVsMf1vr34/T1FH4wD5t7hKPmgvz+fBV0XX4Mk4rArvQVLXoSnI+s/CalL5+l24
F7jouWBsBAeZb39vgBmuYD8esmSHWuZm3Vm3EaRQt/a9yJ5cDrE
^Z

C:\> TYPE MSG.TXT
Lawyer's name is Bob Filmore. He is at 555-789-1000 (ext. 567).
Use PIN 9019 when accessing the funds. All Debbi's funds are now
in escrow, like the lawyer said. The hearing is to be on January 2nd
in Prescott, AZ. Thanks for everything, Sorry about all this mess!

C:\>
```

# Frequently Asked Questions

1. Why does the pek.txt script end in the '.txt' extension instead
of the more conventional '.py'?

The intention of this script was to be sent over email. People I
wanted to communicate securly with would be sent this file via email.
I found that my email applications made it hard to interact with
a file that ended in the '.py' extension, for various reasons:

 1. The .py extension isn't understood so it cannot be viewed.
 2. The .py extension is considered an executable and so won't let
    the user interact with it easily.

By contrast the .txt extension was great to interact with.
The .txt extension was tested on windows, linux, mac and
all the python interpreters handled it without issues.

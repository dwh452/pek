#!/usr/bin/python3

######################################################################
#
# pek is a command to encrypt and decrypt files using public/private keys.
# Written for python3.
#
# This program has been designed to be an easy-to-install and simple-to-use tool
# for exchanging small encrypted messages via email. The encrypted output was designed to
# be cut and pasted from a terminal window into an email message. This program was designed
# to be given to someone with minimal technical skills, such that they have a reasonable
# chance of getting its dependencies installed and running. I.e. communicating with your parents/siblings.
#
# See the COMMAND LINE OVERRIDE section at the bottom of this file to override the command line
# arguments and manually enter the command line arguments. This is most often needed in
# Windows environments.
#
# This program contains code from these other projects:
#   Elliptic Curve   Jimmy Song, https://github.com/jimmysong/programmingbitcoin.git
#   AES              Brandon Sterne, https://gist.github.com/raullenchai/2920069
#   bytes_to_int     brunsgaard, https://stackoverflow.com/questions/21017698/converting-int-to-bytes-in-python-3/30375198#30375198
#
# Dependencies:
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
#
# Synopsis:
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
#
# About:
# The private key is a random 256-bit value (represented by the variable 'k').
# The public key is the secp256k1 generator point multiplied by the private key (represented by the variable 'P').
#
# The shared key (see the 'sk' variable in ENCRYPT() and DECRYPT()) is derived
# using ECDH (Elliptic Curve Diffie-Hellman) Key Exchange. An ephemeral private/public key pair is
# produced (represented by 'e' and 'E'). The public ephemeral key is included in the encrypted output so
# that that the decryption algorithm can derive the shared key 'sk'.
#
# Once the shared key is obtained the plaintext is encrypted with it using AES 128 (Advanced
# Encryption Standard). Cipher block chaining (CBC) is employed. The initialization vector is the shared key 'sk'.
#
# This AES implementation operates on 128-bit blocks (it does use a 256-bit key).
# The lower 128-bits and upper 128-bits are encrypted seperatly and then combined
# (see AES_ENCRYPT() and AES_DECRYPT()).
#
# The public and private keys are represented by a 43-character BASE64 encoded string.
#
# The encrypted file format is a stream of BASE64 characters with allowance
# for whitespace appearing anywhere. The first 32-bytes are the the public ephemeral key.
# The remaining data is the encrypted form of the plaintext.
#
# The code is organized as follows:
#
#   Section 1: Elliptic Curve
#   Section 2: AES - Advanced Encryption Standard
#   Section 3: BASE64 Reading & Writing
#   Section 4: CREATE, ENCRYPT, DECRYPT implementations
#   Section 5: Command Line Processing
#   Section 6: MAIN()
#
######################################################################

import sys
import os
import io
from copy import copy

######################################################################
#
# Section 1: Elliptic Curve
#
######################################################################

#
# This code is from the Programming Bitcoin book by Jimmy Song
# https://github.com/jimmysong/programmingbitcoin.git
#

class FieldElement:

    def __init__(self, num, prime):
        if num >= prime or num < 0:
            error = 'Num {} not in field range 0 to {}'.format(
                num, prime - 1)
            raise ValueError(error)
        self.num = num
        self.prime = prime

    def __repr__(self):
        return 'FieldElement_{}({})'.format(self.prime, self.num)

    def __eq__(self, other):
        if other is None:
            return False
        return self.num == other.num and self.prime == other.prime

    def __ne__(self, other):
        # this should be the inverse of the == operator
        return not (self == other)

    def __add__(self, other):
        if self.prime != other.prime:
            raise TypeError('Cannot add two numbers in different Fields')
        # self.num and other.num are the actual values
        # self.prime is what we need to mod against
        num = (self.num + other.num) % self.prime
        # We return an element of the same class
        return self.__class__(num, self.prime)

    def __sub__(self, other):
        if self.prime != other.prime:
            raise TypeError('Cannot subtract two numbers in different Fields')
        # self.num and other.num are the actual values
        # self.prime is what we need to mod against
        num = (self.num - other.num) % self.prime
        # We return an element of the same class
        return self.__class__(num, self.prime)

    def __mul__(self, other):
        if self.prime != other.prime:
            raise TypeError('Cannot multiply two numbers in different Fields')
        # self.num and other.num are the actual values
        # self.prime is what we need to mod against
        num = (self.num * other.num) % self.prime
        # We return an element of the same class
        return self.__class__(num, self.prime)

    def __pow__(self, exponent):
        n = exponent % (self.prime - 1)
        num = pow(self.num, n, self.prime)
        return self.__class__(num, self.prime)

    def __truediv__(self, other):
        if self.prime != other.prime:
            raise TypeError('Cannot divide two numbers in different Fields')
        # self.num and other.num are the actual values
        # self.prime is what we need to mod against
        # use fermat's little theorem:
        # self.num**(p-1) % p == 1
        # this means:
        # 1/n == pow(n, p-2, p)
        num = (self.num * pow(other.num, self.prime - 2, self.prime)) % self.prime
        # We return an element of the same class
        return self.__class__(num, self.prime)

    def __rmul__(self, coefficient):
        num = (self.num * coefficient) % self.prime
        return self.__class__(num=num, prime=self.prime)


class Point:

    def __init__(self, x, y, a, b):
        self.a = a
        self.b = b
        self.x = x
        self.y = y
        # x being None and y being None represents the point at infinity
        # Check for that here since the equation below won't make sense
        # with None values for both.
        if self.x is None and self.y is None:
            return
        # make sure that the elliptic curve equation is satisfied
        # y**2 == x**3 + a*x + b
        if self.y**2 != self.x**3 + a * x + b:
            # if not, throw a ValueError
            raise ValueError('({}, {}) is not on the curve'.format(x, y))

    def __eq__(self, other):
        return self.x == other.x and self.y == other.y \
            and self.a == other.a and self.b == other.b

    def __ne__(self, other):
        # this should be the inverse of the == operator
        return not (self == other)

    def __repr__(self):
        if self.x is None:
            return 'Point(infinity)'
        elif isinstance(self.x, FieldElement):
            return 'Point({},{})_{}_{} FieldElement({})'.format(
                self.x.num, self.y.num, self.a.num, self.b.num, self.x.prime)
        else:
            return 'Point({},{})_{}_{}'.format(self.x, self.y, self.a, self.b)

    def __add__(self, other):
        if self.a != other.a or self.b != other.b:
            raise TypeError('Points {}, {} are not on the same curve'.format(self, other))
        # Case 0.0: self is the point at infinity, return other
        if self.x is None:
            return other
        # Case 0.1: other is the point at infinity, return self
        if other.x is None:
            return self

        # Case 1: self.x == other.x, self.y != other.y
        # Result is point at infinity
        if self.x == other.x and self.y != other.y:
            return self.__class__(None, None, self.a, self.b)

        # Case 2: self.x ≠ other.x
        # Formula (x3,y3)==(x1,y1)+(x2,y2)
        # s=(y2-y1)/(x2-x1)
        # x3=s**2-x1-x2
        # y3=s*(x1-x3)-y1
        if self.x != other.x:
            s = (other.y - self.y) / (other.x - self.x)
            x = s**2 - self.x - other.x
            y = s * (self.x - x) - self.y
            return self.__class__(x, y, self.a, self.b)

        # Case 4: if we are tangent to the vertical line,
        # we return the point at infinity
        # note instead of figuring out what 0 is for each type
        # we just use 0 * self.x
        if self == other and self.y == 0 * self.x:
            return self.__class__(None, None, self.a, self.b)

        # Case 3: self == other
        # Formula (x3,y3)=(x1,y1)+(x1,y1)
        # s=(3*x1**2+a)/(2*y1)
        # x3=s**2-2*x1
        # y3=s*(x1-x3)-y1
        if self == other:
            s = (3 * self.x**2 + self.a) / (2 * self.y)
            x = s**2 - 2 * self.x
            y = s * (self.x - x) - self.y
            return self.__class__(x, y, self.a, self.b)

    def __rmul__(self, coefficient):
        coef = coefficient
        current = self
        result = self.__class__(None, None, self.a, self.b)
        while coef:
            if coef & 1:
                result += current
            current += current
            coef >>= 1
        return result

A = 0
B = 7
P = 2**256 - 2**32 - 977
N = 0xfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141

class S256Field(FieldElement):

    def __init__(self, num, prime=None):
        super().__init__(num=num, prime=P)

    def __repr__(self):
        return '{:x}'.format(self.num).zfill(64)

    def sqrt(self):
        return self**((P + 1) // 4)

class S256Point(Point):

    def __init__(self, x, y, a=None, b=None):
        a, b = S256Field(A), S256Field(B)
        if type(x) == int:
            super().__init__(x=S256Field(x), y=S256Field(y), a=a, b=b)
        else:
            super().__init__(x=x, y=y, a=a, b=b)

    def __repr__(self):
        if self.x is None:
            return 'S256Point(infinity)'
        else:
            return 'S256Point({}, {})'.format(self.x, self.y)

    def __rmul__(self, coefficient):
        coef = coefficient % N
        return super().__rmul__(coef)

    def verify(self, z, sig):
        # By Fermat's Little Theorem, 1/s = pow(s, N-2, N)
        s_inv = pow(sig.s, N - 2, N)
        # u = z / s
        u = z * s_inv % N
        # v = r / s
        v = sig.r * s_inv % N
        # u*G + v*P should have as the x coordinate, r
        total = u * G + v * self
        return total.x.num == sig.r

    def sec(self, compressed=True):
        '''returns the binary version of the SEC format'''
        if compressed:
            if self.y.num % 2 == 0:
                return b'\x02' + self.x.num.to_bytes(32, 'big')
            else:
                return b'\x03' + self.x.num.to_bytes(32, 'big')
        else:
            return b'\x04' + self.x.num.to_bytes(32, 'big') + \
                self.y.num.to_bytes(32, 'big')

G = S256Point(
    0x79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798,
    0x483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8 )

######################################################################
#
# Section 2: AES - Advanced Encryption Standard
#
######################################################################

#
# Copyright (c) 2007 Brandon Sterne
# Licensed under the MIT license.
# http://brandon.sternefamily.net/files/mit-license.txt
# Python AES implementation

# The actual Rijndael specification includes variable block size, but
# AES uses a fixed block size of 16 bytes (128 bits)

# Additionally, AES allows for a variable key size, though this implementation
# of AES uses only 256-bit cipher keys (AES-256)

sbox = [
        0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76,
        0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0,
        0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15,
        0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75,
        0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84,
        0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf,
        0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8,
        0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2,
        0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73,
        0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb,
        0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79,
        0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08,
        0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a,
        0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e,
        0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf,
        0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16
        ]

sboxInv = [
        0x52, 0x09, 0x6a, 0xd5, 0x30, 0x36, 0xa5, 0x38, 0xbf, 0x40, 0xa3, 0x9e, 0x81, 0xf3, 0xd7, 0xfb,
        0x7c, 0xe3, 0x39, 0x82, 0x9b, 0x2f, 0xff, 0x87, 0x34, 0x8e, 0x43, 0x44, 0xc4, 0xde, 0xe9, 0xcb,
        0x54, 0x7b, 0x94, 0x32, 0xa6, 0xc2, 0x23, 0x3d, 0xee, 0x4c, 0x95, 0x0b, 0x42, 0xfa, 0xc3, 0x4e,
        0x08, 0x2e, 0xa1, 0x66, 0x28, 0xd9, 0x24, 0xb2, 0x76, 0x5b, 0xa2, 0x49, 0x6d, 0x8b, 0xd1, 0x25,
        0x72, 0xf8, 0xf6, 0x64, 0x86, 0x68, 0x98, 0x16, 0xd4, 0xa4, 0x5c, 0xcc, 0x5d, 0x65, 0xb6, 0x92,
        0x6c, 0x70, 0x48, 0x50, 0xfd, 0xed, 0xb9, 0xda, 0x5e, 0x15, 0x46, 0x57, 0xa7, 0x8d, 0x9d, 0x84,
        0x90, 0xd8, 0xab, 0x00, 0x8c, 0xbc, 0xd3, 0x0a, 0xf7, 0xe4, 0x58, 0x05, 0xb8, 0xb3, 0x45, 0x06,
        0xd0, 0x2c, 0x1e, 0x8f, 0xca, 0x3f, 0x0f, 0x02, 0xc1, 0xaf, 0xbd, 0x03, 0x01, 0x13, 0x8a, 0x6b,
        0x3a, 0x91, 0x11, 0x41, 0x4f, 0x67, 0xdc, 0xea, 0x97, 0xf2, 0xcf, 0xce, 0xf0, 0xb4, 0xe6, 0x73,
        0x96, 0xac, 0x74, 0x22, 0xe7, 0xad, 0x35, 0x85, 0xe2, 0xf9, 0x37, 0xe8, 0x1c, 0x75, 0xdf, 0x6e,
        0x47, 0xf1, 0x1a, 0x71, 0x1d, 0x29, 0xc5, 0x89, 0x6f, 0xb7, 0x62, 0x0e, 0xaa, 0x18, 0xbe, 0x1b,
        0xfc, 0x56, 0x3e, 0x4b, 0xc6, 0xd2, 0x79, 0x20, 0x9a, 0xdb, 0xc0, 0xfe, 0x78, 0xcd, 0x5a, 0xf4,
        0x1f, 0xdd, 0xa8, 0x33, 0x88, 0x07, 0xc7, 0x31, 0xb1, 0x12, 0x10, 0x59, 0x27, 0x80, 0xec, 0x5f,
        0x60, 0x51, 0x7f, 0xa9, 0x19, 0xb5, 0x4a, 0x0d, 0x2d, 0xe5, 0x7a, 0x9f, 0x93, 0xc9, 0x9c, 0xef,
        0xa0, 0xe0, 0x3b, 0x4d, 0xae, 0x2a, 0xf5, 0xb0, 0xc8, 0xeb, 0xbb, 0x3c, 0x83, 0x53, 0x99, 0x61,
        0x17, 0x2b, 0x04, 0x7e, 0xba, 0x77, 0xd6, 0x26, 0xe1, 0x69, 0x14, 0x63, 0x55, 0x21, 0x0c, 0x7d
        ]

rcon = [
        0x8d, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1b, 0x36, 0x6c, 0xd8, 0xab, 0x4d, 0x9a,
        0x2f, 0x5e, 0xbc, 0x63, 0xc6, 0x97, 0x35, 0x6a, 0xd4, 0xb3, 0x7d, 0xfa, 0xef, 0xc5, 0x91, 0x39,
        0x72, 0xe4, 0xd3, 0xbd, 0x61, 0xc2, 0x9f, 0x25, 0x4a, 0x94, 0x33, 0x66, 0xcc, 0x83, 0x1d, 0x3a,
        0x74, 0xe8, 0xcb, 0x8d, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1b, 0x36, 0x6c, 0xd8,
        0xab, 0x4d, 0x9a, 0x2f, 0x5e, 0xbc, 0x63, 0xc6, 0x97, 0x35, 0x6a, 0xd4, 0xb3, 0x7d, 0xfa, 0xef,
        0xc5, 0x91, 0x39, 0x72, 0xe4, 0xd3, 0xbd, 0x61, 0xc2, 0x9f, 0x25, 0x4a, 0x94, 0x33, 0x66, 0xcc,
        0x83, 0x1d, 0x3a, 0x74, 0xe8, 0xcb, 0x8d, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1b,
        0x36, 0x6c, 0xd8, 0xab, 0x4d, 0x9a, 0x2f, 0x5e, 0xbc, 0x63, 0xc6, 0x97, 0x35, 0x6a, 0xd4, 0xb3,
        0x7d, 0xfa, 0xef, 0xc5, 0x91, 0x39, 0x72, 0xe4, 0xd3, 0xbd, 0x61, 0xc2, 0x9f, 0x25, 0x4a, 0x94,
        0x33, 0x66, 0xcc, 0x83, 0x1d, 0x3a, 0x74, 0xe8, 0xcb, 0x8d, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20,
        0x40, 0x80, 0x1b, 0x36, 0x6c, 0xd8, 0xab, 0x4d, 0x9a, 0x2f, 0x5e, 0xbc, 0x63, 0xc6, 0x97, 0x35,
        0x6a, 0xd4, 0xb3, 0x7d, 0xfa, 0xef, 0xc5, 0x91, 0x39, 0x72, 0xe4, 0xd3, 0xbd, 0x61, 0xc2, 0x9f,
        0x25, 0x4a, 0x94, 0x33, 0x66, 0xcc, 0x83, 0x1d, 0x3a, 0x74, 0xe8, 0xcb, 0x8d, 0x01, 0x02, 0x04,
        0x08, 0x10, 0x20, 0x40, 0x80, 0x1b, 0x36, 0x6c, 0xd8, 0xab, 0x4d, 0x9a, 0x2f, 0x5e, 0xbc, 0x63,
        0xc6, 0x97, 0x35, 0x6a, 0xd4, 0xb3, 0x7d, 0xfa, 0xef, 0xc5, 0x91, 0x39, 0x72, 0xe4, 0xd3, 0xbd,
        0x61, 0xc2, 0x9f, 0x25, 0x4a, 0x94, 0x33, 0x66, 0xcc, 0x83, 0x1d, 0x3a, 0x74, 0xe8, 0xcb
        ]

# returns a copy of the word shifted n bytes (chars)
# positive values for n shift bytes left, negative values shift right
def rotate(word, n):
    return word[n:]+word[0:n]

# iterate over each "virtual" row in the state table and shift the bytes
# to the LEFT by the appropriate offset
def shiftRows(state):
    for i in range(4):
        state[i*4:i*4+4] = rotate(state[i*4:i*4+4],i)

# iterate over each "virtual" row in the state table and shift the bytes
# to the RIGHT by the appropriate offset
def shiftRowsInv(state):
    for i in range(4):
        state[i*4:i*4+4] = rotate(state[i*4:i*4+4],-i)

# takes 4-byte word and iteration number
def keyScheduleCore(word, i):
    # rotate word 1 byte to the left
    word = rotate(word, 1)
    newWord = []
    # apply sbox substitution on all bytes of word
    for byte in word:
        newWord.append(sbox[byte])
    # XOR the output of the rcon[i] transformation with the first part of the word
    newWord[0] = newWord[0]^rcon[i]
    return newWord

# expand 256 bit cipher key into 240 byte key from which
# each round key is derived
def expandKey(cipherKey):
    cipherKeySize = len(cipherKey)
    assert cipherKeySize == 32
    # container for expanded key
    expandedKey = []
    currentSize = 0
    rconIter = 1
    # temporary list to store 4 bytes at a time
    t = [0,0,0,0]

    # copy the first 32 bytes of the cipher key to the expanded key
    for i in range(cipherKeySize):
        expandedKey.append(cipherKey[i])
    currentSize += cipherKeySize

    # generate the remaining bytes until we get a total key size
    # of 240 bytes
    while currentSize < 240:
        # assign previous 4 bytes to the temporary storage t
        for i in range(4):
            t[i] = expandedKey[(currentSize - 4) + i]

        # every 32 bytes apply the core schedule to t
        if currentSize % cipherKeySize == 0:
            t = keyScheduleCore(t, rconIter)
            rconIter += 1

        # since we're using a 256-bit key -> add an extra sbox transform
        if currentSize % cipherKeySize == 16:
            for i in range(4):
                t[i] = sbox[t[i]]

        # XOR t with the 4-byte block [16,24,32] bytes before the end of the
        # current expanded key.  These 4 bytes become the next bytes in the
        # expanded key
        for i in range(4):
            expandedKey.append(((expandedKey[currentSize - cipherKeySize]) ^ (t[i])))
            currentSize += 1
            
    return expandedKey

# do sbox transform on each of the values in the state table
def subBytes(state):
    for i in range(len(state)):
        #print "state[i]:", state[i]
        #print "sbox[state[i]]:", sbox[state[i]]
        state[i] = sbox[state[i]]

# inverse sbox transform on each byte in state table
def subBytesInv(state):
    for i in range(len(state)):
        state[i] = sboxInv[state[i]]

# XOR each byte of the roundKey with the state table
def addRoundKey(state, roundKey):
    for i in range(len(state)):
        #print i
        #print "old state value:", state[i]
        #print "new state value:", state[i] ^ roundKey[i]
        state[i] = state[i] ^ roundKey[i]

# Galois Multiplication
def galoisMult(a, b):
    p = 0
    hiBitSet = 0
    for i in range(8):
        if b & 1 == 1:
            p ^= a
        hiBitSet = a & 0x80
        a <<= 1
        if hiBitSet == 0x80:
            a ^= 0x1b
        b >>= 1
    return p % 256

# mixColumn takes a column and does stuff
def mixColumn(column):
    temp = copy(column)
    column[0] = galoisMult(temp[0],2) ^ galoisMult(temp[3],1) ^ \
                galoisMult(temp[2],1) ^ galoisMult(temp[1],3)
    column[1] = galoisMult(temp[1],2) ^ galoisMult(temp[0],1) ^ \
                galoisMult(temp[3],1) ^ galoisMult(temp[2],3)
    column[2] = galoisMult(temp[2],2) ^ galoisMult(temp[1],1) ^ \
                galoisMult(temp[0],1) ^ galoisMult(temp[3],3)
    column[3] = galoisMult(temp[3],2) ^ galoisMult(temp[2],1) ^ \
                galoisMult(temp[1],1) ^ galoisMult(temp[0],3)

# mixColumnInv does stuff too
def mixColumnInv(column):
    temp = copy(column)
    column[0] = galoisMult(temp[0],14) ^ galoisMult(temp[3],9) ^ \
                galoisMult(temp[2],13) ^ galoisMult(temp[1],11)
    column[1] = galoisMult(temp[1],14) ^ galoisMult(temp[0],9) ^ \
                galoisMult(temp[3],13) ^ galoisMult(temp[2],11)
    column[2] = galoisMult(temp[2],14) ^ galoisMult(temp[1],9) ^ \
                galoisMult(temp[0],13) ^ galoisMult(temp[3],11)
    column[3] = galoisMult(temp[3],14) ^ galoisMult(temp[2],9) ^ \
                galoisMult(temp[1],13) ^ galoisMult(temp[0],11)

# mixColumns is a wrapper for mixColumn - generates a "virtual" column from
# the state table and applies the weird galois math
def mixColumns(state):
    for i in range(4):
        column = []
        # create the column by taking the same item out of each "virtual" row
        for j in range(4):
            column.append(state[j*4+i])

        # apply mixColumn on our virtual column
        mixColumn(column)

        # transfer the new values back into the state table
        for j in range(4):
            state[j*4+i] = column[j]

# mixColumnsInv is a wrapper for mixColumnInv - generates a "virtual" column from
# the state table and applies the weird galois math
def mixColumnsInv(state):
    for i in range(4):
        column = []
        # create the column by taking the same item out of each "virtual" row
        for j in range(4):
            column.append(state[j*4+i])

        # apply mixColumn on our virtual column
        mixColumnInv(column)

        # transfer the new values back into the state table
        for j in range(4):
            state[j*4+i] = column[j]

# aesRound applies each of the four transformations in order
def aesRound(state, roundKey):
    #print "aesRound - before subBytes:", state
    subBytes(state)
    #print "aesRound - before shiftRows:", state
    shiftRows(state)
    #print "aesRound - before mixColumns:", state
    mixColumns(state)
    #print "aesRound - before addRoundKey:", state
    addRoundKey(state, roundKey)
    #print "aesRound - after addRoundKey:", state

# aesRoundInv applies each of the four inverse transformations
def aesRoundInv(state, roundKey):
    #print "aesRoundInv - before addRoundKey:", state
    addRoundKey(state, roundKey)
    #print "aesRoundInv - before mixColumnsInv:", state
    mixColumnsInv(state)
    #print "aesRoundInv - before shiftRowsInv:", state
    shiftRowsInv(state)
    #print "aesRoundInv - before subBytesInv:", state
    subBytesInv(state)
    #print "aesRoundInv - after subBytesInv:", state


# returns a 16-byte round key based on an expanded key and round number
def createRoundKey(expandedKey, n):
    return expandedKey[(n*16):(n*16+16)]

# create a key from a user-supplied password using SHA-256
def passwordToKey(password):
    sha256 = hashlib.sha256()
    sha256.update(password)
    key = []
    for c in list(sha256.digest()):
        key.append(ord(c))
    return key

# wrapper function for 14 rounds of AES since we're using a 256-bit key
def aesMain(state, expandedKey, numRounds=14):
    roundKey = createRoundKey(expandedKey, 0)
    addRoundKey(state, roundKey)
    for i in range(1, numRounds):
        roundKey = createRoundKey(expandedKey, i)
        aesRound(state, roundKey)
    # final round - leave out the mixColumns transformation
    roundKey = createRoundKey(expandedKey, numRounds)
    subBytes(state)
    shiftRows(state)
    addRoundKey(state, roundKey)

# 14 rounds of AES inverse since we're using a 256-bit key
def aesMainInv(state, expandedKey, numRounds=14):
    # create roundKey for "last" round since we're going in reverse
    roundKey = createRoundKey(expandedKey, numRounds)
    # addRoundKey is the same funtion for inverse since it uses XOR
    addRoundKey(state, roundKey)
    shiftRowsInv(state)
    subBytesInv(state)
    for i in range(numRounds-1,0,-1):
        roundKey = createRoundKey(expandedKey, i)
        aesRoundInv(state, roundKey)
    # last round - leave out the mixColumns transformation
    roundKey = createRoundKey(expandedKey, 0)
    addRoundKey(state, roundKey)
    
# aesEncrypt - encrypt a single block of plaintext
def aesEncrypt(plaintext, key):
    block = copy(plaintext)
    expandedKey = expandKey(key)
    aesMain(block, expandedKey)
    return block

# aesDecrypt - decrypte a single block of ciphertext
def aesDecrypt(ciphertext, key):
    block = copy(ciphertext)
    expandedKey = expandKey(key)
    aesMainInv(block, expandedKey)
    return block

######################################################################
#
# Section 3: BASE64 Reading & Writing
#
######################################################################

class BASE64_READER:
    def __init__(self, i):
        self.i = i          # file should be open using mode READ_TEXT
        self.cb = 0
        self.current_byte = 0
        self.got_lookahead = False
        self.lookahead = False
        self.got_error = False
        self.error_msg = False
        self.error_cnt = 0

    def BYTE_OFFSET(self, b):
        return int( b / 8 )

    def BIT_OFFSET(self, b):
        return 7 - int( b - self.BYTE_OFFSET(b)*8 )

    def DECODE_CHAR(self, ch):
        if ch >= "A" and ch <= "Z":
            return (ord(ch) - ord("A")) + 0
        elif ch >= "a" and ch <= "z":
            return (ord(ch) - ord("a")) + 26
        elif ch >= "0" and ch <= "9":
            return (ord(ch) - ord("0")) + 52
        elif ch == "+":
            return 62
        elif ch == "/":
            return 63
        else:
            self.got_error = True
            self.error_msg = "invalid base64 character '{}' ".format(ch)
            self.error_cnt = self.error_cnt + 1
            return 0

    def IS_WHITESPACE(self, ch):
        return ch.isspace()

    def GET_CHAR(self):
        if self.got_lookahead:
            self.got_lookahead = False
            return self.lookahead
        else:
            ch = self.i.read(1)
            if len(ch) == 0:
                return None
            else:
                return ch

    def UNGET_CHAR(self, ch):
        self.got_lookahead = True
        self.lookahead = ch

    def EOF(self):
        if self.got_lookahead:
            return False
        else:
            ch = self.GET_CHAR()

            while ch != None and self.IS_WHITESPACE(ch):
                ch = self.GET_CHAR()

            if ch != None:
                self.UNGET_CHAR(ch)
                return False
            else:
                return True

    def READ(self, n):
        result = bytearray()
        done = False
        while not done:
            ch = self.GET_CHAR()
            if ch == None:
                done = True
            elif not self.IS_WHITESPACE(ch):
                b6 = self.DECODE_CHAR(ch)
                self.ADD_6BITS(result, b6)

            if len(result) == n:
                done = True

        return result

    def ADD_6BITS(self, result, b6):
        cb = self.cb
        current_byte = self.current_byte

        b = self.BIT_OFFSET(cb)

        if b == 7:
            current_byte = b6 << 2

        elif b == 6:
            current_byte = current_byte | (b6 << 1)

        elif b == 5:
            current_byte = current_byte | b6
            result.append(current_byte)
            current_byte = 0

        elif b == 4:
            current_byte = current_byte | (b6 >> 1)
            result.append(current_byte)
            current_byte = (b6 & 1) << 7

        elif b == 3:
            current_byte = current_byte | (b6 >> 2)
            result.append(current_byte)
            current_byte = (b6 & 3) << 6

        elif b == 2:
            current_byte = current_byte | (b6 >> 3)
            result.append(current_byte)
            current_byte = (b6 & 7) << 5

        elif b == 1:
            current_byte = current_byte | (b6 >> 4)
            result.append(current_byte)
            current_byte = (b6 & 15) << 4

        elif b == 0:
            current_byte = current_byte | (b6 >> 5)
            result.append(current_byte)
            current_byte = (b6 & 31) << 3

        cb = cb + 6

        self.cb = cb
        self.current_byte = current_byte

class BASE64_WRITER:
    def __init__(self, o):
        self.o = o          # should be opened using mode WRITE_TEXT
        self.b6_len = 0
        self.b6 = 0
        self.col = 0

    def ENCODE_B6(self, b6):
        if b6 >= 0 and b6 <= 25:
            return chr(ord("A") + b6)
        elif b6 >= 26 and b6 <= 51:
            return chr(ord("a") + (b6-26))
        elif b6 >= 52 and b6 <= 61:
            return chr(ord("0") + (b6-52))
        elif b6 == 62:
            return "+"
        else:
            return "/"

    def WRITE(self, bytes):
        for b in bytes:
            self.WRITE_BYTE(b)

    def WRITE_BYTE(self, b):
        b6 = self.b6
        b6_len = self.b6_len

        if b6_len == 0:
            b6 = b6 | (b >> 2)
            self.o.write( self.ENCODE_B6(b6) )
            b6 = (b & 0x03) << 4
            b6_len = 2

        elif b6_len == 1:
            b6 = b6 | (b >> 3)
            self.o.write( self.ENCODE_B6(b6) )
            b6 = (b & 0x07) << 3
            b6_len = 3

        elif b6_len == 2:
            b6 = b6 | (b >> 4)
            self.o.write( self.ENCODE_B6(b6) )
            b6 = (b & 0x0F) << 2
            b6_len = 4

        elif b6_len == 3:
            b6 = b6 | (b >> 5)
            self.o.write( self.ENCODE_B6(b6) )
            b6 = (b & 0x1F) << 1
            b6_len = 5

        elif b6_len == 4:
            b6 = b6 | (b >> 6)
            self.o.write( self.ENCODE_B6(b6) )
            b6 = (b & 0x3F) << 0
            self.o.write( self.ENCODE_B6(b6) )
            b6 = 0
            b6_len = 0

        elif b6_len == 5:
            b6 = b6 | (b >> 7)
            self.o.write( self.ENCODE_B6(b6) )
            b6 = (b & 0x7E) >> 1
            self.o.write( self.ENCODE_B6(b6) )
            b6 = (b) << 5
            b6_len = 1

        self.b6 = b6
        self.b6_len = b6_len

        self.col = self.col + 1
        if self.col > 46:
            self.o.write("\n")
            self.col = 0

    def CLOSE(self):
        if self.b6_len > 0:
            self.o.write( self.ENCODE_B6(self.b6) )
        self.o.write("\n")

def IS_BASE64_CHAR(ch):
    if ch >= "a" and ch <= "z":
        return True
    elif ch >= "A" and ch <= "Z":
        return True
    elif ch >= "0" and ch <= "9":
        return True
    elif ch == "+":
        return True
    elif ch == "/":
        return True
    else:
        return False

######################################################################
#
# Section 4: CREATE, ENCRYPT, DECRYPT implementations
#
######################################################################

def PAD(block, n):
    if len(block) < n:
        block.append( 0xFF )

    while len(block) < n:
        block.append( 0x00 )

def UNPAD(block):
    while block[ len(block)-1 ] == 0x00:
        block.pop(-1)
    block.pop(-1)

def XOR(mask, data):
    for i in range(len(data)):
        data[i] = data[i] ^ mask[i]

def RANDOM256():
    return bytearray(os.urandom(32))

#
# [brunsgaard] https://stackoverflow.com/questions/21017698/converting-int-to-bytes-in-python-3/30375198#30375198
#
def INT_TO_BYTES(value, length):
    result = bytearray()
    for i in range(0, length):
        result.append(value >> (i * 8) & 0xff)
    result.reverse()
    return result

def BYTES_TO_INT(bytes):
    result = 0
    for b in bytes:
        result = result * 256 + int(b)
    return result

Gx = INT_TO_BYTES(G.x.num, 32)         # x-coordinate of generator point G

def VALID_POINT(P):
    x = BYTES_TO_INT(P)

    #
    # solve for y:  y^2 = x^3 + a * x + b
    #
    ysquared = S256Field(x)**3 + S256Field(A) * S256Field(x) + S256Field(B)
    y = ysquared.sqrt()

    try:
        P = S256Point(x, y.num)
    except:
        return False

    return True

def SCALE_POINT(P, s):
    x = BYTES_TO_INT(P)
    scalar = BYTES_TO_INT(s)

    #
    # solve for y:  y^2 = x^3 + a * x + b
    #
    ysquared = S256Field(x)**3 + S256Field(A) * S256Field(x) + S256Field(B)
    y = ysquared.sqrt()

    P = S256Point(x, y.num)
    result = scalar * P
    return INT_TO_BYTES(result.x.num, 32)

def AES_ENCRYPT(key, bytes):
    s1 = slice(0, 16)
    s2 = slice(16, 32)
    return aesEncrypt(bytes[s1], key) + aesEncrypt(bytes[s2], key)

def AES_DECRYPT(key, bytes):
    s1 = slice(0, 16)
    s2 = slice(16, 32)
    return aesDecrypt(bytes[s1], key) + aesDecrypt(bytes[s2], key)

def CREATE():
    k = RANDOM256()
    P = SCALE_POINT(Gx, k)
    return (P, k)

def ENCRYPT(P, i, o):
    e = RANDOM256()
    E = SCALE_POINT(Gx, e)
    sk = SCALE_POINT(P, e)
    w = BASE64_WRITER(o)
    w.WRITE(E)
    xor_mask = sk
    eof = False
    while not eof:
        plaintext_bytes = bytearray(i.read(32))
        if len(plaintext_bytes) != 32:
            PAD(plaintext_bytes, 32)
            eof = True
        XOR(xor_mask, plaintext_bytes)
        encrypted_bytes = AES_ENCRYPT(sk, plaintext_bytes)
        w.WRITE(encrypted_bytes)
        xor_mask = encrypted_bytes
    w.CLOSE()
    return None

def DECRYPT(k, i, o):
    r = BASE64_READER(i)
    E = r.READ(32)
    if len(E) != 32:
        return "decoding error. ephemeral public key len={} != 32".format(len(E))
    if not VALID_POINT(E):
        return "decoding error: ephemeral public key is not valid"
    sk = SCALE_POINT(E, k)
    xor_mask = sk
    while not r.EOF():
        encrypted_bytes = r.READ(32)
        if len(encrypted_bytes) != 32:
            return "decoding error: truncated block. len={} (should be 32)".format(len(encrypted_bytes))
        plaintext_bytes = AES_DECRYPT(sk, encrypted_bytes)
        XOR(xor_mask, plaintext_bytes)
        if r.EOF():
            UNPAD(plaintext_bytes)
        o.write(plaintext_bytes)
        xor_mask = encrypted_bytes
    if r.got_error:
        return "error decoding base64. {}. total bad characters: {}".format(r.error_msg, r.error_cnt)
    return None

######################################################################
#
# Section 5: Command Line Processing
#
######################################################################

def DECODE_KEY(str):
    ss = io.StringIO(str)
    r = BASE64_READER(ss)
    result = r.READ(32)
    return result

def ENCODE_KEY(key):
    ss = io.StringIO()
    w = BASE64_WRITER(ss)
    w.WRITE(key)
    w.CLOSE()
    ss.seek(0)
    result = ss.read().rstrip()
    return result

def CHECK_KEY(str):
    if len(str) != 43:
        return "key must be exactly 43 characters long, not {}".format(len(str))

    for i in range(0, len(str)):
        if not IS_BASE64_CHAR(str[i]):
            return "'{}' is not a base64 character".format(str[i])
    return None

def CHECK_INPUT(input_file):
    if input_file == "-":
        return None

    if not os.path.exists(input_file):
        return "no such file"

    if not os.path.isfile(input_file):
        return "not a regular file"

    try:
        f = open(input_file, "r")
        f.close()
    except:
        return "cannot be opened for reading"

    return None

def CHECK_OUTPUT(output_file):
    if output_file == "-":
        return None

    if os.path.exists(output_file):
        if os.path.isfile(output_file):
            try:
                f = open(output_file, "a")
                f.close()
            except:
                return "cannot be opened for writing"
        else:
            return "not a regular file"
    else:
        try:
            f = open(output_file, "w")
            f.close()
        except:
            return "cannot be created for writing"

    return None

#
# modes for OPEN_FILE()
#
READ_TEXT    = "r"
READ_BINARY  = "rb"
WRITE_TEXT   = "w"
WRITE_BINARY = "wb"

def OPEN_FILE(filename, mode):
    if filename == "-":
        if mode == READ_TEXT or mode == READ_BINARY:
            # solved with this: https://bugs.python.org/issue4571
            if mode == READ_BINARY:         
                return sys.stdin.buffer
            else:
                return sys.stdin
        else:
            # solved with this: https://bugs.python.org/issue4571
            if mode == WRITE_BINARY:
                return sys.stdout.buffer
            else:
                return sys.stdout

    return open(filename, mode)

def CLOSE_FILE(f):
    f.close()

def REPORT_ERROR(msg):
    sys.stderr.write("{}\n".format(msg))

def USAGE(msg):
    sys.stdout.write("""
Usage: pek create
       pek encrypt  <public-key>   <input>  <output>
       pek decrypt  <private-key>  <input>  <output>
       pek help

       <public-key>   this is a public key obtained from calling "pek create"
       <private-key>  this is a private key obtained from calling "pek create"
       <input>        this is the filename to read, use "-" to read from standard input
       <output>       this is the filename to write, use "-" to write to standard output

    Example:
        pek create
        pek encrypt UwcQDXZlP1kWjda3ngcJ4HzWsz+C4Ahth5ieidwu8n4 f1.txt f1.pek
        pek decrypt lZCBMbLb8GP/IkeKcPVCeoNLju/ynXsC6MZzm3D3ASk f1.pek original.pek

{}
""".format(msg))

def CMD_CREATE(args):
    if len(args) != 2:
        USAGE("too many arguments for 'create'")
        return False

    keypair = CREATE()
    sys.stdout.write("Public key:  {}\n".format( ENCODE_KEY(keypair[0]) ))
    sys.stdout.write("Private key: {}\n".format( ENCODE_KEY(keypair[1]) ))
    return True

def CMD_ENCRYPT(args):
    if len(args) != 5:
        USAGE("incorrect number of arguments")
        return False

    public_key = args[2]
    input_file = args[3]
    output_file = args[4]

    rc = CHECK_KEY(public_key)
    if rc != None:
        USAGE("{}: <public-key> argument {}".format(public_key, rc))
        return False

    rc = CHECK_INPUT(input_file)
    if rc != None:
        USAGE("{}: {}".format(input_file, rc))
        return False

    rc = CHECK_OUTPUT(output_file)
    if rc != None:
        USAGE("{}: {}".format(output_file, rc))
        return False

    i = OPEN_FILE(input_file, READ_BINARY)
    o = OPEN_FILE(output_file, WRITE_TEXT)
    P = DECODE_KEY(public_key)

    if not VALID_POINT(P):
        REPORT_ERROR("encrypt: public key '{}' is not valid".format(public_key))
        return False

    rc = ENCRYPT(P, i, o)

    CLOSE_FILE(i)
    CLOSE_FILE(o)

    if rc != None:
        REPORT_ERROR("encrypt: {}".format(rc))
        return False

    return True

def CMD_DECRYPT(args):
    if len(args) != 5:
        USAGE("incorrect number of arguments")
        return False

    private_key = args[2]
    input_file = args[3]
    output_file = args[4]

    rc = CHECK_KEY(private_key)
    if rc != None:
        USAGE("{}: <private-key> argument {}".format(private_key, rc))
        return False

    rc = CHECK_INPUT(input_file)
    if rc != None:
        USAGE("{}: {}".format(input_file, rc))
        return False

    rc = CHECK_OUTPUT(output_file)
    if rc != None:
        USAGE("{}: {}".format(output_file, rc))
        return False

    k = DECODE_KEY(private_key)
    i = OPEN_FILE(input_file, READ_TEXT)
    o = OPEN_FILE(output_file, WRITE_BINARY)

    rc = DECRYPT(k, i, o)

    CLOSE_FILE(i)
    CLOSE_FILE(o)

    if rc != None:
        REPORT_ERROR("decrypt: {}".format(rc))
        return False

    return True

def CMD_HELP(args):

    USAGE("")

    sys.stdout.write("""
C:\> pek create
Public key:  BfmFN9jG20aH44zyKxsdybJ1LmTRVO9wfbgoRxUU9v4
Private key: L9q3va61OaoSVQpQXvN/cajGpaoV0vmdCYpHC3JRYEw

C:\> pek encrypt BfmFN9jG20aH44zyKxsdybJ1LmTRVO9wfbgoRxUU9v4 f1.txt f2.pek

C:\> pek decrypt L9q3va61OaoSVQpQXvN/cajGpaoV0vmdCYpHC3JRYEw f2.pek f3.txt

The files f1.txt and f3.txt will be the same after running these commands.

Encrypt files using the recipient's public key.

Decrypt recieved files using your private key.

""".format())

    return True

def PRINT_CWD():
    sys.stdout.write("Current working directory: \"{}\"\n".format(os.getcwd()))

def CHECK_OVERRIDES(argv):
    if 'OVERRIDE' not in globals():
        return

    if OVERRIDE == "create":
        argv.clear()
        argv.append("pek")
        argv.append(OVERRIDE)
        PRINT_CWD()
        sys.stdout.write("OVERRIDE=\"{}\"\n".format(OVERRIDE))

    if OVERRIDE == "encrypt" or OVERRIDE == "decrypt":
        argv.clear()
        argv.append("pek")
        argv.append(OVERRIDE)
        PRINT_CWD()

        sys.stdout.write("OVERRIDE=\"{}\"\n".format(OVERRIDE))

        if 'KEY' in globals():
            argv.append(KEY)
            sys.stdout.write("KEY=\"{}\"\n".format(KEY))

        if 'INPUT' in globals():
            argv.append(INPUT)
            sys.stdout.write("INPUT=\"{}\"\n".format(INPUT))

        if 'OUTPUT' in globals():
            argv.append(OUTPUT)
            sys.stdout.write("OUTPUT=\"{}\"\n".format(OUTPUT))


######################################################################
#
# Section 6: MAIN()
#
######################################################################

def MAIN():
    CHECK_OVERRIDES(sys.argv)

    if len(sys.argv) <= 1:
        USAGE("not enough arguments")
        sys.exit(1)

    command = sys.argv[1]

    if command == "create":
        success = CMD_CREATE(sys.argv)
    elif command == "help":
        success = CMD_HELP(sys.argv)
    elif command == "encrypt":
        success = CMD_ENCRYPT(sys.argv)
    elif command == "decrypt":
        success = CMD_DECRYPT(sys.argv)
    else:
        USAGE( "Unknown command '{}'.".format(command) )
        success = False

    return 0 if success else 1

######################################################################
# BEGIN COMMAND LINE OVERRIDE SECTION:
#
# Modify the variables below to override the command line
# processing mode. This is needed on Windows when running the
# script inside of the python application.
#
# OVERRIDE="off"         <---- turn off command line override section
# KEY="dontcare"
# INPUT="dontcare"
# OUTPUT="dontcare"
#
# OVERRIDE="create"
# KEY="dontcare"
# INPUT="dontcare"
# OUTPUT="dontcare"
#
# OVERRIDE="encrypt"
# KEY="BfmFN9jG20aH44zyKxsdybJ1LmTRVO9wfbgoRxUU9v4"
# INPUT="C:/Python Programs/f1.txt"
# OUTPUT="C:/Python Programs/f1.pek"
#
# OVERRIDE="decrypt"
# KEY="L9q3va61OaoSVQpQXvN/cajGpaoV0vmdCYpHC3JRYEw"
# INPUT="c:/Python Programs/f1.pek"
# OUTPUT="c:/Python Programs/f3.txt"
#
# Notes:
#   1. Use forward slashes (/) in filenames.
#   2. Spaces in filenames are okay.
#   3. Use "-" for the filename to read or write to the console.
#
######################################################################

OVERRIDE="off"
KEY="dontcare"
INPUT="dontcare"
OUTPUT="dontcare"

######################################################################
# END COMMAND LINE OVERRIDE SECTION.
######################################################################

MAIN()

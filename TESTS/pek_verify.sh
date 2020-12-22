#!/bin/sh
#
# verify the functions inside the pek script
#
# Instructions:
# 1) Place test code in the ## TEST SECTION ## below.
# 2) In this section add python code to print() something
#    related to the thing you are testing.
# 3) Run pek_verify.sh
# 4) Update the ## EXPECTED SECTION ## to match the actual output.
#    (refresh.sh will do this)
#
# If a filename is given on the command line, then the actual results
# will be written to that file. I.e,
#
#   $ ./pek_verify.sh  actual.txt
#

if [ $# -eq 1 ]; then
    ACTUAL=$1
    KEEP_ACTUAL=1
else
    ACTUAL=/tmp/pt$$_a.txt
    KEEP_ACTUAL=0
fi

SCRIPT=/tmp/pt$$_s.py
EXPECTED=/tmp/pt$$_e.txt

grep -v '^MAIN()$' pek > $SCRIPT

################ TEST SECTION #########################
cat <<'_EOF_' >> $SCRIPT

x = bytearray(b'hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh')
y = bytearray(b'hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh')
XOR(x, y)
print("Test 1",y)

x = bytearray(b'hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh')
y = bytearray(b'hhhhhhhhbbhhhhhhhhh99hhhhhhhhhhh')
XOR(x, y)
print("Test 2",y)

a = bytearray(b'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA')
b = bytearray(b'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB')
XOR(a, b)
XOR(b, a)
XOR(a, b)
print("Test 3",a,b)

ss = io.StringIO("11iKYC72rKkgLsT13XVCee43bsDQVAUjxlGBmDcedxw")
r = BASE64_READER(ss)
print("Test 4", r.READ(32) )
print("Test4.1",r.READ(32) )

ss = io.StringIO("11iKYC72r Kk gLs T13X     VCee4\t\t3bsD\nQVAUjxlGBmDcedxw")
r = BASE64_READER(ss)
print("Test 5", r.READ(32) )
print("Test 5.1", r.READ(32) )

ss = io.StringIO("YW55IGNhcm5hbCBwbGVhc3Vy")
r = BASE64_READER(ss)
print("Test 5.2", r.READ(1000) )

x = bytearray(b'JJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ')
PAD(x, 32)
print("Test 6",x)
UNPAD(x)
print("Test 6.1",x)

x = bytearray(b'JJJJJJJJJJJJJJJJJ')
PAD(x, 32)
print("Test 7",x)
UNPAD(x)
print("Test 7.1",x)

x = bytearray(b'')
PAD(x, 32)
print("Test 8",x)
UNPAD(x)
print("Test 8.1",x)

print("Test 9",G)
print("Test 9.1",VALID_POINT(Gx))
print("Test 9.2",VALID_POINT( CREATE()[0] ))
kp = CREATE()
print("Test 9.3",kp[0] == SCALE_POINT(Gx, kp[1]))
print("Test 9.4",SCALE_POINT(Gx, INT_TO_BYTES(N-1,32)))

try:
    SCALE_POINT(Gx, INT_TO_BYTES(N,32))
    print("Test 9.5 fail")
except:
    print("Test 9.5: pass")

print("Test 10",RANDOM256()!=RANDOM256())
print("Test 10.1",RANDOM256()<INT_TO_BYTES(N,32))

x = 0
for i in range(0,50):
    x = x | BYTES_TO_INT(RANDOM256())
print("Test 10.2",x)

x = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
for i in range(0,50):
    x = x & BYTES_TO_INT(RANDOM256())
print("Test 10.3",x)

print("Test 11",IS_BASE64_CHAR("A"),IS_BASE64_CHAR("g"),IS_BASE64_CHAR("8"))
print("Test 11.1",IS_BASE64_CHAR("+"),IS_BASE64_CHAR("/"))
print("Test 11.2",IS_BASE64_CHAR("="),IS_BASE64_CHAR("@"))

(Pub, k) = CREATE()
e = RANDOM256()
E = SCALE_POINT(Gx, e)
sk1 = SCALE_POINT(Pub, e)
sk2 = SCALE_POINT(E, k)
print("Test 12",sk1==sk2)

gx = G.x.num
gy = G.y.num
print("Test 13",gy**2 % P == (gx**3 + 7) % P)

_EOF_
################ TEST SECTION #########################

echo Pek Unit Testing BEGIN
date

python3 $SCRIPT > $ACTUAL

echo ""
echo "========================="
echo Expected results:


################ EXPECTED SECTION #########################
cat <<'_EOF_' > $EXPECTED
Test 1 bytearray(b'\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00')
Test 2 bytearray(b'\x00\x00\x00\x00\x00\x00\x00\x00\n\n\x00\x00\x00\x00\x00\x00\x00\x00\x00QQ\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00')
Test 3 bytearray(b'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB') bytearray(b'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA')
Test 4 bytearray(b'\xd7X\x8a`.\xf6\xac\xa9 .\xc4\xf5\xdduBy\xee7n\xc0\xd0T\x05#\xc6Q\x81\x987\x1ew\x1c')
Test4.1 bytearray(b'')
Test 5 bytearray(b'\xd7X\x8a`.\xf6\xac\xa9 .\xc4\xf5\xdduBy\xee7n\xc0\xd0T\x05#\xc6Q\x81\x987\x1ew\x1c')
Test 5.1 bytearray(b'')
Test 5.2 bytearray(b'any carnal pleasur')
Test 6 bytearray(b'JJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ')
Test 6.1 bytearray(b'JJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ')
Test 7 bytearray(b'JJJJJJJJJJJJJJJJJ\xff\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00')
Test 7.1 bytearray(b'JJJJJJJJJJJJJJJJJ')
Test 8 bytearray(b'\xff\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00')
Test 8.1 bytearray(b'')
Test 9 S256Point(79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798, 483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8)
Test 9.1 True
Test 9.2 True
Test 9.3 True
Test 9.4 bytearray(b'y\xbef~\xf9\xdc\xbb\xacU\xa0b\x95\xce\x87\x0b\x07\x02\x9b\xfc\xdb-\xce(\xd9Y\xf2\x81[\x16\xf8\x17\x98')
Test 9.5: pass
Test 10 True
Test 10.1 True
Test 10.2 115792089237316195423570985008687907853269984665640564039457584007913129639935
Test 10.3 0
Test 11 True True True
Test 11.1 True True
Test 11.2 False False
Test 12 True
Test 13 True
_EOF_
################ EXPECTED SECTION #########################

cat $EXPECTED
echo "========================="

echo ""
echo "========================="
echo Actual results:
cat $ACTUAL
echo "========================="

echo ""

echo "========================="
echo Differences:
diff $EXPECTED $ACTUAL
RC=$?

echo "========================="
echo ""
echo ""

if [ $RC  -eq 0 ]; then
    echo SUCCESS
else
    echo FAIL
fi

/bin/rm $SCRIPT
/bin/rm $EXPECTED

if [ $KEEP_ACTUAL = 0 ]; then
    /bin/rm $ACTUAL
fi

echo ""
date
echo Pek Unit Testing END

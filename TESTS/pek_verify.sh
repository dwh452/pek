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
def TEST():

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
	print("Test 9.1",VALID_CURVE_X(G.x.num))
	print("Test 9.2",VALID_CURVE_X( CREATE()[0].x.num ))
	(Q, d) = CREATE()
	print("Test 9.3", Q == SCALE_POINT(G, d))
	print("Test 9.4", SCALE_POINT(G, N-1))
	
	try:
	    SCALE_POINT(G, N)
	    print("Test 9.5 PASS")
	except:
	    print("Test 9.5 FAIL")
	
	print("Test 10",RANDOM256()!=RANDOM256())
	print("Test 10.1",RANDOM256()<N)
	
	x = 0
	for i in range(0,50):
	    x = x | RANDOM256()
	print("Test 10.2",x)
	
	x = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
	for i in range(0,50):
	    x = x & RANDOM256()
	print("Test 10.3",x)
	
	print("Test 11",IS_BASE64_CHAR("A"),IS_BASE64_CHAR("g"),IS_BASE64_CHAR("8"))
	print("Test 11.1",IS_BASE64_CHAR("+"),IS_BASE64_CHAR("/"))
	print("Test 11.2",IS_BASE64_CHAR("="),IS_BASE64_CHAR("@"))
	
	(Pub, k) = CREATE()
	e = RANDOM256()
	E = SCALE_POINT(G, e)
	sk1 = SCALE_POINT(Pub, e)
	sk2 = SCALE_POINT(E, k)
	print("Test 12",sk1==sk2)
	
	gx = G.x.num
	gy = G.y.num
	print("Test 13",gy**2 % P == (gx**3 + 7) % P)
	
	######## PEK2 #########
	
	##### BASE64_READER
	r = BASE64_READER( io.StringIO("2Y9FA9rFfTc5Dwldz8KJiISsqvFdohT0Iooq3Pjh8Pk") )
	bytes = r.READ(32)
	print("Test 13.1", len(bytes), bytes, r.EOF(), r.GET_REMAINDER())
	
	r = BASE64_READER( io.StringIO("2Y9FA9rFfTc5Dwldz8KJiISsqvFdohT0Iooq3Pjh8Pl") )
	bytes = r.READ(32)
	print("Test 13.2", len(bytes), bytes, r.EOF(), r.GET_REMAINDER())
	
	r = BASE64_READER( io.StringIO("2Y9FA9rFfTc5Dwldz8KJiISsqvFdohT0Iooq3Pjh8PK") )
	bytes = r.READ(32)
	print("Test 13.3", len(bytes), bytes, r.EOF(), r.GET_REMAINDER())
	
	r = BASE64_READER( io.StringIO("2Y9FA9rFfTc5Dwldz8KJiISsqvFdohT0Iooq3Pjh8Pz") )
	bytes = r.READ(32)
	print("Test 13.4", len(bytes), bytes, r.EOF(), r.GET_REMAINDER())
	
	##### BASE64_WRITER
	r = BASE64_READER( io.StringIO("2Y9FAKENfTc5Dwldz8KJiISsqvFdohT0Iooq3Pjh8Pk") )
	bytes = r.READ(32)
	ss = io.StringIO()
	w = BASE64_WRITER(ss, 1)
	w.WRITE(bytes)
	w.CLOSE()
	ss.seek(0)
	result = RIGHT_TRIM( ss.read() )
	print("Test 14.1", result)
	
	r = BASE64_READER( io.StringIO("2Y9FAKENfTc5Dwldz8KJiISsqvFdohT0Iooq3Pjh8Pk") )
	bytes = r.READ(32)
	ss = io.StringIO()
	w = BASE64_WRITER(ss, 3)
	w.WRITE(bytes)
	w.CLOSE()
	ss.seek(0)
	result = RIGHT_TRIM( ss.read() )
	print("Test 14.2", result)
	
	#### ENCODE_KEY / DECODE_KEY
	print("Test 15.1", ENCODE_KEY( (3, 3434934) ) )
	print("Test 15.2", ENCODE_KEY( (2, 3434934*554984589) ) )
	print("Test 15.3", ENCODE_KEY( (1, 4848*3434934*554984589) ) )
	print("Test 15.3", ENCODE_KEY( (0, 9*3434934*554984589) ) )
	
	print("Test 16.1", DECODE_KEY( "2Y9FA9rFfTc5Dwldz8KJiISsqvFdohT0Iooq3Pjh8Pk" ))
	print("Test 16.2", DECODE_KEY( "2Y9FA9rFfTc5Dwldz8KJiISsqvFdohT0Iooq3Pjh8Pl" ))
	print("Test 16.3", DECODE_KEY( "2Y9FA9rFfTcFFFldz8KJ1818qvFdohT0Iooq3Pjh8Pm" ))
	print("Test 16.4", DECODE_KEY( "fdslksflksjfldjs2yflkdsjflkdsjflsjfdlPjh8Pn" ))
	
	######## CHECK_PUBLIC_KEY, CHECK_PRIVATE_KEY
	print("Test 17.1", CHECK_PUBLIC_KEY("2Y9FA9rFfTc5Dwldz8KJiISsqvFdohT0Iooq3Pjh8Pk"))
	print("Test 17.2", CHECK_PUBLIC_KEY("2Y9FA9rFfTc5Dwldz8KJiISsqvFdohT0Iooq3Pjh8Pl"))
	print("Test 17.3", CHECK_PUBLIC_KEY("2Y9FA9rFfTc5Dwldz8KJiISsqvFdohT0Iooq3Pjh8Pm"))
	print("Test 17.4", CHECK_PUBLIC_KEY("2Y9FA9rFfTc5Dwldz8KJiISsqvFdohT0Iooq3Pjh8Pn"))
	print("Test 17.5", CHECK_PUBLIC_KEY("2Y9FA9rFfTc5Dwldz8KJiISsqvFdohT0Iooq3Pjh8PnPPP"))
	print("Test 17.6", CHECK_PUBLIC_KEY("2Y9FA9rFfTc5Dwldz8KJiI*sqvFdohT0Iooq3Pjh8Pn"))
	
	print("Test 18.1", CHECK_PRIVATE_KEY("2Y9FA9rFfTc5Dwldz8KJiISsqvFdohT0Iooq3Pjh8Pk"))
	print("Test 18.2", CHECK_PRIVATE_KEY("2Y9FA9rFfTc5Dwldz8KJiISsqvFdohT0Iooq3Pjh8Pl"))
	print("Test 18.3", CHECK_PRIVATE_KEY("2Y9FA9rFfTc5Dwldz8KJiISsqvFdohT0Iooq3Pjh8Pm"))
	print("Test 18.4", CHECK_PRIVATE_KEY("2Y9FA9rFfTc5Dwldz8KJiISsqvFdohT0Iooq3Pjh8Pn"))
	print("Test 18.5", CHECK_PRIVATE_KEY("2Y9FA9rFfTc5Dwldz8KJiISsqvFdohT0Iooq3Pjh8PnPPP"))
	print("Test 18.6", CHECK_PRIVATE_KEY("2Y9FA9rFfTc5Dwldz8KJiI*sqvFdohT0Iooq3Pjh8PB"))
	print("Test 18.7", CHECK_PRIVATE_KEY("/////////////////////rqu3OavSKA7v9JejNA2QUB"))
	print("Test 18.8", CHECK_PRIVATE_KEY("/////////////////////rqu3OavSKA7v9JekNA2QUB"))
	
	###### PUBLIC_KEY_TO_POINT / POINT_TO_PUBLIC_KEY
	key = DECODE_KEY( "U+hQu8NLwGAND688zTChXs4Jda7MbbAHwWa7J97qxGv" )  # type 11
	TP = PUBLIC_KEY_TO_POINT(key)
	print("Test 19.1", TP, POINT_TO_PUBLIC_KEY(TP))

	key = DECODE_KEY( "afq/8kY1Q0pAvhFn5jfxIhYkW9T72uUjjbICWDA81MC" )  # type 10
	TP = PUBLIC_KEY_TO_POINT(key)
	print("Test 19.2", TP, POINT_TO_PUBLIC_KEY(TP))

	key = DECODE_KEY( "32h2MNZA7IewO8a563mm060TOCYaFzbwnsqG2Gtv986" )
	TP = PUBLIC_KEY_TO_POINT(key)
	print("Test 19.3", TP, POINT_TO_PUBLIC_KEY(TP))
	
	###### PRIVATE_KEY_TO_INT / INT_TO_PRIVATE_KEY
	key = DECODE_KEY( "vBUmrCLRgO1XaVjjFSrlkpEM1/FyrG7Uw6FFK1nd0tV" )  # type 01
	d = PRIVATE_KEY_TO_INT(key)
	print("Test 20.1", d, INT_TO_PRIVATE_KEY(d))

	###### VALUE_CURVE_X / VALID_SCALAR
	print("Test 22.1",VALID_CURVE_X(G.x.num))
	print("Test 22.2",VALID_CURVE_X(0xdeadbeef))
	print("Test 22.3",VALID_CURVE_X(0xdeadbeef0))
	print("Test 22.4",VALID_CURVE_X( 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000 ) )
	print("Test 22.5",VALID_SCALAR(0) )
	print("Test 22.6",VALID_SCALAR(1) )
	print("Test 22.7",VALID_SCALAR(N-1) )
	print("Test 22.8",VALID_SCALAR(N) )

	######## SCALE_POINT
	TP1 = SCALE_POINT(G, N)
	print("Test 22a.1", TP1)

	TP1 = SCALE_POINT(G, 1)
	print("Test 22a.2", G == TP1, G, TP1)

	TP1 = SCALE_POINT(G, 1000000)
	TP1 = SCALE_POINT(TP1, 0)
	print("Test 22a.3", TP1)

	TP1 = SCALE_POINT(G, N-2)
	TP1 = SCALE_POINT(G, 2)
	print("Test 22a.3", TP1)

	##### ADD_POINTS
	TP1 = SCALE_POINT(G, 9999)
	TP2 = SCALE_POINT(TP1, 2)
	TP3 = ADD_POINTS(TP1, TP1)
	print("Test 22b.1", TP2 == TP3, TP1, TP2, TP3)

	TP1 = SCALE_POINT(G, 9999)
	TP2 = SCALE_POINT(TP1, 494943943)
	TP3 = ADD_POINTS(TP1, TP2)
	TP4 = ADD_POINTS(TP2, TP1)
	print("Test 22b.2", TP3 == TP4, TP1, TP2, TP3, TP4)

	TP1 = SCALE_POINT(G, N-1)
	TP2 = SCALE_POINT(G, 1)
	TP3 = ADD_POINTS(TP1, TP2)
	print("Test 22b.3", TP3 )

	TP3 = ADD_POINTS(TP3, TP2)
	print("Test 22b.5", TP3 == G, TP3)

	TP1 = SCALE_POINT(G, N-1)
	TP2 = SCALE_POINT(G, 2)
	TP3 = ADD_POINTS(TP1, TP2)
	print("Test 22b.6", TP3 == G, TP3)

	###### POINT_TO_BYTES / BYTES_TO_POINT
	TP1 = G
	TP2 = SCALE_POINT(G, 10101019)
	TP3 = ADD_POINTS(TP1, TP2)

	k1 = POINT_TO_BYTES(TP1)
	k2 = POINT_TO_BYTES(TP2)
	k3 = POINT_TO_BYTES(TP3)
	
	print("Test 23.1",TP1, k1, BYTES_TO_POINT(k1))
	print("Test 23.2",TP2, k2, BYTES_TO_POINT(k2))
	print("Test 23.3",TP3, k3, BYTES_TO_POINT(k3))

	k4 = INT_TO_BYTES(0xdeadbeef0, 32) + INT_TO_BYTES(PublicKeyEvenY, 1)
	k5 = INT_TO_BYTES(0xdeadbeef0, 32) + INT_TO_BYTES(PublicKeyOddY, 1)
	print("Test 23.4",k4, BYTES_TO_POINT(k4))
	print("Test 23.5",k4, BYTES_TO_POINT(k5))

	####### RANDOM256()
	r1 = RANDOM256()
	r2 = RANDOM256()
	print("Test 24.1",r1 != 0, r1 != N, r1 != r2 )

	####### CHAR_TO_KEYTYPE
	print("Test 25.1", CHAR_TO_KEY_TYPE("A"), CHAR_TO_KEY_TYPE("B"), CHAR_TO_KEY_TYPE("C"), CHAR_TO_KEY_TYPE("D") )
	print("Test 25.2", CHAR_TO_KEY_TYPE("8"), CHAR_TO_KEY_TYPE("9"), CHAR_TO_KEY_TYPE("+"), CHAR_TO_KEY_TYPE("/") )
	print("Test 25.3", CHAR_TO_KEY_TYPE("k"), CHAR_TO_KEY_TYPE("J"), CHAR_TO_KEY_TYPE("K"), CHAR_TO_KEY_TYPE("b") )

	####### IS_HASHCODE
	print("Test 26.1", IS_HASHCODE("ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff") )
	print("Test 26.2", IS_HASHCODE("0000000000000000000000000000000000000000000000000000000000000000") )
	print("Test 26.3", IS_HASHCODE("483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8") )
	print("Test 26.4", IS_HASHCODE("fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff") )
	print("Test 26.5", IS_HASHCODE("fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000000") )
	print("Test 26.6", IS_HASHCODE("48*ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8") )

	######## SHA256()
	# $ echo 'Hello, World!' | shasum -a 256 -
	# c98c24b677eff44860afea6f493bbaec5bb1c4cbb209c6fc2bbb47f66ff2ad31  -
	ss = io.BytesIO(b"Hello, World!\n")
	print("Test 27.1", hex( SHA256(ss) ) )

	###### AES_ENCRYPT / AES_DECRYPT
	ss = io.BytesIO(b"Secret90210\n")
	ak1 = INT_TO_BYTES( SHA256(ss), 32)

	ss = io.BytesIO(b"Secret90211\n")
	ak2 = INT_TO_BYTES( SHA256(ss), 32)

	cipher = AES_ENCRYPT(ak1, bytearray(b'HelloThisMustBe32BytesLong256Bye') )
	plain = AES_DECRYPT(ak1, cipher)
	print("Test 28.1", ak1, cipher, plain)

	cipher = AES_ENCRYPT(ak2, bytearray(b'HelloThisMustBe32BytesLong256Bye') )
	plain = AES_DECRYPT(ak2, cipher)
	print("Test 28.2", ak2, cipher, plain)

	plain = AES_DECRYPT(ak1, cipher)
	print("Test 28.3", plain)

	###### HASH_POINT
	print("Test 29.1", HASH_POINT(G))
	print("Test 29.2", HASH_POINT( SCALE_POINT(G, 48483438) ))

	###### BASE64_WRITER

	###### BYTES_TO_INT and INT_TO_BYTES endiness

TEST()

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
Test 9.4 S256Point(79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798, b7c52588d95c3b9aa25b0403f1eef75702e84bb7597aabe663b82f6f04ef2777)
Test 9.5 PASS
Test 10 True
Test 10.1 True
Test 10.2 115792089237316195423570985008687907853269984665640564039457584007913129639935
Test 10.3 0
Test 11 True True True
Test 11.1 True True
Test 11.2 False False
Test 12 True
Test 13 True
Test 13.1 32 bytearray(b'\xd9\x8fE\x03\xda\xc5}79\x0f\t]\xcf\xc2\x89\x88\x84\xac\xaa\xf1]\xa2\x14\xf4"\x8a*\xdc\xf8\xe1\xf0\xf9') True (2, 0)
Test 13.2 32 bytearray(b'\xd9\x8fE\x03\xda\xc5}79\x0f\t]\xcf\xc2\x89\x88\x84\xac\xaa\xf1]\xa2\x14\xf4"\x8a*\xdc\xf8\xe1\xf0\xf9') True (2, 1)
Test 13.3 32 bytearray(b'\xd9\x8fE\x03\xda\xc5}79\x0f\t]\xcf\xc2\x89\x88\x84\xac\xaa\xf1]\xa2\x14\xf4"\x8a*\xdc\xf8\xe1\xf0\xf2') True (2, 2)
Test 13.4 32 bytearray(b'\xd9\x8fE\x03\xda\xc5}79\x0f\t]\xcf\xc2\x89\x88\x84\xac\xaa\xf1]\xa2\x14\xf4"\x8a*\xdc\xf8\xe1\xf0\xfc') True (2, 3)
Test 14.1 2Y9FAKENfTc5Dwldz8KJiISsqvFdohT0Iooq3Pjh8Pl
Test 14.2 2Y9FAKENfTc5Dwldz8KJiISsqvFdohT0Iooq3Pjh8Pn
Test 15.1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA0abb
Test 15.2 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAbFzU5hUT6
Test 15.3 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgEHf/FLyhiB
Test 15.3 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADz0N8Fr2y4
Test 16.1 (0, 98405023597249205683583746756051312645106688749329204061519472300162631725305)
Test 16.2 (1, 98405023597249205683583746756051312645106688749329204061519472300162631725305)
Test 16.3 (2, 98405023597249205682309219302460946269091637217848733122447207198666388533497)
Test 16.4 (3, 56926304901913396421504431988396528007164481852076221122497528748686637658361)
Test 17.1 is not a public key, (marked invalid)
Test 17.2 is not a public key (marked private)
Test 17.3 None
Test 17.4 None
Test 17.5 must be exactly 43 characters long, not 46
Test 17.6 '*' is not a base64 character
Test 18.1 is not a private key, (marked invalid)
Test 18.2 None
Test 18.3 is not a private key (marked public)
Test 18.4 is not a private key (marked public)
Test 18.5 must be exactly 43 characters long, not 46
Test 18.6 '*' is not a base64 character
Test 18.7 None
Test 18.8 None
Test 19.1 S256Point(53e850bbc34bc0600d0faf3ccd30a15ece0975aecc6db007c166bb27deeac46b, ba253129411f593d88fb94ddad84e1ad971c3cb8f8e785d720cedfc8c5775385) (3, 37952432153224524622566816393001916528902706829388344168983243649924727489643)
Test 19.2 S256Point(69fabff24635434a40be1167e637f12216245bd4fbdae5238db20258303cd4c0, d0c9fa2be196e442242196b9e00e0e6f99f6a572bbd5ce354a0077593b8946f4) (2, 47935885632690668792858574693516940774105896065724317420753847121743714243776)
Test 19.3 S256Point(df687630d640ec87b03bc6b9eb79a6d3ad1338261a1736f09eca86d86b6ff7ce, 132d7c20969d908e5834efd07991baa0cb668dd1417420bddaa627d9b779bd04) (2, 101050333051515256466382367629335744754571059598319524671696498993890329622478)
Test 20.1 85072186229153234584177236419013418181421367435692072948161198905817493787349 (1, 85072186229153234584177236419013418181421367435692072948161198905817493787349)
Test 22.1 True
Test 22.2 True
Test 22.3 True
Test 22.4 False
Test 22.5 False
Test 22.6 True
Test 22.7 True
Test 22.8 False
Test 22a.1 S256Point(infinity)
Test 22a.2 True S256Point(79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798, 483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8) S256Point(79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798, 483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8)
Test 22a.3 S256Point(infinity)
Test 22a.3 S256Point(c6047f9441ed7d6d3045406e95c07cd85c778e4b8cef3ca7abac09b95c709ee5, 1ae168fea63dc339a3c58419466ceaeef7f632653266d0e1236431a950cfe52a)
Test 22b.1 True S256Point(7793ef5f8e57e872ea9fbb18bd710ab96ea4f646134d3308930cbf62e73f0e1c, 8d5b3b793573090fa4a7e7e5c38fd987e889bc3e720e05b243e856f632ae7cc5) S256Point(49421e70e35a26b188156bd1408ad7524db900f8085fbc5b5fbc91c1602872fd, d32acfff1c1627b5eaed27246834e352913dc9d6d280f8890336edf2c5b62517) S256Point(49421e70e35a26b188156bd1408ad7524db900f8085fbc5b5fbc91c1602872fd, d32acfff1c1627b5eaed27246834e352913dc9d6d280f8890336edf2c5b62517)
Test 22b.2 True S256Point(7793ef5f8e57e872ea9fbb18bd710ab96ea4f646134d3308930cbf62e73f0e1c, 8d5b3b793573090fa4a7e7e5c38fd987e889bc3e720e05b243e856f632ae7cc5) S256Point(5bb26512998889d8e2032217ccfe92c2903ee67509979095b981675c6e90469d, 0180ed974ceeb7bdf837fee1a6a038a053f85c28c6da360c6bb245b65fbdd840) S256Point(46824deb238eb99b406b4e336013bafa8044e5fb2f50b2ffa30d3e0e5b904946, 889d11f5637c65a02f3ab91d49ed1232d6d94d9e1be54ead03286b41e54786cd) S256Point(46824deb238eb99b406b4e336013bafa8044e5fb2f50b2ffa30d3e0e5b904946, 889d11f5637c65a02f3ab91d49ed1232d6d94d9e1be54ead03286b41e54786cd)
Test 22b.3 S256Point(infinity)
Test 22b.5 True S256Point(79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798, 483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8)
Test 22b.6 True S256Point(79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798, 483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8)
Test 23.1 S256Point(79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798, 483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8) bytearray(b'y\xbef~\xf9\xdc\xbb\xacU\xa0b\x95\xce\x87\x0b\x07\x02\x9b\xfc\xdb-\xce(\xd9Y\xf2\x81[\x16\xf8\x17\x98\x02') S256Point(79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798, 483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8)
Test 23.2 S256Point(440ba9e5ba2ab08a67abc301cd7200bb27885caca6e06313b514a0e90ae85977, 8d514de7d98a45fabe9b114cd091db23c4fbb77680d2ddfac39ee284606e4d51) bytearray(b"D\x0b\xa9\xe5\xba*\xb0\x8ag\xab\xc3\x01\xcdr\x00\xbb\'\x88\\\xac\xa6\xe0c\x13\xb5\x14\xa0\xe9\n\xe8Yw\x03") S256Point(440ba9e5ba2ab08a67abc301cd7200bb27885caca6e06313b514a0e90ae85977, 8d514de7d98a45fabe9b114cd091db23c4fbb77680d2ddfac39ee284606e4d51)
Test 23.3 S256Point(a26c16a01562a213d1fcb755e52a2ee326278ef6ded93af1692b29c5b43bb4a0, c9a9ec49fd517d92cfc618a1d5a67d98e19136339437de722ba4819d93bbc1db) bytearray(b"\xa2l\x16\xa0\x15b\xa2\x13\xd1\xfc\xb7U\xe5*.\xe3&\'\x8e\xf6\xde\xd9:\xf1i+)\xc5\xb4;\xb4\xa0\x03") S256Point(a26c16a01562a213d1fcb755e52a2ee326278ef6ded93af1692b29c5b43bb4a0, c9a9ec49fd517d92cfc618a1d5a67d98e19136339437de722ba4819d93bbc1db)
Test 23.4 bytearray(b'\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\r\xea\xdb\xee\xf0\x02') S256Point(0000000000000000000000000000000000000000000000000000000deadbeef0, 7cf678f6863ce7715846ec286a8081895d4e397d82f302a8ba6fe4950902f5ee)
Test 23.5 bytearray(b'\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\r\xea\xdb\xee\xf0\x02') S256Point(0000000000000000000000000000000000000000000000000000000deadbeef0, 8309870979c3188ea7b913d7957f7e76a2b1c6827d0cfd5745901b69f6fd0641)
Test 24.1 True True True
Test 25.1 0 1 2 3
Test 25.2 0 1 2 3
Test 25.3 0 1 2 3
Test 26.1 True
Test 26.2 True
Test 26.3 True
Test 26.4 False
Test 26.5 False
Test 26.6 False
Test 27.1 0xc98c24b677eff44860afea6f493bbaec5bb1c4cbb209c6fc2bbb47f66ff2ad31
Test 28.1 bytearray(b'\xfa\xd2WV\xbc\xbc\x7f#d\xeb{C^6y\x9dq%\xe7\x96<\xf0X\xbb\xe9\x89\x18c\x0c\x10\xcb\xa0') bytearray(b'\xe6(\xe5\x97\xb1\x9e\xb9\x9f\xd4\x00\xc0k\xca\xa9g\x14s\xa85A\x0c\xd4Q\xa6RO%kg4^\xdc') bytearray(b'HelloThisMustBe32BytesLong256Bye')
Test 28.2 bytearray(b'\xb2\x97\x1c\x0c\xab\xc2c\xfc\x1bJ\xd5\xca\x14\xd1-\xd7|\xc1\xc2\xbd\xb8\x1e\xe2\x03\xa4(\x8d;a\xccr\xe8') bytearray(b'\xd9\xcf\xd3\xe0\xfc\x99#^\x12\x98-\t\xaf\xc3a1l\x8fU\x14\x13g\x93\x1a\x14\xe1\x06\xc3\xec\xbe_\xad') bytearray(b'HelloThisMustBe32BytesLong256Bye')
Test 28.3 bytearray(b'\x90C\x8f@\xabO\x9c\x95\x92\xee0\xa9\xaa3U\x1a0\xd4\xa3N\x87ZB0\xd7b\x1e`\xd9`\xb4?')
Test 29.1 bytearray(b"\xd8KAsR\x93\xbd\x81\x89U~,\xba\x00\xfd,\xe9\x1c\xee\xc6\xd09\x8e\x0eN\'\xecU\xfb\x9d\xb3Q")
Test 29.2 bytearray(b'\x9e\x1a\xce"\xb9\x11z\xdfy\x8f\x07\xd0/\\$F\xbe\xfag\xfd4\xf0-Mp\xfb\xa4\xa8\xc5\x1d,-')
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

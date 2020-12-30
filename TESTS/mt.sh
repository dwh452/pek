#!/bin/sh
#
# Each test pipes a series of commands into the pek menu.
# The output is captured in the temp file RESULTS.txt.
# This file is searched for patterns to check for success or fail.
#
# This exercises the interactive menu and all the error code paths.
#

echo Menu Testing BEGIN.
date

######################################################################
T='Test 1: successful create/encrypt/decrypt'
######################################################################

./pek <<_EOF_ > RESULTS.txt
1
2

-
MT1.txt
JohnnyCab911
.
3


-
7
_EOF_

grep JohnnyCab911 RESULTS.txt > /dev/null
if [ $? -eq 0 ]; then
	echo Pass $T
else
	echo Fail $T
fi

######################################################################
T='Test 2: Help'
######################################################################

./pek <<_EOF_ > RESULTS.txt
6
7
_EOF_

grep 'Usage:' RESULTS.txt > /dev/null
if [ $? -eq 0 ]; then
	echo Pass $T
else
	echo Fail $T
fi

######################################################################
T='Test 3: Show File'
######################################################################

./pek <<_EOF_ > RESULTS.txt
4
MSG.pek
_EOF_

grep 'cut here' RESULTS.txt > /dev/null
if [ $? -eq 0 ]; then
	echo Pass $T
else
	echo Fail $T
fi

######################################################################
T='Test 4: Show File - Bad Filename'
######################################################################

./pek <<_EOF_ > RESULTS.txt
4
XMSGX.pek
_EOF_

grep 'no such file' RESULTS.txt > /dev/null
if [ $? -eq 0 ]; then
	echo Pass $T
else
	echo Fail $T
fi

######################################################################
T='Test 5: Show File - stdin filename'
######################################################################

./pek <<_EOF_ > RESULTS.txt
4
-
_EOF_

grep 'Invalid filename' RESULTS.txt > /dev/null
if [ $? -eq 0 ]; then
	echo Pass $T
else
	echo Fail $T
fi

######################################################################
T='Test 6: Create File'
######################################################################

./pek <<_EOF_ > RESULTS.txt
5
MT1.txt
i am the internet
.
4

7
_EOF_

grep 'i am the internet' RESULTS.txt > /dev/null
if [ $? -eq 0 ]; then
	echo Pass $T
else
	echo Fail $T
fi

######################################################################
T='Test 7: Create File - Bad Filename'
######################################################################

./pek <<_EOF_ > RESULTS.txt
5
/bogus/file
7
_EOF_

grep 'cannot be created' RESULTS.txt > /dev/null
if [ $? -eq 0 ]; then
	echo Pass $T
else
	echo Fail $T
fi

######################################################################
T='Test 8: Create File - stdin Filename'
######################################################################

./pek <<_EOF_ > RESULTS.txt
5
-
7
_EOF_

grep 'Invalid filename' RESULTS.txt > /dev/null
if [ $? -eq 0 ]; then
	echo Pass $T
else
	echo Fail $T
fi

######################################################################
T='Test 9: menu UNDER'
######################################################################

./pek <<_EOF_ > RESULTS.txt
0
_EOF_

grep 'too small' RESULTS.txt > /dev/null
if [ $? -eq 0 ]; then
	echo Pass $T
else
	echo Fail $T
fi

######################################################################
T='Test 10: menu OVER'
######################################################################

./pek <<_EOF_ > RESULTS.txt
8
_EOF_

grep 'too big' RESULTS.txt > /dev/null
if [ $? -eq 0 ]; then
	echo Pass $T
else
	echo Fail $T
fi

######################################################################
T='Test 11: menu BAD'
######################################################################

./pek <<_EOF_ > RESULTS.txt
XXX
_EOF_

grep 'Invalid choice' RESULTS.txt > /dev/null
if [ $? -eq 0 ]; then
	echo Pass $T
else
	echo Fail $T
fi

######################################################################
T='Test 12: Create Keys'
######################################################################

./pek <<_EOF_ > RESULTS.txt
1
7
_EOF_

grep 'Public key' RESULTS.txt > /dev/null
if [ $? -eq 0 ]; then
	echo Pass $T
else
	echo Fail $T
fi

######################################################################
T='Test 13: Show File - filename default is used'
######################################################################

./pek <<_EOF_ > RESULTS.txt
5
MT1.txt
GrandTime100
.
4

7
_EOF_

grep 'GrandTime100' RESULTS.txt > /dev/null
if [ $? -eq 0 ]; then
	echo Pass $T
else
	echo Fail $T
fi

######################################################################
T='Test 14: Encrypt - invalid point'
######################################################################

./pek <<_EOF_ > RESULTS.txt 2>&1
2
IkWtOXF7x6a3V9xMFVoqSSsElPiGjCrXDGSPCEsy111
7
_EOF_

grep 'is not valid' RESULTS.txt > /dev/null
if [ $? -eq 0 ]; then
	echo Pass $T
else
	echo Fail $T
fi

######################################################################
T='Test 15: Encrypt - not such file'
######################################################################

./pek <<_EOF_ > RESULTS.txt 2>&1
2
IkWtOXF7x6a3V9xMFVoqSSsElPiGjCrXDGSPCEsyLtA
BADFILE.txt
7
_EOF_

grep 'no such file' RESULTS.txt > /dev/null
if [ $? -eq 0 ]; then
	echo Pass $T
else
	echo Fail $T
fi

######################################################################
T='Test 16: Encrypt - error opening output'
######################################################################

./pek <<_EOF_ > RESULTS.txt 2>&1
2
IkWtOXF7x6a3V9xMFVoqSSsElPiGjCrXDGSPCEsyLtA
-
/bogus/file
7
_EOF_

grep 'cannot be created for writing' RESULTS.txt > /dev/null
if [ $? -eq 0 ]; then
	echo Pass $T
else
	echo Fail $T
fi

######################################################################
T='Test 17: EOF TEST - from menu'
######################################################################

./pek <<_EOF_ > RESULTS.txt 2>&1
_EOF_

tail -1 RESULTS.txt | grep 'Choose 1-7' > /dev/null
if [ $? -eq 0 ]; then
	echo Pass $T
else
	echo Fail $T
fi

######################################################################
T='Test 18: EOF TEST - encrypt 1'
######################################################################

./pek <<_EOF_ > RESULTS.txt 2>&1
2
_EOF_

tail -1 RESULTS.txt | grep 'Enter public key' > /dev/null
if [ $? -eq 0 ]; then
	echo Pass $T
else
	echo Fail $T
fi

######################################################################
T='Test 19: EOF TEST - encrypt 2'
######################################################################

./pek <<_EOF_ > RESULTS.txt 2>&1
1
2

_EOF_

tail -1 RESULTS.txt | grep 'file to encrypt' > /dev/null
if [ $? -eq 0 ]; then
	echo Pass $T
else
	echo Fail $T
fi

######################################################################
T='Test 20: EOF TEST - encrypt 3'
######################################################################

./pek <<_EOF_ > RESULTS.txt 2>&1
1
2

mt.sh
_EOF_

tail -1 RESULTS.txt | grep 'Enter output file' > /dev/null
if [ $? -eq 0 ]; then
	echo Pass $T
else
	echo Fail $T
fi

######################################################################
T='Test 21: EOF TEST - decrypt 1'
######################################################################

./pek <<_EOF_ > RESULTS.txt 2>&1
3
_EOF_

tail -1 RESULTS.txt | grep 'Enter private key' > /dev/null
if [ $? -eq 0 ]; then
	echo Pass $T
else
	echo Fail $T
fi

######################################################################
T='Test 22: EOF TEST - decrypt 2'
######################################################################

./pek <<_EOF_ > RESULTS.txt 2>&1
1
3

_EOF_

tail -1 RESULTS.txt | grep 'Enter file to decrypt' > /dev/null
if [ $? -eq 0 ]; then
	echo Pass $T
else
	echo Fail $T
fi

######################################################################
T='Test 23: EOF TEST - decrypt 3'
######################################################################

./pek <<_EOF_ > RESULTS.txt 2>&1
1
3

MSG.pek
_EOF_

tail -1 RESULTS.txt | grep 'Enter output file' > /dev/null
if [ $? -eq 0 ]; then
	echo Pass $T
else
	echo Fail $T
fi

######################################################################
T='Test 24: MENU BLANK LINES TEST'
######################################################################

./pek <<_EOF_ > RESULTS.txt 2>&1


   
    			



7
MSG.pek
_EOF_

tail -1 RESULTS.txt | grep 'Choose' > /dev/null
if [ $? -eq 0 ]; then
	echo Pass $T
else
	echo Fail $T
fi

######################################################################
T='Test 25: Decrypt - bad file to decrypt'
######################################################################

./pek <<_EOF_ > RESULTS.txt 2>&1
1
3

/bogus/file
7
_EOF_

cat RESULTS.txt | grep 'no such file' > /dev/null
if [ $? -eq 0 ]; then
	echo Pass $T
else
	echo Fail $T
fi

######################################################################
T='Test 26: Decrypt - error opening output'
######################################################################

./pek <<_EOF_ > RESULTS.txt 2>&1
1
3

-
/bogus/file
7
_EOF_

cat RESULTS.txt | grep 'cannot be created' > /dev/null
if [ $? -eq 0 ]; then
	echo Pass $T
else
	echo Fail $T
fi

######################################################################
T='Test 26: Decrypt - invalid private key'
######################################################################

./pek <<_EOF_ > RESULTS.txt 2>&1
3
thisiswrong
7
_EOF_

cat RESULTS.txt | grep 'exactly 43' > /dev/null
if [ $? -eq 0 ]; then
	echo Pass $T
else
	echo Fail $T
fi

######################################################################
T='Test 27: Encrypt - invalid public key'
######################################################################

./pek <<_EOF_ > RESULTS.txt 2>&1
2
thisiswrong
7
_EOF_

cat RESULTS.txt | grep 'exactly 43' > /dev/null
if [ $? -eq 0 ]; then
	echo Pass $T
else
	echo Fail $T
fi

######################################################################
rm MT1.txt
rm RESULTS.txt

date
echo Menu Testing END.

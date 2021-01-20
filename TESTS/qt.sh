#!/bin/sh

echo Testing BEGIN.
date

T1=/tmp/qt$$_1.txt
T2=/tmp/qt$$_2.txt
T3=/tmp/qt$$_3.txt

#
# This command will execute two commands like the following:
#
# export PUBLIC_KEY=DKBrVBbcJ7gX4l5plb1Q9Vio4E3ZQEMu9MP1h6WpGx8
# export PRIVATE_KEY=n8mRji1by28lxKOuMseXTUGVAQqPHEPQ9Kytmy1TSo0
#
`./pek create | awk '{ T = (NR==1) ? "PUBLIC" : "PRIVATE";  print "export " T "_KEY=" $3 }'`

echo 'dwh Not Gonna Take It Anymore' | ./pek encrypt $PUBLIC_KEY - - | ./pek decrypt $PRIVATE_KEY - - | grep -q 'dwh Not Gonna Take It Anymore'

if [ $? -eq 0 ]; then
	echo 1 success
else
	echo 1 fail
fi

echo 'dwh Not Gonna Take It Anymore' | ./pek encrypt $PUBLIC_KEY - - | ./pek decrypt $PRIVATE_KEY - - | grep -q 'DWH NOT GONNA TAKE IT ANYMORE'

if [ $? -eq 0 ]; then
	echo 2 fail 
else
	echo 2 success
fi

PUBLIC_KEY=Pvf2ZHZWoLa1uVn12JxmFpl+SjKKrv39xVoHClXxRer
PRIVATE_KEY=Tr9+E2bmaWPQm8Q9/uOzV7STWwAsZBkbaNepQFeRnrF

echo 'dwh Not Gonna Take It Anymore' | ./pek encrypt $PUBLIC_KEY - - | ./pek decrypt $PRIVATE_KEY - - | grep -q 'dwh Not Gonna Take It Anymore'

if [ $? -eq 0 ]; then
	echo 3 success
else
	echo 3 fail
fi

######################################################################
######################################################################

#
# this tests a longer message. check using this script itself
#
./pek encrypt $PUBLIC_KEY qt.sh - | ./pek decrypt $PRIVATE_KEY - $T3
diff -q qt.sh $T3 > /dev/null

if [ $? -eq 0 ]; then
	echo 4 success
else
	echo 4 fail
fi

######################################################################
######################################################################@

#
# This tests that two successful encryptions generated different encryted text
#

#
# This command will execute two commands like the following:
#
# export PUBLIC_KEY=DKBrVBbcJ7gX4l5plb1Q9Vio4E3ZQEMu9MP1h6WpGx8
# export PRIVATE_KEY=n8mRji1by28lxKOuMseXTUGVAQqPHEPQ9Kytmy1TSo0
#
`./pek create | awk '{ T = (NR==1) ? "PUBLIC" : "PRIVATE";  print "export " T "_KEY=" $3 }'`

echo 'dwh Not Gonna Take It Anymore' | ./pek encrypt $PUBLIC_KEY - - | tee $T1 | ./pek decrypt $PRIVATE_KEY - - | grep -q 'dwh Not Gonna Take It Anymore'

if [ $? -eq 0 ]; then
	echo 5 success
else
	echo 5 fail
fi

echo 'dwh Not Gonna Take It Anymore' | ./pek encrypt $PUBLIC_KEY - - | tee $T2 | ./pek decrypt $PRIVATE_KEY - - | grep -q 'dwh Not Gonna Take It Anymore'

if [ $? -eq 0 ]; then
	echo 6 success
else
	echo 6 fail
fi

diff -q $T1 $T2 > /dev/null

if [ $? -eq 0 ]; then
	echo 7 fail
else
	echo '7 success (only valid if 5 and 6 were also successful)'
fi

######################################################################
######################################################################

#
# Sign / Verify
#
echo 'HelloTest' | ./pek sign $PRIVATE_KEY - - > $T1
echo 'HelloTest' | ./pek verify $PUBLIC_KEY - $T1 > $T2
grep -q GOOD $T2

if [ $? -eq 0 ]; then
	echo 8 success
else
	echo 8 fail
fi

######################################################################
#
# Testing that GOOD things happen when the hashcode mechanism used
#
HASH_CODE1=`echo 'HelloTest' | shasum -a 256 - | awk '{ print $1 }'`
HASH_CODE2=`echo 'HelloTest' | shasum -a 256 - | awk '{ print $1 }'`

./pek sign $PRIVATE_KEY $HASH_CODE1 - > $T1
./pek verify $PUBLIC_KEY $HASH_CODE2 $T1 > $T2
grep -q GOOD $T2

if [ $? -eq 0 ]; then
	echo 9 success
else
	echo 9 fail
fi

######################################################################
#
# Testing that BAD things happen when the messages are different, though
#
HASH_CODE1=`echo 'HelloTest' | shasum -a 256 - | awk '{ print $1 }'`
HASH_CODE2=`echo 'XelloXest' | shasum -a 256 - | awk '{ print $1 }'`

./pek sign $PRIVATE_KEY $HASH_CODE1 - > $T1
./pek verify $PUBLIC_KEY $HASH_CODE2 $T1 > $T2
grep -q BAD $T2

if [ $? -eq 0 ]; then
	echo 9.5 success
else
	echo 9.5 fail
fi

######################################################################
#
# Testing that BAD things happen when the signatures are different
#

echo 'HelloTest' | ./pek sign $PRIVATE_KEY - - | tr abc1 ABC0 > $T1
echo 'HelloTest' | ./pek verify $PUBLIC_KEY - $T1 > $T2
grep -q BAD $T2

if [ $? -eq 0 ]; then
	echo 10 success
else
	# this could fail if no 'abc1' symbols in signature file
	echo 10 fail
fi

######################################################################
#
# Testing that BAD things happen when the keys are different
#

OLD_PUB=$PUBLIC_KEY
OLD_PRIV=$PRIVATE_KEY
#
# This command will execute two commands like the following:
#
# export PUBLIC_KEY=DKBrVBbcJ7gX4l5plb1Q9Vio4E3ZQEMu9MP1h6WpGx8
# export PRIVATE_KEY=n8mRji1by28lxKOuMseXTUGVAQqPHEPQ9Kytmy1TSo0
#
`./pek create | awk '{ T = (NR==1) ? "PUBLIC" : "PRIVATE";  print "export " T "_KEY=" $3 }'`

echo 'HelloTest' | ./pek sign $OLD_PRIV - - > $T1
echo 'HelloTest' | ./pek verify $PUBLIC_KEY - $T1 > $T2
grep -q BAD $T2

if [ $? -eq 0 ]; then
	echo 11 success
else
	echo 11 fail
fi

######################################################################

#
# Testing that BAD things happen when the messages are different
#
echo 'HelloTest1' | ./pek sign $PRIVATE_KEY - - > $T1
echo 'HelloTest2' | ./pek verify $PUBLIC_KEY - $T1 > $T2
grep -q BAD $T2

if [ $? -eq 0 ]; then
	echo 12 success
else
	echo 12 fail
fi

######################################################################
######################################################################@

/bin/rm $T1
/bin/rm $T2
/bin/rm $T3

echo Testing END.
date

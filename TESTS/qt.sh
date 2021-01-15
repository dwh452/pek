#!/bin/sh

echo Testing BEGIN.
date

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

echo 'The next command will generate an error message. That is expected. If no error message appears, then something is broken:'
echo 'dwh Not Gonna Take It Anymore' | ./pek encrypt $PRIVTE_KEY - - | ./pek decrypt $PUBLIC_KEY - - | grep -q 'dwh Not Gonna Take It Anymore'

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
T3=/tmp/qt$$_3.txt

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

T1=/tmp/qt$$_1.txt
T2=/tmp/qt$$_2.txt

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
######################################################################@

/bin/rm $T1
/bin/rm $T2
/bin/rm $T3

echo Testing END.
date

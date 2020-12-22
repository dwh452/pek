#!/bin/sh
#
# This script refreshes the EXPECTED results in pek_verify.sh
# with the actual results of running the test suite.
#

ACTUAL=/tmp/actual_$$.txt
TMP=/tmp/refresh_$$.txt

./pek_verify.sh $ACTUAL > /dev/null

awk '
        BEGIN                           { KEEP=1 }
        KEEP == 1                       { print $0 }
        /#### EXPECTED SECTION ####/    { KEEP=0 } ' pek_verify.sh > $TMP

echo "cat <<'_EOF_' > \$EXPECTED" >> $TMP
cat $ACTUAL >> $TMP
echo '_EOF_' >> $TMP

awk '
        BEGIN                                   { KEEP=0; c=0 }
        c == 1 && /#### EXPECTED SECTION ####/  { KEEP=1 }
        c == 0 && /#### EXPECTED SECTION ####/  { c=1 }
        KEEP == 1                               { print $0 } ' pek_verify.sh >> $TMP

cp $TMP pek_verify.sh

/bin/rm $ACTUAL
/bin/rm $TMP

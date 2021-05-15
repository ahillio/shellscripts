#!/bin/bash
# Mon Jan 11 18:05:58 EST 2016 alec hill
#
echo "This program is about to fuck up the file called $1"
read -p "are your ready?" an
sed -ri 's/DDA POS DEBIT POS DEB|DDA POS DEBIT DBT CRD/DBT CRD/g' $1
sed -ri 's/DDA ATM DEBIT ATM....................\d{7}/fun/g' $1
#sed -ri 's/DDA ATM DEBIT ATM W/D 09:23 04/05/15 0003921 

#!/usr/bin/env bash

set -euo pipefail

###       #clear
###       
###       # Find how many levels below parent dir
###       PARENTDIR=$(pwd| sed -e 's|.*themes/contrib||')
###       #PARENTDIR=$(pwd| sed -e 's|.*web||')
###       CHAR="/"
###       #COUNT=$(echo $PARENTDIR | awk -F"${CHAR}" '{print NF-1}')
###       COUNT=$(grep -o "$CHAR" <<< $PARENTDIR | wc -l)
###       #echo $COUNT
###       TO=""
###       for i in $(seq 1 $COUNT); do
###         TO+="../"
###       done
###       echo $TO
###       
###       # OS Type influences who `sed` should be invoked
###       # https://stackoverflow.com/questions/43171648/sed-gives-sed-cant-read-no-such-file-or-directory/57766728#57766728
###       echo $OSTYPE


#########
# RADIX #
#########

echo "
+------------------------------------------------------------------------------+
| Creating a custom radix subtheme!                                            |
| This script assumes:                                                         |
|   1) Your site is in a git repo                                              |
|   2) Your drupal docroot is in \`web\` according to drupal/recommended-project |
|   3) Themes are located in \`web/themes/contrib\` and \`web/themes/custom\`      |
| Let's begin...                                                               |
+------------------------------------------------------------------------------+
"
cd $(git rev-parse --show-toplevel)/web/themes
if [[ ! -e custom ]]; then
    mkdir custom
fi
echo "Enter the machine name of your custom subtheme: [e.g. custom_radix_subtheme]"
read SUBTHEME_MACHINENAME
cp -r contrib/radix/src/kits/default custom/$SUBTHEME_MACHINENAME
cd custom/$SUBTHEME_MACHINENAME
for F in $(find . -name "*default*"); do mv $F $(echo $F | sed "s|default|$SUBTHEME_MACHINENAME|g"); done 
find . -type f -exec sed -i "s|RADIX_SUBTHEME_MACHINE_NAME|$SUBTHEME_MACHINENAME|g" {} \;
find . -type f -exec sed -i "s|RADIX_SUBTHEME_NAME|$SUBTHEME_MACHINENAME|g" {} \;
echo "Enter subtheme description:"
read SUBTHEME_DESCRIPTION
find . -type f -exec sed -i "s|RADIX_SUBTHEME_DESCRIPTION|$SUBTHEME_DESCRIPTION|g" {} \;
sed -i "/hidden: true/d" $SUBTHEME_MACHINENAME.info.yml

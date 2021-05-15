#!/usr/bin/env bash

set -euxo pipefail

# Turn one big vcard file into many individual ones
# @ASK: what is the syntax `"{*}"` achieving?
csplit contacts.vcf "/BEGIN:VCARD/" "{*}"

# rename each file to be named after a random 36-character string
for FILE in $(ls); do mv $FILE $(random.sh 36).vcf; done

# create UID at 3rd line of file using the random strong from the file's name
#for FILE in *; do STRING=$(echo $FILE | rev | cut -c5- | rev); sed "3i\\$STRING" $FILE > ../$FILE; done
for FILE in *; do
  RND=$(echo $FILE | rev | cut -c5- | rev)
  STRING="UID:$RND"
  # @Syntax insert text at line#3, \\ to escape $var
  sed "3i\\$STRING" $FILE > ../$FILE #note @TODO update file path, here we're running the command on a subdirectory of the ~/.contacts dir and we're copying the updated files to the parent directory
done

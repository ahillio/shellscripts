#!/usr/bin/env bash

set -euo pipefail

# @TODO: set directory of "dev_html" to proper location
cd ~/www

DATE=$(date +%F)
COMMIT=$(git rev-parse HEAD | cut -c-7)

#create production dump file
printf "Create production dump files...\n"
DRUPALDB=$DATE--$COMMIT--prod
if [[ -e ~/backups/$DRUPALDB.sql ]] ; then
  i=0
  while [[ -e ~/backups/$DRUPALDB-$i.sql ]] ; do
    i=$((i + 1))
  done
  DRUPALDB=$DRUPALDB-$i
fi
drush @prod sql-dump > ~/backups/$DRUPALDB.sql

#backup test site
printf "Backup test site just in case...\n"
# @TODO: set directory of "dev_html" to proper location
cd ~/dev_html/docroot
DEVCOMMIT=$(git rev-parse HEAD | cut -c-7)
DEVDB=dev--$DATE--$DEVCOMMIT
if [[ -e ~/backups/$DEVDB ]] ; then
  i=0
  while [[ -e ~/backups/$DEVDB-$i.sql ]] ; do
    i=$((i + 1))
  done
  DEVDB=$DEVDB-$i
fi
drush @test sql-dump > ~/backups/DEVDB.sql

#Drop tables from test site
printf "Deleting test site data...\n"
drush @test sql-drop -y

# import production dbs
printf "Importing production data...\n"
drush @test sqlc < ~/backups/$DRUPALDB.sql
printf "The test site has been rebuilt from production data."

printf "\nChange stripe api keys...\n" # @TODO: are these correct api keys?
drush @local sqlq "update rules_config set data = replace(data, 'pk_live_xyz', 'pk_test_xyz') where name = 'commerce_payment_commerce_stripe'"
drush @local sqlq "update rules_config set data = replace(data, 'sk_live_xyz', 'sk_test_xyz') where name = 'commerce_payment_commerce_stripe'"

# @TODO: add environment_indicator_settings.... probably to settings.php

# @TODO: sanitize dbs, at least change all emails
# echo 'Scrub email addresses and passwords...'
# drush @test sql-sanitize -y
# then reset admin & roots emails/passwords? or exclude them from sanitization?
# or maybe do like this with logical sql queries...
# echo 'Erase field data for emails...'
# drush @test sqlq "truncate field_data_field_email"
# drush @test sqlq "truncate field_revision_field_email"
# 
# @TODO do any other tables need to be dropped?
# echo 'Truncate webform submissions table...'
# drush @test sqlq "truncate webform_submissions"
# drush @test sqlq "truncate webform_submitted_data"
# drush @test sqlq "truncate commerce_cardonfile"

echo 'Display errors...'
drush @test vset error_level 2
echo 'Disable css/js preprocessing...'
drush @test vset preprocess_css 0
drush @test vset preprocess_js 0
echo 'and clear cache...'
drush @test cc all
echo 'Done!'

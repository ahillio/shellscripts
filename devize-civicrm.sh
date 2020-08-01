#!/usr/local/bin/bash

set -euo pipefail

cd ~/public_html/docroot

DATE=$(date +%F)
COMMIT=$(git rev-parse HEAD | cut -c-7)

#create production dump files
printf "Create production dump files...\n"
DRUPALDB=$DATE--$COMMIT--prod-drupal
if [[ -e ~/backups/$DRUPALDB.sql ]] ; then
  i=0
  while [[ -e ~/backups/$DRUPALDB-$i.sql ]] ; do
    i=$((i + 1))
  done
  DRUPALDB=$DRUPALDB-$i
fi
drush @prod sql-dump > ~/backups/$DRUPALDB.sql

CIVIDB=$DATE--$COMMIT--prod-civi
if [[ -e ~/backups/$CIVIDB.sql ]] ; then
  i=0
  while [[ -e ~/backups/$CIVIDB-$i.sql ]] ; do
    i=$((i + 1))
  done
  CIVIDB=$CIVIDB-$i
fi
drush @prod civicrm-sql-dump > ~/backups/$CIVIDB.sql

#backup test site
printf "Backup test site just in case...\n"
cd ~/dev_html/docroot
DEVCOMMIT=$(git rev-parse HEAD | cut -c-7)
drush @test sql-dump > ~/backups/dev--$DATE--$DEVCOMMIT-drupal.sql
drush @test civicrm-sql-dump > ~/backups/dev--$DATE--$DEVCOMMIT-civi.sql

#Drop tables from test site
printf "Deleting test site data...\n"
echo "SET FOREIGN_KEY_CHECKS=0;" > drop-all-civi-tables.sql
drush @test civicrm-sql-query "show tables" | sed -E 's/(.*)/DROP TABLE IF EXISTS `\1`;/g' >> drop-all-civi-tables.sql
echo "SET FOREIGN_KEY_CHECKS=1;" >> drop-all-civi-tables.sql
drush @test civicrm-sql-query "source drop-all-civi-tables.sql"
sed -i '' 's/TABLE/VIEW/g' drop-all-civi-tables.sql
drush @test civicrm-sql-query "source drop-all-civi-tables.sql"
rm drop-all-civi-tables.sql
drush @test sql-drop -y

# import production dbs
printf "Importing production data...\n"
drush @test sqlc < ~/backups/$DRUPALDB.sql
drush @test cvsqlc < ~/backups/$CIVIDB.sql 
printf "The test site at dev.milkwithdignity.org has been completely rebuilt."


# @TODO: sanitize dbs, at least change all emails
# OTHER POSSIBLE TASKS
#
# echo 'Scrub email addresses and passwords...'
# drush @dev sql-sanitize -y
# 
# echo 'Erase field data for example...'
# drush @dev sqlq "truncate field_data_field_email"
# drush @dev sqlq "truncate field_revision_field_email"
# 
# echo 'Truncate webform submissions table...'
# drush @dev sqlq "truncate webform_submissions"
# drush @dev sqlq "truncate webform_submitted_data"
# 
# @todo determine if webform submissions must be dropped 
# drush @dev sqlq "truncate commerce_cardonfile"
# echo 'Display errors...'
# drush @dev vset error_level 1
# echo 'Disable css/js preprocessing...'
# drush @dev vset preprocess_css 0
# drush @dev vset preprocess_js 0
# echo 'and clear cache...'
# drush @dev cc all
# echo 'Done!'

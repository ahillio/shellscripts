#! /bin/bash

cd ~/www

DATE=$(date +%F)
COMMIT=$(git rev-parse HEAD | cut -c-7)

DRUPALDB=$COMMIT--$DATE--prod-drupal
if [[ -e ~/backups/$DRUPALDB.sql ]] ; then
  i=2
  while [[ -e $DRUPALDB-$i.sql ]] ; do
    let i++
  done
  DRUPALDB=$DRUPALDB-$i
fi
drush @prod sql-dump > ~/backups/$DRUPALDB.sql

CIVIDB=$COMMIT--$DATE--prod-civi
if [[ -e ~/backups/$CIVIDB.sql ]] ; then
  i=2
  while [[ -e $CIVIDB-$i.sql ]] ; do
    let i++
  done
  DRUPALDB=$CIVIDB-$i
fi
drush @prod civicrm-sql-dump > ~/backups/$COMMIT--$DATE--prod-civi.sql

===

# deploy.sh
cd www
db-backup.sh
drush vset maintenance_mode 1
drush dis -y webform_civicrm webform_civicrm_results
git fetch && git pull
rm sites/default/files/civicrm/templates_c/*
drush updb
drush cvupdb
drush en -y webform_civicrm webform_civicrm_results
drush vset maintenance_mode 0
drush cc all

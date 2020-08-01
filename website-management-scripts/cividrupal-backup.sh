#! /bin/bash
# or
#! /usr/local/bin/bash
# etc

cd ~/www

DATE=$(date +%F)
COMMIT=$(git rev-parse HEAD | cut -c-7)

DRUPALDB=$COMMIT--$DATE--prod-drupal
if [[ -e ~/backups/$DRUPALDB.sql ]] ; then
  i=2
  while [[ -e ~/backups/$DRUPALDB-$i.sql ]] ; do
    i=$((i + 1))
  done
  DRUPALDB=$DRUPALDB-$i
fi
drush @prod sql-dump > ~/backups/$DRUPALDB.sql

CIVIDB=$COMMIT--$DATE--prod-civi
if [[ -e ~/backups/$CIVIDB.sql ]] ; then
  i=2
  while [[ -e ~/backups/$CIVIDB-$i.sql ]] ; do
    i=$((i + 1))
  done
  CIVIDB=$CIVIDB-$i
fi
drush @prod civicrm-sql-dump > ~/backups/$CIVIDB.sql

#!/bin/bash

DATE=$(date +%F)
COMMIT=$(git rev-parse HEAD | cut -c-7)
#@todo: change backup dir if necessary
BACKUPDIR="../backups"

DRUPALDB=$COMMIT--$DATE--prod-drupal
if [[ -e $BACKUPDIR/$DRUPALDB.sql ]] ; then
  i=0
  while [[ -e $BACKUPDIR/$DRUPALDB-$i.sql ]] ; do
    i=$((i + 1))
  done
  DRUPALDB=$DRUPALDB-$i
fi

#@todo: update @site alias if necessary
drush @prod sql-dump > $BACKUPDIR/$DRUPALDB.sql

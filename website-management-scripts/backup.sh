#!/bin/bash

DATE=$(date +%F)
COMMIT=$(git rev-parse HEAD | cut -c-7)

DRUPALDB=$DATE--$COMMIT--prod
if [[ -e ~/backups/$DRUPALDB.sql ]] ; then
  i=0
  while [[ -e ~/backups/$DRUPALDB-$i.sql ]] ; do
    i=$((i + 1))
  done
  DRUPALDB=$DRUPALDB-$i
fi

drush @prod sql-dump > ~/backups/$DRUPALDB.sql

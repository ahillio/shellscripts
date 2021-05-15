#!/bin/bash
d=$(date +%b%d)
drush sql-dump > drupal_$d.sql

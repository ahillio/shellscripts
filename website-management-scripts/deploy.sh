#! /usr/local/bin/bash

set -e
# this will cause the script to fail
# drush en/dis commands barf out a callstack and exit with non-zero status

cd www
backup.sh
drush vset maintenance_mode 1
drush dis -y webform_civicrm webform_civicrm_results
git fetch && git pull
#admin settings forms may need to be flushed...
#but right now I don't want to delete these...
#rm sites/default/files/civicrm/templates_c/*
drush updb
drush cvupdb
drush en -y webform_civicrm webform_civicrm_results
drush vset maintenance_mode 0
drush cc all

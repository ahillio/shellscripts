#!/usr/bin/env bash

set -euo pipefail

if [ $# -eq 0 ]; then
  printf "  Create a new CiviBase website with ddev, git, and composer etc
  Script needs 1 parameter: name of project/directory.\n"
  exit 64
fi


PROJ=$1
composer create-project Vardot/varbase-project:8.8.8 $PROJ --no-dev --no-interaction
cd $PROJ
git init
echo "*~
*.swp
*.swo
*.tmp
*.sql
*.zip
*.tgz
*.tar.gz
docroot/sites/default/files
docroot/sites/default/settings.php
docroot/sites/default/civicrm.settings.php
" > .gitignore; git add .gitignore
git commit -m "Begin."
git add .
git commit -m "Track Varbase files."
ddev config --project-name=$PROJ --docroot=docroot --project-type=drupal8 --webimage-extra-packages=exuberant-ctags
ddev start
git add .ddev
git commit "Initialize ddev."
composer require civicrm/civicrm-asset-plugin:'~1.1'
git commit -m "Require civicrm-asset-plugin."
cd vendor/civicrm/civicrm-asset-plugin
find . -type f -exec sed -i "s|web/libraries|docroot/libraries|g" {} \;
git commit -m "Hack civicrm-asset-plugin path to libraries."
cd ../../..
composer require civicrm/civicrm-{core,packages,drupal-8}:'~5.35' #@TODO this requires a manually confirmation...?
#@TODO and then it puts the libraries directory in the git root, wtf

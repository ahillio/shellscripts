#!/usr/bin/env bash

set -euo pipefail

if [ $# -eq 0 ]; then
  printf "  Create a new ddev project using Drupal, CiviCRM, Varbase, and others.
  Script needs 1 parameter: name of project/directory.\n"
  exit 64
fi
PROJ=$1

composer create-project drupal/recommended-project:8.x $PROJ
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
*/sites/default/files
*/sites/default/settings.php
*/sites/default/civicrm.settings.php" > .gitignore; git add .gitignore
git commit -m "Begin."
git add .
git commit -m "Track Varbase files."
#ddev config --project-name=$PROJ --docroot=docroot --project-type=drupal8 --webimage-extra-packages=exuberant-ctags
# we don't know what "docroot" will be...
# @TODO possibly might need to specify docroot in previous case statement
ddev config --project-name=$PROJ --project-type=drupal8 --webimage-extra-packages=exuberant-ctags
ddev start
git add .ddev
git commit -m "Initialize ddev."

composer require civicrm/civicrm-asset-plugin:'~1.1'
git add vendor composer*
git commit -m "civi-asset-plug"

mv web docroot

## this is the `bash` mechanism for letting the user who ran the script select options from a list
#select opt in "${options[@]}"
#do
## ensure user input is valid and create new projects...
#    case $opt in
#        "Plain Drupal")
#            echo "installing $opt into $PROJ"
#            composer create-project drupal/recommended-project:8.x $PROJ
#            init_git_and_ddev
#            composer require drupal/admin_toolbar
#            # @TODO delete following civi lines...
#            composer require civicrm/civicrm-asset-plugin:'~1.1'
#            git add vendor composer*
#            git commit -m "civi-asset-plug"
#            mv web docroot
#            composer require civicrm/civicrm-{core,packages,drupal-8}:'~5.35'
#            # @TODO drush site install && enables
#            break
#            ;;
#        "CiviBase")
#            echo "installing $opt into $PROJ"
#            composer create-project Vardot/varbase-project:8.8.8 $PROJ --no-dev --no-interaction
#            init_git_and_ddev
#            composer require civicrm/civicrm-asset-plugin:'~1.1'
#            git commit -m "Require civicrm-asset-plugin."
#            composer require civicrm/civicrm-{core,packages,drupal-8}:'~5.35' #@TODO this requires a manually confirmation...?
#            break
#            ;;
#        "OpenSocial")
#            echo "installing $opt into $PROJ"
#            composer create-project Vardot/varbase-project:8.8.8 $PROJ --no-dev --no-interaction
#            init_git_and_ddev
#            break
#            ;;
#        "[x] Cancel")
#            echo "whoops, nevermind.  aborted."
#            break
#            ;;
#        *) echo "Invalid response: $REPLY";;
#    esac
##echo "installing $opt in $1"
##break
#done
#
#ls

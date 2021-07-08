#!/usr/bin/env bash

set -euo pipefail

if [ $# -eq 0 ]; then
  printf "  Create a new ddev project using Drupal, CiviCRM, Varbase, and others.
  Script needs 1 parameter: name of project/directory.\n"
  exit 64
fi
PROJ=$1

init_git_and_ddev(){
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
  # @TODO? possibly might need to specify docroot in previous case statement
  # actually the following doesn't specify docroot at all so maybe it's not needed?
  ddev config --project-name=$PROJ --project-type=drupal8 --webimage-extra-packages=exuberant-ctags
  ddev start
  git add .ddev
  git commit -m "Initialize ddev."
}

PS3='Type number and hit Enter to select which website you want to start. ' # PS3 is automatically printed below select options
options=("Plain Drupal" "CiviBase" "OpenSocial" "[x] Cancel")
# this is the `bash` mechanism for letting the user who ran the script select options from a list
select opt in "${options[@]}"
do
# ensure user input is valid and create new projects...
    case $opt in
        "Plain Drupal")
            echo "installing $opt into $PROJ"
            composer create-project drupal/recommended-project:8.x $PROJ
            init_git_and_ddev
            composer require drupal/admin_toolbar
            # @TODO drush enables
            ddev exec drush site-install --yes
            ddev exec drush en -y admin_toolbar_tools
            break
            ;;
        "CiviBase")
            echo "installing $opt into $PROJ"
            composer create-project Vardot/varbase-project:8.8.8 $PROJ --no-dev --no-interaction
            init_git_and_ddev
            composer require civicrm/civicrm-asset-plugin:'~1.1'
            git add vendor composer*
            git commit -m "Require civicrm-asset-plugin."
            composer require civicrm/civicrm-{core,packages,drupal-8}:'~5.35' #@TODO this requires a manually confirmation...?
            mv libraries/civicrm docroot/libraries/civicrm; rm -rf libraries
            find vendor -name ".git" -exec rm -rf {} \;
            # @TODO why did script abort right here?
            git add composer* bin vendor docroot; git commit -m "Require CiviCRM stuff."
            composer require drush/drush; git add composer* vendor bin; git commit -m "Require Drush."
            ddev exec drush site-install varbase --yes --site-name="$PROJ" --account-name=webmaster --account-pass=dD.123123ddd --account-mail=webmaster@vardot.com varbase_multilingual_configuration.enable_multilingual=false varbase_extra_components.vmi=true varbase_extra_components.varbase_heroslider_media=true varbase_extra_components.varbase_carousels=true varbase_extra_components.varbase_search=true varbase_development_tools.varbase_development=false
            break
            ;;
        "Exist D7")
          echo "Get what you need:\n1) git origin url like: wpp:~/git_repo_origin\n2) remote location of db like: wpp:~/backups/2021-06-09--6fc69b6--prod.sql\n... then report back."
            #read "ready"
            echo "installing $opt into $PROJ"
            # @TODO use read command so url of origin repo can be provided by user instead of hardcoded here...
            git clone wpp:~/git_repo_origin $PROJ; cd $PROJ
            ddev config --project-name=$PROJ --project-type=drupal7 --webimage-extra-packages=exuberant-ctags
            git add .ddev; git commit -m "Initialize ddev."
            #composer create-project goalgorilla?/opensocial? $PROJ --no-dev --no-interaction
            #init_git_and_ddev
            break
            ;;
        "OpenSocial")
            echo "installing $opt into $PROJ"
            #composer create-project goalgorilla?/opensocial? $PROJ --no-dev --no-interaction
            #init_git_and_ddev
            break
            ;;
        "[x] Cancel")
            echo "whoops, nevermind.  aborted."
            break
            ;;
        *) echo "Invalid response: $REPLY";;
    esac
#echo "installing $opt in $1"
#break
done

ls

#!/usr/bin/env bash

set -euxo pipefail

mkdir $1
cd $1
ddev config --project-type=drupal8 --docroot=web --create-docroot
ddev start
ddev composer create-project roundearth/drupal-civicrm-project:8.x-dev --no-interaction
ddev composer require drush/drush
ddev launch

docker cp git-prompt.sh ddev-roundearth-demo-web:/home/alec/.git-prompt.sh
docker cp bashrc ddev-roundearth-demo-web:/home/alec/.bashrc
docker cp inputrc ddev-roundearth-demo-web:/home/alec/.inputrc
docker cp git-completion.bash ddev-roundearth-demo-web:/etc/bash_completion.d/git

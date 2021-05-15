#!/usr/bin/env bash

set -euo pipefail

composer update drupal/core-recommended --with-dependencies
git add .
git commit -m "Update Drupal core."
drush updatedb
drush cache:rebuild

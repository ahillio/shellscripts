#!/usr/bin/env bash

set -euo pipefail

# only contains example code so far

select name in Latest Successful  Stable "Pick a Build Number" ;
do
  case "$name" in
    Latest)
      build=lastSuccessful
      break
      ;;
    Successful)
      build=lastSuccessful
      break
      ;;
    Stable)
      build=lastSuccessful
      break
      ;;
    Pick*)
      read -p "Enter a number from 1 to 10000: " number
      break
      ;;
  esac
done

echo 'Please pick from the following'

select area in area1 area2 area3
do
  case $area in 
    area1|area2|area3)   
      break
      ;;
    *)
      echo "Invalid area" 
      ;;
  esac
done

echo 'Now pick a place based on the area you chose'
select place in place1 place2 place3
do
  case $place in
    place1|place2|place3)
      break
      ;;
    *)
      echo "Invalid place"
      ;;
        esac
done

echo "Based on $area and $place here is what you need..."
# composer create-project panopoly/panopoly-composer-template:8.x-dev panopoly1 --no-interaction
composer create-project panopoly/panopoly-composer-template:8.x-dev panopoly1 --no-interaction

cd panopoly1
ginit
cp ../ATN/.gitignore .gitignore
gs
git add .gitignore
gcm "Gitignore."
find vendor -name ".git" -exec rm -rf {} \;
find web -name ".git" -exec rm -rf {} \;
find docroot -name ".git" -exec rm -rf {} \;
git add .
gcm "Track all files."
ddev config
git add .ddev/
gcm "Ddev."
ddev start

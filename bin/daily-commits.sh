#!/usr/bin/env bash
# run daily via `anacron` with an `/etc/anacrontab` entry:
# 1 0 cron.daily /usr/bin/bash /home/alec/bin/daily-commits.sh

set -euo pipefail

#sudo su alec

DIRS=(
  "/home/alec/Documents/wiki"
  "/home/alec/.task"
  "/home/alec/.timewarrior"
  "/home/alec/.calendar"
)
for d in "${DIRS[@]}"
do
  cd $d
  git add .
  if [ $# -eq 0 ]; then
    git commit -m "Daily commit."
  fi
    git commit -m "$1"
done

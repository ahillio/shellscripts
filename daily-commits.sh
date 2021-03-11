#!/usr/bin/env bash
# run daily via `anacron` with `/etc/anacrontab` entry:
# 1 0 cron.daily /usr/bin/bash /home/alec/bin/daily-commits.sh

set -euo pipefail

DIRS=(
  "/home/alec/Documents/wiki"
  "/home/alec/.task"
  "/home/alec/.timewarrior"
)
for d in "${DIRS[@]}"
do
  cd $d
  git add .
  git commit -m "Daily commit."
done

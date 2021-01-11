#!/usr/bin/env bash
# run daily via `anacron` with `/etc/anacrontab` entry:
# 1 0 cron.daily /usr/bin/bash /home/alec/bin/wiki-backup.sh

set -euo pipefail

cd /home/alec/Documents/wiki
git add .
git commit -m "Daily commit."

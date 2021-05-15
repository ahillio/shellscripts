#!/usr/bin/env bash

set -euo pipefail

if [ $# -eq 0 ]; then
  printf "  git-changes
  required parameter: filename
  might allow multiple filenames???\n"
  exit 64
fi

git log -p -- "$@"

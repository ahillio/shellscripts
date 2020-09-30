#!/usr/bin/env bash

set -euo pipefail
VAR=$(timew :id summary 2020-01-01 - tomorrow $1 | grep -v invoiced | grep -o "@[0-9]*" | tr '\n' ' '); timew tag $VAR invoiced

#!/usr/bin/env bash

set -euo pipefail

sed -e 's/|/'$'\001''|/g' | column -t -s $'\001'

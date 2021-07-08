#!/usr/bin/env bash

set -euo pipefail

if [ $# -eq 0 ]; then
  printf "  Name of script
  Parameters required...
  Provide info here\n"
  exit 64
fi

jq -Cr '
  . as $input |
  ($input | [
   .data[]
   | {invoice_id: .id,
      client: .customer_name,
      date: .date | strftime("%Y-%m-%d"),
      amount: .total,
      status: .status}
   | .amount = "$" + (.amount/100|tostring)
  ] | sort_by(.date)),
  "Total: $\([$input | .data[] | .total] | add | . / 100)"
'

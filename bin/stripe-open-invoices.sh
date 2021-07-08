#!/usr/bin/env bash

set -euo pipefail

APIKEY=$(cat ~/.password-store/stripe-live-sk)
#stripe --api-key=$APIKEY --live get /v1/invoices -d status=open
stripe get /v1/invoices -d status=open --api-key=$APIKEY --live | jq '.data[] | {id: .id, client: .customer_name, amount: .total} | .amount = "$" + (.amount/100|tostring) | .id, .client, .amount'

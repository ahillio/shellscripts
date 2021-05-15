#!/usr/bin/env bash

set -euo pipefail


function stripe-invoices {
  APIKEY=$(cat ~/.passwords/stripe-live-sk)
  curl https://api.stripe.com/v1/invoices -u $APIKEY: -G |
    #works, unsorted
    #jq -S -C '.data[] | {invoice_id: .id, client: .customer_name, date: .date | strftime("%Y-%m-%d"), amount: .total, status: .status} | .amount = "$" + (.amount/100|tostring)'
    # to sort this took a lot of time, formerly unsorted, the following is sorted:
    jq -S -C '[.data[] | {invoice_id: .id, client: .customer_name, date: .date | strftime("%Y-%m-%d"), amount: .total, status: .status} | .amount = "$" + (.amount/100|tostring)] | sort_by(.date)'
    # https://unix.stackexchange.com/questions/613779/how-to-get-the-right-type-and-value-for-jq-to-sort
  }

#stripe-invoices
cat /home/alec/bin/inc/stripe.json | jq -S -C '[.data[] | {invoice_id: .id, date: .date | strftime("%Y-%m-%d"), amount: .total,} | .amount = "$" + (.amount/100|tostring)] | sort_by(.date)'

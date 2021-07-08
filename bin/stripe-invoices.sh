#!/usr/bin/env bash

set -euo pipefail

CLIENT=$1
#CLIENT='Winooski'
APIKEY=$(cat ~/.password-store/stripe-live-sk)
#clear

#curl https://api.stripe.com/v1/invoices -u $APIKEY: -G | jq -Cr 
#curl https://api.stripe.com/v1/invoices -u $APIKEY: -G | jq -C "[.data[] | select(.customer_name | contains(\"$CLIENT\")) | {invoice_id: .id, client: .customer_name, date: .date | strftime(\"%Y-%m-%d\"), amount: .total, status: .status} | .amount = \"$\" + (.amount/100|tostring)] | sort_by(.date)"

# nice and easy to read on multiple lines :)
#curl https://api.stripe.com/v1/invoices -u $APIKEY: -G | jq -Cr "
#  [.data[]
#  | select(.customer_name | contains(\"$CLIENT\"))
#  | {invoice_id: .id,
#     client: .customer_name,
#     date: .date | strftime(\"%Y-%m-%d\"),
#     amount: .total, status: .status,
#     work: .lines.data[].description}
#  | .amount = \"$\" + (.amount/100|tostring)]
#  | sort_by(.date)"

FINALLINE='"Total: $\([$input | .data[] | .total] | add | . / 100)"'

#curl https://api.stripe.com/v1/invoices -u $APIKEY: -G | jq -Cr '
#  . as $input |
#  ($input | [
#   .data[]
#   | {invoice_id: .id,
#      client: .customer_name,
#      date: .date | strftime("%Y-%m-%d"),
#      amount: .total,
#      status: .status}
#   | .amount = "$" + (.amount/100|tostring)
#  ] | sort_by(.date)),
#  "Total: $\([$input | .data[] | .total] | add | . / 100)"
#'

curl https://api.stripe.com/v1/invoices -u $APIKEY: -G | jq -Cr "

def todollar:
  \"$\" + tostring;
  
def json:
  [.data[]
   | select(.customer_name | contains(\"$CLIENT\"))
   | {invoice_id: .id,
      client: .customer_name,
      date: .date | strftime(\"%Y-%m-%d\"),
      amount: (.total/100),
      status: .status} ]
  | sort_by(.date) ;

json
| map_values(.amount |= todollar),
  \"Total: \" + (map(.amount) | add | todollar)
"

#
#cat ~/code/inc/stripe-minified-anonymized.json | jq -C "[.data[] | {invoice_id: .id, client: .customer_name, date: .date | strftime(\"%Y-%m-%d\"), amount: .total, status: .status} | .amount = \"$\" + (.amount/100|tostring)] | sort_by(.date)"

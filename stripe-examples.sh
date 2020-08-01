#!/usr/bin/env bash

set -euxo pipefail

# from https://stripe.com/docs/cli/get
# note the final ' does not have a matching one to open or close
stripe get /v1/subscriptions -d status=past_due \
    | jq ".data[].id" \
    | xargs -I % -p stripe delete /subscriptions/%'

'
# close that string since the previous get command has odd straggler '

stripe invoices update in_1H9eld2eZvKYlo2CVk03r9Xl \
    -d "metadata[order_id]"=6735

stripekey get /v1/invoices -d status=open | jq '.data[] | {id: .id, client: .customer_name, amount: .total} | .amount = "$" + (.amount/100|tostring)'

stripekey get /v1/invoices -d status=open | jq '.data[] | {id: .id, client: .customer_name, amount: .total} | .amount = "$" + (.amount/100|tostring) | .id, .client, .amount'

stripekey get /v1/invoices -d status=open | jq '.data[] | .id, .customer_name, .total'

# but the following has error cannot index string with string "total"
stripekey get /v1/invoices -d status=open | jq '.data[] | .id, .customer_name, .total | .total = "$" + (.total/100|tostring)'


#update invoice status to "paid":
stripekey post in_1H612CFGUwFHXzvljXvGe4z6 -d paid=true

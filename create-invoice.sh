#!/usr/bin/env bash

set -euxo pipefail

APIKEY=$(cat ~/.passwords/stripe-live-sk)
# if we set environment variable: STRIPE_API_KEY
# then we don't need to specify `--api-key=` in every command...?

DATE=$(date -d '2020-07-31' +%s)
CUSTOMER="cus_HOUqUyIeZfOsKu"
AMOUNT="20000"

stripe invoiceitems create --api-key=$APIKEY --customer=$CUSTOMER --amount=$AMOUNT --currency=usd --description='Configure new server and migrate website to it.'
stripe invoices create --live --api-key=$APIKEY --customer=$CUSTOMER --due-date=$DATE --collection-method=send_invoice --description='Alec Hill
14 Maple Leaf Farm Road
Underhill, VT 05489'

# then:
# stripekey invoices send_invoice in_1H612CFGUwFHXzvljXvGe4z6 --live

# What does the `--due-date` parameter in the cli's `stripe invoices create` do?  The value I provided is not represented by any of the timestamps in the json object that the api returns after successfully executing that the `stripe invoices create` command.
# 
# On the `stripe invoices update` command... what's the difference between `--due-date` and `--days-until-due`?
# 
# The `stripe invoices send` command has no date parameter at all.  But the user interface has the setting "Payment due = x days after invoice is sent".  How do I modify that x# of days from the cli?

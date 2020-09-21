#!/usr/bin/env bash

set -euo pipefail

# Use live/production API
APIKEY=$(cat ~/.passwords/stripe-live-sk)
# if we set environment variable: STRIPE_API_KEY
# then we don't need to specify `--api-key=` in every command...?

# @TODO: set these four values to create the invoice
DATE=$(date -d '2020-08-31' +%s)
CUSTOMER="cus_HOUnJ8NiE7pj6g"
AMOUNT="51000"
WORKDESCRIPTION="Deploy splash window to production.  Update date module to fix php7.3 compatibility.  Planning for video content, email list, resources pages, google analytics, D8 upgrade, surveys and CRM."

# Create Invoice
stripe invoiceitems create --api-key=$APIKEY --customer=$CUSTOMER --amount=$AMOUNT --currency=usd --description="$WORKDESCRIPTION"
stripe invoices create --live --api-key=$APIKEY --customer=$CUSTOMER --due-date=$DATE --collection-method=send_invoice --description='Alec Hill
14 Maple Leaf Farm Road
Underhill, VT 05489'

# Instructions to SEND invoice
echo "
now run:
  stripe-invoices
  stripekey invoices send_invoice in_idstringxyz"

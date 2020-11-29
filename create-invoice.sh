#!/usr/bin/env bash

set -euo pipefail

# Use live/production API
APIKEY=$(cat ~/.passwords/stripe-live-sk)
# if we set environment variable: STRIPE_API_KEY
# then we don't need to specify `--api-key=` in every command...?


# SET THESE FOUR VARIABLES TO CREATE THE INVOICE
# ----------------------------------------------
# DUEDATE must be in the future
DUEDATE=$(date -d '2020-11-20' +%s)
# CUSTOMER ID's
# ATN cus_HtVDaVrIBz5RfC
# WPP cus_HOUnJ8NiE7pj6g
CUSTOMER="cus_HOUnJ8NiE7pj6g"
AMOUNT="113500"
WORKDESCRIPTION="Discussing image layout and templates for current/D7 site.  Planning and testing sitebuilding tools.  Installing Drupal 8 with the Varbase distribution and CiviCRM, overcomming several hurdles with the package management system.  Meeting showcasing the 'paragraphs' and 'layout builder' tools plus webforms and CiviCRM."

# Invoke Stripe API to create line items and invoice
stripe invoiceitems create --api-key=$APIKEY --customer=$CUSTOMER --amount=$AMOUNT --currency=usd --description="$WORKDESCRIPTION"
stripe invoices create --live --api-key=$APIKEY --customer=$CUSTOMER --due-date=$DUEDATE --collection-method=send_invoice --description='Alec Hill
PO Box 160
Richmond, VT 05477'

# Instructions to SEND invoice
echo "
now run:
  stripe-invoices
  stripekey invoices send_invoice in_idstringxyz
  stripe-open-invoices.sh

then if you're sure all open time entries have been billed for run this script to mark them as such:
  danger: the following script will mark **unbillable** entries as invoiced
  timew-mark-invoiced-entries.sh ABBR
  (where ABBR is the client's initial, like ATN, MCW, etc)"

#!/usr/bin/env bash

set -euo pipefail

# Use live/production API
APIKEY=$(cat ~/.passwords/stripe-live-sk)
# if we set environment variable: STRIPE_API_KEY
# then we don't need to specify `--api-key=` in every command...?

# @TODO SET THESE 4 VARIABLES TO CREATE THE INVOICE
# -------------------------------------------------
# DUEDATE must be in the future
DUEDATE=$(date -d '2021-02-25' +%s)
# CUSTOMER ID's:
# ATN     cus_HtVDaVrIBz5RfC
#CUSTOMER="cus_HtVDaVrIBz5RfC"
# ---
# WPP     cus_HOUnJ8NiE7pj6g
CUSTOMER="cus_HOUnJ8NiE7pj6g"
# ---
# TEF     cus_HOUjgdCSsEQCzg
#CUSTOMER="cus_HOUjgdCSsEQCzg"
AMOUNT="29000"
WORKDESCRIPTION="Install CiviCRM with Varbase Drupal distribution on the webserver, located at http://civibase.winooskiprevention.org/.  Meeting with Jane discussing CiviCRM and Varbase page-building tools."

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
  (where ABBR is the client's initial, like ATN, MCW, etc)

** When an invoice is paid by check the following command can mark it as having been paid:
  stripekey invoices pay in_1H9et32eZvKYlo2C3zDszUCz --paid-out-of-band true"

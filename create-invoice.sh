#!/usr/bin/env bash

set -euo pipefail

# Use live/production API
APIKEY=$(cat ~/.passwords/stripe-live-sk)
# if we set environment variable: STRIPE_API_KEY
# then we don't need to specify `--api-key=` in every command...?


# SET THESE FOUR VARIABLES TO CREATE THE INVOICE
# ----------------------------------------------
# DUEDATE must be in the future
DUEDATE=$(date -d '2020-11-04' +%s)
# CUSTOMER ID's
# ATN cus_HtVDaVrIBz5RfC
# WPP cus_HOUnJ8NiE7pj6g
CUSTOMER="cus_HtVDaVrIBz5RfC"
AMOUNT="49500"
WORKDESCRIPTION="Build out site and custom theme: configuring layout_builder; drush site aliases, site management scripts, rebuild local dev from prod; media configuration; fix theme bug: breaks media insert in layout builder; clean up git history, push dev branch to test site online; add manager role with basic permissions; configure path aliases, event type, classes view, fix nav menu dropdown; reinstall SSL certificate and communicate need for auto-renewing certs with Erik to relay to greengeeks.  Fix spamblock on login form on old D7 site.  Training Jenni in Drupal content management, discussing design process, planning data architecture of event types."

# Invoke Stripe API to create line items and invoice
stripe invoiceitems create --api-key=$APIKEY --customer=$CUSTOMER --amount=$AMOUNT --currency=usd --description="$WORKDESCRIPTION"
stripe invoices create --live --api-key=$APIKEY --customer=$CUSTOMER --due-date=$DUEDATE --collection-method=send_invoice --description='Alec Hill
14 Maple Leaf Farm Road
Underhill, VT 05489'

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

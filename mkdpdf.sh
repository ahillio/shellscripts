#!/usr/bin/env bash

set -euxo pipefail

# pandoc -V geometry:left=1in -V geometry:top=.5in $1 --pdf-engine=xelatex -o $2

pandoc -t html5 --css ~/bin/inc/pandoc-pdf.css $1 -o $2 -s --pdf-engine=wkhtmltopdf

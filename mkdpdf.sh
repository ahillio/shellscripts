#!/usr/bin/env bash

set -euxo pipefail
echo $1
# pandoc -V geometry:left=1in -V geometry:top=.5in $1 --pdf-engine=xelatex -o $2
TITLE=$(echo $1 | sed 's|.mkd||')
MARGIN=.35in
# @TODO $SIZE should be parameter
# b6 = postcard size, amount of handwriting that can fit in a folded postcard
#SIZE=b6
SIZE=letter
#pandoc -t html5 -V margin-top=$MARGIN -V margin-left=$MARGIN -V margin-bottom=$MARGIN -V margin-right=$MARGIN -V papersize=$SIZE --css ~/bin/inc/pandoc-pdf.css $1 -o $2 -s --pdf-engine=wkhtmltopdf
pandoc -t html5 -V margin-top=$MARGIN -V margin-left=$MARGIN -V margin-bottom=$MARGIN -V margin-right=$MARGIN -V papersize=$SIZE --css ~/bin/inc/pandoc-pdf.css --metadata pagetitle="$TITLE" $1 -o $2 -s --pdf-engine=wkhtmltopdf
#pandoc -t html5 -V margin-top=$MARGIN -V margin-left=$MARGIN -V margin-bottom=$MARGIN -V margin-right=$MARGIN -V papersize=letter --css ~/bin/inc/pandoc-pdf.css $1 -o $2 -s --pdf-engine=wkhtmltopdf --footer-center [page]

#pandoc --template=/home/alec/bin/inc/pandoc.html5 -t html5 -V margin-top=$MARGIN -V margin-left=$MARGIN -V margin-bottom=$MARGIN -V margin-right=$MARGIN -V papersize=letter --css ~/bin/inc/pandoc-pdf.css $1 -o $2 -s --pdf-engine=wkhtmltopdf
# pandoc templates live at:
# /usr/share/pandoc/data/templates
#pandoc --template=htmlpagenumbers -t html5 -V margin-top=$MARGIN -V margin-left=$MARGIN -V margin-bottom=$MARGIN -V margin-right=$MARGIN -V papersize=letter --css ~/bin/inc/pandoc-pdf.css $1 -o $2 -s --pdf-engine=wkhtmltopdf

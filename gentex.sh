#! /bin/bash
# generate pdf files from php files
# used for making code posters

[ "$#" = 1 ] || { echo Supply filetype as argument; return 9; }
codefiles=$(ls | grep ".$1" | sed "s|\.$1||g")
for file in $codefiles; do
  cp ~/bin/inc/template.tex $file.tex
  sed -i "s/filetype/$1/" $file.tex
  sed -i "s/example/$file.$1/" $file.tex
  pdflatex --shell-escape $file.tex
done
rm -rf _minted-$file *.tex *.aux *.log

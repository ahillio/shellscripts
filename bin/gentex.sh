#! /bin/bash
# generate pdf files from php files
# used for making code posters

[ "$#" = 1 ] || { echo Supply filetype as argument; return 9; }
codefiles=$(ls | grep ".$1" | sed "s|\.$1||g")
for file in $codefiles; do
  cp ~/bin/inc/template.tex $file.tex
  linelength=$(wc -L $file.$1 | grep -Po "\\d+")
  pagewidth=$(echo "$linelength * .34" | bc)
  sed -i "s/pagewidth/$pagewidth/" $file.tex
  sed -i "s/filetype/$1/" $file.tex
  sed -i "s/example/$file.$1/" $file.tex
  # if $1=='php' then set [firstline=2,firstnumber=1]
  pdflatex --shell-escape $file.tex
done
rm -rf _minted* *.tex *.aux *.log
# pdfcrop --margins '5 -18 5 5' --clip create_array.pdf create_array.pdf

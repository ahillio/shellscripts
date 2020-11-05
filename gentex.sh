#! /bin/bash
# generate pdf files from php files
# used for making code posters

[ "$#" = 1 ] || { echo Supply filetype as argument; return 9; }
codefiles=$(ls | grep ".$1" | sed "s|\.$1||g")
for file in $codefiles; do
  if [ -e $file.tex ]
  then
    echo "$file.tex exists already.  Now creating pdf file..."
    pdflatex --shell-escape $file.tex
  else
    cp ~/bin/inc/template.tex $file.tex
    sed -i "s/filetype/$1/" $file.tex
    sed -i "s/example/$file.$1/" $file.tex
    pdflatex --shell-escape $file.tex
  fi
  pdfcrop $file.pdf
  rm $file.pdf
  mv $file-crop.pdf $file.pdf
  rm $file.aux $file.log texput.log
  rm -rf _minted-$file
done

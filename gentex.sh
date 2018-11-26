#! /bin/bash
# generate pdf files from php files
# used for making code posters

phpfiles=$(ls | grep ".php" | sed 's|\.php||g')
for file in $phpfiles; do
  if [ -e $file.tex ]
  then
    echo "$file.tex exists already.  Now creating pdf file..."
    pdflatex --shell-escape $file.tex
  else
    cp template.tex $file.tex
    sed -i "s/example/$file/" $file.tex
    pdflatex --shell-escape $file.tex
  fi
  pdfcrop $file.pdf
  rm $file.pdf
  mv $file-crop.pdf $file.pdf
  rm $file.aux $file.log texput.log
  rm -rf _minted-$file
done

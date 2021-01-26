#! /bin/bash
# generate pdf files from php files
# used for making code posters

[ "$#" = 1 ] || { echo Supply filetype as argument; return 9; }
codefiles=$(ls | grep ".$1" | sed "s|\.$1||g")
rm *tex
for file in $codefiles; do
  if [ -e $file.tex ]
  then
    echo "$file.tex exists already.  Now creating pdf file..."
    latex --shell-escape $file.tex
    #pdflatex --shell-escape $file.tex
    #cat $file.tex | xargs -0 -t -I % /usr/local/lib/node_modules/mathjax-node-cli/bin/tex2svg '%' > $file.svg
  else
    cp ~/bin/inc/template.tex $file.tex
    sed -i "s/filetype/$1/" $file.tex
    sed -i "s/example/$file.$1/" $file.tex
    #latex --shell-escape $file.tex
    pdflatex --shell-escape $file.tex
    #cat $file.tex | xargs -0 -t -I % /usr/local/lib/node_modules/mathjax-node-cli/bin/tex2svg '%' > $file.svg
  fi
  #rm $file.pdf
  #mv $file-crop.pdf $file.pdf
  rm $file.aux $file.log texput.log
  rm -rf _minted-$file
  #mv $file.dvi $file.pdf
done

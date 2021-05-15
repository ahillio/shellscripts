#!/usr/bin/env bash

set -euo pipefail

# Create a temporary directory
curdir=$( pwd )
tmpdir=$( mktemp -dt "latex.XXXXXXXX" )

# Set up a trap to clean up and return back when the script ends
# for some reason
clean_up () {
    cd "$curdir"
    [ -d "$tmpdir" ] && rm -rf "$tmpdir"
    exit
}
trap 'clean_up' EXIT SIGHUP SIGINT SIGQUIT SIGTERM 

# Switch to the temp. directory and extract the .tex file
cd $tmpdir
# Quoting the 'THEEND' string prevents $-expansion.
cat > myfile.tex <<'THEEND'
\documentclass{article}
\begin{document}
Blah blah \(x^2 + 1\) or $x^2 + 1$.
\end{document}
THEEND

# If the file extracts succesfully, try to run pdflatex 3 times.
# If something fails, print a warning and exit
if [[ -f 'myfile.tex' ]]
then
   for i in {1..3}
   do
      if pdflatex myfile.tex
      then
         echo "Pdflatex run $i finished."
      else
         echo "Pdflatex run $i failed."
         exit 2
      fi
   done
else
   echo "Error extracting .tex file"
   exit 1
fi

# Copy the resulting .pdf file to original directory and exit
cp myfile.pdf $curdir
exit 0

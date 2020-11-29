#!/usr/bin/env bash

set -euo pipefail

### solutions here provided from my question at: ###
# https://stackoverflow.com/questions/65052880/how-to-loop-through-string-for-patterns-from-linux-shell/65052996

### Sweet One-liner ###
grep -rh -e '^:\S*:$' ~/Documents/wiki/diary/*.mkd | tr -s ':' '\n' | sort -u
# but why doesn't `sed` work in place of `tr`???
# grep -rh -e '^:\S*:$' ~/Documents/wiki/diary/*.mkd | sed 's|:|\r|g' | sort -u
# because you're using `\r` instead of `\n` -- this is sed, not vim :/
# use `\n` and sed will work

### Initial {broken} Script ###
# grep --color=always -rh -e '^:\S*:$' ~/Documents/wiki/*.mkd ~/Documents/wiki/diary/*.mkd | \
# sed -r 's|.*(:[Aa-Zz_]*:)|\1|g' | \
# sort -u
# printf '\nNote: this fails to display combined :tagOne:tagTwo:etcTag:\n'

### It Works! ###
# but what the hell is that regex in grep#2 ???
# it uses "positive lookbehind" and PCRE
# grep -rh -e '^:\S*:$' ~/Documents/wiki/*.mkd ~/Documents/wiki/diary/*.mkd | \
#   grep -Po "(?<=:)[^:]+:" | \
#   sed 's/://g' | \
#   sort -u | less

### Previously prefered solution, before sweet oneliner ###
#grep -rh -e '^:\S*:$' ~/Documents/wiki/diary/*.mkd \ |
## note: this is not looking through wiki, just diary...
#while read -r line
#do
#  for word in ${line//:/ }
#  do
#    printf "${word}\n"
#  done
#done | sort -u | less

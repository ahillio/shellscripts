#!/bin/bash

#while inotifywait -e modify -qq timewarrior-custom.py; do
#  timew custom test
while inotifywait -e modify -qq $1; do
  # zsh $1
  # something $1
  # or just the script itself with an argument:
  $1 $2
done

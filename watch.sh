#!/bin/bash

while inotifywait -e modify -qq $1; do
  #zsh $1
  $1
done

#! /bin/bash

name=$1
if [ -e $name ] ; then
  i=0
  while [ -e $name-$i ] ; do
    let i++
  done
  name=$name-$i
fi
touch "$name"
ls | grep $1


# name=$1
# if [ -e ../dir/$name ] ; then
#   i=0
#   while [ -e ../dir/$name-$i ] ; do
#     let i++
#   done
#   name=$name-$i
# fi
# touch ../dir/"$name"
# ls ../dir | grep $1

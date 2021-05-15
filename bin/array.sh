#!/bin/bash

my_array=(red orange green)
value='green'

for i in "${!my_array[@]}"; do
  if [[ "${my_array[$i]}" = "${value}" ]]; then
    echo "${i}";
  fi
done

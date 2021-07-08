#!/usr/bin/env bash

set -euo pipefail

#if [ $# -eq 0 ]; then
#  printf "  Name of script
#  Parameters required...
#  Provide info here\n"
#  exit 64
#fi

PS3='Please enter your choice: ' #PS3 variable automatically prints below the options
options=("Option 1" "Option 2" "Option 3" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Option 1")
            echo "you chose choice 1"
            ;;
        "Option 2")
            echo "you chose choice 2"
            ;;
        "Option 3")
            echo "you chose choice $REPLY which is $opt" #$REPLY automatically assigned
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done

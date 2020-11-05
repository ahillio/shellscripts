#!/usr/bin/python3

import os

directory = '/home/alec/Documents/wiki/diary/'
for filename in sorted(os.listdir(directory)):
  if filename.startswith("20") and filename.endswith(".mkd"): 
    with open(directory + filename) as file:
        copy = False
        struggle = ''
        date = file.readline()
        date = date.replace("\n", "")
        for line in file:
            if "## Struggles" in line:
                copy = True
                continue
            elif "## " in line:
                copy = False
                continue
            elif copy:
                if len(line.strip()) != 0 :
                    struggle += line
        if len(struggle) != 0:
            print(date)
            print(struggle)

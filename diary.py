#!/usr/bin/python3
# Section report
# @TODO print a little more content like line# section name along w/date

import os
import sys

sectionName = sys.argv[1]
sectionHeader = '## ' + sectionName
directory = '/home/alec/Documents/wiki/diary/'
for filename in sorted(os.listdir(directory)):
  if filename.startswith("20") and filename.endswith(".mkd"): 
    with open(directory + filename) as file:
        copy = False
        content = ''
        date = file.readline()
        date = date.replace("\n", "")
        for line in file:
            if sectionHeader in line:
                copy = True
                continue
            elif "## " in line:
                copy = False
                continue
            elif copy:
                if len(line.strip()) != 0 :
                    content += line
        if len(content) != 0:
            print(date)
            print(content)

#!/usr/bin/python3

import os
import re
import sys

tagname = ':' + sys.argv[1] + ':'
directory = '/home/alec/Documents/wiki/diary/'
for filename in sorted(os.listdir(directory)):
  if filename.startswith("20") and filename.endswith(".mkd"): 
    with open(directory + filename) as file:
        copy = False
        tagcontent = ''
        date = file.readline()
        date = date.replace("\n", "")
        lnum = 1
        # loop through file line by line
        for line in file:
            lnum += 1
            if tagname in line:
                tagline = line
                taglinenum = lnum
                copy = True
                continue
            # stop copying when reaching a new section header
            elif re.search(r'^##', line):
                copy = False
                continue
            # stop copying when reaching a line break
            elif re.search(r'^---', line):
                copy = False
                continue
            # stop copying when reaching a blank line
            elif re.search(r'^\s*$', line):
                copy = False
                continue
            # stop copying when reaching a new tag
            elif re.search(r'^:\w*:', line):
                copy = False
                continue
            # now add lines that follow tagname to the tagcontent variable
            elif copy:
                if len(line.strip()) != 0 :
                    tagcontent += line
        # if we have results, print them!
        if len(tagcontent) != 0:
            print(date + ' ' + tagline.rstrip() + ' line#' + str(taglinenum))
            print(tagcontent)

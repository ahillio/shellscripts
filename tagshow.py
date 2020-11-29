#!/usr/bin/python3

import os
import re
import sys

tagname = ':' + sys.argv[1] + ':'
directory = '/home/alec/Documents/wiki/diary/'
for filename in sorted(os.listdir(directory)):
  # @ASK so "filename" is a string.... does python turn all variables into objects?  It looks like there are basic sting "methods" available here: `.startswith()` and `.endswith()`...
  if filename.startswith("20") and filename.endswith(".mkd"): 
    with open(directory + filename) as file:
        copy = False
        tagcontent = ''
        date = file.readline()
        date = date.replace("\n", "")
        # loop through file line by line
        for line in file:
            # @TODO: when multiple occurences of tag exist in a file, like:
            #        :politics:culture:empathy:love:BoL:
            #        :BoL:
            #        they get lumped together and the former tagline gets overwritten by the latter tagline
            #        This issue and the ## SectionName TODO could be achieved through the same means, but giving a new date+stuff headding for each instance of a tag within a file
            #        How to loop through instances of a matched string?
            if tagname in line:
                tagline = line
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
            # stop copying when reaching a new tag
            elif re.search(r'^:\w*:', line):
                copy = False
                continue
            # now add lines that follow tagname to the tagcontent variable
            elif copy:
                if len(line.strip()) != 0 :
                    tagcontent += line
            # @TODO: `section = get the "### SectionName"` that contains the tag so it can be printed below
        # if we have results, print them!
        if len(tagcontent) != 0:
            print(date + ' ' + tagline.rstrip())
            #print(date)
            #print(tagline.rstrip())
            print(tagcontent)

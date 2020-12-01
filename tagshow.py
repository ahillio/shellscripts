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
            # keep track of what ##section we're in
            if re.search(r'^#{2,} \w{1,}', line):
                section = line.strip()
                section = re.sub('###', '##', section)
                section = re.sub(' ', '', section)
                continue
            if tagname in line:
                tagline = line
                taglinenum = lnum
                tagsection = section
                copy = True
                continue
            # stop copying when tag content is complete
            elif re.search('^##|^---|^\s*$|^:\w*:|^- TODO', line):
                copy = False
                continue
            # now add lines that follow tagname to the tagcontent variable
            elif copy:
                if len(line.strip()) != 0 :
                    tagcontent += line
        # if we have results, print them!
        if len(tagcontent) != 0:
            print(date + ' ' + tagsection + ' ' + tagline.rstrip() + ' line#' + str(taglinenum))
            print(tagcontent)

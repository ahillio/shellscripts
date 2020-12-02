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
            # find tag and start copying tag content
            if tagname in line:
                tagline = line
                taglinenum = lnum
                tagsection = section
                copy = True
                continue
            elif copy:
                # now add lines that follow tagname to the tagcontent variable
                if not re.search('^##|^---|^\s*$|^:\w*:|^- TODO', line):
                    tagcontent += line
                else:
                    # we've hit the end of that tag's content
                    # if we have results, print them!
                    print(date + ' ' + tagsection + ' ' + tagline.rstrip() + ' line#' + str(taglinenum))
                    print(tagcontent)
                    tagcontent=''
                    # resume loop process of looking for next tag
                    copy = False
                    continue

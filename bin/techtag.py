#!/usr/bin/python3
# tagshow.py -- a script to generate a report of tagged diary content
# invoke like `tagshow.py tagName`
# this script requires three of python's core modules
import os
import re
import sys
# tags in the diary are in format :tagName: and are the 1st argument passed to this script
tagname = ':' + sys.argv[1] + ':'
# this is where the diary files are stored
directory = '/home/alec/Documents/wiki/tech/diary/'
# loop through the contents of that directory
for filename in sorted(os.listdir(directory)):
  if filename.startswith("20") and filename.endswith(".mkd"):
    # open and read the file if it has .mkd extension
    with open(directory + filename) as file:
        # create a 'boolean' indicator to keep track of where we are in relation to tagged content
        copy = False
        # initialize empty string for later use
        tagcontent = ''
        # get the date from the first line of the file
        date = file.readline()
        # remove newline character
        date = date.replace("\n", "")
        # we have to manually count what line we're on, so create an integer variable to do that
        lnum = 1
        # loop through file line by line
        for line in file:
            lnum += 1# manually increment the line number
            # keep track of what ##section we're in
            # actually, tech diary doesn't have sections
            #if re.search(r'^#{2,} \w{1,}', line):
            #    section = line.strip()
            #    section = re.sub('###', '##', section)
            #    section = re.sub(' ', '', section)
            #    continue
            # find tag and start copying tag content
            if tagname in line:
                tagline = line
                taglinenum = lnum
                #tagsection = section
                copy = True
                continue
            elif copy:
                # if line does not match one of these patterns, proceed...
                # it breaks without `^\s*$`
                # apparently it doesn't break anymore when removing that...
                #if not re.search('^##|^---|^\s*$|^:\w*:|^- TODO', line):
                # @TODO add "end of file" to the logic here...
                if not re.search('^##|^---|^:\w*:|^- TODO', line):
                    # ...to add lines that follow tagname to the tagcontent variable
                    tagcontent += line
                else:
                    # double negative, if above `not re.search(...)` is false...
                    # that means we've hit the end of that tag's content
                    # and we should now print our results
                    print(date + ' ' + tagline.rstrip() + ' line#' + str(taglinenum))
                    print(tagcontent)
                    tagcontent=''
                    # resume loop process of looking for next tag
                    # we're no longer in a tag, so `copy` is no longer TRUE
                    copy = False
                    continue

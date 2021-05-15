#!/usr/bin/python
import datetime
import re
import sys

date = datetime.date.today()
# print date
taskID = sys.argv[1]
newline = "  * [ ] task #" + taskID + "\n"
diary = "/home/alec/Documents/wiki/diary/" + str(date) + ".mkd"
with open(diary, "r") as in_file:
    buf = in_file.readlines()

with open(diary, "w") as out_file:
    for line in buf:
        # if line == "- [ ] work\n":
        #if re.search(r'- \[.*\] work\n', line):
        if line == "**Work**\n":
            line = line + newline
        out_file.write(line)

#!/usr/bin/python
import sys
import datetime

date = datetime.date.today()
# print date
taskID = sys.argv[1]
newline = "* [ ] task #" + taskID + "\n"
diary = "/home/alec/Documents/wiki/diary/" + str(date) + ".mkd"
with open(diary, "r") as in_file:
    buf = in_file.readlines()

with open(diary, "w") as out_file:
    for line in buf:
        if line == "## Todo\n":
            line = line + newline
        out_file.write(line)

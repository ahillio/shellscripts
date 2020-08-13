#!/usr/bin/python
import sys
import datetime
from datetime import timedelta
from timewreport.parser import TimeWarriorParser #https://github.com/lauft/timew-report

parser = TimeWarriorParser(sys.stdin)

total = datetime.timedelta()
tags = ''
for interval in parser.get_intervals():
    tags = interval.get_tags()
    if 'invoiced' not in tags:
        date = interval.get_start()
        duration = interval.get_duration()
        # @TODO: delete "clients", "work", tags
        ant = interval.get_annotation()
        sep = ', '
        taglist = sep.join(tags)
        output = str(date.date()) + ' - ' + str(duration) + ' - ' + taglist
        if ant:
            output += ' ||| ' + str(ant)
        print(output)
        total = total + duration

#total = datetime.timedelta()
#print(total)
#for interval in parser.get_intervals():
#    duration = interval.get_duration()
#    print(duration)
#    total = total + duration

#print(total)
print('--------')

# We calculate the time out like this manually because we don't want numbers of hours greater than 24 to be presented as days
total_secs = int(total.total_seconds())
secs = total_secs % 60
mins = (total_secs // 60) % 60
hours = (total_secs // 3600)

# for new versions of python 3.6 and up
# print(f"{hours}:{mins:02}:{secs:02}")
print("{hours}:{mins:02}:{secs:02}".format(hours=hours, mins=mins, secs=secs))

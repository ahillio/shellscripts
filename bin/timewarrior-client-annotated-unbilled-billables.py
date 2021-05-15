#!/usr/bin/python
from __future__ import division #needed for the last division but not the previous divisions - wtf?
import sys
import datetime
from datetime import timedelta
from timewreport.parser import TimeWarriorParser #https://github.com/lauft/timew-report

parser = TimeWarriorParser(sys.stdin)

total = datetime.timedelta()
tags = ''
for interval in parser.get_intervals():
    tags = interval.get_tags()
    # this report shows only un-invoiced time, so we ignore "invoiced" time entries  
    if 'invoiced' not in tags:
        if 'unbillable' not in tags:
            if 'nonbillable' not in tags:
                # hide 'client' and 'work' tags since they clutter this report
                if 'clients' in tags:
                    tags.remove('clients')
                if 'work' in tags:
                    tags.remove('work')
                sep = ', '
                taglist = sep.join(tags)
                date = interval.get_start()
                duration = interval.get_duration()
                output = str(date.date()) + ' - ' + str(duration) + ' - ' + taglist
                ant = interval.get_annotation()
                if ant:
                    output += ' ||| ' + str(ant)
                # print individual time entry
                print(output)
                # add individual time to total time
                total = total + duration

print('----------------')

# We calculate the time out like this manually because we don't want numbers of hours greater than 24 to be presented as days
total_secs = int(total.total_seconds())
secs = total_secs % 60
mins = (total_secs // 60) % 60
hours = (total_secs // 3600)
# for new versions of python 3.6 and up the following could work
# print(f"{hours}:{mins:02}:{secs:02}")
# but for older python this works...
print("total = {hours}:{mins:02}:{secs:02}".format(hours=hours, mins=mins, secs=secs))
decimal = mins / 60
time = hours + decimal
print("for billing: {time}".format(time=time))

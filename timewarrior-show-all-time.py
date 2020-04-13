#!/usr/bin/python
import sys
#import datetime
from timewreport.parser import TimeWarriorParser

parser = TimeWarriorParser(sys.stdin)

totals = dict()

for interval in parser.get_intervals():
    tracked = interval.get_duration()
    
    for tag in interval.get_tags():
        if tag in totals:
            totals[tag] += tracked
        else:
            totals[tag] = tracked

# Determine largest tag width.
max_width = len('Total')

for tag in totals:
    if len(tag) > max_width:
        max_width = len(tag)

# Compose report header.
print('Total by Tag')
print('')

# Compose table header.
print('{:{width}} {:>10}'.format('Tag', 'Total', width=max_width))
print('{} {}'.format('-' * max_width, '----------'))

# Compose table rows.
grand_total = 0
for tag in sorted(totals):
    formatted = totals[tag]
    grand_total += totals[tag].seconds
    print('{:{width}} {:10}'.format(tag, formatted, width=max_width))

## Compose total.
#print('{} {}'.format(' ' * max_width, '----------'))
#grand_total = datetime.timedelta(seconds=grand_total)
#print('{:{width}} {:10}'.format('Total', grand_total, width=max_width))


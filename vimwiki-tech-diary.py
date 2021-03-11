#!/usr/bin/python3
#import os
#import sys
from datetime import datetime, timedelta

# Date
date = datetime.strftime(datetime.now(), "%A %d %B %Y")
uline = '--'
length = len(date)
i = 0
while i < length:
    uline += '-'
    i += 1

template = """# {date}
{uline}
"""

print(template.format(uline=uline, date=date))

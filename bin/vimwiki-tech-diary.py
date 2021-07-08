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
[learnCode Pedagogy PoC](../education/pedagogy-proof-of-concept)
[Documentation](../Documentation-Index.mkd)
[Blog Content](../web-content-planning.mkd)
[CS Education](../education/computer-programming-education-pitch.mkd)



---
linebreak needed for `techtag.py` to work `¯\_(ツ)_/¯`"""

print(template.format(uline=uline, date=date))

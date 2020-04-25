#!/usr/bin/python
import sys
import datetime

# note VimwikiDiaryGenerateLinks uses this particular title format to generate date-based links
template = """# {date}
{uline}


## Dreams & Feelings


## Daily checklist

- [ ] wake up
- [ ] make bed
- [ ] prayers - get outdoors and talk to those who can hear and understand
- [ ] make breakfast
- [ ] eat and enjoy

- [ ] do Work

- [ ] deeply relax at some point

- [ ] make a bead
- [ ] journal (using vimwiki diary)

## Todo

---

## Reflections

### Accomplishments

### Gratitudes

### Forgiveness

"""

date = (datetime.date.today() if len(sys.argv) < 2
        # Expecting filename in YYYY-MM-DD.foo format
        else sys.argv[1].rsplit(".", 1)[0])
date = date.strftime("%A %d %B %Y")
uline = '--'
length = len(date)
i = 0
while i < length:
    uline += '-'
    i += 1
print(template.format(uline=uline, date=date))

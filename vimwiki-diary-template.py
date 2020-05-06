#!/usr/bin/python
import sys
import datetime

# note VimwikiDiaryGenerateLinks uses this particular title format to generate date-based links
# @TODO: take yesterday's #Tomorrow section and add it here somewhere.
template = """# {date}
{uline}


## Dreams & Feelings


## Daily checklist
- [ ] get up | 
- [ ] make bed
- [ ] Yoga
- [ ] [Daily Prayer <3](../Daily Prayer <3.mkd)
- [ ] meditate
- [ ] feeding prayers - get outdoors to talk and sing to spirit
- [ ] outdoors chore? (water turkey wing) gardening?
- [ ] make breakfast
- [ ] eat and enjoy

- [ ] do Work

- [ ] body self care
- [ ] deeply relax (other than meditation)

- [ ] make a bead
- [ ] journal
- [ ] go to bed on time | 

## Todo

---

## Reflections

### Accomplishments

### Gratitudes

### Forgiveness

## Tomorrow
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

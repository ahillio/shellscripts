#!/usr/bin/python
import sys
import datetime

template = """# {date}

## Daily checklist

- [ ] wake up
- [ ] make bed
- [ ] make breakfast
- [ ] prayer
- [ ] eat and enjoy

- [ ] do Work

- [ ] deeply relax at some point

- [ ] make a bead
- [ ] journal (using vimwiki diary)

## Todo

---

## Notes

### Accomplishments

### Gratitudes

### Forgiveness

"""

date = (datetime.date.today() if len(sys.argv) < 2
        # Expecting filename in YYYY-MM-DD.foo format
        else sys.argv[1].rsplit(".", 1)[0])
date = date.strftime("%A %d %B %Y")
print(template.format(date=date))

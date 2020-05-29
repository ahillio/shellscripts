#!/usr/bin/python3
import sys
from datetime import datetime, timedelta
from tasklib import TaskWarrior
tw = TaskWarrior('/home/alec/.task')
tasksDue = tw.tasks.filter('due:today')
todaysTasks = ''
for task in tasksDue:
    todaysTasks += '* [ ] ' + task['description'] + '  #' + task['uuid'][:8] + '\n'

# note VimwikiDiaryGenerateLinks uses this particular title format to generate date-based links
template = """# {date}
{uline}


## Dreams & Feelings


## Daily checklist
- [ ] get up | 
- [ ] make bed
- [ ] Yoga
- [ ] [Daily Prayer <3](../Daily Prayer <3.mkd)
- [ ] feeding prayers - get outdoors to talk and sing to spirit
- [ ] GARDEN CHORES!
- [ ] make breakfast
- [ ] eat and enjoy

- [ ] do Work

- [ ] meditate
- [ ] body self care
- [ ] deeply relax (other than meditation)

- [ ] make a bead
- [ ] journal
- [ ] go to bed on time | 

## Todo
{yesNotes}
{todaysTasks}

## Chores

---

## Reflections

### Accomplishments

### Gratitudes

### Forgiveness

## Tomorrow
"""

date = datetime.strftime(datetime.now(), "%A %d %B %Y")
uline = '--'
length = len(date)
i = 0
while i < length:
    uline += '-'
    i += 1

yesNotes = ''
yesJournal = '/home/alec/Documents/wiki/diary/' + datetime.strftime(datetime.now() - timedelta(1), '%Y-%m-%d') + '.mkd'
with open (yesJournal, "r") as f:
    for line in f:
        if "## Tomorrow" in line:
            for line in f:
                yesNotes = yesNotes + line

print(template.format(uline=uline, date=date, todaysTasks=todaysTasks, yesNotes=yesNotes))

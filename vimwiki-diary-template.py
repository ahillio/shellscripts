#!/usr/bin/python3
import sys
import subprocess
from datetime import datetime, timedelta
from tasklib import TaskWarrior

# Date
date = datetime.strftime(datetime.now(), "%A %d %B %Y")
uline = '--'
length = len(date)
i = 0
while i < length:
    uline += '-'
    i += 1


# Today's calendar items
# @TODO: does `calEvents = ''` need to be there?
calEvents = ''
calEvents = subprocess.run("khal list today 1d | tail -n +2", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
# @TODO: 
# 01:00 PM-03:00 PM hang with Aliona :: email from JJJ, tuning forks?
# in events fromatted like that, change `::` to other string, perhpas `|` or `—` since vimwiki detects it as a tag.


# Tasks
tw = TaskWarrior('/home/alec/.task')
tasksDue = tw.tasks.filter(status='pending', due__before='tomorrow')
todaysTasks = ''
for task in tasksDue:
    todaysTasks += '  * [ ] ' + task['description'] + '  #' + task['uuid'][:8] + '\n'
# @TODO: exclude work tasks on weekends :)
# 1. get tags
# 2. test `datetime.datetime.today().weekday() < 5` (days of week represented as 0-6 integers, so 5 is saturday)
# 3. exclude tasks with `work` tag


# Notes from yesterday's diary
yesNotes = ''
yesJournal = '/home/alec/Documents/wiki/diary/' + datetime.strftime(datetime.now() - timedelta(1), '%Y-%m-%d') + '.mkd'
# @TODO: will fail if yesterday's journal doesn't exist
with open (yesJournal, "r") as f:
    for line in f:
        if "## Tomorrow" in line:
            for line in f:
                line = '  ' + line
                yesNotes = yesNotes + line

# BEGIN TEMPLATE
# note VimwikiDiaryGenerateLinks uses this particular title format to generate date-based links
# so `# {date}` must be the exact title
template = """# {date}
{uline}
[Journal entry template](../../../bin/vimwiki-diary-template.py)

## Dreams, Waking, Morning

## Daily checklist
- [ ] get up | 
- [ ] make bed
- [ ] yoga
- [ ] find solace in nature

- [ ] work
{yesNotes}{calEvents}{todaysTasks}
- [ ] meditate
- [ ] deep relaxtion/nourishment
- [ ] body self care

- [ ] prep tomorrows food&tea
- [ ] go to bed on time | 

## Prayers
- [ ] shellbeads
[Prayer <3](../prayer.mkd)

## Chores
- garden
- cleaning

---

## Reflections

### Struggles

### Accomplishments

### Gratitudes

### Forgiveness

## Tomorrow"""

print(template.format(uline=uline, date=date, todaysTasks=todaysTasks, yesNotes=yesNotes, calEvents=calEvents.stdout))

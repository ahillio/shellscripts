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

## Dreams & Waking

## Daily checklist
- [ ] get up | 
- [ ] make bed
- [ ] yoga
- [ ] find solace in nature
- [ ] [Prayer <3](../prayer.mkd)

- [ ] work
{yesNotes}{calEvents}{todaysTasks}
- [ ] meditate in prayer

- [ ] body self care
- [ ] water the garden

- [ ] deeply relax (other than meditation)
- [ ] prep tomorrows food&tea
- [ ] [meditate in prayer <3](../prayer.mkd)
- [ ] go to bed on time | 

## Chores

---

## Reflections

### Struggles

### Accomplishments

### Gratitudes

### Forgiveness

## Tomorrow"""

# @TODO: logic to only include yesNotes/calEvents/todaysTasks if they have values
# make them all a single variable to include as {work}
print(template.format(uline=uline, date=date, todaysTasks=todaysTasks, yesNotes=yesNotes, calEvents=calEvents.stdout))

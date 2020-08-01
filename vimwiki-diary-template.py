#!/usr/bin/python3
import sys
import subprocess
from datetime import datetime, timedelta
from tasklib import TaskWarrior
tw = TaskWarrior('/home/alec/.task')
tasksDue = tw.tasks.filter(status='pending', due__before='tomorrow')
todaysTasks = ''
for task in tasksDue:
    todaysTasks += '  * [ ] ' + task['description'] + '  #' + task['uuid'][:8] + '\n'
# @TODO: exclude work tasks on weekends :)
calEvents = subprocess.run("khal list today 1d | tail -n +2", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)

# note VimwikiDiaryGenerateLinks uses this particular title format to generate date-based links
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

date = datetime.strftime(datetime.now(), "%A %d %B %Y")
uline = '--'
length = len(date)
i = 0
while i < length:
    uline += '-'
    i += 1

yesNotes = ''
yesJournal = '/home/alec/Documents/wiki/diary/' + datetime.strftime(datetime.now() - timedelta(1), '%Y-%m-%d') + '.mkd'
# @TODO: will fail if yesterday's journal doesn't exist
with open (yesJournal, "r") as f:
    for line in f:
        if "## Tomorrow" in line:
            for line in f:
                line = '  ' + line
                yesNotes = yesNotes + line

print(template.format(uline=uline, date=date, todaysTasks=todaysTasks, yesNotes=yesNotes, calEvents=calEvents.stdout))

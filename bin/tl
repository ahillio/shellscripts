#!/bin/bash
#@TODO if we're doing scripting with zsh completions (easier than bash?) then we need to use /bin/zsh instead... I think... but is that so?  Maybe since the shell (environment) and not the script itself is what matters...?


if [ $# -eq 0 ]; then
  task
elif [ $# -eq 1 ]; then
  # test if project named $1 exists, if so use `task list project:`
  task list project:"$1"
  # if no project named $1 exists use `task list tag:`
elif [ $# -eq 2 ]; then
  task list tag:"$2"
fi

# @TODO: make the above into a real progam
: <<'CMNT'
PROJECTS=$(grep -o 'project:".*" ' .task/pending.data | sed 's/^.*"\(.*\)" status.*$/\1/' | sort -u)
echo $PROJECTS

Plan:
=====

1. create array of project names
2. enable those to be used in tab-completion of parameters
3. do stuff for tags
4. maybe tags don't r

For shell completion refer to:
- https://mads-hartmann.com/2017/08/06/writing-zsh-completion-scripts.html
- https://github.com/zsh-users/zsh-completions/blob/master/zsh-completions-howto.org
- https://askubuntu.com/a/854365/693219 mentions `complete` command that looks easier though crude (relying on adding code to shell rc file)


Misc
====

- check current directory for .taskrc before loading it from $HOME
  if [ `pwd` != $HOME -a -e ".taskrc" ]
  then
   task rc:.taskrc $@
  else
   task $@
  fi
- put that into a `t` function, the master wrapper.
CMNT

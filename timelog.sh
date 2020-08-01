#!/usr/bin/env bash

timew export $1 $2 |

#jq 'def duration($finish; $start):
#jq --arg client $1 'def duration($finish; $start):
jq -r --arg client $1 'def duration($finish; $start):
  def twodigits: "00" + tostring | .[-2:];
  [$finish, $start]
  | map(strptime("%Y%m%dT%H%M%SZ") | mktime) # seconds
  | .[0] - .[1]
  | (. % 60 | twodigits) as $s
  | (((. / 60) % 60) | twodigits)  as $m
  | (./3600 | floor) as $h
  | "\($h):\($m):\($s)" ;

map( {time: duration(.end;.start)} + del(.end)) |

.[] | del(.tags[] | select(. == ($client, "clients", "work"))) | [.start, .time, (.tags | join(", ")),  .annotation // empty] | @tsv' |
#.[] | del(.tags[] | select(. == ($client, "clients", "work"))) | [.start, .time, (.tags | join(", ")),  .annotation // empty]' |

#sed 's|"||g' |
sed -r 's|^([0-9]{4})([0-9]{2})([0-9]{2})T.*Z|\1-\2-\3|g'

#map( {time: duration(.end;.start)} + del(.start,.end) )'

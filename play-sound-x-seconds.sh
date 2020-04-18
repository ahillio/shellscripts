#!/usr/bin/env bash

progname=$(basename ${0})
command=${1}
default_seconds="60"
default_filepath="${HOME}/attention.wav"

usage() {
  echo "
Usage: attention.sh start [seconds] [file]
       attention.sh stop [file]
Simple bash script to play a file every X seconds.
The 'stop' command is simply a convenience function if the script was
put in a background job, eg. '${progname} start &'.
  seconds: Optional, play file every N seconds, defaults to ${default_seconds}.
           Can also be set via the ATTENTION_SECONDS environment variable.
  file:    Optional, file to play, defaults to ${default_filepath} for the
           start action, and no file for the stop action.
           For the start action, can also be set via the ATTENTION_FILEPATH
           environment variable.
CAVEATS:
The sox 'play' binary must be installed and in your PATH, it will play the
sound through the default audio device.
For PulseAudio users, it is recommended to install the 'libsox-fmt-pulse'
package as well, to prevent issues with sox/PulseAudio integration.
"
}

if [ "$(which play)" = "" ]; then
  echo "ERROR: no 'play' binary found"
  echo
  usage
  exit 1
fi

if [ $# -lt 1 ]; then
  usage
  exit 1
fi

if [ "${command}" = "start" ]; then
  if [ $# -gt 3 ]; then
    usage
    exit 1
  fi

  if [ -n "${2}" ]; then
    seconds="${2}"
  else
    seconds="${ATTENTION_SECONDS:-${default_seconds}}"
  fi

  if [ -n "${3}" ]; then
    filepath="${3}"
  else
    filepath="${ATTENTION_FILEPATH:-${default_filepath}}"
  fi
elif [ "${command}" = "stop" ]; then
  if [ $# -gt 2 ]; then
    usage
    exit 1
  fi

  if [ -n "${2}" ]; then
    filepath="${2}"
  fi
fi

log() {
  message="${1}"
  echo "${message}"
  logger "${message}"
}

start() {
  log "Playing ${filepath} every ${seconds} seconds"
  while true; do
    sleep ${seconds}
    play -q ${filepath} 2> /dev/null
  done
}

stop() {
  log "Stopping ${progname}"
  if [ -n "${filepath}" ]; then
    play -q "${filepath}" &
  fi
  pkill -f -9 ${progname}
}

case ${command} in
  start)
    start
    ;;
  stop)
    stop
    ;;
  *)
    usage
    exit 1
    ;;
esac

#!/bin/sh
curday=`date +%Y-%m-%d\ %H:%M:%S`
if ping -q -c 1 -W 1 223.5.5.5 >/dev/null; then
  echo "${curday} Internet connection is up"
else
  echo "${curday} Internet connection is down, attempting to login"
  # ./login.sh
fi

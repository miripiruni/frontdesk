#!/bin/bash

# The simple status code checker based on https://github.com/csheahan/check404/
#
# Simple bash script to print out the status codes of every link in an html
# file. Useful as a sanity checker for link 404s or other status errors on
# personal websites. A short list of status codes is below:
#
#   2xx - Link is good.
#   301 - Permanent move. Could be a permanent http -> https upgrade.
#   4xx - Error. Common one is 404, which is a page not found.
#   5xx - Server Errors. One retry needed
#
# Disclaimer: uses a regex for parsing for hrefs, so not guaranteed
# to work, as it's tailored towards my personal formatting.

# COLORS
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NOCOLOR='\033[0m'

# Make sure there is the correct amount of args
if [[ $# -lt 1 ]]
then
  echo "Usage: $0 FILENAME"
  exit 1
fi

FILENAME=$1

# Technically shouldn't do this, but works
regex="\((https?[^\)]*)\)"

cat $FILENAME | while read LINE
do
  if [[ $LINE =~ $regex ]]
  then
    i=1
    n=${#BASH_REMATCH[*]}
    while [[ $i -lt $n ]]
    do
      match=${BASH_REMATCH[$i]}
      statuscode=$(curl -o /dev/null --silent --head \
                   --write-out '%{http_code}\n' $match)

      # Good 2xx
      if [[ $statuscode -ge 200 && $statuscode -lt 300 ]]
      then
        echo -e "${GREEN}$statuscode${NOCOLOR}: $match"
      # Bad 4xx
      elif [[ $statuscode -ge 400 && $statuscode -lt 500 ]]
      then
        echo -e "${RED}$statuscode${NOCOLOR}: $match"
      # Unknown
      else
        echo -e "${YELLOW}$statuscode${NOCOLOR}: $match"
      fi

      let i++
    done
  fi
done

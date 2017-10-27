#!/usr/bin/env bash

set -exuo pipefail

[[ -n "$NOW_TOKEN" ]] || {
  echo "missing BROWSER variable"
  exit 1
}

hash now 2>/dev/null || {
  echo "\"now\" is not found. Let install it ;)"

  npm i -g now
}

#

latest_server() {
  {
    now -t $NOW_TOKEN ls @onedoes/snapdrop-server \
    | awk '{print $1}' \
    | grep onedoessnapdrop-server

  } || {
    echo "Can't find any server :("
    exit 1
  }
}

do_sync() {
  echo

  local endpoint=()
  endpoint=($(latest_server))

  file_to_sync=./packages/pwa/app/scripts/app.js

  sed -i -e "s/onedoessnapdrop-server-.*.now.sh/$endpoint/g" $file_to_sync

  git add $file_to_sync

  echo
}

do_reset() {
  echo "resest"
  unset -f do_sync do_reset
}

trap do_reset INT TERM EXIT
do_sync
do_reset
trap - INT TERM EXIT


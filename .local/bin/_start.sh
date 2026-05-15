#! /usr/bin/bash
cd "$HOME" && ./v2rayN-linux-64/v2rayN &
sleep 10
syncthing >/dev/null &
# kitty --hold sh -c "$HOME/coding/sh/backup.sh"

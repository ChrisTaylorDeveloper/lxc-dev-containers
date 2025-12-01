#!/bin/bash

if [ -z "$1" ]; then
  echo "Error: No argument supplied."
  echo "Usage: $0 <container name>"
  exit 1
fi

lxc ls | grep "\<$1\>" 1>/dev/null
grep_status=$?

if [ $grep_status -eq 0 ]; then
  echo "A container $1 already exists. Removing it first."
  lxc rm --force "$1"
fi

lxc launch ubuntu:24.04 "$1"

lxc config set "$1" boot.autostart false

lxc exec "$1" -- /bin/bash -c '
  adduser --disabled-password --gecos "" sammy
  usermod -aG sudo sammy
  echo "sammy:sam" | chpasswd
'

# Now do a manual install of nix package manager.
# 1. lxc exec the_container -- su sammy
# 2. Run the multi-user install command from https://nixos.org/download/#download-nix
# Snapshot this point.
# TODO: non-interactive install of Nix package manager.

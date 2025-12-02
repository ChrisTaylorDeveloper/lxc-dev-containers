#!/bin/bash

# Ensure a container name is provided.
if [ -z "$1" ]; then
  echo "Error: No argument supplied."
  echo "Usage: $0 <container name>"
  exit 1
fi

# Check if a container with this name already exists.
lxc ls | grep "\<$1\>" 1>/dev/null
grep_status=$?
if [ $grep_status -eq 0 ]; then
  echo "A container $1 already exists. Removing it first."
  lxc rm --force "$1"
fi

lxc launch ubuntu:24.04 "$1"

# Do not start the container just because the host has started!
lxc config set "$1" boot.autostart false

lxc exec "$1" -- mkdir --parents /home/ubuntu/.config/nvim
echo Sleeping ...
sleep 4
lxc exec "$1" -- git clone https://github.com/ChrisTaylorDeveloper/LazyVim.git /home/ubuntu/.config/nvim
lxc exec "$1" -- chown -R ubuntu:ubuntu /home/ubuntu/

# Now, manually install nix package manager.
# 1. lxc exec the_container -- su ubuntu
# 2. Run multi-user install command on https://nixos.org/download/#download-nix
# Snapshot this point.
# TODO: non-interactive install of Nix package manager.

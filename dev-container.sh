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

sleep 4
lxc exec "$1" -- wget -O /usr/local/bin/nvim https://github.com/neovim/neovim/releases/download/v0.11.5/nvim-linux-x86_64.appimage
lxc exec "$1" -- chmod 755 /usr/local/bin/nvim

# chmod u+x nvim-linux-x86_64.appimage
# ./nvim-linux-x86_64.appimage

# Need to add these:
# sudo apt-get install unzip
# set -o vi
# set correct git author name and email in /home/ubuntu/.gitconfig
# install neovim
# set git editor to nvim
# git config --global core.editor "vim"

lxc exec "$1" -- mkdir --parents /home/ubuntu/.config/nvim
sleep 4
lxc exec "$1" -- git clone https://github.com/ChrisTaylorDeveloper/LazyVim.git /home/ubuntu/.config/nvim
lxc exec "$1" -- chown -R ubuntu:ubuntu /home/ubuntu/

# Now, manually install nix package manager.
# 1. lxc exec the_container -- su ubuntu
# 2. Run multi-user install command on https://nixos.org/download/#download-nix
# Snapshot this point.
# TODO: non-interactive install of Nix package manager.

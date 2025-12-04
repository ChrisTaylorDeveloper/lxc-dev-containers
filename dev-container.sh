#!/bin/bash

# Usage
if [ -z "$1" ]; then
  echo "Error: No argument supplied."
  echo "Usage: $0 <container name>"
  exit 1
fi

# Check if container already exists
lxc ls | grep "\<$1\>" 1>/dev/null
grep_status=$?
if [ $grep_status -eq 0 ]; then
  echo "Container $1 already exists. Removing it first."
  lxc rm --force "$1"
fi

# Launch container for 1st time
lxc launch ubuntu:24.04 "$1"
# Do not start container next time host starts
lxc config set "$1" boot.autostart false

sleep 3
lxc exec "$1" --user 1000 -- sudo apt update

# Create a public key
lxc exec "$1" --user 1000 -- sh -c 'ssh-keygen -N "" -f /home/ubuntu/.ssh/id_ed25519'

# Install miscellaneous tools
lxc exec "$1" --user 1000 -- sudo apt -y install unzip
lxc exec "$1" --user 1000 -- sudo apt -y install build-essential

# Install Neovim appimage
sleep 3
lxc exec "$1" --user 1000 -- sudo wget -O /usr/local/bin/nvim https://github.com/neovim/neovim/releases/download/v0.11.5/nvim-linux-x86_64.appimage
lxc exec "$1" --user 1000 -- sudo chmod 755 /usr/local/bin/nvim

# Install my own LazyVim config
sleep 3
lxc exec "$1" --user 1000 -- mkdir --parents /home/ubuntu/.config/nvim
lxc exec "$1" --user 1000 -- git clone https://github.com/ChrisTaylorDeveloper/LazyVim.git /home/ubuntu/.config/nvim

# Install Java
lxc exec "$1" --user 1000 -- sudo apt -y install default-jre
lxc exec "$1" --user 1000 -- sudo apt -y install default-jdk

# TODO: Add these:
# set -o vi
# set correct git author name and email in /home/ubuntu/.gitconfig
# git config --global core.editor "vim"

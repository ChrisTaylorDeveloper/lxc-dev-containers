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
  echo "Container $1 already exists. Removing it first."
  lxc rm --force "$1"
fi

# Launch container for first time
lxc launch ubuntu:24.04 "$1"

# Do not start container when host starts.
lxc config set "$1" boot.autostart false

sleep 3
lxc exec "$1" --user 1000 -- sudo apt update

# Create a public key
lxc exec "$1" --user 1000 -- sh -c 'ssh-keygen -N "" -f /home/ubuntu/.ssh/id_ed25519'

# Install Chrome, so we can use it headless
lxc exec "$1" --user 1000 -- sudo wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
lxc exec "$1" --user 1000 -- sudo apt -y install ./google-chrome-stable_current_amd64.deb

# Install Neovim
sleep 3
lxc exec "$1" --user 1000 -- sudo wget -O /usr/local/bin/nvim https://github.com/neovim/neovim/releases/download/v0.11.5/nvim-linux-x86_64.appimage
lxc exec "$1" --user 1000 -- sudo chmod 755 /usr/local/bin/nvim

# Install my LazyVim config
sleep 3
lxc exec "$1" --user 1000 -- mkdir --parents /home/ubuntu/.config/nvim
lxc exec "$1" --user 1000 -- git clone https://github.com/ChrisTaylorDeveloper/LazyVim.git /home/ubuntu/.config/nvim

# Install miscellaneous tools
lxc exec "$1" --user 1000 -- sudo apt -y install unzip

# Install Java
lxc exec "$1" --user 1000 -- sudo apt -y install default-jre
lxc exec "$1" --user 1000 -- sudo apt -y install default-jdk

# TODO: Add these:
# set -o vi
# set correct git author name and email in /home/ubuntu/.gitconfig
# git config --global core.editor "vim"

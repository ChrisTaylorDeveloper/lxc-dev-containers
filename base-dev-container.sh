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

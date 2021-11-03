#!/bin/bash

# This script updates the file /etc/skel/.bashrc to include conda and mamba.

# It is idempotent.

# To do this, it creates a temporary user, runs the init commands, and copies
# the resulting changes to .bashrc back to /etc/skel.

# Strict mode
set -euo pipefail

tempuser=tempuser123
adduser --disabled-password --gecos "" $tempuser
sudo -u $tempuser conda init
sudo -u $tempuser mamba init
chown root:root /home/$tempuser/.bashrc
chmod 644 /home/$tempuser/.bashrc
mv /home/$tempuser/.bashrc /etc/skel/
deluser --remove-home $tempuser
unset tempuser

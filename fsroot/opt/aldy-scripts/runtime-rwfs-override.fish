#!/usr/bin/env fish

# Copy over customized files from /usr/share/factory/
# Ensures that state of modified files is restored on startup
# Needs to be ran as root

cp -r /usr/share/factory/var/ /var/
cp -r /usr/share/factory/etc/ /etc/

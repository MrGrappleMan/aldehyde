#!/usr/bin/env fish

# User perms
usermod -aG video,render boinc
usermod -aG boinc root
usermod --add-subuids 100000-165535 --add-subgids 100000-165535 boinc

# SELinux
setsebool -P container_use_devices true

# LoginCtl
loginctl enable-linger boinc

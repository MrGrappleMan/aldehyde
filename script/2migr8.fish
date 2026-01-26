#!/usr/bin/env fish

# FS Perms
echo --- Setup permissions ---
chmod a+x /opt/Fyn-scripts
chown -R boinc:boinc /var/lib/boinc/
chmod -R 755 /var/lib/boinc/
chmod 600 /var/lib/boinc/gui_rpc_auth.cfg

# User perms
usermod -aG video,render boinc
usermod -aG boinc root
usermod --add-subuids 100000-165535 --add-subgids 100000-165535 boinc

# SELinux
setsebool -P container_use_devices true

# LoginCtl
loginctl enable-linger boinc

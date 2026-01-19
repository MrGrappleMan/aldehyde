#!/usr/bin/env fish

clear

# FS Perms
echo __Setup permissions__
chmod a+x /opt/Fyn-scripts
mkdir -p /etc/playit
mkdir -p /opt/playit
chmod a+x /opt/playit/playit
chmod a+x /opt/mc-server/mc-server
chown -R boinc:boinc /var/lib/boinc/
chmod -R 755 /var/lib/boinc/
chmod 600 /var/lib/boinc/gui_rpc_auth.cfg
echo

# User perms
usermod -aG video,render boinc
usermod -aG boinc root
usermod --add-subuids 100000-165535 --add-subgids 100000-165535 boinc

# SELinux
setsebool -P container_use_devices true

# LoginCtl
loginctl enable-linger boinc

# Subexecution of sub-scripts that dont require user interaction. ujust has some user specifics - may cause issues on root
echo Now executing subscripts

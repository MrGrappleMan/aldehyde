#!/usr/bin/env fish

clear

echo === === Filesystem setup === ===

# FS Copy over
echo Copying over...
cp -r /ctx/fsroot/etc/* /etc/
cp -r /ctx/fsroot/var/* /var/
cp -r /ctx/fsroot/opt/* /opt/
echo

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

fish /opt/Fyn-scripts/sysfresh.fish
fish /tmp/Fynelium-LX/script/Automated/bootc.fish
fish /tmp/Fynelium-LX/script/Automated/rpm-ostree.fish
fish /tmp/Fynelium-LX/script/Automated/flatpak.fish
fish /tmp/Fynelium-LX/script/Automated/systemd.fish
fish /tmp/Fynelium-LX/script/Automated/fwupdmgr.fish
fish /tmp/Fynelium-LX/script/Automated/dconf.fish
fish /tmp/Fynelium-LX/script/Automated/ujust.fish

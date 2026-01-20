#!/bin/bash

# === === /ctx/fsroot/ filesystem === ===
echo ---Copying over filesystem components---

cp -r /ctx/fsroot/etc/* /etc/
cp -r /ctx/fsroot/usr/* /usr/
cp -r /ctx/fsroot/var/* /var/
cp -r /ctx/fsroot/opt/* /opt/

# === === /ctx/script/ subscripts === ===
echo ---Running subscripts---

fish /ctx/script/bootc.fish
fish /ctx/script/dnf5.fish
fish /ctx/script/flatpak.fish
fish /ctx/script/systemd.fish
fish /ctx/script/fwupdmgr.fish
#fish /ctx/script/dconf.fish
#fish /ctx/script/ujust.fish

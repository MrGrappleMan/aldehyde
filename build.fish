#!/bin/fish
echo "⚠️ --- Run 'build.fish' ---"

echo "Quick reminder!"
echo "Search for this character '⚠️' to look for messages provided by Aldehyde's scripts"

# === === /ctx/fsroot/ filesystem === ===
echo "⚠️ --- Copy over filesystem components ---"

cp -r /ctx/fsroot/etc/* /etc/
cp -r /ctx/fsroot/usr/* /usr/
cp -r /ctx/fsroot/var/* /var/
cp -r /ctx/fsroot/opt/* /opt/


# === Install fish ===
echo "⚠️ --- Install fish ---"

dnf5 install fish -y


# === === /ctx/script/ subscripts === ===
echo "⚠️ --- Run subscripts ---"

fish /ctx/script/dnf5.fish
fish /ctx/script/flatpak.fish
fish /ctx/script/systemd.fish
#fish /ctx/script/fwupdmgr.fish
#fish /ctx/script/dconf.fish
#fish /ctx/script/ujust.fish



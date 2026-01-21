#!/bin/fish
echo "⚠️ --- Run 'build.fish' ---"

echo "Quick reminder!"
echo "Search for this character '⚠️' to look for messages provided by Aldehyde's scripts"

# === === /ctx/fsroot/ filesystem, using factory === ===
echo "⚠️ --- Copy over filesystem components ---"

cp -r /ctx/fsroot/usr/* /usr/
cp -r /ctx/fsroot/usr/share/factory/etc/* /etc/ # user modify
#cp -r /ctx/fsroot/usr/share/factory/var/* /var/ # Never copy to base while building in progress
#cp -r /ctx/fsroot/usr/share/factory/opt/* /opt/ # Include files in it only if it will be immutable directory


# === Install fish ===
echo "⚠️ --- Install fish ---"

dnf5 install fish -y


# === === /ctx/script/ subscripts === ===
echo "⚠️ --- Run subscripts ---"

fish /ctx/script/dnf5.fish
fish /ctx/script/systemd.fish
#fish /ctx/script/flatpak.fish # Writes to /var/, so no
#fish /ctx/script/fwupdmgr.fish
#fish /ctx/script/ujust.fish



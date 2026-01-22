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

# === === /var/ cleanup === ===
echo "⚠️ --- Clean var ---"

# 1. Standard log and cache cleanup
rm -rf /var/log/*
rm -rf /var/cache/*
rm -rf /var/tmp/*

# 2. Deep DNF5/PackageKit cleanup (Satisfies the 'terra-mesa' and 'PackageKit' warnings)
rm -rf /var/lib/dnf/*
rm -rf /var/lib/dnf5/*
rm -rf /var/lib/PackageKit/*

# 3. Clean up non-compliant spool and db files (Fixes anacron and firebird warnings)
rm -rf /var/spool/anacron/*
rm -rf /var/lib/firebird/*

# 4. Remove Greetd user-state that was generated during the build
rm -rf /var/lib/greetd/.config/*
rm -rf /var/lib/greetd/.cache/*

# 5. Final safety wipe of /var/tmp and /tmp
# (Sometimes files are hidden or have restricted permissions)
find /var/tmp -mindepth 1 -delete
find /tmp -mindepth 1 -delete

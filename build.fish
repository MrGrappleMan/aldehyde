#!/bin/fish
echo "🚩 --- Run 'build.fish' ---"

echo "Quick reminder!"
echo "Search for these characters,
echo "'⭕' --- Start of a section"
echo "'✅' --- End of a section"
echo "'🚩' --- Start of script"
echo "'🏁' --- End of a script"
echo "to look for messages provided by Aldehyde's scripts"

# === === /ctx/fsroot/ filesystem, using factory === ===
echo "⭕ --- Copy over filesystem components ---"

cp -r /ctx/fsroot/usr/* /usr/
cp -r /ctx/fsroot/usr/share/factory/etc/* /etc/ # user modify
#cp -r /ctx/fsroot/usr/share/factory/var/* /var/ # Never copy to base while building in progress
#cp -r /ctx/fsroot/usr/share/factory/opt/* /opt/ # Include files in it only if it will be immutable directory


# === Install fish ===
echo "⭕ --- Install fish shell ---"

dnf5 install fish -y

echo "✅ --- Install fish shell ---"

# === === /ctx/script/ subscripts === ===
echo "⭕ --- Run subscripts ---"

fish /ctx/script/dnf5.fish
fish /ctx/script/systemd.fish
#fish /ctx/script/flatpak.fish # Writes to /var/, so no
#fish /ctx/script/fwupdmgr.fish
#fish /ctx/script/ujust.fish

echo "✅ --- Run subscripts ---"

# === === /var/ cleanup === ===
echo "⭕ --- Clean /var/ ---"

# Clear, Opportunistically clean /var/ without failing on active mounts
# We use 'find' with '-xdev' to stay on the same filesystem
# and avoid trying to delete the actual mount points.
#for item in (find /var -mindepth 1 -maxdepth 1)
#	# Try to delete all contents INSIDE the item (files and hidden files)
#	if test -d "$item"
#		# We use 'find' inside to avoid 'argument list too long' errors
#		find "$item" -mindepth 1 -delete 2>/dev/null
#		rmdir "$item" 2>/dev/null # Directory deletion, but fail silently even if it's a busy mount point
#	else
#		rm -f "$item" 2>/dev/null # File deletion
#	end # This 'end' closes the 'if/else' block
#end # This 'end' closes the 'for' loop

# tf is wrong here, correct syntax
# First ever instance of if it works, do not touch it I have experienced

for item in (find /var -mindepth 1 -maxdepth 1)
    if test -d "$item"
        find "$item" -mindepth 1 -delete 2>/dev/null
        rmdir "$item" 2>/dev/null
     else
        rm -f "$item" 2>/dev/null
    end
end

echo "✅ --- Clean /var/ ---"

# Essential directories reconstruct
echo "⭕ --- Remake essential directories ---"

mkdir -p /var/tmp
chmod 1777 /var/tmp
mkdir -p /var/lib/systemd
mkdir -p /var/log/journal

echo "✅ --- Remake essential directories ---"

echo "🏁 --- Run 'build.fish' ---"

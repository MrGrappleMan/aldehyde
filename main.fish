#!/usr/bin/env fish

## Functions
function diskfree
	echo "📊 --- DISK SPACE REPORT ---"
	df -h
	#df -h / | awk 'NR==2 {print "Total: " $2 " | Used: " $3 " | Available: " $4}'
end

## User Instructions
echo "🚩 --- Run 'build.fish' ---"

echo "Quick reminder!"
echo "Search for these characters,"
echo "'⭕' --- Start of a section"
echo "'✅' --- End of a section"
echo "'🚩' --- Start of script"
echo "'🏁' --- End of a script"
echo "to look for messages provided by Aldehyde scripts"

## Image modification

# === === /ctx/fsroot/ filesystem, using factory === ===
echo "⭕ --- Copy over filesystem components ---"

cp -r /ctx/fsroot/usr/* /usr/ # Immutable
cp -r /ctx/fsroot/usr/share/factory/etc/* /etc/ # User modifiable, maybe should include a post install script that does this on user end
#cp -r /ctx/fsroot/usr/share/factory/var/* /var/ # This won't be preserved
#cp -r /ctx/fsroot/usr/share/factory/opt/* /opt/ # Include files in it only if /opt/ immutable directory else it will all be wiped out, see Containerfile for better explanation

# === Install fish ===
echo "⭕ --- Install fish shell ---"

dnf5 install fish -y

echo "✅ --- Install fish shell ---"

# === === /ctx/script/ subscripts === ===
echo "⭕ --- Run subscripts ---"

fish /ctx/script/dnf5.fish # System packages
#fish /ctx/script/kernel.fish # Kernel modification
fish /ctx/script/systemd.fish # System services
#fish /ctx/script/flatpak.fish # Writes to /var/, so no
#fish /ctx/script/fwupdmgr.fish # DBus issues, execute once deployed into user's PC
#fish /ctx/script/ujust.fish # this is for user environment

echo "✅ --- Run subscripts ---"

# === === Cleanup === ===
echo "⭕ --- Cleanup directories ---"

# Only target specific directories
rm -rf /var/cache/*
rm -rf /var/log/*
rm -rf /tmp/*

#for item in (find /var -mindepth 1 -maxdepth 1)
#    if test -d "$item"
#        find "$item" -mindepth 1 -delete 2>/dev/null
#        rmdir "$item" 2>/dev/null
#     else
#        rm -f "$item" 2>/dev/null
#    end
#end

echo "✅ --- Cleanup directories ---"

# === === Essential directories reconstruct === ===
echo "⭕ --- Remake essential directories ---"

mkdir -p /var/tmp
chmod 1777 /var/tmp
mkdir -p /var/lib/systemd
mkdir -p /var/log/journal

echo "✅ --- Remake essential directories ---"

echo "🏁 --- Run 'build.fish' ---"

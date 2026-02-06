#!/usr/bin/env fish

## Functions
function diskfree
	echo "📊 --- DISK SPACE REPORT ---"
	df -h
	#df -h / | awk 'NR==2 {print "Total: " $2 " | Used: " $3 " | Available: " $4}'
end

## User Instructions
echo "🚩 --- Run 'main.fish' ---"

echo "Quick reminder!"
echo "Search for these characters,"
echo "'⭕' --- New section begun"
echo "'🚩' --- New script begun"
echo "to look for messages provided by Aldehyde scripts"

## Image modification

# === === /ctx/fsroot/ filesystem, using factory === ===
echo "⭕ --- Copy over filesystem components ---"

cp -r /ctx/fsroot/usr/* /usr/ # Mutable during build, immutable on user end
cp -r /ctx/fsroot/usr/share/factory/etc/* /etc/ # script/postinstall.fish will handle that on user end as well
cp -r /ctx/fsroot/usr/share/factory/opt/* /opt/ # Include files in it only if /opt/ immutable directory else it will all be wiped out, see Containerfile for better explanation
#cp -r /ctx/fsroot/usr/share/factory/var/* /var/ # Buid time only

# === === /ctx/script/ subscripts === ===
echo "⭕ --- Run subscripts ---"

fish /ctx/script/dnf5.fish # Packages
fish /ctx/script/systemd.fish # Services

# === === Cleanup === ===
echo "⭕ --- Cleanup directories ---"

#rm -rf /var/*
rm -rf /tmp/*
rm -rf /var/log/*
rm -rf /var/cache/libdnf5/*
rm -rf /var/lib/dnf5/history/*
rm -rf /var/log/dnf5.log
#rm -rf /boot/*
#rm -rf /boot/.*

#for item in (find /var -mindepth 1 -maxdepth 1)
#    if test -d "$item"
#        find "$item" -mindepth 1 -delete 2>/dev/null
#        rmdir "$item" 2>/dev/null
#     else
#        rm -f "$item" 2>/dev/null
#    end
#end

# === === Essential directories reconstruct === ===
echo "⭕ --- Remake essential directories ---"

mkdir -p /var/tmp
chmod 1777 /var/tmp
mkdir -p /var/lib/systemd
mkdir -p /var/log/journal

#!/usr/bin/env fish

## Functions
function diskfree
	echo "📊 --- DISK SPACE REPORT ---"
	df -h
	#df -h / | awk 'NR==2 {print "Total: " $2 " | Used: " $3 " | Available: " $4}'
end

## User Instructions
echo "🚩 --- Run 'build-image.fish' ---"

echo "Search for these characters,"
echo "'⭕' --- Section start"
echo "'✅' --- Section end"
echo "'🚩' --- Script start"
echo "'🏁' --- Script end"
echo "Denoted by the build scripts"

## Image modification

# === === /ctx/fsroot/ filesystem contents === ===
echo "⭕ --- Copy over files to image ---"

cp -r /ctx/fsroot/usr/* /usr/ # Files to be built into the image
cp -r /ctx/fsroot/etc/* /etc/ # Affects build time only
#cp -r /ctx/fsroot/var/* /var/ # Affects build time only
#cp -r /ctx/fsroot/opt/* /opt/ # To insert 3rd party programs into image manually, dnf5 preferred

echo "✅ --- Copy over files to image ---"

# === === /ctx/script/ subscripts === ===
echo "⭕ --- Run subscripts ---"

fish /ctx/scripts/dnf5.fish # Packages
fish /ctx/scripts/systemd.fish # Services

echo "✅ --- Run subscripts ---"
# === === Cleanup === ===
echo "⭕ --- Cleanup directories ---"

rm -rf /var/*
rm -rf /var/log/*
rm -rf /var/log/dnf5.log
rm -rf /var/cache/*
rm -rf /var/cache/dnf/*
rm -rf /var/cache/libdnf5/*
rm -rf /var/lib/*
rm -rf /var/lib/dnf5/history/*
rm -rf /tmp/*
rm -rf /boot/*
rm -rf /boot/.*
rm -rf /usr/etc

for item in (find /var -mindepth 1 -maxdepth 1)
    if test -d "$item"
        find "$item" -mindepth 1 -delete 2>/dev/null
        rmdir "$item" 2>/dev/null
     else
        rm -f "$item" 2>/dev/null
    end
end

echo "✅ --- Cleanup directories ---"

# === === Essential directories reconstruct === ===
echo "⭕ --- Remake essential directories ---"

mkdir -p /var/tmp
chmod 1777 /var/tmp
mkdir -p /var/lib/systemd
mkdir -p /var/log/journal

#if not test -L /ostree
#    echo "re-linking /ostree..."
#    ln -s sysroot/ostree /ostree
#end

echo "✅ --- Remake essential directories ---"

echo "🏁 --- Run 'build-image.fish' ---"

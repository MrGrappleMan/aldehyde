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

# rm -rf (Top-Down): If rm hits a directory that is locked, in use, or lacks write permissions, 
# it can fail immediately on that directory descriptor and skip processing the entire nested path underneath it.
# 
# find -depth -delete (Bottom-Up): By processing leaf nodes first, find ensures that every individual file is evaluated independently.
# If a parent directory is locked or in use, find has already successfully purged all of its children before it even attempts
# (and potentially fails) to delete that parent.

find -depth -delete -mindepth 1 /var/cache/*
find -depth -delete -mindepth 1 /var/tmp/*
find -depth -delete -mindepth 1 /var/log/*
find -depth -delete -mindepth 1 /tmp/*

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

# --- 1. Fix the missing sysroot symlink ---
RUN ln -s sysroot/ostree /ostree

# --- 2. Fix the missing composefs configuration layout ---
RUN mkdir -p /usr/lib/ostree \
    && echo -e "[sysroot]\ncomposefs=yes" > /usr/lib/ostree/prepare-root.conf

echo "✅ --- Remake essential directories ---"

echo "🏁 --- Run 'build-image.fish' ---"

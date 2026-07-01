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
# === === Satisfy linter === ===
echo "⭕ --- Cleanup directories ---"

# rm -rf (Top-Down): If rm hits a directory that is locked, in use, or lacks write permissions, 
# it can fail immediately on that directory descriptor and skip processing the entire nested path underneath it.
# 
# find -depth -delete (Bottom-Up): By processing leaf nodes first, find ensures that every individual file is evaluated independently.
# If a parent directory is locked or in use, find has already successfully purged all of its children before it even attempts
# (and potentially fails) to delete that parent.

# nonempty-run-tmp
find -depth -delete -mindepth 1 /run/*
find -depth -delete -mindepth 1 /tmp/*

# nonempty-boot
find -depth -delete -mindepth 1 /boot/*

# var-log
find -depth -delete -mindepth 1 /var/log/*

# var-cache
find -depth -delete -mindepth 1 /var/cache/*
find -depth -delete -mindepth 1 /var/tmp/*

# etc-usretc
rm -rf /usr/etc/

echo "✅ --- Cleanup directories ---"

echo "⭕ --- Remake essential directories ---"

# --- 1. Fix the missing sysroot symlink ---
ln -s sysroot/ostree /ostree

# --- 2. Fix the missing composefs configuration layout ---
mkdir -p /usr/lib/ostree
echo -e "[sysroot]\ncomposefs=yes" > /usr/lib/ostree/prepare-root.conf

echo "✅ --- Remake essential directories ---"

echo "🏁 --- Run 'build-image.fish' ---"

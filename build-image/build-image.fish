#!/usr/bin/env fish
echo "🚩 --- Run 'build-image.fish' ---"

# Debugging Guide
    echo "Search for these characters,"
    echo "'⭕' --- Section within a script starts"
    echo "'✅' --- Section within a script ends"
    echo "'🚩' --- Script starts"
    echo "'🏁' --- Script ends"
    echo "Denoted by the build scripts"

# Image modification
    # Copy /ctx/fsroot/ contents into the image
        echo "⭕ --- Copy image files"
        cp -r /ctx/fsroot/usr/* /usr/ # Files to be built into the image
        cp -r /ctx/fsroot/etc/* /etc/ # Affects build time only
        #cp -r /ctx/fsroot/var/* /var/ # Affects build time only
        #cp -r /ctx/fsroot/opt/* /opt/ # To insert 3rd party programs into image manually, dnf5 preferred
        echo "✅ --- Copy image files"

    # Run /ctx/script/ subscripts
        echo "⭕ --- Run subscripts"
        fish /ctx/scripts/dnf5.fish # Packages
        fish /ctx/scripts/systemd.fish # Services
        echo "✅ --- Run subscripts"

# Satisfy linter
    echo "⭕ --- Cleanup directories"
    
    # rm -rf (Top-Down): If rm hits a directory that is locked, in use, or lacks write permissions, 
    # it can fail immediately on that directory descriptor and skip processing the entire nested path underneath it.
    # 
    # find -depth -delete (Bottom-Up): By processing leaf nodes first, find ensures that every individual file is evaluated independently.
    # If a parent directory is locked or in use, find has already successfully purged all of its children before it even attempts
    # (and potentially fails) to delete that parent.
    # -mindepth 1: Ensures that the deletion starts from the immediate children of the specified directory, not the directory itself.
    # -type f: Ensures that only regular files are deleted, not directories or symlinks.

    # nonempty-run-tmp
        rm -rf /run/
        rm -rf /tmp/

    # nonempty-boot
        rm -rf /boot/

    # var-log
        rm -rf /var/log/

    # var-cache
        rm -rf /var/cache/
        rm -rf /var/tmp/

    # etc-usretc
        rm -rf /usr/etc/

echo "✅ --- Cleanup directories ---"

# Force initramfs generation for the installed kernel version
    #KERNEL_VER=$(ls /lib/modules | tail -n 1) && \
    #    dracut --kver "$KERNEL_VER" --force --reproducible /boot/initramfs-"$KERNEL_VER".img

echo "🏁 --- Run 'build-image.fish' ---"

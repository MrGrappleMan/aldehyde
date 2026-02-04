#!/usr/bin/env fish

if test (id -u) -eq 0
    echo "Running as root, proceeding"
else
    echo "Not running as root, beginning re-execute..."
    echo "Please insert the proper password for your user"
    sleep 3
    curl "https://raw.githubusercontent.com/MrGrappleMan/aldehyde-lx/refs/heads/main/User-SwitchToImage.fish" | pkexec fish
    exit
end

# ⛑️ Cleanup legacy
echo "Canceling any ongoing operations"
rpm-ostree cancel

echo "Remove rpm-ostree related contents"
rpm-ostree reset -l -o -i

echo "Unpinning all images"
ostree admin pin -u 0
ostree admin pin -u 1
ostree admin pin -u 2
ostree admin pin -u 3
ostree admin pin -u 4

# 🎛️ Switch image
echo "Switching to new image"
bootc switch ghcr.io/mrgrappleman/aldehyde-lx:latest --apply
bootc update

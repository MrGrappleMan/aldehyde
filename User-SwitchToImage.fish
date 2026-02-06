#!/usr/bin/env fish
clear

if test (id -u) -eq 0
    echo "Running as root, proceeding"
else
    echo "Not running as root, beginning re-execution!"
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
clear
echo "   ▄████████  ▄█       ████████▄     ▄████████    ▄█    █▄    ▄██   ▄   ████████▄     ▄████████ ";
echo "  ███    ███ ███       ███   ▀███   ███    ███   ███    ███   ███   ██▄ ███   ▀███   ███    ███ ";
echo "  ███    ███ ███       ███    ███   ███    █▀    ███    ███   ███▄▄▄███ ███    ███   ███    █▀  ";
echo "  ███    ███ ███       ███    ███  ▄███▄▄▄      ▄███▄▄▄▄███▄▄ ▀▀▀▀▀▀███ ███    ███  ▄███▄▄▄     ";
echo "▀███████████ ███       ███    ███ ▀▀███▀▀▀     ▀▀███▀▀▀▀███▀  ▄██   ███ ███    ███ ▀▀███▀▀▀     ";
echo "  ███    ███ ███       ███    ███   ███    █▄    ███    ███   ███   ███ ███    ███   ███    █▄  ";
echo "  ███    ███ ███▌    ▄ ███   ▄███   ███    ███   ███    ███   ███   ███ ███   ▄███   ███    ███ ";
echo "  ███    █▀  █████▄▄██ ████████▀    ██████████   ███    █▀     ▀█████▀  ████████▀    ██████████ ";
echo "             ▀                                                                                  ";
echo "Improvise, Perform, Inspire";
echo
echo "❇ Preparing your experience ❇";
echo "Please be patient, your device will automatically reboot";
bootc switch ghcr.io/mrgrappleman/aldehyde-lx:latest --apply
bootc upgrade --apply

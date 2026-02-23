#!/usr/bin/env bash
clear

# Checks, proceed only if root and device has /usr/bin/bootc

#if test (id -u) -eq 0
#    echo "Running as root, proceeding"
#else
#    echo "Not running as root, beginning re-execution!"
#    echo "Please insert the proper password for your user to proceed"
#    echo "";
#    sleep 6
#    curl "https://raw.githubusercontent.com/MrGrappleMan/aldehyde-lx/refs/heads/main/User-SwitchToImage.fish" | pkexec fish
#    exit
#end

# ⛑️ Cleanup legacy
echo "Cancel rpm-ostree operations"
rpm-ostree cancel
echo "";

echo "Reset state via rpm-ostree"
rpm-ostree reset -l -o -i
echo "";

echo "Unpin all images"
ostree admin pin -u 0
ostree admin pin -u 1
ostree admin pin -u 2
ostree admin pin -u 3
ostree admin pin -u 4
echo "";

# 🎛️ Switch image
clear
echo "                                                                                                  ";
echo "__________________________________________________________________________________________________";
echo "                                                                                                  ";
echo "   ▄████████  ▄█       ████████▄     ▄████████    ▄█    █▄    ▄██   ▄   ████████▄     ▄████████   ";
echo "  ███    ███ ███       ███   ▀███   ███    ███   ███    ███   ███   ██▄ ███   ▀███   ███    ███   ";
echo "  ███    ███ ███       ███    ███   ███    █▀    ███    ███   ███▄▄▄███ ███    ███   ███    █▀    ";
echo "  ███    ███ ███       ███    ███  ▄███▄▄▄      ▄███▄▄▄▄███▄▄ ▀▀▀▀▀▀███ ███    ███  ▄███▄▄▄       ";
echo "▀███████████ ███       ███    ███ ▀▀███▀▀▀     ▀▀███▀▀▀▀███▀  ▄██   ███ ███    ███ ▀▀███▀▀▀       ";
echo "  ███    ███ ███       ███    ███   ███    █▄    ███    ███   ███   ███ ███    ███   ███    █▄    ";
echo "  ███    ███ ███▌    ▄ ███   ▄███   ███    ███   ███    ███   ███   ███ ███   ▄███   ███    ███   ";
echo "  ███    █▀  █████▄▄██ ████████▀    ██████████   ███    █▀     ▀█████▀  ████████▀    ██████████   ";
echo "             ▀                                                                                    ";
echo "____________________________ < ~ Improvise, Perform, Inspire ~ > _________________________________";
echo "                                                                                                  ";
echo "                         ❇ Get ready to experience real productivity ❇                           ";
echo "                    Please be patient, your device will automatically reboot                      ";
bootc switch ghcr.io/mrgrappleman/aldehyde-lx:latest --apply
bootc upgrade --apply

#!/usr/bin/env bash
clear

# --- 🛡️ Environment Checks ---

# 1. Check for bootc availability
if [[ ! -x /usr/bin/bootc ]]; then
    echo "Host does not have bootc, this OS is not supported"
    exit 1
fi

# 2. Check for Root & Re-execute if necessary
if [[ $EUID -ne 0 ]]; then
    echo "🔐 Not running as root, beginning re-execution!"
    echo "Please insert the proper password for your user to proceed"
    echo ""
    sleep 6
    # Re-executing via pkexec
    curl -s "https://raw.githubusercontent.com/MrGrappleMan/aldehyde-lx/refs/heads/main/start.bash" | pkexec bash
    exit $?
fi

# ⛑️ No rpm-ostree redundancies
echo "Cancel rpm-ostree operations"
rpm-ostree cancel

echo "Reset state via rpm-ostree"
rpm-ostree reset -l -o -i

echo "Unpin any pinned images"
ostree admin pin -u 0
ostree admin pin -u 1
ostree admin pin -u 2
ostree admin pin -u 3
ostree admin pin -u 4
ostree admin pin -u 5
ostree admin pin -u 6
ostree admin pin -u 7
ostree admin pin -u 8
ostree admin pin -u 9

# 🎛️ Switch image
echo "System will auto reboot if switch or update is done";
bootc switch ghcr.io/mrgrappleman/aldehyde-lx:latest --apply
bootc upgrade --apply

echo "If you can see this message, latest image is already running"

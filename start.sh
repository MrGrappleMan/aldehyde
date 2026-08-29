#!/usr/bin/env bash
clear

# ------------------------------------------------------------------------------
# ⚙️ Prerequisites:
# 1. Linux
# 2. BootC presence
# 3. Root user
# ------------------------------------------------------------------------------

# 1. Check if the script is running on Linux
    if [[ "$OSTYPE" != "linux-gnu"* ]]; then
        echo "Error: This script is for Linux" >&2
        echo "Try our project https://github.com/MrGrappleMan/bento for macOS!"
        exit 1
    fi

# 2. Check for BootC presence
    if ! command -v bootc &> /dev/null; then
        echo "Error: You are using a non-BootC-based host." >&2
        echo "Please install Bazzite GNOME to use this script." >&2
        exit 1
    fi


# 3. Check for Root & Re-execute if necessary
    if [[ $EUID -ne 0 ]]; then
        echo "Error: You are not running as root." >&2
        echo "Please insert the proper password for your user to proceed" >&2
        echo ""
        sleep 6
        # Re-execute
        curl -H "Cache-Control: no-cache, no-store, must-revalidate" -H "Pragma: no-cache" -H "Expires: 0" -sSL https://raw.githubusercontent.com/MrGrappleMan/aldehyde/refs/heads/main/start.bash | pkexec bash
        exit $?
    fi

# ------------------------------------------------------------------------------
# Cleanup:
# Removal of any pinned images, layered packages and overrides and rpm-ostree related mutations
# ------------------------------------------------------------------------------

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

# ------------------------------------------------------------------------------
# Switch image
# ------------------------------------------------------------------------------

bootc switch ghcr.io/mrgrappleman/aldehyde:latest
bootc upgrade

echo "Switch to image has been applied, please reboot manully";

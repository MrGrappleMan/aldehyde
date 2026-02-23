#!/usr/bin/env bash
clear

# --- 🛰️ Network Watchdog (Background) ---
# Pings DNS providers randomly to ensure the bridge/internet is alive during pull
spawn_watchdog() {
    (
        while true; do
            # Generate random sleep between 65 and 80 seconds
            sleep_time=$(( RANDOM % 16 + 65 ))
            sleep "$sleep_time"
            
            # Randomly pick between 8.8.8.8 and 1.1.1.1
            target=$([ $(( RANDOM % 2 )) -eq 0 ] && echo "8.8.8.8" || echo "1.1.1.1")
            
            if ! ping -c 1 -W 2 "$target" >/dev/null 2>&1; then
                # Try the fallback if the first fails
                fallback=$([ "$target" == "8.8.8.8" ] && echo "1.1.1.1" || echo "8.8.8.8")
                if ! ping -c 1 -W 2 "$fallback" >/dev/null 2>&1; then
                    echo -e "\n⚠️  [WARNING]: Network unreachable. Pull may fail." >&2
                fi
            fi
        done
    ) &
    WATCHDOG_PID=$!
}

# --- 🛡️ Environment Checks ---

# 1. Check for bootc availability
if [[ ! -x /usr/bin/bootc ]]; then
    echo "❌ Error: /usr/bin/bootc not found. This script requires a bootc-compatible host."
    exit 1
fi

# 2. Check for Root & Re-execute if necessary
if [[ $EUID -ne 0 ]]; then
    echo "🔐 Not running as root, beginning re-execution!"
    echo "Please insert the proper password for your user to proceed"
    echo ""
    sleep 6
    # Re-executing via pkexec as per your requirement
    curl -s "https://raw.githubusercontent.com/MrGrappleMan/aldehyde-lx/refs/heads/main/User-SwitchToImage.fish" | pkexec fish
    exit $?
else
    echo "🚀 Running as root, proceeding..."
fi

# Start connectivity watchdog
spawn_watchdog

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
echo "___________________________________________________________________________________________________";
echo "                                                                                                   ";
echo "    ▄████████  ▄█       ████████▄     ▄████████    ▄█    █▄    ▄██   ▄   ████████▄     ▄████████   ";
echo "   ███    ███ ███       ███   ▀███   ███    ███   ███    ███   ███   ██▄ ███   ▀███   ███    ███   ";
echo "   ███    ███ ███       ███    ███   ███    █▀    ███    ███   ███▄▄▄███ ███    ███   ███    █▀    ";
echo "   ███    ███ ███       ███    ███  ▄███▄▄▄      ▄███▄▄▄▄███▄▄ ▀▀▀▀▀▀███ ███    ███  ▄███▄▄▄       ";
echo " ▀███████████ ███       ███    ███ ▀▀███▀▀▀     ▀▀███▀▀▀▀███▀  ▄██   ███ ███    ███ ▀▀███▀▀▀       ";
echo "   ███    ███ ███       ███    ███   ███    █▄    ███    ███   ███   ███ ███    ███   ███    █▄    ";
echo "   ███    ███ ███▌    ▄ ███   ▄███   ███    ███   ███    ███   ███   ███ ███   ▄███   ███    ███   ";
echo "   ███    █▀  █████▄▄██ ████████▀    ██████████   ███    █▀     ▀█████▀  ████████▀    ██████████   ";
echo "              ▀                                                                                    ";
echo "_____________________________ < ~ Improvise, Perform, Inspire ~ > _________________________________";
echo "                                                                                                   ";
echo "                         ❇ Get ready to experience real productivity ❇                             ";
echo "                   Please be patient, your device will automatically reboot                        ";
bootc switch ghcr.io/mrgrappleman/aldehyde-lx:latest --apply
echo "You are already on Aldehyde, checking if there are any updates available";
bootc upgrade --apply

# At this point, the system will reboot, this kill command is redundant in that case
kill $WATCHDOG_PID 2>/dev/null

# If both are already satisfied
clear
echo "";
echo "  Your device is already running Aldehyde's latest version!  ";

exit
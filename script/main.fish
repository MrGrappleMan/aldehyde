#!/bin/fish

clear
if fish_is_root_user
    echo "Running as root! Please re-run as a regular user, as some settings require user-level modifications"
    exit
end

echo Type the password for your user...
curl "https://raw.githubusercontent.com/MrGrappleMan/Fynelium-LX/refs/heads/main/script/Automated.fish" | pkexec fish
curl "https://raw.githubusercontent.com/MrGrappleMan/Fynelium-LX/refs/heads/main/script/Automated/ujust.fish" | fish
curl "https://raw.githubusercontent.com/MrGrappleMan/Fynelium-LX/refs/heads/main/script/Automated/dconf.fish" | fish
clear
echo All set! Reboot your system as soon as you can.

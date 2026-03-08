#!/usr/bin/env fish

# Gets executed once by root, then the user, as seeen in documentation. Some require non root user.

# Decky
ujust setup-decky install
ujust setup-decky prerelease

# Graphics
ujust get-framegen
#ujust get-framegen install-decky-plugins
ujust get-lsfg install
ujust get-lsfg install-decky-plugin
ujust toggle-global-fsr4 enable
ujust toggle-global-fsr4-rdna3 enable

# Visual Tweaks
ujust toggle-password-feedback on # Worth it, I know the password recognition by keyboard sounds and keypresses method, but is worth the feedback it provides

# Boot process
ujust setup-luks-tpm-unlock
ujust configure-grub 2 # Hide GRUB
ujust enable-automount-all # Automount

# Cross platform
ujust setup-virtualization
ujust setup-waydroid

# Backend/Services
ujust setup-sunshine enable
ujust toggle-ssh enable

# User end applications
ujust get-media-app "YouTube" # Dedicated and optimized for YouTube with a cleaner interface.
ujust get-media-app "Spotify"
ujust get-media-app "YouTube Music"
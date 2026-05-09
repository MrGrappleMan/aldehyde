#!/usr/bin/env fish

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
ujust toggle-password-feedback off # Prevent password prediction

# Boot process
ujust setup-luks-tpm-unlock
ujust configure-grub 1 # Hide GRUB if not dual booting
ujust enable-automount-all # Automount

# Cross platform
#ujust setup-virtualization
ujust setup-waydroid

# Backend/Services
ujust setup-sunshine enable
ujust toggle-ssh enable

# Applications
ujust get-media-app "YouTube" # Cobalt UI, AD Block, De Arrow, etc.
ujust get-media-app "Spotify"
ujust get-media-app "YouTube Music"

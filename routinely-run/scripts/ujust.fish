#!/usr/bin/env fish

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

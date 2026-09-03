#!/usr/bin/env fish

# Prevent password prediction
    ujust toggle-password-feedback off # Prevent password prediction

# Boot process
    ujust setup-luks-tpm-unlock
    ujust configure-grub 1 # Hide GRUB if not dual booting
    ujust enable-automount-all # Automount

# Compatibility
    #ujust setup-virtualization
    ujust setup-waydroid

# sunshine
    ujust setup-sunshine enable

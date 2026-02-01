#!/usr/bin/env fish

# Gets executed once by root, then the user, as seeen in documentation. Some require non root user.

ujust setup-decky install # Additional functionality
ujust setup-decky prerelease

# QoL Features
ujust get-framegen
ujust get-framegen install-decky-plugins
ujust get-lsfg install
ujust get-lsfg install-decky-plugin
ujust toggle-password-feedback on # Easier to interpret, by just password position not much risk
ujust ptyxis-transparency 1 # Easiest to read
ujust toggle-global-fsr4 enable
ujust toggle-global-fsr4-rdna3 enable
ujust toggle-wol enable

ujust configure-grub 2 # Hide GRUB
ujust enable-automount-all # Automount

ujust setup-sunshine enable
ujust toggle-ssh enable
ujust get-media-app "YouTube" # Dedicated and optimized for YouTube with a cleaner interface.
ujust get-media-app "Spotify"
ujust get-media-app "YouTube Music"

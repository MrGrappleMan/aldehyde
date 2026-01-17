#!/usr/bin/env fish

# 👣 Configures GSettings / Dconf - The settings for GNOME

# Gets executed once by root, then the user, as seeen in documentation.

# Generic
dconf load -f / < /tmp/Fynelium-LX/export/gnome.dconf

# For extensions
dconf load -f /org/gnome/shell/extensions/ < /tmp/Fynelium-LX/export/gnome-extensions.dconf

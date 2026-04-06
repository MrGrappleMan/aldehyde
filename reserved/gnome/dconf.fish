#!/usr/bin/env fish

# 👣 Configures GSettings / Dconf - GNOME

# Generic
dconf load -f / < gnome.dconf

# Extension Specific
dconf load -f /org/gnome/shell/extensions/ < gnome-extensions.dconf

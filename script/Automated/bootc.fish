#!/bin/fish

# ⛑️ Ensure clean state - remove compatibility
rpm-ostree cancel -q
rpm-ostree reset -l -o -i -q
ostree admin pin -u 0
ostree admin pin -u 1
ostree admin pin -u 2
ostree admin pin -u 3
ostree admin pin -u 4

# 🎛️ Switch base - will change up later with custom image
bootc switch ghcr.io/ublue-os/bazzite-dx-gnome:latest --quiet

# 📈 Upgrade
bootc upgrade --quiet

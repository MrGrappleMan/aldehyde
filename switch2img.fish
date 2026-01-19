#!/bin/fish

# ⛑️ Remove compatibility
rpm-ostree cancel -q
rpm-ostree reset -l -o -i -q
ostree admin pin -u 0
ostree admin pin -u 1
ostree admin pin -u 2
ostree admin pin -u 3
ostree admin pin -u 4

# 🎛️ Switch bootc base to Aldehyde
bootc switch ghcr.io/mrgrappleman/aldehyde-lx:latest --quiet

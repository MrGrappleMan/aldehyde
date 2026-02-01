#!/usr/bin/env fish

# 🖨️ fwupdmgr - Firmware Update Manager updates your system firmware

# Alias
alias fwu "fwupdmgr"
alias fwurepadd "fwupdmgr enable-remote -y"

# REP ADD
fwurepadd lvfs
fwurepadd lvfs-testing

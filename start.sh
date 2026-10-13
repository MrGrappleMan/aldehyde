#!/usr/bin/env bash
set -euo pipefail
clear

# Requirements
    # Linux only
        req_linux=0
        if [[ "$(uname -s)" == "Linux" ]]; then
            req_linux=1
        fi
    # bootc only
        req_bootc=0
        if [[ -f /run/ostree-booted ]] || command -v bootc &>/dev/null; then
            req_bootc=1
        fi
    # Run as root
        req_root=0
        if [ "$(id -u)" -eq 0 ]; then
            req_root=1
        fi
    # Verify
        readonly TICK="✓"
        readonly CROSS="✗"
        # Helper function to print formatted status
            print_check() {
                local flag="$1"
                local description="$2"
                if (( flag == 1 )); then
                    printf "[ %b ] %s\n" "\033[32m${TICK}\033[0m" "$description"
                else
                    printf "[ %b ] %s\n" "\033[31m${CROSS}\033[0m" "$description"
                fi
            }
        
        echo "Requirements check:"
        print_check "$req_linux" "Is Linux"
        print_check "$req_bootc" "System is bootc based"
        print_check "$req_root" "Run as root"
        
        echo
        if (( req_linux == 1 && req_bootc == 1 && req_root == 1 )); then
            echo "All system requirements were met, proceeding"
        else
            echo "Requirements were not met, please ensure your system is"
            echo "https://projectbluefin.io/dakota/"
            echo "to proceed further."
        fi

# Unpin any pinned images
    ostree admin pin -u 0
    ostree admin pin -u 1
    ostree admin pin -u 2
    ostree admin pin -u 3
    ostree admin pin -u 4
    ostree admin pin -u 5
    ostree admin pin -u 6
    ostree admin pin -u 7
    ostree admin pin -u 8
    ostree admin pin -u 9

# Switch to image or upgrade
    bootc switch ghcr.io/mrgrappleman/aldehyde:latest
    bootc upgrade

# Remind to reboot
    echo "Please reboot manually for the changes to take effect";

#!/usr/bin/env fish
echo "🚩 --- Run 'dnf5.fish' ---"

# DNF5: For installing essential packages to the system's base - these will be unremoveable

# NOTICE: rpm-ostree is deprecated for bootc
# Transitioning to bootc is intended to move system management toward a pure image-based model,
# which effectively removes the client-side package layering and management functionality.
# The core idea is that the entire operating system state is defined by a container image.
# The entire package management part will be removed, requiring you to shift to userspace components, like Flatpak and Distrobox
# Highly stable, faster to update and universally standardized.
# Never layer any packages onto the image or use rpm-ostree.
# Flatpak is indeed somewhat of of a terrible choice not because how corporations want it, but the way it is built in terms of architecture.
# As terrible as Electron in my opinion. Tauri is like distrobox but x100 resource efficient. Snapd is even worse.
# I try to package as much of good software that follows logical philosophies, performance and efficiency requirements into the base image as much as I can for best integration.
# See https://youtu.be/f_Xa_JvpfK0 for a rough overview

# 📛 Aliases
alias sysPkg- "dnf5 remove -y"
function sysPkg+ -d "Install packages individually to prevent transaction poisoning, at the cost of reducing parallelism"
    set -l pkgs (string split -n " " -- (string join " " $argv))

    for pkg in $pkgs
        echo "🛠️ Attempting to install: $pkg"
        dnf5 install -y allowerasing --skip-broken --skip-unavailable-allow-downgrade $pkg

        if test $status -ne 0
            echo "⚠️  Failed to install $pkg, skipping to next..."
        else
            echo "✅ Successfully installed $pkg"
        end
    end
end
alias sysPkgq "echo Temporarily disable package modification, just add a 'q'"

# PKG DEL
echo "⭕ --- Delete system packages ---"

sysPkg- docker docker-compose moby-engine \
        firefox \
        code \
        tuned tuned-ppd power-profiles-daemon

# @gnome-desktop gnome-software gnome-shell-extension-common 'gnome-terminal*' 'nautilus*' 'gedit*' 'yelp*' 'adwaita-icon-theme*' 'baobab' 'evince' 'google-gnu-free-*'

echo "✅ --- Delete system packages ---"

# PKG UPD
echo "⭕ --- Update system packages ---"
dnf5 update -y --allowerasing --skip-unavailable --allow-downgrade
echo "✅ --- Update system packages ---"

# PKG ADD
echo "⭕ --- Add system packages ---"

### Notes:
# Always update system before installing packages.
# Brave - Efficient, aligned w/ community more than most browsers, practical QoL features, Tor support
# COSMIC - Modern DE, better performance and efficiency

sysPkgq distcc distcc-server \
        host-spawn \
        inkscape krita krita-libs libei-utils \
        libvirt-daemon-kvm \
        nodejs obs-studio-plugin-browser \
        obs-studio-plugin-droidcam obs-studio-plugin-vaapi persepolis \
        pnpm preload qbittorrent qemu-kvm qemu-kvm-core rocm \
        tor \
        uget warp-terminal

fish /ctx/script/manual-edits/removePPD.fish # Let TLP manage power properly

sysPkg+ "dnf-plugins-core etckeeper-dnf dnf-repo \
        boinc-client boinc-client-static boinc-manager \
        tlp tlp-pd tlp-rdw \
        cosmic-app-library cosmic-applets cosmic-panel cosmic-workspaces cosmic-bg cosmic-comp cosmic-desktop cosmic-greeter cosmic-idle cosmic-osd cosmic-session cosmic-randr cosmic-screenshot cosmic-settings cosmic-settings-daemon xdg-desktop-portal-cosmic greetd \
        uutils-coreutils \
        obs-studio obs-studio-libs \
        git gh zed \
        gemini-cli ollama \
        brave-browser-nightly brave-keyring \
        hblock mosh \
        rustup cargo clippy \
        podman podman-docker"

echo "✅ --- Add system packages ---"

### Reserved:

## REFERENCE ##
#fedora-gpg-keys fedora-repos flatpak-libs flatpak-selinux
#flatpak-session-helper git kernel-modules-extra libei libportal openssh
#openssh-server p7zip p7zip-plugins
#tailscale util-linux xdg-desktop-portal
#obs-studio-plugin-vaapi obs-studio-plugin-vkcapture obs-studio-plugin-droidcam
#ghostty-nightly ghostty-nightly-fish-completion ghostty-nightly-shell-integration
#amd-gpu-firmware amd-ucode-firmware amdsmi am-utils
#nvidia-gpu-firmware libva-nvidia-driver envytools nvidia-patch

## CONFLICTS ##
# warp-cli | warp-terminal, already includes warp-cli
# tlp, tlp-rdw | tuned-ppd, power-profiles-daemon ( architectural shift in tlp therefore it conflicts with them )
# fedora-release-identity-cosmic-atomic fedora-release-cosmic-atomic ( this independent image is NOT cosmic atomic, spoofing it as one will cause conflicts )
# fedora-repos-rawhide ( only use pre-provided yum.repos.d repos )
# cosmic-config-fedora ( We have our own config files )


## PORTS ## for GUI/applications that work better on other package managers

     ## Pentesting:
      # aircrack-ng turbo-attack golang-github-redteampentesting-monsoon
    ### Gaming:-
     ## Steam:
      # steam steam-devices
     ## Mesa:
      # mesa-va-drivers-freeworld mesa-vdpau-drivers-freeworld mesa-vulkan-drivers-freeworld
      # mesa-dri-drivers
      # mesa-va-drivers mesa-vdpau-drivers mesa-vulkan-drivers
      # mesa-libOSMesa mesa-compat-libOSMesa

# === List ===
echo "⭕ --- List DNF5 packages ---"
dnf5 list --installed
echo "✅ --- List DNF5 packages ---"

# === Clean ===
echo "⭕ --- Clean DNF5 packages ---"
dnf5 clean all -y
echo "✅ --- Clean DNF5 packages ---"

echo "🏁 --- Run 'dnf5.fish' ---"

#!/usr/bin/env fish
echo "🚩 --- Run 'dnf5.fish' ---"

# DNF5: For installing essential packages to the system's immutable base

# 📛 Handling
alias sysPkg- "dnf5 remove -y"
function sysPkg+T -d "Fallback method to just make things install, reducing parallelism, avoid it, trace the core issue"
    set -l pkgs (string split -n " " -- (string join " " $argv))

    for pkg in $pkgs
        echo "🛠️ Install try: $pkg"
        dnf5 install -y --skip-broken --skip-unavailable --allow-downgrade $pkg

        if test $status -ne 0
            echo "⚠️ $pkg install failed!"
        else
            echo "✅ $pkg installed"
        end
    end
end
alias sysPkg+ "dnf5 install -y --skip-broken --skip-unavailable --allow-downgrade" # Batches operations, faster builds
alias sysPkgq "Ignored modifications,"

# --allowerasing

# PKG DEL
echo "⭕ --- Delete packages ---"

sysPkg- docker docker-compose moby-engine \
        firefox \
        code
#@gnome-desktop "gnome-*" "dconf*" "gdm*" "nautilus*" "adwaita*" "evolution*" "totem*" "rhythmbox*" "brasero*" "gedit*" "yelp*" "baobab" "evince"

# PKG UPD
#echo "⭕ --- Update packages ---"
#dnf5 update -y --skip-unavailable --allow-downgrade

# PKG ADD
echo "⭕ --- Add packages ---"

### Notes:
# Always update system before installing packages.
# Brave - Efficient, aligned w/ community more than most browsers, practical QoL features, Tor support
# COSMIC - Modern DE, better performance and efficiency

sysPkg+ cosmic-app-library cosmic-applets cosmic-panel cosmic-workspaces cosmic-bg cosmic-comp cosmic-desktop cosmic-greeter cosmic-idle cosmic-osd cosmic-session cosmic-randr cosmic-screenshot cosmic-settings cosmic-settings-daemon greetd \
        boinc-client boinc-client-static boinc-manager \
        uutils-coreutils \
        tuned tuned-ppd tuned-utils-systemtap \
        obs-studio obs-studio-libs \
        krita krita-libs inkscape \
        git gh zed-nightly \
        peazip mission-center \
        brave-browser-nightly brave-keyring \
        hblock tor mosh tailscale trayscale \
        rustup cargo clippy \
        podman podman-docker \
        rocm cuda

#fedora-gpg-keys fedora-repos flatpak-libs flatpak-selinux
#flatpak-session-helper git kernel-modules-extra libei libportal openssh
#openssh-server p7zip p7zip-plugins
#tailscale util-linux xdg-desktop-portal
#obs-studio-plugin-vaapi obs-studio-plugin-vkcapture obs-studio-plugin-droidcam
#ghostty-nightly ghostty-nightly-fish-completion ghostty-nightly-shell-integration
#amd-gpu-firmware amd-ucode-firmware amdsmi am-utils
#nvidia-gpu-firmware libva-nvidia-driver envytools nvidia-patch
#distcc distcc-server
#host-spawn
#inkscape krita krita-libs libei-utils
#libvirt-daemon-kvm
#nodejs obs-studio-plugin-browser
#obs-studio-plugin-droidcam obs-studio-plugin-vaapi persepolis
#pnpm preload qbittorrent qemu-kvm qemu-kvm-core rocm
#uget warp-terminal
#steam steam-devices
#aircrack-ng turbo-attack golang-github-redteampentesting-monsoon
#mesa-va-drivers-freeworld mesa-vdpau-drivers-freeworld mesa-vulkan-drivers-freeworld mesa-dri-drivers mesa-va-drivers mesa-vdpau-drivers mesa-vulkan-drivers mesa-libOSMesa mesa-compat-libOSMesa
#dnf-plugins-core etckeeper-dnf dnf-repo

## CONFLICTS ## ( Format: Chosen/BetterPackage | ConflictingPackage )
# warp-terminal | warp-cli ( warp-terminal already includes warp-cli )
# fedora-release-identity-cosmic-atomic fedora-release-cosmic-atomic ( this independent image is NOT cosmic atomic, spoofing it as one will cause conflicts )
# fedora-repos-rawhide ( only use repos in fsroot/usr/share/factory/etc/yum.repos.d or pre-packaged ones )
# cosmic-config-fedora ( We have our own config files )
# power-profiles-daemon tuned tuned-ppd | tlp tlp-pd tlp-rdw | auto-cpufreq ( PPD better integrated w/ modern standards, drivers, pstate support, less breakage points by low configurability )

# === List ===
#echo "⭕ --- List DNF5 packages ---"
dnf5 list --installed

# === Clean ===
echo "⭕ --- Clean DNF5 ---"
dnf5 autoremove -y # May misinterpret what is "essential" for the OS, on average is fine
dnf5 clean all -y

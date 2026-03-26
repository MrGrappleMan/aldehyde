#!/usr/bin/env fish
echo "🚩 --- Run 'dnf5.fish' ---"

# DNF5: For installing essential packages to the system's immutable base

### Notes:
# Always update system before installing packages.
# Brave - Efficient, aligned w/ community more than most browsers, practical QoL features, Tor support
# COSMIC - Modern DE, better performance and efficiency

# 📛 Handling
alias sysPkg- "dnf5 remove -y"
function sysPkg+T -d "Fallback method to just make things install, reducing parallelism, avoid it, trace the core issue"
    set -l pkgs (string split -n " " -- (string join " " $argv))

    for pkg in $pkgs
        echo "🛠️ Install try: $pkg"
        dnf5 install -y --skip-broken --skip-unavailable --allow-downgrade --allowerasing $pkg

        if test $status -ne 0
            echo "⚠️ $pkg install failed!"
        else
            echo "✅ $pkg installed"
        end
    end
end
alias sysPkg+ "dnf5 install -y --skip-broken --skip-unavailable --allow-downgrade --allowerasing" # Batches operations, faster builds
alias sysPkgq "echo Ignored modifications list,"

# (-) PKG DEL
echo "⭕ --- (-) Delete packages ---"

sysPkg- docker docker-compose moby-engine \
        firefox \
        code \
        @gnome-desktop gnome-shell gdm mutter gnome-session gnome-control-center gnome-randr gnome-initial-setup nautilus gnome-terminal

# (@) PKG Distro derived versioning
# in comparision to updating, this ensures that the system is in a reliable state matching the exact versions of
# packages meant for that version of the distro, abiding more by single source of truth.
# While updating, some thing might progress, but others might break, you want a system that works correctly
# and not just packages with a higher version number that may not properly coordinate with each other.
# This also ensures as a way that things are re-initializated before updating, if you want to.
# Works best with non rawhide versions of the distro. This is better for bootc, in general
echo "⭕ --- (@) Sync packages ---"
dnf5 -y distro-sync --skip-unavailable --skip-broken --allowerasing

# (^) PKG UPD
# This method is not practical for the philosophy of an atomic distro, distro-sync works better for the use case
#echo "⭕ --- (^) Update packages ---"
#dnf5 update -y --skip-unavailable --allow-downgrade --allowerasing

# (+) PKG ADD
echo "⭕ --- (+) Add packages ---"

sysPkg+ \
        fedora-gpg-keys \
        dnf-plugins-core etckeeper-dnf dnf-repo

sysPkg+ \
        cosmic-app-library cosmic-applets cosmic-panel cosmic-workspaces cosmic-bg cosmic-comp cosmic-desktop cosmic-greeter cosmic-idle cosmic-osd cosmic-session cosmic-randr cosmic-screenshot cosmic-settings cosmic-settings-daemon greetd greetd-selinux cosmic-edit cosmic-icon-theme cosmic-launcher \
        cosmic-ext-applet-tailscale cosmic-ext-applet-clipboard-manager cosmic-ext-applet-emoji-selector cosmic-ext-applet-external-monitor-brightness cosmic-ext-storage cosmic-ext-tasks cosmic-ext-tweaks \
        boinc-client boinc-client-static \
        uutils-coreutils util-linux fish \
        tuned tuned-ppd tuned-utils-systemtap \
        obs-studio obs-studio-libs obs-studio-plugin-browser \
        rustup cargo clippy git gh zed \
        peazip zstd neohtop \
        hblock tor mosh tailscale openssh persepolis \
        podman podman-docker \
        rocm cuda \
        steam steam-devices

#fedora-gpg-keys fedora-repos flatpak-libs flatpak-selinux
#flatpak-session-helper kernel-modules-extra libei libportal
#xdg-desktop-portal
#obs-studio-plugin-vaapi obs-studio-plugin-vkcapture obs-studio-plugin-droidcam
#ghostty-nightly ghostty-nightly-fish-completion ghostty-nightly-shell-integration
#amd-gpu-firmware amd-ucode-firmware amdsmi am-utils
#nvidia-gpu-firmware libva-nvidia-driver envytools nvidia-patch
#distcc distcc-server
#host-spawn libei-utils
#libvirt-daemon-kvm
#nodejs
#obs-studio-plugin-droidcam obs-studio-plugin-vaapi
#pnpm preload qbittorrent qemu-kvm qemu-kvm-core
#uget
#aircrack-ng turbo-attack golang-github-redteampentesting-monsoon
#mesa-va-drivers-freeworld mesa-vdpau-drivers-freeworld mesa-vulkan-drivers-freeworld mesa-dri-drivers mesa-va-drivers mesa-vdpau-drivers mesa-vulkan-drivers mesa-libOSMesa mesa-compat-libOSMesa

## CONFLICTS ## ( Format: ChosenPackages | ConflictingPackages )
# warp-terminal | warp-cli ( warp-terminal already includes warp-cli )
# fedora-release-identity-cosmic-atomic fedora-release-cosmic-atomic ( this independent image is NOT cosmic atomic, spoofing it as one will cause conflicts )
# fedora-repos-rawhide ( only use repos in fsroot/usr/share/factory/etc/yum.repos.d or pre-packaged ones )
# cosmic-config-fedora ( We have our own config files )
# tuned tuned-ppd | power-profiles-daemon | tlp tlp-pd tlp-rdw | auto-cpufreq ( TuneD better integrated w/ modern standards, drivers, pstate support, less breakage points by low configurability )

# === List ===
#echo "⭕ --- (=) List DNF5 packages ---"
#dnf5 list --installed

# === Clean ===
echo "⭕ --- (🧹) Clean DNF5 ---"
dnf5 autoremove -y # May misinterpret what is "essential" for the OS, usually safe
dnf5 clean all -y
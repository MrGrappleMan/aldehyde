#!/usr/bin/env fish
echo "🚩 --- Run 'dnf5.fish' ---"

# DNF5: Install pkgs to the immutable base, only most essentials

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

echo " --- (-) Delete packages ---"
# (@) PKG Distro derived versioning
# vs updating, this ensures that the system is in a reliable state matching the exact versions of
# packages meant for that version of the distro, abiding more by SSoT.
# While updating, some thing might progress, but others might break, you want a system that works correctly
# and not just packages with a higher version number that may not properly coordinate with each other.
# This also ensures as a way that things are re-initializated before updating, if you want to.
# Works best with non rawhide versions of the distro. This is better for bootc, in general
echo "⭕ --- (@) Sync packages ---"
dnf5 -y distro-sync --skip-unavailable --skip-broken --allowerasing
echo " --- (@) Sync packages ---"

# (^) PKG UPD
# This method is not practical for the philosophy of an atomic distro, distro-sync works better for the use case
#echo "⭕ --- (^) Update packages ---"
#dnf5 update -y --skip-unavailable --allow-downgrade --allowerasing
#echo " --- (^) Update packages ---"

# (+) PKG ADD
echo "⭕ --- (+) Add packages ---"

sysPkg+ \
        fedora-gpg-keys \
        dnf-plugins-core etckeeper-dnf dnf-repo

sysPkg+ \
        xdg-desktop-portal-cosmic cutecosmic-qt6 cosmic-app-library cosmic-applets cosmic-panel cosmic-workspaces cosmic-bg cosmic-comp cosmic-notifications cosmic-desktop cosmic-greeter cosmic-idle cosmic-osd cosmic-session cosmic-randr cosmic-screenshot cosmic-settings cosmic-settings-daemon greetd greetd-selinux cosmic-icon-theme cosmic-launcher \
        cosmic-reader cosmic-edit cosmic-player cosmic-files \
        cosmic-ext-applet-places-menu cosmic-ext-applet-sysinfo cosmic-ext-applet-ollama cosmic-ext-applet-tailscale cosmic-ext-applet-clipboard-manager cosmic-ext-applet-emoji-selector cosmic-ext-applet-external-monitor-brightness cosmic-ext-applet-logomenu \
        cosmic-ext-disks cosmic-ext-examine cosmic-ext-storage cosmic-ext-tasks cosmic-ext-tweaks cosmic-ext-camera cosmic-ext-calculator cosmic-ext-xcalendar \
        xdg-desktop-portal flatpak flatseal flatpak-libs flatpak-selinux flatpak-session-helper libportal \
        uutils-coreutils util-linux kernel-modules-extra fish \
        tuned tuned-ppd tuned-utils-systemtap \
        obs-studio obs-studio-libs obs-studio-plugin-browser obs-studio-plugin-vaapi obs-studio-plugin-droidcam \
        zstd mission-center \
        hblock tor mosh tailscale openssh persepolis rsync rclone rclone-browser \
        podman podman-docker \
        rocm cuda \
        steam steam-devices

#rustup cargo clippy git gh zed
#amd-gpu-firmware amd-ucode-firmware amdsmi am-utils
#nvidia-gpu-firmware libva-nvidia-driver envytools nvidia-patch
#host-spawn libei libei-utils
#pnpm preload
#qemu-kvm qemu-kvm-core libvirt-daemon-kvm
#mesa-va-drivers-freeworld mesa-vdpau-drivers-freeworld mesa-vulkan-drivers-freeworld mesa-dri-drivers mesa-va-drivers mesa-vdpau-drivers mesa-vulkan-drivers mesa-libOSMesa mesa-compat-libOSMesa

## CONFLICTS ## ( Format: ChosenPackages | ConflictingPackages )
# NONE | fedora-release-identity-cosmic-atomic fedora-release-cosmic-atomic ( this independent image is NOT cosmic atomic, recognizing it as one will cause conflicts )
# NONE | fedora-repos-rawhide ( only use repos in fsroot/usr/share/factory/etc/yum.repos.d or pre-packaged ones )
# NONE | cosmic-config-fedora ( We have our own configs )
# tuned tuned-ppd | power-profiles-daemon , tlp tlp-pd tlp-rdw , auto-cpufreq ( TuneD better integrated w/ modern standards, drivers, pstate support, less breakage points by low configurability )
echo " --- (+) Add packages ---"

# === List ===
#echo "⭕ --- (=) List DNF5 packages ---"
#dnf5 list --installed
#echo " --- (=) List DNF5 packages ---"

# === Clean ===
echo "⭕ --- (🧹) Clean DNF5 ---"
dnf5 autoremove -y # Clean non essential packages
dnf5 clean all -y # Clean all cached data
echo " --- (🧹) Clean DNF5 ---"

echo " --- Run 'dnf5.fish' ---"
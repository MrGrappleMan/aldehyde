#!/usr/bin/env fish
echo "🚩 --- Run 'dnf5.fish' ---"

# DNF5: Install only essential pkgs to the immutable base

### Notes:
# Always update system before installing packages.
# COSMIC - Modern DE, better performance and efficiency
# 
# ROCm and CUDA work in distrobox
# Install your dev files to home folder, distrobox or flatpak. They will probably work in any case. Just set it up with care as it is not a traditional system.

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
        @gnome-desktop gnome-shell gdm mutter gnome-session gnome-control-center gnome-randr gnome-initial-setup nautilus gnome-terminal \
        rpm-ostree \
        wpa_supplicant
echo " --- (-) Delete packages ---"

# (@) PKG Distro derived versioning
# Distro-sync - Packages versions are set to the version meant for that version of the distro
# for coordinated versioning.
# 
# Updating - Packages are bindly updated, but some may break compatibility
# with each other and not coordinate
# 
# You want a system that works correctly,
# and not just packages with a higher version that may not properly coordinate with each other.
# Distro-sync also fixes conflicts and missing dependencies
# May behave abnormally on rawhide versions. This is better for the bootc philosophy, overall.
echo "⭕ --- (@) Sync packages ---"
#dnf5 -y distro-sync --skip-unavailable --skip-broken --allowerasing
echo " --- (@) Sync packages ---"

# (^) PKG UPD
# Use distro-sync instead of update
#echo "⭕ --- (^) Update packages ---"
#dnf5 update -y --skip-unavailable --allow-downgrade --allowerasing
#echo " --- (^) Update packages ---"

# (+) PKG ADD
echo "⭕ --- (+) Add packages ---"
sysPkg+ \
        fedora-gpg-keys \
        dnf-plugins-core etckeeper-dnf dnf-repo
sysPkg+ \
        xdg-desktop-portal-cosmic cutecosmic-qt6 cosmic-app-library cosmic-applets cosmic-panel cosmic-workspaces cosmic-bg cosmic-comp cosmic-notifications cosmic-desktop cosmic-greeter cosmic-idle cosmic-osd cosmic-session cosmic-randr cosmic-screenshot cosmic-settings cosmic-settings-daemon cosmic-icon-theme cosmic-launcher \
        cosmic-reader cosmic-edit cosmic-player cosmic-files \
        cosmic-ext-applet-ollama cosmic-ext-applet-tailscale cosmic-ext-applet-clipboard-manager cosmic-ext-applet-emoji-selector cosmic-ext-applet-external-monitor-brightness \
        cosmic-ext-disks cosmic-ext-examine cosmic-ext-storage cosmic-ext-tasks cosmic-ext-tweaks cosmic-ext-camera cosmic-ext-calculator cosmic-ext-xcalendar \
        \
        greetd greetd-selinux \
        \
        xdg-desktop-portal flatpak flatseal flatpak-libs flatpak-selinux flatpak-session-helper libportal \
        uutils-coreutils util-linux \
        fish zsh \
        tuned tuned-ppd tuned-utils-systemtap \
        zstd mission-center \
        \
        hblock tor mosh tailscale openssh rsync rclone playit iwd \
        \
        podman podman-docker \
        kmod-ryzen-smu kernel-modules-extra
        

# Install your dev apps by flatpak or to distrobox,
#amd-gpu-firmware amd-ucode-firmware amdsmi am-utils
#nvidia-gpu-firmware libva-nvidia-driver envytools nvidia-patch
#host-spawn libei libei-utils
#pnpm
#qemu-kvm qemu-kvm-core libvirt-daemon-kvm
#mesa-va-drivers-freeworld mesa-vdpau-drivers-freeworld mesa-vulkan-drivers-freeworld mesa-dri-drivers mesa-va-drivers mesa-vdpau-drivers mesa-vulkan-drivers mesa-libOSMesa mesa-compat-libOSMesa
## CONFLICTS ## ( Format: ChosenPackages | ConflictingPackages (reason) )
# NONE | fedora-release-identity-cosmic-atomic fedora-release-cosmic-atomic ( this independent image is NOT cosmic atomic, recognizing it as one will cause conflicts )
# NONE | fedora-repos-rawhide ( only use repos in fsroot/usr/share/factory/etc/yum.repos.d or pre-packaged ones )
# NONE | cosmic-config-fedora ( We have our own configs )
# tuned tuned-ppd | power-profiles-daemon , tlp tlp-pd tlp-rdw , auto-cpufreq ( TuneD better integrated w/ modern standards, drivers, pstate support, less breakage points by low configurability )
echo " --- (+) Add packages ---"

# === Clean ===
echo "⭕ --- (🧹) Clean DNF5 ---"
dnf5 autoremove -y # Clean non essential packages
dnf5 clean all -y # Clean all cached data
echo " --- (🧹) Clean DNF5 ---"

echo " --- Run 'dnf5.fish' ---"
#!/usr/bin/env fish
echo "🚩 --- Run 'dnf5.fish' ---"

# DNF5: For installing essential packages to the system's immutable base

### Notes:
# Always update system before installing packages.
# Brave - Efficient, aligned w/ community more than most browsers, practical QoL features, Tor support
# COSMIC - Modern DE, better performance and efficiency

# 📛 Handling
function sysPkg+T -d "Fallback method to just make things install, reducing parallelism, avoid it, trace the core issue"
    set -l pkgs (string split -n " " -- (string join " " $argv))

    for pkg in $pkgs
        echo "🛠️ Install try: $pkg"
        dnf5 install -y --skip-broken --allowerasing $pkg

        if test $status -ne 0
            echo "⚠️ $pkg install failed!"
        else
            echo "✅ $pkg installed"
        end
    end
end
alias sysPkg+ "dnf5 install -y --skip-broken --allowerasing" # Batches operations, faster builds
alias sysPkgq "echo Ignored modifications list,"

# (^) PKG UPD
#echo "⭕ --- (^) Update packages ---"
#dnf5 update -y --allowerasing
# Linter hadn't transitioned to bootc yet, still wants /ostree directory
# Distro syncing is better

#fedora-gpg-keys fedora-repos flatpak-libs flatpak-selinux
#flatpak-session-helper kernel-modules-extra libei libportal
#p7zip p7zip-plugins
#util-linux xdg-desktop-portal
#obs-studio-plugin-vaapi obs-studio-plugin-vkcapture obs-studio-plugin-droidcam
#ghostty-nightly ghostty-nightly-fish-completion ghostty-nightly-shell-integration
#amd-gpu-firmware amd-ucode-firmware amdsmi am-utils
#nvidia-gpu-firmware libva-nvidia-driver envytools nvidia-patch
#distcc distcc-server
#host-spawn libei-utils
#libvirt-daemon-kvm
#nodejs obs-studio-plugin-browser
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
echo "⭕ --- (0) Clean DNF5 ---"
dnf5 autoremove -y # May misinterpret what is "essential" for the OS, usually safe
dnf5 clean all -y

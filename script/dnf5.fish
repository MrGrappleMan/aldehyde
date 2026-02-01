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

# 📛 Aliases - For easier handling of commands
function sysPkg+Obsolete -d "Add pkg if present in dnf repos, was originally for rpm-ostree"
    set -l packages $argv
    # Handle cases where packages are passed as a single quoted string with spaces
    if test (count $argv) -eq 1; and string match -q '* *' $argv[1]
        set packages (string split ' ' $argv[1])
    end

    set -l install_list

    for pkg in $packages
        # 'dnf5 list' with --available is fast and returns exit code 0 if found
        if dnf5 list --quiet --available $pkg >/dev/null 2>&1
            set -a install_list $pkg
        else
            echo "Package '$pkg' not found in repos, skipping..."
        end
    end

    if test (count $install_list) -gt 0
        # dnf5 install is inherently idempotent (won't re-install if present)
        dnf5 install -y --allowerasing --skip-broken --skip-unavailable --allow-downgrade $install_list
    end
end
alias sysPkg+ "dnf install -y --allowerasing --skip-broken --skip-unavailable --allow-downgrade --setopt=install_weak_deps=False"
alias sysPkgq "echo Temporarily disable package modification, just add a 'q'"
alias sysPkg- "dnf remove -y"

# PKG DEL
echo "⭕ --- Delete system packages ---"

sysPkg- docker docker-compose moby-engine \
        firefox \
        code

# @gnome-desktop gnome-software gnome-shell-extension-common 'gnome-terminal*' 'nautilus*' 'gedit*' 'yelp*' 'adwaita-icon-theme*' 'baobab' 'evince' 'google-gnu-free-*'

echo "✅ --- Delete system packages ---"

# PKG UPD
echo "⭕ --- Update system packages ---"
dnf update -y --allowerasing --skip-unavailable --allow-downgrade
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

sysPkg+ \
        dnf-plugins-core etckeeper-dnf dnf-repo \
        boinc-client boinc-client-static boinc-manager \
        cosmic-app-library cosmic-applets cosmic-panel cosmic-workspaces cosmic-bg cosmic-comp cosmic-desktop cosmic-greeter cosmic-idle cosmic-osd cosmic-session cosmic-randr cosmic-screenshot cosmic-settings cosmic-settings-daemon xdg-desktop-portal-cosmic greetd \
        uutils-coreutils \
        obs-studio obs-studio-libs \
        git gh zed \
        gemini-cli ollama \
        brave-browser-nightly brave-keyring \
        hblock mosh \
        mission-center \
        rustup cargo clippy \
        podman podman-docker

echo "✅ --- Add system packages ---"

### Reserved:

## REFERENCE ##
#cpp fedora-gpg-keys fedora-repos flatpak-libs flatpak-selinux
#flatpak-session-helper git kernel-modules-extra libei libportal openssh
#openssh-server p7zip p7zip-plugins
#tailscale util-linux xdg-desktop-portal

## CONFLICTS ##
# warp-cli | warp-terminal, already includes warp-cli
# tlp, tlp-rdw | tuned-ppd, power-profiles-daemon ( architectural shift in tlp therefore it conflicts with them )
# fedora-release-identity-cosmic-atomic fedora-release-cosmic-atomic ( this independent image is NOT cosmic atomic, spoofing it as one will cause conflicts )
# fedora-repos-rawhide ( only obey this image yum.repos.d, nothing else )
# cosmic-config-fedora ( We have our own config files )


## PORTS ## for GUI/applications that work better on other package managers
# boinc-manager | fpk:edu.berkeley.BOINC

#obs-studio-plugin-vaapi obs-studio-plugin-vkcapture obs-studio-plugin-droidcam
## GhosTTY ## ghostty-nightly ghostty-nightly-fish-completion ghostty-nightly-shell-integration

     ## Pentesting / Hacking:
      # aircrack-ng turbo-attack golang-github-redteampentesting-monsoon
    ### Gaming:-
     ## Steam:
      # steam steam-devices
     ## Vavoom:
      # vavoom vavoom-engine

    ### Graphics:-
     ## Mesa:
      # mesa-va-drivers-freeworld mesa-vdpau-drivers-freeworld mesa-vulkan-drivers-freeworld
      # mesa-dri-drivers
      # mesa-va-drivers mesa-vdpau-drivers mesa-vulkan-drivers
      # mesa-libOSMesa mesa-compat-libOSMesa
     ## AMD: amd-gpu-firmware amd-ucode-firmware amdsmi am-utils
     ## Nvidia: nvidia-gpu-firmware libva-nvidia-driver envytools nvidia-patch

# Kernel Arguments
# 🛠️ UNIVERSAL KERNEL ARGUMENT EXPLANATIONS
# rhgb     # 🏙 Disabled: Less boot overhead and less conflicts with drivers, at the cost of UX beauty
# quiet    # 🤫 Enabled: Simpler, focused debugging on errors than general stats
# threadirqs                 # 🧵 Enabled: Moves hardware interrupt handlers into threads, allowing the scheduler to prioritize tasks.
# sysrq_always_enabled=1     # 🔑 Enabled: Provides a low-level interface to rescue a frozen system (e.g., REISUB), regardless of UI state.
# consoleblank=180           # 🖥️ Enabled: Prevents TTY from display burn in and efficiency
# (n) profile                # 🚫 Disabled: Stops the kernel from collecting profiling data, saving CPU cycles.
# bluetooth.disable_ertm=0   # 📶 Enabled: Enhanced Retransmission Mode for modern BT peripherals.
# (n) nomodeset              # 🚫 Disabled: Allows the kernel to use high-performance GPU drivers (KMS) instead of slow VESA fallbacks.
# loglevel=3                 # 📉 Enabled: Limits logging to 'Error' level; prevents the 'dmesg' buffer from being flooded by minor warnings.
# preempt=full               # ⚡ Enabled: Allows the kernel to be interrupted more aggressively; improves desktop and audio responsiveness.
# systemd.zram=0             # 🛑 Disabled: Never use with zswap
# zswap.enabled=1            # 🗜️ Enabled: Intercepts pages moving to swap and compresses them in RAM to reduce physical Disk I/O.
# zswap.shrinker_enabled=Y   # ♻️ Enabled: Automatically evicts the coldest compressed pages to disk when RAM is needed elsewhere.
# zswap.zpool=zsmalloc       # 🏗️ Enabled: Uses a highly efficient memory allocator that reduces fragmentation in compressed memory pools.
# zswap.compressor=lz4       # 🚀 Enabled: Prioritizes decompression speed over compression ratio; ideal for modern high-frequency CPUs.
# nowatchdog                 # 🐕 Enabled: Disables the 'hang' detector; frees up a hardware timer and prevents NMI-related latency spikes.
# clocksource=tsc            # ⏱️ Enabled: Forces the 'Time Stamp Counter'; the lowest latency method for the OS to track time on x86.
# pcie_aspm=on               # 🍃 Enabled: Enables Active State Power Management; allows PCIe links to enter low-power states when idle.
# amd_pstate=guided          # 💎 Enabled: Requests the hardware to manage its own clock speeds based on workload, rather than OS-fixed steps.
# amd_pstate.enable=1        # ✅ Enabled: Activates the modern AMD P-State driver for finer-grained power/performance control on Zen CPUs.
# amd_pstate.shared_mem=1    # 🧠 Enabled: Allows the CPU and OS to communicate via shared memory for faster frequency transitions.
# intel_pstate=active        # 🏎️ Enabled: Uses Intel's hardware-managed P-states (HWP) for superior efficiency compared to legacy ACPI.
# amdgpu.sg_display=1        # 📽️ Enabled: Enables Scatter/Gather display; allows the GPU to use non-contiguous memory for frame buffers.
# pci=realloc=on             # 🗺️ Enabled: Allows the kernel to re-map PCI resources if the BIOS didn't allocate enough space (BAR).
# intel_pstate=guided does not exist
# lz4 > lzo in terms of efficiency and modernity. zstd fine for speed but great for balanced usage. brotli is unsuitable for this, as memory content is dynamic.
# lz4 overall lowest latency

# === List ===
echo "⭕ --- List DNF5 packages ---"
dnf5 list --installed
echo "✅ --- List DNF5 packages ---"

# === Clean ===
echo "⭕ --- Clean DNF5 packages ---"
dnf5 clean all -y
echo "✅ --- Clean DNF5 packages ---"

echo "🏁 --- Run 'dnf5.fish' ---"

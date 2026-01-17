#!/usr/bin/env fish

# NOTICE: rpm-ostree will soon be decaprated in favour of bootc
# Transitioning to bootc is intended to move system management toward a pure image-based model,
# which effectively removes the client-side package layering and management functionality that rpm-ostree supports. The core idea is that the entire operating system state is defined by a container image.
# The entire package management part will be removed, requiring you to shift to userspace components, like Flatpak and Distrobox
# Highly stable, faster to update and universally standardized.
# Never layer any packages onto the image and thus, avoid rpm-ostree as much as you can

# 📛 Alias
alias rpm-ostree "rpm-ostree"
function rotPkg+ -d "RPM-OSTree add package if present(dependancy checks not implemented yet)"
    set packages $argv
    if test (count $argv) -eq 1 -a -n (string match '* *' $argv[1])
        set packages (string split ' ' $argv[1])
    end

    set -l install_list

    for pkg in $packages
        set -l output (rpm-ostree search $pkg)
        set -l lines (string split \n -- $output)
        set -l found false

        for line in $lines
            if string match -q '* *' $line
                set -l candidate (string split -m 1 ' ' $line)[1]
                if test "$candidate" = "$pkg"
                    set found true
                    break
                end
            end
        end

        if $found
            set install_list $install_list $pkg
        end
    end

    if test (count $install_list) -gt 0
        rpm-ostree install --allow-inactive --idempotent -y $install_list
    end
end
alias rotPkg+Adv "rpm-ostree install --allow-inactive --idempotent -y" # Use if you know the package exists and there won't be dependency conflicts
alias rotPkg- "rpm-ostree uninstall --allow-inactive --idempotent -y"

# PKG ADD

### Notes:
### Always update system before installing packages. Avoid layering packages that end up in InactiveRequests
### Packages are now uncategorized, this is to simplify drop-in from 'rpm-ostree status' 
###  Systemd unit files in /etc/systemd/system/ may cause an rpm-ostree hardlinking 
### file exists error when you try to install the actual packages that provide those same files later. 
### Systemd units placed in /etc/systemd/system/ are part of the mutable host configuration, 
### which rpm-ostree attempts to manage or migrate across deployments. When a package providing the exact same 
### file is introduced, the conflict occurs. It it happens, rename the doubtful one to *.bak, do the rpm-ostree operation, rename to original if successful.

   echo "🢷 Adding RPM-OSTree packages, this may take time - searching for packages"
   #rotPkg+ "boinc-client boinc-client-static brotli cargo clippy code-insiders \
    #                       cosmic-app-library cosmic-applets cosmic-comp cosmic-config-fedora cosmic-desktop \
     #                      cosmic-edit cosmic-greeter cosmic-idle cosmic-osd cosmic-session cosmic-settings \
      #                     cosmic-settings-daemon cosmic-store distcc distcc-server dnf-plugins-core dnf-repo \
       #                    dnfdaemon dnfdaemon-selinux etckeeper-dnf featherpad fedora-release-cosmic-atomic \
        #                   fedora-repos-ostree fedora-repos-rawhide flatseal gemini-cli gh \
         #                  google-chrome-canary greetd hblock host-spawn initial-setup-gui-wayland-cosmic \
          #                 inkscape java-latest-openjdk krita krita-libs libei-utils libreoffice \
           #                libvirt-daemon-kvm mcpelauncher-manifest mcpelauncher-ui-manifest mission-center \
            #               mosh msa-manifest nodejs obs-studio obs-studio-libs obs-studio-plugin-browser \
             #              obs-studio-plugin-droidcam obs-studio-plugin-vaapi ollama persepolis plymouth-kcm \
              #             pnpm preload qbittorrent qemu-kvm qemu-kvm-core rocm rust \
               #            rust-zram-generator-devel rustup snapd systemd-swap thunar tor torbrowser-launcher \
                #           trayscale uget uutils-coreutils warp-terminal xdg-desktop-portal-cosmic"

### Reserved/reference pacakges:

## REFERENCE ##
#cpp fedora-gpg-keys fedora-repos flatpak-libs flatpak-selinux
#flatpak-session-helper gcc git kernel-modules-extra libei libportal openssh
#openssh-server p7zip p7zip-plugins plymouth plymouth-core-libs plymouth-scripts
#tailscale util-linux vim xdg-desktop-portal

## CONFLICTS ##
# warp-cli | warp-terminal ( it already includes warp-cli )
# tlp, tlp-rdw | tuned-ppd, power-profiles-daemon ( architectural shift in tlp. great but inconvenient, therefore it conflicts with the base image, error: Checkout tlp-1.9.0-6.fc44.noarch: Hardlinking 22/4ea4cdcf902e721f5550bca4e5e6e1630672751aa0931cdad5634f7eb49201.file to net.hadess.PowerProfiles.service: File exists )

## PORTS ## for GUI/applications that work better on other package managers
# boinc-manager | fpk:edu.berkeley.BOINC

#obs-studio-plugin-vaapi obs-studio-plugin-vkcapture obs-studio-plugin-droidcam
## GhosTTY ## ghostty-nightly ghostty-nightly-fish-completion ghostty-nightly-shell-integration

     ## Pentesting / Hacking:
      # aircrack-ng turbo-attack golang-github-redteampentesting-monsoon
     ## Docker:
      # docker-cli docker-compose docker-compose-switch docker-buildx docker-buildkit
     ## C / C++:
      # gcc gcc-c++ cpp
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
# rhgb                       # 🏙 Disabled: Less boot overhead and less conflicts with drivers, at the cost of UX beauty
# quiet                      # 🤫 Enabled: Simpler, focused debugging on errors than general stats
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

echo "🗣️ Modifying kernel arguments"
rpm-ostree kargs \
  --delete-if-present=rhgb \
  --append-if-missing=quiet \
  --append-if-missing=threadirqs \
  --append-if-missing=sysrq_always_enabled=1 --delete-if-present=sysrq_always_enabled=0 \
  --append-if-missing=consoleblank=180 \
  --delete-if-present=profile \
  --delete-if-present=bluetooth.disable_ertm=1 --append-if-missing=bluetooth.disable_ertm=0 \
  --delete-if-present=nomodeset \
  --append-if-missing=loglevel=3 \
  --append-if-missing=preempt=full \
  --delete-if-present=systemd.zram=1 --append-if-missing=systemd.zram=0 \
  --append-if-missing=zswap.enabled=1 --delete-if-present=zswap.enabled=0 \
  --append-if-missing=zswap.shrinker_enabled=Y --delete-if-present=zswap.shrinker_enabled=N \
  --append-if-missing=zswap.zpool=zsmalloc \
  --append-if-missing=zswap.compressor=lz4 --delete-if-present=zswap.compressor=lzo --delete-if-present=zswap.compressor=zstd \
  --append-if-missing=nowatchdog --append-if-missing=clocksource=tsc \
  --append-if-missing=pcie_aspm=on --delete-if-present=pcie_aspm=off \
  --append-if-missing=amd_pstate=guided --append-if-missing=amd_pstate.enable=1 --delete-if-present=amd_pstate.enable=0 --append-if-missing=amd_pstate.shared_mem=1 \
  --append-if-missing=intel_pstate=active --append-if-missing=intel_pstate.enable=1 --delete-if-present=intel_pstate.enable=0 \
  --append-if-missing=amdgpu.sg_display=1 \
  --append-if-missing=pci=realloc=on

# intel_pstate=guided does not exist
# lz4 > lzo in terms of efficiency and modernity. zstd fine for speed but great for balanced usage. brotli is unsuitable for this, as memory content is dynamic.
# lz4 overall lowest latency

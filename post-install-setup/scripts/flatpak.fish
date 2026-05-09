#!/usr/bin/env fish

# Notes:
# Actively avoid electron-based applications to ensure efficient resource utilization - use native counterparts
# 

# 📛 Alias
alias fpk "flatpak --system" # Main alias
alias fpkr1 "flatpak --system remote-add --if-not-exists" # Repository add
alias fpkr0 "flatpak --system remote-delete --force" # Repository remove
alias fpkp1 "flatpak --system install -y --noninteractive --or-update" # Package add
alias fpkp0 "flatpak --system uninstall -y --noninteractive" # Package remove

# -----------------------------------------------------------------------------------------------------------------------------------------------

# ADD REPOS +
  fpkr1 flathub https://flathub.org/repo/flathub.flatpakrepo
  fpkr1 flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo
  fpkr1 cosmic https://apt.pop-os.org/cosmic/cosmic.flatpakrepo
  #fpkr1 eos-sdk https://ostree.endlessm.com/ostree/eos-sdk
  #fpkr1 igalia https://software.igalia.com/flatpak-refs/igalia.flatpakrepo
  #fpkr1 dragon-nightly https://cdn.kde.org/flatpak/dragon-nightly/dragon-nightly.flatpakrepo
  #fpkr1 eos-apps https://ostree.endlessm.com/ostree/eos-apps
  #fpkr1 webkit https://software.igalia.com/flatpak-refs/webkit-sdk.flatpakrepo
  fpkr1 gnome-nightly https://nightly.gnome.org/gnome-nightly.flatpakrepo
  #fpkr1 webkit-sdk https://software.igalia.com/flatpak-refs/webkit-sdk.flatpakrepo
  #fpkr1 fedora oci+https://registry.fedoraproject.org
  #fpkr1 fedora-testing oci+https://registry.fedoraproject.org/#testing
  #fpkr1 rhel https://flatpaks.redhat.io/rhel.flatpakrepo
  #fpkr1 eclipse-nightly https://download.eclipse.org/linuxtools/flatpak-I-builds/eclipse.flatpakrepo
  #fpkr1 elementaryos https://flatpak.elementary.io/repo.flatpakrepo
  #fpkr1 pureos https://store.puri.sm/repo/stable/pureos.flatpakrepo

# Remove all user Flatpaks, system wide installs standardize location, save storage, keep user data seperate
   flatpak uninstall -u --all -y --noninteractive --force-remove

# ADD PKGS +
# You dont need the SDKs, install them for development else save space


  fpkp1 \
      org.gnome.Platform org.freedesktop.Platform org.kde.Platform \
      

  fpkp1 \
      org.freedesktop.Platform.VulkanLayer.lsfgvk//25.08 org.freedesktop.Platform.VulkanLayer.lsfgvk//24.08 \
      org.freedesktop.Platform.VulkanLayer.gamescope org.freedesktop.Platform.VulkanLayer.MangoHud org.freedesktop.Platform.VulkanLayer.OBSVkCapture org.freedesktop.Platform.VulkanLayer.vkBasalt

# "app.zen_browser.zen" > "org.mozilla.firefox" - Polished, user friendly
# "io.github.tobagin.karere" Uses GTK4 and is lightweight + native integration > "com.rtosta.zapzap" Electron based
# "org.equicord.equibop" More performant, despite electron based > "dev.vencord.Vesktop" 

  fpkp1 \
    com.rafaelmardojai.Blanket \
    io.github.flattool.Warehouse com.github.tchx84.Flatseal org.gnome.Boxes rs.ruffle.Ruffle \
    com.nuclearplayer.Nuclear com.spotify.Client com.warlordsoftwares.youtube-downloader-4ktube io.github.ecotubehq.player \
    io.github.brunofin.Cohesion org.onlyoffice.desktopeditors \
    io.ente.auth \
    io.frama.tractor.carburetor com.brave.Browser org.localsend.localsend_app \
    io.github.qwersyk.Newelle \
    org.kde.krita org.upscayl.Upscayl \
    org.telegram.desktop io.github.tobagin.karere org.equicord.equibop org.gnome.Fractal \
    com.github.wwmm.easyeffects

# Permission modifications
flatpak override -u --unset-env=ZED_FLATPAK_NO_ESCAPE dev.zed.Zed
#export appid=rocks.shy.VacuumTube
#mkdir -p ~/.config/lsfg-vk
#flatpak override --user --filesystem=/home/$USER/.config/lsfg-vk:rw $appid
#flatpak override --user --filesystem=/home/$USER/local/share/Steam/steamapps/common:ro $appid
#flatpak override --user --env=LSFGVK_CONFIG=/home/$USER/.config/lsfg-vk/conf.toml $appid

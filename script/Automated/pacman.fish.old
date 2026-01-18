
### Assume repos installed yet at this phase, a base config with just the AUR will be used, else pacman errors for the missing mirrorlists and keys ###

# pacman commonflags list: --noconfirm --needed

## Adding repo keys
sudo rm -rf /var/lib/pacman/db.lck /etc/pacman.d/gnupg /var/lib/pacman/sync/* ~/pacman-git
sudo pacman -Syyuu --noconfirm
sudo pacman -Scc --noconfirm
sudo pacman-key --init
sudo pacman-key --populate archlinux

# Chaotic AUR
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB
sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

# Replace basic cfg with main cfg here #
rm -f /etc/pacman.conf
cp /etc/pacman.conf.fyn-mod /etc/pacman.conf

# Get paru

### Now starting to utilize paru ###

sudo pacman -Syy --noconfirm base-devel base git

for getpkgs in \
 google-chrome-dev ramroot-btrfs \
 pipewire libpipewire-git wireplumber-git libwireplumber-git \
 paru mc-git pi-hole-standalone snowflake-pt-proxy flatpak snap
#  hyprland-git eww-git flatpak
do paru -Suu --noconfirm $getpkgs
done

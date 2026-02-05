#!/usr/bin/env bash
set -Eeuo pipefail

#-------------------------
# Helpers
#-------------------------
require_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "You are not ROOT, rerunning with sudo..."
        exec sudo bash "$0" "$@"
    fi
}

prompt_nonempty() {
    local var prompt secret=false
    prompt="$1"
    [[ "${2:-}" == "secret" ]] && secret=true

    while :; do
        if $secret; then
            read -rsp "$prompt" var
            echo
        else
            read -rp "$prompt" var
        fi

        [[ -n "$var" ]] && { echo "$var"; return; }
        echo "Input cannot be empty, try again."
    done
}

#-------------------------
# Root check
#-------------------------
require_root "$@"

#-------------------------
# User Input
#-------------------------
hostname="$(prompt_nonempty 'Hostname: ')"
ROOT_PASSWORD="$(prompt_nonempty 'Root Password: ' secret)"

read -rp "Config (default: ah-w): " config
config="${config:-ah-w}"

read -rp "Branch (default: master): " branch
branch="${branch:-master}"

#-------------------------
# Disk Selection
#-------------------------
lsblk
read -rp "Which Drive? (e.g. sda, /dev/sda, nvme0n1): " drive
[[ "$drive" != /dev/* ]] && drive="/dev/$drive"

echo "Partitioning $drive..."

#-------------------------
# Partitioning
#-------------------------
parted -s $drive -- mklabel gpt
parted -s $drive -- mkpart ESP fat32 1MiB 2049MiB
parted -s $drive -- set 1 esp on
parted -s $drive -- mkpart root ext4 2050MiB -8GiB
parted -s $drive -- mkpart swap linux-swap -8GiB 100%

partprobe "$drive"
udevadm settle
sleep 1

#-------------------------
# Device suffix handling
#-------------------------
suffix=""
[[ "$drive" =~ (nvme|mmcblk) ]] && suffix="p"

boot="${drive}${suffix}1"
root="${drive}${suffix}2"
swap="${drive}${suffix}3"

#-------------------------
# Formatting
#-------------------------
echo "Formatting disks..."
mkfs.fat -F32 -n boot "$boot"
mkfs.ext4 -F -L nixos "$root"
mkswap -f -L swap "$swap"

#-------------------------
# Mounting
#-------------------------
echo "Mounting disks..."
sleep 2
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
swapon "$swap"

#-------------------------
# Install
#-------------------------
echo "Installing system..."
mkdir -p /mnt/etc
git clone --depth 1 --branch "$branch" \
    https://github.com/iLikeToCode/nixos-config \
    /mnt/etc/nixos

nixos-install --flake "/mnt/etc/nixos#$config" --no-root-password

echo "root:$ROOT_PASSWORD" | nixos-enter -c "chpasswd"

#-------------------------
# Reboot
#-------------------------
echo "Rebooting in 5 seconds..."
sleep 5
reboot

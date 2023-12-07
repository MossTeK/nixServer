#!/run/current-system/sw/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root. Please use sudo or run as root."
    exit 1
fi

touch installLog.txt
installLog="$(dirname "$(readlink -f "$0")")/installLog.txt"

#Main function
function main() {
    
    for arg in "$@"; do
        $arg | tee $installLog
        if $? >> $installLog; then
           echo "ran $arg" | tee $installLog
        else
           echo "unable to run $arg" | tee $installLog
        fi
    done

}

#function to partition drive
function partition () {
# Partitioning the disk using parted
parted /dev/sda -- mklabel msdos
parted /dev/sda -- mkpart primary 1MB -8GB
parted /dev/sda -- set 1 boot on
parted /dev/sda -- mkpart primary linux-swap -8GB 8GB
parted /dev/sda -- mkpart primary ext4 8GB 100%

# Check if partitioning was successful
if [[ $? -ne 0 ]]; then
    echo "Error: Partitioning /dev/sda failed."
    exit 1
fi

# Format the partitions
mkfs.ext4 -L nixos /dev/sda1
mkswap -L swap /dev/sda2
swapon /dev/sda2

# Mount the root partition
mount /dev/disk/by-label/nixos /mnt

# Check if formatting was successful
if [[ $? -ne 0 ]]; then
    echo "Error: Formatting partitions failed."
    exit 1
fi

}


#Nix install

fucntion installNix () {
# Generate NixOS configuration
nixos-generate-config --root /mnt
sed -i 's/^# \(boot.loader.grub.device = "\/dev\/sda"; # or "nodev" for efi only\)/\1/' your_file.conf
nixos-install

if [ $? -eq 0 ]; then
    echo "nixos-install was successful"
else
    echo "nixos-install failed"
    exit 1
fi

#add home manager
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update

#curling configuration.nix
curl https://raw.githubusercontent.com/MossTeK/nixConfigTemplate/main/configuration.nix > /mnt/etc/nixos/configuration.nix

#reboot nix instance
sudo reboot
}

main "partition" "installNix"
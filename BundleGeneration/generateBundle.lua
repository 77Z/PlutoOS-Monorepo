#!/usr/bin/env lua

--[[

PlutoOS bundle generation

This script generates the images that get installed
into live PlutoOS A/B partitioned systems

The pacman package sources are listed in the pluto-pacman.conf
that lives next to this script. It uses mostly base archlinux
stuff but there are some package overrides provided by "server"

"server" is expected to belong in /etc/hosts and points to the
PlutoOS live pacman repo.

]]

local dbg = require('debugger')

-- Global config settings

-- excludes nvidia

local bundlePackages = [[

amd-ucode
intel-ucode

vulkan-radeon
vulkan-intel
intel-gpu-tools
intel-media-driver

vulkan-extra-tools
vulkan-extra-layers
vulkan-validation-layers

alsa-card-profiles
b43-fwcutter
sof-firmware

base
bolt
ark
bc
bluez
bluez-utils
btop
distrobox
podman
efibootmgr
ethtool
filelight
flatpak
fprintd
gwenview
htop
kalarm
kate
kamoso
kdeconnect
kfind
khelpcenter
konsole
linux
linux-firmware
linux-headers
vim
networkmanager
nvtop
okular
powertop
plymouth
rauc
thermald
tlp
unzip
zip
plasma
cups cups-pdf
system-config-printer
noto-fonts
noto-fonts-cjk
noto-fonts-emoji
samba
fish
openssh
fwupd
sshfs
dolphin
wget
kwalletmanager
pipewire
pipewire-pulse
pipewire-jack
pipewire-alsa
ncdu
pluto-customizations
pluto-os-system-config
pluto-update-manager
pluto-system-services
pluto-bootloader-backend
pluto-notification-helper
tailscale
grub
jc
]]


print("What PlutoOS version is this? (e.g. 2025-8)")
local plutoOSVersion = io.read()

print("Making dirs")
dbg()
os.execute("mkdir -p bundle targetroot pacman-cache")

print("Making root filesystem")
os.execute("fallocate -l10G ./bundle/root.ext4")
-- os.execute("mkfs.ext4 ./bundle/root.ext4")
os.execute("mkfs.btrfs ./bundle/root.ext4") -- Still called .ext4 cause... history ig

print("Making boot filesystem")
os.execute("fallocate -l512M ./bundle/boot.ext4")
os.execute("mkfs.ext4 ./bundle/boot.ext4")

print("Writing bundle manifest")
local bundleManifest = io.open("./bundle/manifest.raucm", "w")
if bundleManifest == nil then
	error("Failed to open manifest file")
end
bundleManifest:write([[
[update]
compatible=PlutoFreeze
version=]] .. plutoOSVersion .. [[


[bundle]
format=verity

[image.rootfs]
filename=root.ext4

[image.bootfs]
filename=boot.ext4
]])
bundleManifest:close();


print("Mounting filesystems")
-- os.execute("sudo mount -t ext4 -o loop ./bundle/root.ext4 ./targetroot")
os.execute("sudo mount -t btrfs -o loop,compress=zstd ./bundle/root.ext4 ./targetroot")
os.execute("sudo mkdir ./targetroot/boot") -- sudo for root perms
os.execute("sudo mount -t ext4 -o loop ./bundle/boot.ext4 ./targetroot/boot")

-- print("Bridging cache dir...")
-- os.execute("sudo mkdir -p ./targetroot/var/cache/pacman/")
-- os.execute("bash -c 'sudo ln -s `pwd`/pacman-cache ./targetroot/var/cache/pacman/pkg'")

local pacmanFormattedPackages, _n = string.gsub(bundlePackages, "\n", " ")

local pacstrapCommand = "sudo pacstrap -c -C ./pluto-pacman.conf -K ./targetroot " .. pacmanFormattedPackages

print("Executing: " .. pacstrapCommand)
os.execute(pacstrapCommand)

print("Does everything look good? (Ctrl+C if not, Enter if yes)")
local _nothing = io.read();

print("Misc generation...")
os.execute("deno run --allow-all IndexFirmware.ts")
os.execute("sudo mv ./firmware.json ./targetroot/pluto/firmware.json")
os.execute("sudo chmod 0644 ./targetroot/pluto/firmware.json")

os.execute("deno run --allow-all InjectPlymouthMkinitcpio.ts")
os.execute("sudo mv ./mkinitcpio.conf ./targetroot/etc/mkinitcpio.conf")
os.execute("sudo chmod 0644 ./targetroot/etc/mkinitcpio.conf")

print("Writing chroot commands...")
local postPacstrap = io.open("./post-pacstrap.sh", "w")
if postPacstrap == nil then
	error("Failed to open post-pacstrap.sh file")
end
-- Commands to execute inside of chroot
postPacstrap:write([[
#!/usr/bin/env bash

# need to regen initramfs to include plymouth (and helps include ucode probably)
mkinitcpio -P

pacman -Qdtq | pacman -Rns - --noconfirm

echo -e '[options]\nHoldPkg = glibc' > /temp-pacman.conf

# Pacman kills itself :((
pacman --config=/temp-pacman.conf -Rdd pacman archlinux-keyring --noconfirm

echo 'en_US.UTF-8 UTF-8  ' > /etc/locale.gen
locale-gen

# make the main user for our system
useradd -m main
yes "default" | passwd main

usermod -aG network,video,uucp.optical,audio,wheel main

# Set version info in os-release file
sed -i 's/UNKNOWN/]] .. plutoOSVersion .. [[/' /usr/lib/os-release

# Clean up system
rm -r /usr/lib/qt6/plugins/kf6/kded/donationmessage.so
rm -r /etc/pacman.d/
rm -r /etc/pacman.conf
rm -r /var/log/pacman.log
rm -r /var/lib/pacman/
rm -r /var/cache/pacman/
rm -r /usr/include

rm -r /usr/share/doc
rm -r /usr/share/man

for dir in /usr/share/locale/*; do
    [ "$dir" = "en_US" ] && continue
    rm -rf "$dir"
done

rm /temp-pacman.conf
rm /post-pacstrap.sh

]])
postPacstrap:close()

os.execute("sudo mv ./post-pacstrap.sh ./targetroot/post-pacstrap.sh")

-- Run chroot commands

os.execute("sudo chmod 0777 ./targetroot/post-pacstrap.sh") -- fine because only temporary file
os.execute("sudo arch-chroot ./targetroot /post-pacstrap.sh")

local plutoVersionFile = io.open("./version", "w")
if plutoVersionFile == nil then
	error("Failed to open pluto version file")
end

plutoVersionFile:write(plutoOSVersion)

plutoVersionFile:close();

os.execute("sudo mv ./version ./targetroot/pluto/version")
os.execute("sudo chmod 0644 ./targetroot/pluto/version")

os.execute("sudo killall gpg-agent")

print("Unmounting filesystems")
os.execute("sudo umount ./targetroot/boot")
os.execute("sudo umount ./targetroot/proc") -- this shouldn't be mounted... but just in case
os.execute("sudo umount ./targetroot")

print("Generating RAUC bundle... (This will take a bit)")
os.execute("rauc --cert ../../PRIVATE/pluto-prod.cert.pem --key ../../PRIVATE/pluto-prod.key.pem bundle ./bundle PlutoOS-Update-".. plutoOSVersion ..".raucb")

--[[

things that the installer needs to do to the home dir

- user named main

mkdirs:
/home/.etcOverlay/upper
/home/.etcOverlay/work
/home/.varOverlay/upper
/home/.varOverlay/work
/home/.rauc

file /home/main/.config/kscreenlockerrc
[Daemon]
LockOnStart=true

]]

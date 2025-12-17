#!/usr/bin/env bash
set -e


mkdir -p ./build/EFI/PLUTO/

grub-mkstandalone \
	-O x86_64-efi \
	-o ./build/EFI/PLUTO/PLUTO.EFI \
	--core-compress=xz \
	--compress=xz \
	/boot/grub/grub.cfg=./grub.cfg

tar --zstd -cf Pluto-Chainloader-4.0.tar.zst -C ./build .

rm -r ./build
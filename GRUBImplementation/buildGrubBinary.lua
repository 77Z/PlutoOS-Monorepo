#!/usr/bin/env lua

--[[

Generates EFI binary of grub to be used when "chainloading" PlutoOS

]]

local grubModules = [[
part_gpt
part_msdos
iso9660
all_video
efi_gop
efi_uga
video_bochs
video_cirrus
gfxterm
gettext
font
]]

local cmd = "grub-mkstandalone --output=PLUTO.EFI -O x86_64-efi --compress=xz --install-modules=\"" .. string.gsub(grubModules, "\n", " ") .. "\" boot/grub/grub.cfg"

-- print(cmd)

os.execute(cmd)

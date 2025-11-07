# PlutoOS RAUC Custom Backend

RAUC needs to be able to interact with the bootloader. In this case GRUB, which RAUC does have a backend for, but I wanted to better control the communication between the two, so that's what this binary is for. RAUC talks to this to configure which partition is going to boot, as well as learn about its environment.

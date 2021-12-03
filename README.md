# Arch Linux install configuration

Run script via `curl`:

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/rnln/alis/main/install.sh)"
```
or:
```sh
sh -c "$(curl -fsSL https://v.gd/_alis)"
```

Supported arguments:
```
-l, --lts    Install linux-lts package instead of linux
-p, --post   Start post-installation (grub, swapiness, pacman configuring, GNOME installation, etc.)
             By deafult script starts Arch Linux base installation with NetworkManager
-v, --vbox   Install VirtualBox guest utilities
-x, --xorg   Configure GNOME to use only Xorg and disable Wayland
-d, --drive  Drive name to install Arch Linux, /dev/sda by default
```

Full Arch Linux installation example:
```sh
sh -c "$(curl -fsSL https://v.gd/_alis)" '' --lts --vbox
# reboot
sh -c "$(curl -fsSL https://v.gd/_alis)" '' --post --xorg
# and reboot
```

If curl fails with `SSL certificate problem: certificate is not yet valid`, run:
```sh
timedatectl set-ntp true
```

The project also includes configuration files: `rc`, `.ini`, dotfiles, etc.

## License

CC0 1.0 Universal licensed. See the [LICENSE](./LICENSE) file for more details.

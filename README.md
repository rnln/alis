# Arch Linux install scripts

Run script via `curl`:

```sh
sh -c "$(curl -fsSL https://gitlab.com/romanilin/alis/-/raw/main/install.sh)"
```
or:
```sh
sh -c "$(curl -fsSL https://v.gd/alisa)"
```

Supported arguments:
* `-l, --lts `: Install linux-lts package instead of linux.
* `-p, --post`: Start post-installation (grub, swapiness, pacman configuring, GNOME installation, etc.). By deafult script starts Arch Linux base installation with NetworkManager.
* `-v, --vbox`: Install VirtualBox guest utilities.
* `-x, --xorg`: Configure GNOME to use only Xorg and disable Wayland.

Full installation example:
```sh
sh -c "$(curl -fsSL https://gitlab.com/romanilin/alis/-/raw/main/install.sh)" '' --lts --vbox
# reboot
sh -c "$(curl -fsSL https://gitlab.com/romanilin/alis/-/raw/main/install.sh)" '' --post --xorg
# reboot
```

Project includes collection of configuration files: `rc`, `.ini`, dotfiles, etc.

## License

CC0 1.0 Universal licensed. See the [LICENSE](./LICENSE) file for more details.

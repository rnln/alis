#!/bin/sh
# Run script via curl:
#   sh -c "$(curl -fsSL https://gitlab.com/romanilin/alis/-/raw/main/install.sh)"
# Arguments:
#   -l, --lts   Install linux-lts package instead of linux
#   -p, --post  Start post-installation (grub, swapiness, pacman configuring, GNOME installation, etc.)
#               By deafult script starts base Arch Linux installation with NetworkManager
#   -v, --vbox  Install VirtualBox guest utilities
#   -x, --xorg  Configure GNOME to use only Xorg and disable Wayland
# Example:
#   sh -c "$(curl -fsSL https://gitlab.com/romanilin/alis/-/raw/main/install.sh)" '' --post --xorg

set -e

for option in "$@"; do
    shift
    case "$option" in
        '--lts')
            set -- "$@" '-l' ;;
        '--post')
            set -- "$@" '-p' ;;
        '--vbox')
            set -- "$@" '-v' ;;
        '--xorg')
            set -- "$@" '-x' ;;
        *)  set -- "$@" "$option"
    esac
done

lts=false
mode='base'
vbox=false
xorg=false

OPTIND=1

while getopts 'lpvx' option; do
    case "$option" in
        l) lts=true ;;
        p) mode='post' ;;
        v) vbox=true ;;
        x) xorg=true
    esac
done

shift $((OPTIND-1))
[ "${1:-}" = '--' ] && shift


mirror_countries='Austria,Belarus,Czechia,Denmark,Finland,Germany,Hungary,Latvia,Lithuania,Moldova,Norway,Poland,Romania,Russia,Slovakia,Sweden,Ukraine'
sudo=$([ "$EUID" == 0 ] || echo sudo)
chroot=$([ "$mode" == 'post' ] || echo arch-chroot /mnt)


setup_terminal_colors () {
    # only use colors if connected to a terminal
    if [ -t 1 ]; then
        ES_BLACK=`tput setaf 0`
        ES_RED=`tput setaf 1`
        ES_GREEN=`tput setaf 2`
        ES_YELLOW=`tput setaf 3`
        ES_BLUE=`tput setaf 4`
        ES_MAGENTA=`tput setaf 5`
        ES_CYAN=`tput setaf 6`
        ES_WHITE=`tput setaf 7`
        ES_BOLD=`tput bold`
        ES_RESET=`tput sgr0`
    fi
}


log () {
    # log function
    # -f        set "Finished" as status message (default is "Started")
    # -d DEPTH  add indent in message beggining

    local OPTIND=1
    local depth=0
    local error=false
    local format="${ES_BOLD}"
    local padding=''

    while getopts 'd:efs' option; do
        case "$option" in
            d) depth=$OPTARG ;;
            e) error=true
               format="${format}${ES_RED}"
               ;;
            f) status='Finished ' ;;
            s) status='Started ' ;;
        esac
    done

    shift $((OPTIND-1))
    [ "${1:-}" = '--' ] && shift

    if [ $depth -gt 0 ]; then
        padding=$(printf "=%.0s" `seq $(($depth * 4 - 2))`)
        padding="${ES_CYAN}$padding>${ES_RESET} "
    fi

    echo -e "$padding$status${format}$@${ES_RESET}." >&2
}


setup_color_scheme () {
    BLACK='#121212'
    RED='#ff714f'
    GREEN='#00d965'
    YELLOW='#e0e000'
    BLUE='#7e9df9'
    MAGENTA='#ff5de1'
    CYAN='#90cbdb'
    WHITE='#ffffff'

    BLACK_BRIGHT='#555555'
    RED_BRIGHT=$RED
    GREEN_BRIGHT=$GREEN
    YELLOW_BRIGHT=$YELLOW
    BLUE_BRIGHT=$BLUE
    MAGENTA_BRIGHT=$MAGENTA
    CYAN_BRIGHT=$CYAN
    WHITE_BRIGHT=$WHITE

    export FOREGROUND=$WHITE
    export BACKGROUND=$BLACK
    export BACKGROUND_HIGHLIGHT='#1f4871' #3298ff66
    export PALETTE="['$BLACK', '$RED', '$GREEN', '$YELLOW', '$BLUE', '$MAGENTA', '$CYAN', '$WHITE', '$BLACK_BRIGHT', '$RED_BRIGHT', '$GREEN_BRIGHT', '$YELLOW_BRIGHT', '$BLUE_BRIGHT', '$MAGENTA_BRIGHT', '$CYAN_BRIGHT', '$WHITE_BRIGHT']"
}


system_errors () {
    echo -e "${ES_BOLD}System errors information${ES_RESET}."
    echo -e "${ES_BOLD}${ES_CYAN}systemctl --failed${ES_RESET}:"
    PAGER= $sudo systemctl --failed
    echo -e "${ES_BOLD}${ES_CYAN}journalctl -p 3 -xb${ES_RESET}:"
    PAGER= $sudo journalctl -p 3 -xb

    while true; do
        read -e -p "Clear these logs? [Y/n] " yn
        case $yn in
            [Nn]*) break ;;
            [Yy]*|'')
                $sudo systemctl reset-failed
                $sudo journalctl --vacuum-time=1s
                break
                ;;
            *) echo 'Try again.'
        esac
    done
}


revert_sudoers () {
    # revert original /etc/sudoers after preventing sudo timeout
    [ -f '/etc/sudoers.bak' ] && sudo mv /etc/sudoers.bak /etc/sudoers
}


install_packages () {
    case $1 in
        -a) shift
            yay -S --noconfirm --needed "$@" ;;
        *) $sudo pacman -S --noconfirm --needed "$@"
    esac
}


install_vbox_guest_utils () {
    $chroot sh -c "pacman -Q linux 2>/dev/null || $sudo pacman -S --noconfirm --needed virtualbox-guest-dkms"
    $chroot $sudo pacman -S --noconfirm --needed virtualbox-guest-utils
    $chroot $sudo systemctl enable --now vboxservice
}


install_base () {
    echo -e "Started ${ES_BOLD}${ES_GREEN}Arch Linux base installation${ES_RESET}."

    log -s 'getting user data'
    read -p "(1/7) Hostname [host]: " hostname
    hostname=${hostname:-host}
    while true; do
        read -s -p "(2/7) Root password [root]: " root_password
        echo
        read -s -p "(3/7) Retype root password [root]: " root_password_check
        echo
        if [ "$root_password" == "$root_password_check" ]; then
            break
        fi
        echo "Password, try again"
    done
    root_password=${root_password:-root}
    read -p "(4/7) User full name [User]: " user_fullname
    user_fullname=${user_fullname:-User}
    read -p "(5/7) Username [user]: " user_username
    user_username=${user_username:-user}
    while true; do
        read -s -p "(6/7) User password [user]: " user_password
        echo
        read -s -p "(7/7) Retype user password [user]: " user_password_check
        echo
        if [ "$user_password" == "$user_password_check" ]; then
            break
        fi
        echo "Password, try again"
    done
    user_password=${user_password:-user}
    log -f 'getting user data'

    log -s 'system clock synchronizing'
    timedatectl set-ntp true
    log -f 'system clock synchronizing'

    log -s 'partitioning'
    sector_size=512
    swap_sectors=$((`free -b | awk '/Mem/ {print $2}'` / $sector_size))
    sfdisk --list
    echo "
        label: gpt
        sector-size: $sector_size
        /dev/sda1: type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B, size=532480
        /dev/sda2: type=0657FD6D-A4AB-43C4-84E5-0933C84B4F4F, size=$swap_sectors
        /dev/sda3: type=0FC63DAF-8483-4772-8E79-3D69D8477DE4
    " | sfdisk /dev/sda
    log -f 'partitioning'

    log -s 'partitions formatting'
    mkfs.fat -F 32 /dev/sda1
    mkswap /dev/sda2
    mkfs.ext4 /dev/sda3
    log -f 'partitions formatting'

    log -s 'file systems mounting'
    mount /dev/sda3 /mnt
    swapon /dev/sda2
    log -f 'file systems mounting'

    log -s 'essential packages installation'
    reflector --latest 20 --sort rate -c $mirror_countries --protocol https >/etc/pacman.d/mirrorlist
    pacman -Syy
    pacstrap /mnt base linux-firmware
    if [ "$lts" == true ]; then
        pacstrap /mnt linux-lts # linux-lts-headers
    else
        pacstrap /mnt linux
    fi
    log -f 'essential packages installation'

    log -s 'system configuring'
    genfstab -U /mnt >>/mnt/etc/fstab
    $chroot ln --force --symbolic /usr/share/zoneinfo/Europe/Moscow /etc/localtime
    $chroot hwclock --systohc
    sed -i 's/^#\(\(en_US\|ru_RU\)\.UTF-8 UTF-8\)/\1/' /mnt/etc/locale.gen
    $chroot locale-gen
    echo LANG=en_US.UTF-8 >/mnt/etc/locale.conf
    log -f 'system configuring'

    log -s 'network configuring'
    echo "$hostname" >/mnt/etc/hostname
    echo '127.0.0.1 localhost' >/mnt/etc/hosts
    echo '::1 localhost' >>/mnt/etc/hosts
    echo "127.0.1.1 $hostname.localdomain $hostname" >>/mnt/etc/hosts
    $chroot pacman -S --noconfirm --needed networkmanager
    $chroot systemctl enable NetworkManager
    log -f 'network configuring'

    log -s 'users configuring'
    $chroot sh -c "(echo '$root_password'; echo '$root_password') | passwd >/dev/null"
    $chroot useradd --create-home --comment $user_fullname --groups wheel,audio $user_username
    $chroot sh -c "(echo '$user_password'; echo '$user_password') | passwd $user_username >/dev/null"
    $chroot pacman -S --noconfirm --needed sudo
    sed -i 's/^# \(%wheel ALL=(ALL) ALL\)/\1/' /mnt/etc/sudoers
    log -f 'users configuring'

    if [ "$vbox" == true ]; then
        log -s 'VirtualBox guest utilities installation'
        install_vbox_guest_utils
        log -f 'VirtualBox guest utilities installation'
    fi

    log -s 'boot loader installation and configuring'
    $chroot pacman -S --noconfirm --needed grub efibootmgr
    mkdir /mnt/boot/efi
    mount /dev/sda1 /mnt/boot/efi
    $chroot grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
    $chroot grub-mkconfig -o /boot/grub/grub.cfg
    log -f 'boot loader installation and configuring'

    log -s 'partitions unmounting'
    umount -R /mnt
    log -f 'partitions unmounting'

    echo -e "Finished ${ES_BOLD}${ES_GREEN}Arch Linux base installation${ES_RESET}."

    system_errors
}


install_post () {
    echo -e "Started ${ES_BOLD}${ES_GREEN}Arch Linux post-installation${ES_RESET}."

    export XDG_CONFIG_HOME="$HOME/.config"

    log -s 'sudo timeout preventing'
    command -v sudo >/dev/null 2>&1 || {
        log -e "sudo isn't installed"
        exit 1
    }
    trap revert_sudoers EXIT SIGHUP SIGINT SIGTERM
    sudo cp /etc/sudoers /etc/sudoers.bak
    sudo sh -c "echo '$(whoami) ALL=(ALL) NOPASSWD: ALL' | (EDITOR='tee -a' visudo)" >/dev/null
    log -f 'sudo timeout preventing'

    log -s 'swappiness configuring'
    sudo sh -c 'echo "vm.swappiness=10" >/etc/sysctl.conf'
    log -f 'swappiness configuring'

    log -s 'grub configuring'
    sudo sed -i 's/^\(GRUB_TIMEOUT\).*/\1=0/' /etc/default/grub
    sudo grub-mkconfig -o /boot/grub/grub.cfg
    log -f 'grub configuring'

    log -s 'pacman configuring'
    sudo pacman -Syyu --noconfirm --needed
    install_packages reflector
    sudo sh -c "reflector --latest 20 --sort rate -c $mirror_countries --protocol https >/etc/pacman.d/mirrorlist"
    log -f 'pacman configuring'

    log -s 'yay installation'
    install_packages base-devel git
    local tempdir="$(mktemp -d)"
    git clone https://aur.archlinux.org/yay.git "$tempdir"
    sh -c "cd '$tempdir' && makepkg -si --noconfirm --needed"
    rm -rf "$tempdir"
    log -f 'yay installation'

    log -s 'fonts installation'
    install_packages noto-fonts noto-fonts-emoji noto-fonts-cjk
    install_packages ttf-jetbrains-mono
    log -f 'fonts installation'

    log -s 'GNOME installation'
    install_packages gdm gnome-terminal gnome-control-center
    # eog
    # gnome-themes-extra
    # gedit
    # gnome-calculator
    # gnome-color-manager
    # gnome-screenshot
    # gnome-shell
    # gnome-shell-extensions
    # nautilus
    # gnome-tweaks
    sudo systemctl enable gdm
    log -f 'GNOME installation'

    log -s 'zsh installation'
    install_packages zsh
    echo 'export XDG_CONFIG_HOME="$HOME/.config"' >/etc/zshenv
    echo 'export ZDOTDIR="$XDG_CONFIG_HOME/zsh"' >>/etc/zshenv
    install_packages -a starship-bin
    sudo chsh -s "$(which zsh)" "$(whoami)"
    export HISTFILE=/dev/null
    rm "$HOME/.bash"*
    log -f 'zsh installation'

    log -s 'OpenSSH installation'
    install_packages openssh
    sudo sh -c 'echo "DisableForwarding yes # disable all forwarding features (overrides all other forwarding-related options)" >>/etc/ssh/sshd_config'
    sudo sed -i 's/^#\(IgnoreRhosts\).*/\1 yes/' /etc/ssh/sshd_config
    # sudo sed -i 's/^#\(PasswordAuthentication\).*/\1 no/' /etc/ssh/sshd_config
    sudo sed -i 's/^#\(PermitRootLogin\).*/\1 no/' /etc/ssh/sshd_config
    sudo systemctl enable sshd
    log -f 'OpenSSH installation'

    log -s 'ufw installation'
    install_packages ufw
    sudo ufw limit ssh
    sudo ufw allow transmission
    sudo systemctl enable ufw
    log -f 'ufw installation'

    log -s 'additional packages installation'
    install_packages man vim tilix code
    # wget
    # nmap
    # imagemagick
    # python
    # python-pip
    # inetutils
    # firefox
    # telegram-desktop
    # vlc
    # transmission-gtk
    # youtube-dl
    # ffmpeg
    # p7zip
    install_packages -a xcursor-openzone
    log -f 'additional packages installation'

    log -s 'runtime configuration files cloning'
    install_packages rsync
    tempdir="$(mktemp -d)"
    git clone https://gitlab.com/romanilin/rcs.git "$tempdir"
    rm -rf "$tempdir/.git"
    rm -rf "$tempdir/LICENSE"
    rm -rf "$tempdir/README.md"
    rsync -a "$tempdir/" "$HOME/"
    envsubst '$USER,$HOST' <"$tempdir/.mozilla/firefox/default/user.js" >"$HOME/.mozilla/firefox/default/user.js"
    envsubst '$XDG_CONFIG_HOME' <"$tempdir/.config/ssh/config" >"$HOME/.config/ssh/config"
    rm -rf "$tempdir"
    log -f 'runtime configuration files cloning'

    log -s 'GDM configuring'
    tempdir=$(mktemp -d)
    cd "$tempdir"
    echo '<?xml version="1.0" encoding="UTF-8"?>' >"$tempdir/gnome-shell-theme.gresource.xml"
    echo '<gresources><gresource>' >>"$tempdir/gnome-shell-theme.gresource.xml"
    for file in $(gresource list /usr/share/gnome-shell/gnome-shell-theme.gresource); do
        mkdir -p "$(dirname "$tempdir$file")"
        gresource extract /usr/share/gnome-shell/gnome-shell-theme.gresource "$file" >"$tempdir$file"
        echo "<file>${file#\/}</file>" >>"$tempdir/gnome-shell-theme.gresource.xml"
    done
    echo '</gresource></gresources>' >>"$tempdir/gnome-shell-theme.gresource.xml"
    sed -i -zE 's/(#lockDialogGroup \{)[^}]+/\1 background-color: #000000; /g' "$tempdir/org/gnome/shell/theme/gnome-shell.css"
    glib-compile-resources "$tempdir/gnome-shell-theme.gresource.xml"
    sudo cp -f "$tempdir/gnome-shell-theme.gresource" /usr/share/gnome-shell/
    cd - >/dev/null
    rm -rf "$tempdir"
    log -f 'GDM configuring'

    log -s 'GNOME configuring'
    # https://superuser.com/questions/1359253/how-to-remove-starred-tab-in-gnomes-nautilus

    if [ "$xorg" == true ]; then
        sudo sed -i 's/^#\(WaylandEnable=false\)/\1/' /etc/gdm/custom.conf
    fi

    export terminal_profile="$(uuidgen)"
    sudo sed -i 's/^Exec=gnome-terminal/& --maximize/' /usr/share/applications/org.gnome.Terminal.desktop
    sudo sed -i 's/^Exec=tilix$/& --maximize/' /usr/share/applications/com.gexperts.Tilix.desktop
    sudo sed -i '/DBusActivatable/d' /usr/share/applications/com.gexperts.Tilix.desktop

    not_to_hide_apps=(
        "code-oss"
        "com.gexperts.Tilix"
        "firefox"
        "gnome-control-center"
        "google-chrome"
        "org.gnome.Nautilus"
        "org.gnome.Terminal"
        "org.gnome.tweaks"
        "telegramdesktop"
        "transmission-gtk"
        "vlc"
    )
    not_to_hide_apps=`printf '\|%s' "${not_to_hide_apps[@]}" | cut -c 3-` # join with "\|"
    export other_apps=$(ls -A1 /usr/share/applications | grep .desktop$)
    other_apps=$(grep -v "\($not_to_hide_apps\).desktop" <<<$other_apps)
    other_apps=$(awk '{ print $0 }' RS='\n' ORS="', '" <<<$other_apps)
    other_apps=[\'${other_apps::-4}\']

    envsubst '$FOREGROUND,$BACKGROUND,$BACKGROUND_HIGHLIGHT,$PALETTE,$other_apps,$terminal_profile' <"$HOME/.config/dconf/dump.ini" | dconf load /
    rm "$HOME/.config/dconf/dump.ini"
    log -f 'GNOME configuring'

    if [ "$vbox" == true ]; then
        log -s 'VirtualBox guest utilities installation'
        install_vbox_guest_utils
        log -f 'VirtualBox guest utilities installation'
    fi

    log -s 'pacman clearing up'
    orphans="$(pacman -Qtdq)"
    if [[ -n "$orphans" ]]; then
        sudo pacman -Rns --noconfirm $orphans
    fi
    sudo pacman -Scc --noconfirm
    log -f 'pacman clearing up'

    echo -e "Finished ${ES_BOLD}${ES_GREEN}Arch Linux post-installation${ES_RESET}."

    system_errors
}


setup_terminal_colors

if [ "$mode" == 'post' ]; then
    setup_color_scheme
    install_post
else
    install_base
fi

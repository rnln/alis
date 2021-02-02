#!/bin/sh
# Run script via curl:
#   sh -c "$(curl -fsSL https://gitlab.com/romanilin/alrc/-/raw/main/install.sh)"
# Supported arguments:
#   -l, --lts    Install linux-lts package instead of linux
#   -p, --post   Start post-installation (grub, swapiness, pacman configuring, GNOME installation, etc.)
#                By deafult script starts Arch Linux base installation with NetworkManager
#   -v, --vbox   Install VirtualBox guest utilities
#   -x, --xorg   Configure GNOME to use only Xorg and disable Wayland
#   -d, --drive  Drive name to install Arch Linux, /dev/sda by default
# Example:
#   sh -c "$(curl -fsSL https://gitlab.com/romanilin/alrc/-/raw/main/install.sh)" '' -px

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
        '--drive')
            set -- "$@" '-d' ;;
        *)  set -- "$@" "$option"
    esac
done

LTS=false
MODE='base'
VBOX=false
XORG=false
DRIVE='/dev/sda'

OPTIND=1

while getopts 'd:lpvx' option; do
    case "$option" in
        d) DRIVE="$OPTARG" ;;
        l) LTS=true ;;
        p) MODE='post' ;;
        v) VBOX=true ;;
        x) XORG=true
    esac
done

shift $((OPTIND-1))
[ "${1:-}" = '--' ] && shift


MIRROR_COUNTRIES='Austria,Belarus,Czechia,Denmark,Finland,Germany,Hungary,Latvia,Lithuania,Moldova,Norway,Poland,Romania,Russia,Slovakia,Sweden,Ukraine'
SUDO=$([ "$EUID" == 0 ] || echo sudo)
CHROOT=$([ "$MODE" == 'post' ] || echo arch-chroot /mnt)


setup_terminal_colors () {
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
}


log () {
    # log function
    # -i DEPTH  Add indent in message beggining
    # -s        Print "Started..." message
    # -f        Print "Finished..." message
    # -n        Prevent line break
    # -e        End message with provided string, '.' by default
    # -w        Wrap message with provided escape sequence

    local OPTIND=1
    local DEPTH=0
    local FORMAT="${ES_BOLD}"
    local PADDING=''
    local NEWLINE='\n'
    local END='.'

    while getopts 'i:e:fnsw:' option; do
        case "$option" in
            i) DEPTH=$OPTARG ;;
            e) END="${OPTARG}" ;;
            w) FORMAT="${FORMAT}${OPTARG}" ;;
            f) STATUS='Finished ' ;;
            s) STATUS='Started ' ;;
            n) NEWLINE='' ;;
        esac
    done

    shift $((OPTIND-1))
    [ "${1:-}" = '--' ] && shift

    if [ $DEPTH -gt 0 ]; then
        PADDING=$(printf "=%.0s" `seq $(($DEPTH * 4 - 2))`)
        PADDING="${ES_CYAN}${PADDING}>${ES_RESET} "
    fi

    printf "${ES_BOLD}${ES_CYAN}[ALRC]${ES_RESET} ${PADDING}${STATUS}${FORMAT}$@${ES_RESET}${END}${NEWLINE}" >&2
}


setup_color_scheme () {
    export BLACK='#121212'
    export RED='#ff714f'
    export GREEN='#00d965'
    export YELLOW='#e0e000'
    export BLUE='#7e9df9'
    export MAGENTA='#ff5de1'
    export CYAN='#90cbdb'
    export WHITE='#ffffff'

    export BLACK_BRIGHT='#555555'
    export RED_BRIGHT=$RED
    export GREEN_BRIGHT=$GREEN
    export YELLOW_BRIGHT=$YELLOW
    export BLUE_BRIGHT=$BLUE
    export MAGENTA_BRIGHT=$MAGENTA
    export CYAN_BRIGHT=$CYAN
    export WHITE_BRIGHT=$WHITE

    export FOREGROUND=$WHITE
    export BACKGROUND=$BLACK
    export BACKGROUND_HIGHLIGHT='#1f4871' # #3298ff66 on #121212 background
    export PALETTE="['$BLACK', '$RED', '$GREEN', '$YELLOW', '$BLUE', '$MAGENTA', '$CYAN', '$WHITE', '$BLACK_BRIGHT', '$RED_BRIGHT', '$GREEN_BRIGHT', '$YELLOW_BRIGHT', '$BLUE_BRIGHT', '$MAGENTA_BRIGHT', '$CYAN_BRIGHT', '$WHITE_BRIGHT']"
}


check_system_errors () {
    log 'System errors information'
    log -i 1 'systemctl --failed:'
    PAGER= $SUDO systemctl --failed
    log -i 1 'journalctl -p 3 -xb:'
    PAGER= $SUDO journalctl -p 3 -xb

    while true; do
        log -i 1 -n 'Clear these logs? [Y/n] '
        read -e answer
        case $answer in
            [Nn]*) break ;;
            [Yy]*|'')
                $SUDO systemctl reset-failed
                $SUDO journalctl --vacuum-time=1s
                break
                ;;
            *) log -i 1 'Try again.'
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
            paru -S --noconfirm --needed "$@" ;;
        *) $SUDO pacman -S --noconfirm --needed "$@"
    esac
}


install_vbox_guest_utils () {
    $CHROOT sh -c "pacman -Q linux 2>/dev/null || $SUDO pacman -S --noconfirm --needed virtualbox-guest-dkms"
    $CHROOT $SUDO pacman -S --noconfirm --needed virtualbox-guest-utils
    $CHROOT $SUDO systemctl enable vboxservice
    if [ "$MODE" == 'post' ]; then $SUDO systemctl start vboxservice; fi
}


install_base () {
    log -s -w "${ES_GREEN}" 'Arch Linux base installation'

    log -s 'getting user data'
    log -n -i 1 -e ': ' '(1/7) Hostname [host]'
    read HOSTNAME
    HOSTNAME=${HOSTNAME:-host}
    while true; do
        log -n -i 1 -e ': ' '(2/7) Root password [root]'
        read -s ROOT_PASSWORD
        echo
        log -n -i 1 -e ': ' '(3/7) Retype root password [root]'
        read -s ROOT_PASSWORD_CHECK
        echo
        if [ "$ROOT_PASSWORD" == "$ROOT_PASSWORD_CHECK" ]; then
            break
        fi
        log -i 1 -w "${ES_RED}" 'Passwords do not match, try again'
    done
    ROOT_PASSWORD=${ROOT_PASSWORD:-root}
    log -n -i 1 -e ': ' '(4/7) User full name [User]'
    read USER_FULLNAME
    USER_FULLNAME=${USER_FULLNAME:-User}
    log -n -i 1 -e ': ' '(5/7) Username [user]'
    read USER_USERNAME
    USER_USERNAME=${USER_USERNAME:-user}
    while true; do
        log -n -i 1 -e ': ' '(6/7) User password [user]'
        read -s USER_PASSWORD
        echo
        log -n -i 1 -e ': ' '(7/7) Retype user password [user]'
        read -s USER_PASSWORD_CHECK
        echo
        if [ "$USER_PASSWORD" == "$USER_PASSWORD_CHECK" ]; then
            break
        fi
        log -i 1 -w "${ES_RED}" 'Passwords do not match, try again'
    done
    USER_PASSWORD=${USER_PASSWORD:-user}
    log -f 'getting user data'

    log -s 'system clock synchronizing'
    timedatectl set-ntp true
    log -f 'system clock synchronizing'

    log -s 'partitioning'
    SECTOR_SIZE=512
    SWAP_SECTORS=$((`free -b | awk '/Mem/ {print $2}'` / $SECTOR_SIZE))
    echo "
        label: gpt
        sector-size: $SECTOR_SIZE
        ${DRIVE}1: type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B, size=532480
        ${DRIVE}2: type=0657FD6D-A4AB-43C4-84E5-0933C84B4F4F, size=$SWAP_SECTORS
        ${DRIVE}3: type=0FC63DAF-8483-4772-8E79-3D69D8477DE4
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
    reflector --latest 20 --sort rate -c "$MIRROR_COUNTRIES" --protocol https >/etc/pacman.d/mirrorlist
    pacman -Syy
    pacstrap /mnt base linux-firmware
    if [ "$LTS" == true ]; then
        pacstrap /mnt linux-lts # linux-lts-headers
    else
        pacstrap /mnt linux
    fi
    log -f 'essential packages installation'

    log -s 'system configuring'
    genfstab -U /mnt >>/mnt/etc/fstab
    $CHROOT ln --force --symbolic /usr/share/zoneinfo/Europe/Moscow /etc/localtime
    $CHROOT hwclock --systohc
    sed -i 's/^#\(\(en_US\|ru_RU\)\.UTF-8 UTF-8\)/\1/' /mnt/etc/locale.gen
    $CHROOT locale-gen
    echo LANG=en_US.UTF-8 >/mnt/etc/locale.conf
    log -f 'system configuring'

    log -s 'network configuring'
    echo "$HOSTNAME" >/mnt/etc/hostname
    echo '127.0.0.1 localhost' >/mnt/etc/hosts
    echo '::1 localhost' >>/mnt/etc/hosts
    echo "127.0.1.1 $HOSTNAME.localdomain $HOSTNAME" >>/mnt/etc/hosts
    $CHROOT pacman -S --noconfirm --needed networkmanager
    $CHROOT systemctl enable NetworkManager
    log -f 'network configuring'

    log -s 'users configuring'
    # PASSWORD=$(/usr/bin/openssl passwd -crypt 'vagrant')
    # /usr/bin/usermod --password ${PASSWORD} root
    # /usr/bin/useradd --password ${PASSWORD} --comment 'Vagrant User' --create-home --gid users --groups vagrant,vboxsf vagrant

    $CHROOT sh -c "(echo '$ROOT_PASSWORD'; echo '$ROOT_PASSWORD') | passwd >/dev/null"
    $CHROOT useradd --create-home --comment $USER_FULLNAME --groups wheel,audio $USER_USERNAME
    $CHROOT sh -c "(echo '$USER_PASSWORD'; echo '$USER_PASSWORD') | passwd $USER_USERNAME >/dev/null"
    $CHROOT pacman -S --noconfirm --needed sudo
    sed -i 's/^# \(%wheel ALL=(ALL) ALL\)/\1/' /mnt/etc/sudoers
    log -f 'users configuring'

    if [ "$VBOX" == true ]; then
        log -s 'VirtualBox guest utilities installation'
        install_vbox_guest_utils
        log -f 'VirtualBox guest utilities installation'
    fi

    log -s 'boot loader installation and configuring'
    $CHROOT pacman -S --noconfirm --needed grub efibootmgr
    mkdir /mnt/boot/efi
    mount /dev/sda1 /mnt/boot/efi
    $CHROOT grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
    $CHROOT grub-mkconfig -o /boot/grub/grub.cfg
    log -f 'boot loader installation and configuring'

    log -s 'partitions unmounting'
    umount -R /mnt
    log -f 'partitions unmounting'

    log -f -w "${ES_GREEN}" 'Arch Linux base installation'

    check_system_errors
}


install_post () {
    echo -e "Started ${ES_BOLD}${ES_GREEN}Arch Linux post-installation${ES_RESET}."

    export XDG_CONFIG_HOME="$HOME/.config"

    log -s 'sudo timeout preventing'
    command -v sudo >/dev/null 2>&1 || {
        log -w "${ES_RED}" "sudo isn't installed"
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
    sudo sh -c "reflector --latest 20 --sort rate -c '$MIRROR_COUNTRIES' --protocol https >/etc/pacman.d/mirrorlist"
    log -f 'pacman configuring'

    log -s 'paru installation'
    install_packages base-devel git
    local tempdir="$(mktemp -d)"
    git clone https://aur.archlinux.org/paru-bin.git "$tempdir"
    sh -c "cd '$tempdir' && makepkg -si --noconfirm --needed"
    rm -rf "$tempdir"
    log -f 'paru installation'

    log -s 'fonts installation'
    install_packages -a ttf-jetbrains-mono noto-fonts noto-fonts-emoji # noto-fonts-cjk
    log -f 'fonts installation'

    log -s 'GNOME installation'
    install_packages -a gdm gnome-terminal gnome-control-center nautilus gnome-themes-extra chrome-gnome-shell gnome-tweaks eog
    sudo systemctl enable gdm
    log -f 'GNOME installation'

    log -s 'zsh installation'
    install_packages -a zsh starship-bin
    sudo sh -c "echo 'export XDG_CONFIG_HOME=\"\$HOME/.config\"' >/etc/zsh/zshenv"
    sudo sh -c "echo 'export ZDOTDIR=\"\$XDG_CONFIG_HOME/zsh\"' >>/etc/zsh/zshenv"
    sudo chsh -s "$(which zsh)" "$(whoami)"
    rm "$HOME/.bash"*
    log -f 'zsh installation'

    log -s 'OpenSSH installation'
    install_packages -a openssh
    sudo sh -c 'echo "DisableForwarding yes # disable all forwarding features (overrides all other forwarding-related options)" >>/etc/ssh/sshd_config'
    sudo sed -i 's/^#\(IgnoreRhosts\).*/\1 yes/' /etc/ssh/sshd_config
    # sudo sed -i 's/^#\(PasswordAuthentication\).*/\1 no/' /etc/ssh/sshd_config
    sudo sed -i 's/^#\(PermitRootLogin\).*/\1 no/' /etc/ssh/sshd_config
    sudo systemctl enable sshd
    log -f 'OpenSSH installation'

    log -s 'ufw installation'
    install_packages -a ufw
    sudo ufw limit ssh
    sudo ufw allow transmission
    sudo systemctl enable ufw
    log -f 'ufw installation'

    log -s 'additional packages installation'
    additional_packages=(
        "code"
        "inetutils"
        "kitty"
        "librewolf-bin"
        "man"
        "p7zip"
        "python-pip"
        "qalculate-gtk"
        "telegram-desktop"
        "transmission-gtk"
        "vim"
        "vlc"
        "xcursor-openzone"
        "youtube-dl"
    )
    install_packages -a "${additional_packages[@]}"
    if [ "$VBOX" == true ]; then
        install_packages virtualbox
    fi
    log -f 'additional packages installation'

    log -s 'runtime configuration files cloning'
    install_packages -a rsync
    tempdir="$(mktemp -d)"
    git clone https://gitlab.com/romanilin/alis.git "$tempdir"
    rm -rf "$tempdir/.git"
    rm -rf "$tempdir/LICENSE"
    rm -rf "$tempdir/README.md"
    rsync -a "$tempdir/" "$HOME/"
    chmod 700 "$XDG_CONFIG_HOME/gnupg"
    envsubst '$XDG_CONFIG_HOME' <"$tempdir/.config/ssh/config" >"$XDG_CONFIG_HOME/ssh/config"
    envsubst '$XDG_CONFIG_HOME' <"$tempdir/.config/paru/paru.conf" >"$XDG_CONFIG_HOME/paru/paru.conf"
    sudo mkdir /usr/lib/electron9/bin
    sudo ln /usr/bin/code-oss /usr/lib/electron9/bin/code-oss
    # generate Firefox add-ons list for "runOncePerModification.extensionsInstall" preference
    addons_root="https://addons.mozilla.org/firefox"
    addons_list=(
        # https://addons.mozilla.org/addon/${addon}/
        'copy-selected-tabs-to-clipboar'
        'darkvk'
        'default-bookmark-folder'
        'gnome-shell-integration'
        'image-search-options'
        'tampermonkey'
        'wappalyzer'
        # Privacy
        'decentraleyes'
        'dont-touch-my-tabs'
        'dont-track-me-google1'
        'facebook-container'
        'google-container'
        'nano-defender-firefox'
        'nohttp' # 'https-everywhere'
        'noscript'
        'privacy-badger17'
        'privacy-possum'
        'smart-referer'
        'uaswitcher'
        'ublock-origin'
    )
    xpi_list=()
    echo "getting URIs of Firefox add-ons' xpi files"
    for addon in "${addons_list[@]}"; do
        echo "checking add-on \"$addon\""
        xpi_url="$addons_root/downloads/file/$(curl -sL "$addons_root/addon/$addon" | grep -oP 'file/\K.+\.xpi(?=">Download file)')"
        xpi_url="$(curl -s -D - -o /dev/null "$xpi_url" | grep -oP 'Location:.+\Khttps.+(?=\?filehash)')"
        xpi_list+=("\\\"$xpi_url\\\"")
    done
    xpi_list=`printf ',%s' "${xpi_list[@]}" | cut -c 2-`
    export xpi_list
    envsubst '$USER,$HOST,$xpi_list' <"$tempdir/.librewolf/default/user.js" >"$HOME/.librewolf/default/user.js"
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

    if [ "$XORG" == true ]; then
        sudo sed -i 's/^#\(WaylandEnable=false\)/\1/' /etc/gdm/custom.conf
    fi

    export terminal_profile="$(uuidgen)"

    not_to_hide_apps=(
        "chromium"
        "code-oss"
        "kitty"
        "librewolf"
        "org.gnome.Nautilus"
        "qalculate-gtk"
        "telegramdesktop"
        "transmission-gtk"
        "virtualbox"
    )
    not_to_hide_apps=`printf '\|%s' "${not_to_hide_apps[@]}" | cut -c 3-` # join with "\|"
    export other_apps=$(ls -A1 /usr/share/applications | grep .desktop$)
    other_apps=$(grep -v "\($not_to_hide_apps\).desktop" <<<$other_apps)
    other_apps=$(awk '{ print $0 }' RS='\n' ORS="', '" <<<$other_apps)
    other_apps=[\'${other_apps::-4}\']

    envsubst '$FOREGROUND,$BACKGROUND,$BACKGROUND_HIGHLIGHT,$PALETTE,$other_apps,$terminal_profile' <"$HOME/.config/dconf/dump.ini" | dconf load /
    rm "$HOME/.config/dconf/dump.ini"
    log -f 'GNOME configuring'

    if [ "$VBOX" == true ]; then
        log -s 'VirtualBox guest utilities installation'
        install_vbox_guest_utils
        log -f 'VirtualBox guest utilities installation'
    fi

    log -s 'pacman clearing up'
    orphans="$(pacman -Qtdq)"
    if [[ -n "$orphans" ]]; then
        sudo pacman -Rns --noconfirm $orphans
        # sudo pacman -Rcns --noconfirm $orphans
    fi
    sudo pacman -Scc --noconfirm
    log -f 'pacman clearing up'

    echo -e "Finished ${ES_BOLD}${ES_GREEN}Arch Linux post-installation${ES_RESET}."

    check_system_errors
}


setup_terminal_colors

if [ "$MODE" == 'post' ]; then
    setup_color_scheme
    install_post
else
    install_base
fi

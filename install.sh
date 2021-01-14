#!/bin/sh
#
# Run script via curl:
#   sh -c "$(curl -fsSL https://gitlab.com/romanilin/alis/-/raw/main/install.sh)"
# Arguments:
#   -p, --post  Start post-install (grub, swapiness, pacman configuring, GNOME installation, etc.)
#               By deafult script starts base Arch Linux installation with NetworkManager
#   --no-lts    Install linux package instead of linux-lts
# Example:
#   sh -c "$(curl -fsSL https://gitlab.com/romanilin/alis/-/raw/main/install.sh)" '' --unattended
#
set -e

for option in "$@"; do
    shift
    case "$option" in
        '--no-lts')
            set -- "$@" '-l' ;;
        *)
            set -- "$@" "$option"
    esac
done

mode=base
keep_color_scheme=false
lts=true

OPTIND=1

while getopts 'p' option; do
    case "$option" in
        p) mode='post' ;;
        c) keep_color_scheme=true
        l) lts=false
    esac
done

shift $((OPTIND-1))
[ "${1:-}" = '--' ] && shift


log () {
    # log function
    # -f        set "Finished" as status message (default is "Started")
    # -d DEPTH  add indent in message beggining

    local OPTIND=1
    local status='Started'
    local depth=0

    while getopts 'fd:' option; do
        case "$option" in
            f) status='Finished' ;;
            d) depth=$OPTARG
        esac
    done

    shift $((OPTIND-1))
    [ "${1:-}" = '--' ] && shift

    if [ $depth -gt 0 ]; then
        local padding=$(printf "=%.0s" `seq $(($depth * 4 - 2))`)
        padding="$ES_CYAN$padding>$ES_RESET "
    else
        padding=''
    fi

    echo "$padding$status $ES_BOLD$@$ES_RESET." >&2
}


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


setup_color_scheme () {
    BLACK='#000000'
    RED='#aa0000'
    GREEN='#00aa00'
    YELLOW='#aa5500'
    BLUE='#0000aa'
    MAGENTA='#aa00aa'
    CYAN='#00aaaa'
    WHITE='#aaaaaa'
    BLACK_BRIGHT='#555555'
    RED_BRIGHT='#ff5555'
    GREEN_BRIGHT='#55ff55'
    YELLOW_BRIGHT='#ffff55'
    BLUE_BRIGHT='#5555ff'
    MAGENTA_BRIGHT='#ff55ff'
    CYAN_BRIGHT='#55ffff'
    WHITE_BRIGHT='#ffffff'
    BACKGROUND_HIGHLIGHT='#000055'

    # BLACK='#121212'
    # RED='#ff746c'
    # GREEN='#00bb23'
    # YELLOW='#a4a600'
    # BLUE='#a594ff'
    # MAGENTA='#ff5aff'
    # CYAN='#00b4b5'
    # WHITE='#ffffff'
    # BLACK_BRIGHT='#555555'
    # RED_BRIGHT=$RED
    # GREEN_BRIGHT=$GREEN
    # YELLOW_BRIGHT=$YELLOW
    # BLUE_BRIGHT=$BLUE
    # MAGENTA_BRIGHT=$MAGENTA
    # CYAN_BRIGHT=$CYAN
    # WHITE_BRIGHT='#ffffff'
    # BACKGROUND_HIGHLIGHT='#264f78'

    BACKGROUND=$BLACK
    FOREGROUND=$WHITE

    PALETTE="['$BLACK', '$RED', '$GREEN', '$YELLOW', '$BLUE', '$MAGENTA', '$CYAN', '$WHITE', '$BLACK_BRIGHT', '$RED_BRIGHT', '$GREEN_BRIGHT', '$YELLOW_BRIGHT', '$BLUE_BRIGHT', '$MAGENTA_BRIGHT', '$CYAN_BRIGHT', '$WHITE_BRIGHT']"
}


install_packages () {
    case $1 in
        -a) shift
            yay -S --noconfirm --needed "$@" ;;
        *) sudo pacman -S --noconfirm --needed "$@"
    esac
}


system_errors () {
    local sudo=''
    while getopts 's' option; do
        case "$option" in
            s) sudo='sudo '
        esac
    done

    echo -e "${ES_BOLD}System errors information${ES_RESET}."
    echo -e "${ES_BOLD}${ES_CYAN}${sudo}systemctl --failed${ES_RESET}:"
    PAGER= $sudo systemctl --failed
    echo -e "${ES_BOLD}${ES_CYAN}${sudo}journalctl -p 3 -xb${ES_RESET}:"
    PAGER= $sudo journalctl -p 3 -xb

    while true; do
        read -e -p "Clear these logs? [Y/n] " yn
        case $yn in
            [Nn]*) break ;;
            *)  $sudo systemctl reset-failed
                $sudo journalctl --vacuum-time=1s
                break
        esac
    done
}


install_base () {
    echo -e "Started ${ES_BOLD}${ES_GREEN}Arch Linux base installation${ES_RESET}."

    log 'getting user data'
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

    log 'system clock synchronizing'
    timedatectl set-ntp true
    log -f 'system clock synchronizing'

    log 'partitioning'
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

    log 'partitions formatting'
    mkfs.fat -F 32 /dev/sda1
    mkswap /dev/sda2
    mkfs.ext4 /dev/sda3
    log -f 'partitions formatting'

    log 'file systems mounting'
    mount /dev/sda3 /mnt
    swapon /dev/sda2
    log -f 'file systems mounting'

    log 'essential packages installation'
    reflector --latest 20 --sort rate -c Austria,Belarus,Czechia,Denmark,Finland,Germany,Hungary,Latvia,Lithuania,Moldova,Norway,Poland,Romania,Russia,Slovakia,Sweden,Ukraine --protocol https > /etc/pacman.d/mirrorlist
    pacman -Syy
    pacstrap /mnt base linux-lts linux-firmware # linux-lts-headers
    log -f 'essential packages installation'

    log 'system configuring'
    genfstab -U /mnt >> /mnt/etc/fstab
    # arch-chroot /mnt ln --force --symbolic /usr/share/zoneinfo/Europe/Moscow /etc/localtime
    ln --force --symbolic /mnt/usr/share/zoneinfo/Europe/Moscow /mnt/etc/localtime
    arch-chroot /mnt hwclock --systohc
    sed -i 's/^#\(\(en_US\|ru_RU\)\.UTF-8 UTF-8\)/\1/' /mnt/etc/locale.gen
    arch-chroot /mnt locale-gen
    echo LANG=en_US.UTF-8 > /mnt/etc/locale.conf
    log -f 'system configuring'

    log 'network configuring'
    echo "$hostname" > /mnt/etc/hostname
    echo '127.0.0.1 localhost' > /mnt/etc/hosts
    echo '::1 localhost' >> /mnt/etc/hosts
    echo "127.0.1.1 $hostname.localdomain $hostname" >> /mnt/etc/hosts
    arch-chroot /mnt pacman -S --noconfirm --needed networkmanager
    arch-chroot /mnt systemctl enable NetworkManager
    log -f 'network configuring'

    log 'users configuring'
    arch-chroot /mnt sh -c "(echo '$root_password'; echo '$root_password') | passwd >/dev/null"
    arch-chroot /mnt useradd --create-home --comment $user_fullname --groups wheel,audio $user_username
    arch-chroot /mnt sh -c "(echo '$user_password'; echo '$user_password') | passwd >/dev/null $user_username"
    arch-chroot /mnt pacman -S --noconfirm --needed sudo
    sed -i 's/^# \(%wheel ALL=(ALL) ALL\)/\1/' /mnt/etc/sudoers
    log -f 'users configuring'

    log 'boot loader installation and configuring'
    arch-chroot /mnt pacman -S --noconfirm --needed grub efibootmgr
    mkdir /mnt/boot/efi
    # arch-chroot /mnt mount /dev/sda1 /boot/efi
    # mount /mnt/dev/sda1 /mnt/boot/efi
    mount /dev/sda1 /mnt/boot/efi
    arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
    arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
    log -f 'boot loader installation and configuring'

    log 'partitions unmounting'
    umount -R /mnt
    log -f 'partitions unmounting'

    system_errors

    log -f installation
}


install_post () {
    sudo true

    echo -e "Started ${ES_BOLD}${ES_GREEN}Arch Linux post-installation${ES_RESET}."

    log 'swappiness configuring'
    sudo sh -c 'echo "vm.swappiness=10" > /etc/sysctl.conf'
    log -f 'swappiness configuring'

    log 'grub configuring'
    sudo sed -i 's/^\(GRUB_TIMEOUT\).*/\1=0/' /etc/default/grub
    # sudo sed -i '/GRUB_TIMEOUT/d' /etc/default/grub
    # sudo sh -c 'echo "GRUB_TIMEOUT=0" >> /etc/default/grub'
    sudo grub-mkconfig -o /boot/grub/grub.cfg
    log -f 'grub configuring'

    log 'pacman configuring'
    sudo pacman -Syyu --noconfirm --needed
    install_packages reflector
    sudo sh -c 'reflector --latest 20 --sort rate -c Austria,Belarus,Czechia,Denmark,Finland,Germany,Hungary,Latvia,Lithuania,Moldova,Norway,Poland,Romania,Russia,Slovakia,Sweden,Ukraine --protocol https > /etc/pacman.d/mirrorlist'
    log -f 'pacman configuring'

    log 'yay installation'
    install_packages base-devel git
    tempdir="$(mktemp -d)"
    git clone https://aur.archlinux.org/yay.git "$tempdir"
    sh -c "cd '$tempdir' && makepkg -si --noconfirm --needed"
    rm -rf "$tempdir"
    mkdir "$HOME/.gnupg"
    echo 'keyserver hkps://keyserver.ubuntu.com' > "$HOME/.gnupg/gpg.conf"
    log -f 'yay installation'

    log 'fonts installation'
    install_packages noto-fonts noto-fonts-emoji noto-fonts-cjk
    install_packages ttf-jetbrains-mono
    log -f 'fonts installation'

    log 'GNOME installation'
    install_packages gdm gnome-terminal
    sudo systemctl enable gdm
    log -f 'GNOME installation'

    log 'zsh installation'
    install_packages zsh
    # [ -d "$HOME/.oh-my-zsh" ] || sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" '' --unattended
    curl -fsSL https://starship.rs/install.sh | bash -s -- -f
    sudo chsh -s "$(which zsh)" "$(whoami)"
    rm "$HOME/.bash"*
    log -f 'zsh installation'

    log 'OpenSSH installation'
    install_packages openssh
    sudo sh -c 'echo "DisableForwarding yes # disable all forwarding features (overrides all other forwarding-related options)" >> /etc/ssh/sshd_config'
    sudo sed -i 's/^#\(IgnoreRhosts\).*/\1 yes/' /etc/ssh/sshd_config
    # sudo sed -i 's/^#\(PasswordAuthentication\).*/\1 no/' /etc/ssh/sshd_config
    sudo sed -i 's/^#\(PermitRootLogin\).*/\1 no/' /etc/ssh/sshd_config
    sudo systemctl enable sshd
    log -f 'OpenSSH installation'

    log 'ufw installation'
    install_packages ufw
    sudo ufw limit ssh
    sudo ufw allow transmission
    sudo systemctl enable ufw
    log -f 'ufw installation'

    log 'additional packages installation'
    install_packages \
        man \
        vim \
        tilix \
        # wget \
        # nmap \
        # imagemagick \
        # python \
        # python-pip \
        # inetutils \
        # code \
        # firefox \
        # telegram-desktop \
        # vlc \
        # transmission-gtk
    install_packages -a xcursor-openzone
    log -f 'additional packages installation'

    # log 'GDM configuring'
    # tempdir=$(mktemp -d)
    # cd "$tempdir"

    # me.gresource "$file" >"$tempdir$file"
    #     echo "<file>${file#\/}</file>" >>"$tempdir/gnome-shell-theme.gresource.xml"
    # done
    # echo '</gresource></gresources>' >>"$tempdir/gnome-shell-theme.gresource.xml"
    # sed -i -zE 's/(#lockDialogGroup \{)[^}]+/\1 background-color: #000000; /g' "$tempdir/org/gnome/shell/theme/gnome-shell.css"
    # glib-compile-resources "$tempdir/gnome-shell-theme.gresource.xml"
    # sudo cp -f /usr/share/gnome-shell/gnome-shell-theme.gresource /usr/share/gnome-shell/gnome-shell-theme.gresource.bak
    # sudo cp -f "$tempdir/gnome-shell-theme.gresource" /usr/share/gnome-shell/
    # cd - > /dev/null
    # rm -rf "$tempdir"
    # log -f 'GDM configuring'

    log 'GNOME configuring'
    # sudo sed -i 's/^#\(WaylandEnable=false\)/\1/' /etc/gdm/custom.conf

    dconf write /org/gnome/desktop/input-sources/sources "[('xkb', 'us'), ('xkb', 'ru')]"
    dconf write /org/gnome/desktop/privacy/remember-app-usage false
    dconf write /org/gnome/shell/favorite-apps "['']"
    dconf write /org/gnome/shell/extensions/user-theme/name "'Custom'"
    dconf write /org/gnome/desktop/background/primary-color "'#000000'"
    dconf write /org/gnome/desktop/screensaver/primary-color "'#000000'"

    dconf write /org/gnome/desktop/interface/enable-animations false
    dconf write /org/gnome/desktop/interface/gtk-theme "'Adwaita-dark'"
    dconf write /org/gnome/desktop/interface/cursor-theme "'OpenZone_Black'"
    dconf write /org/gnome/desktop/interface/clock-show-date false
    dconf write /org/gnome/desktop/interface/clock-show-seconds true
    dconf write /org/gnome/desktop/wm/preferences/action-middle-click-titlebar "'minimize'"
    dconf write /org/gnome/mutter/dynamic-workspaces false
    dconf write /org/gnome/desktop/wm/preferences/num-workspaces 1
    dconf write /org/gnome/mutter/center-new-windows true
    dconf write /org/gnome/desktop/interface/monospace-font-name "'JetBrains Mono NL 9.5'"
    dconf write /org/gnome/desktop/sound/theme-name "''"
    dconf write /org/gnome/desktop/screensaver/lock-enabled false
    dconf write /org/gnome/desktop/notifications/show-in-lock-screen false
    dconf write /org/gnome/desktop/session/idle-delay "'uint32 0'"

    sudo sed -i 's/^Exec=gnome-terminal/& --maximize/' /usr/share/applications/org.gnome.Terminal.desktop
    dconf write /org/gnome/terminal/legacy/keybindings/reset-and-clear "'<Primary>k'"
    terminal_profile="$(uuidgen)"
    dconf write /org/gnome/terminal/legacy/profiles:/list "['$terminal_profile']"
    dconf write /org/gnome/terminal/legacy/profiles:/:$terminal_profile/visible-name "'Default'"
    dconf write /org/gnome/terminal/legacy/profiles:/:$terminal_profile/highlight-colors-set true
    dconf write /org/gnome/terminal/legacy/profiles:/:$terminal_profile/use-theme-colors false
    dconf write /org/gnome/terminal/legacy/profiles:/:$terminal_profile/palette "$PALETTE"
    dconf write /org/gnome/terminal/legacy/profiles:/:$terminal_profile/foreground-color "'$FOREGROUND'"
    dconf write /org/gnome/terminal/legacy/profiles:/:$terminal_profile/background-color "'$BACKGROUND'"
    dconf write /org/gnome/terminal/legacy/profiles:/:$terminal_profile/highlight-foreground-color "'$FOREGROUND'"
    dconf write /org/gnome/terminal/legacy/profiles:/:$terminal_profile/highlight-background-color "'$BACKGROUND_HIGHLIGHT'"
    dconf write /org/gnome/terminal/legacy/profiles:/:$terminal_profile/cell-height-scale 1.15
    dconf write /org/gnome/terminal/legacy/profiles:/:$terminal_profile/scrollback-lines 1000000

    sudo sed -i 's/^Exec=tilix$/& --maximize/' /usr/share/applications/com.gexperts.Tilix.desktop
    sudo sed -i '/DBusActivatable/d' /usr/share/applications/com.gexperts.Tilix.desktop
    dconf write /com/gexperts/Tilix/app-title "'\${appName}: \${title}'"
    dconf write /com/gexperts/Tilix/unsafe-paste-alert false
    dconf write /com/gexperts/Tilix/window-save-state true
    dconf write /com/gexperts/Tilix/window-style "'disable-csd-hide-toolbar'"
    dconf write /com/gexperts/Tilix/session-name "'\${title}'"
    dconf write /com/gexperts/Tilix/use-tabs true
    dconf write /com/gexperts/Tilix/terminal-title-style "'none'"
    dconf write /com/gexperts/Tilix/enable-wide-handle true
    dconf write /com/gexperts/Tilix/keybindings/terminal-reset-and-clear "'<Primary>k'"
    dconf write /com/gexperts/Tilix/profiles/list "['$terminal_profile']"
    dconf write /com/gexperts/Tilix/profiles/default "'$terminal_profile'"
    dconf write /com/gexperts/Tilix/profiles/$terminal_profile/visible-name "'Default'"
    dconf write /com/gexperts/Tilix/profiles/$terminal_profile/terminal-title "'\${title}'"
    dconf write /com/gexperts/Tilix/profiles/$terminal_profile/use-theme-colors false
    dconf write /com/gexperts/Tilix/profiles/$terminal_profile/foreground-color "'$FOREGROUND'"
    dconf write /com/gexperts/Tilix/profiles/$terminal_profile/background-color "'$BACKGROUND'"
    dconf write /com/gexperts/Tilix/profiles/$terminal_profile/background-transparency-percent 6
    dconf write /com/gexperts/Tilix/profiles/$terminal_profile/highlight-colors-set true
    dconf write /com/gexperts/Tilix/profiles/$terminal_profile/highlight-foreground-color "'$FOREGROUND'"
    dconf write /com/gexperts/Tilix/profiles/$terminal_profile/highlight-background-color "'$BACKGROUND_HIGHLIGHT'"
    dconf write /com/gexperts/Tilix/profiles/$terminal_profile/palette "$PALETTE"
    dconf write /com/gexperts/Tilix/profiles/$terminal_profile/bold-is-bright false
    dconf write /com/gexperts/Tilix/profiles/$terminal_profile/scrollback-lines 1000000
    dconf write /com/gexperts/Tilix/profiles/$terminal_profile/show-scrollbar false
    dconf write /com/gexperts/Tilix/profiles/$terminal_profile/cell-height-scale 1.15

    # https://superuser.com/questions/1359253/how-to-remove-starred-tab-in-gnomes-nautilus
    dconf write /org/gnome/desktop/privacy/remember-recent-files false
    dconf write /org/gnome/nautilus/list-view/default-column-order "['where', 'name', 'owner', 'group', 'permissions', 'date_accessed', 'date_modified', 'date_modified_with_time', 'size', 'type', 'detailed_type', 'recency', 'starred']"
    dconf write /org/gnome/nautilus/list-view/default-visible-columns "['name', 'date_modified_with_time', 'size', 'detailed_type']"
    dconf write /org/gnome/nautilus/list-view/default-zoom-level "'small'"
    dconf write /org/gnome/nautilus/list-view/use-tree-view true
    dconf write /org/gnome/nautilus/preferences/default-folder-viewer "'list-view'"

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
    other_apps=$(ls -A1 /usr/share/applications | grep .desktop$)
    other_apps=$(grep -v "\($not_to_hide_apps\).desktop" <<< $other_apps)
    other_apps=$(awk '{ print $0 }' RS='\n' ORS="', '" <<< $other_apps)
    other_apps=[\'${other_apps::-4}\']
    dconf write /org/gnome/desktop/app-folders/folder-children "['Other']"
    dconf write /org/gnome/desktop/app-folders/folders/Other/name "'Other'"
    dconf write /org/gnome/desktop/app-folders/folders/Other/apps "$other_apps"
    dconf write /org/gnome/shell/app-picker-layout "[{'Other': <{'position': <0>}>}]"

    log -f 'GNOME configuring'

    log 'runtime configuration files cloning'
    install_packages rsync
    tempdir="$(mktemp -d)"
    git clone https://gitlab.com/romanilin/rcs.git "$tempdir"
    rsync -a "$tempdir/" "$HOME/"
    rm -rf "$tempdir"
    echo "user_pref(\"identity.fxaccounts.account.device.name\", \"$HOST\");" > "$HOME/.mozilla/firefox/default/user.js"
    log -f 'runtime configuration files cloning'

    log 'packages clearing up'
    orphans="$(pacman -Qtdq)"
    if [[ -n "$orphans" ]]; then
        sudo pacman -Rns --noconfirm $orphans
    fi
    log -f 'packages clearing up'

    echo -e "Finished ${ES_BOLD}${ES_GREEN}Arch Linux post-installation${ES_RESET}."

    system_errors -s
}


setup_terminal_colors

if [ "$mode" == 'post' ]; then
    setup_color_scheme
    install_post
else
    install_base
fi

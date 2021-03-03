#!/bin/sh
set -e
function help () {
cat <<EOF >&2
Run script via curl:
  sh -c "\$(curl -s https://gitlab.com/romanilin/alis/-/raw/main/install.sh)"
or equivalently:
  sh -c "\$(curl -sL https://v.gd/alisa)"
or run version from development branch:
  sh -c "\$(curl -s https://gitlab.com/romanilin/alis/-/raw/dev/install.sh)"

Supported options:
  -l, --lts            install linux-lts package instead of linux
  -p, --post           run post-installation: grub, swapiness, pacman configuring, GNOME installation, etc.
  -v, --vbox           install VirtualBox guest utilities
  -x, --xorg           configure GNOME to use only Xorg and disable Wayland
  -d, --drive <drive>  install Arch Linux to <drive>, /dev/sda by default
  -u, --update         just update rc-files and other configurations
EOF
exit
}


MIRRORS_COUNTRIES=(
	'Austria'
	'Belarus'
	'Czechia'
	'Denmark'
	'Finland'
	'Germany'
	'Hungary'
	'Latvia'
	'Lithuania'
	'Moldova'
	'Norway'
	'Poland'
	'Romania'
	'Russia'
	'Slovakia'
	'Sweden'
	'Ukraine'
)
MIRRORS_COUNTRIES=`printf ',%s' "${MIRRORS_COUNTRIES[@]}" | cut -c 2-`

FONTS_PACKAGES=(
	'ttf-jetbrains-mono'
	'ttf-nerd-fonts-symbols-mono'
	'noto-fonts'
	'noto-fonts-emoji'
	'noto-fonts-cjk'
)

GNOME_PACKAGES=(
	'gdm'
	'gnome-terminal'
	'jack2'
	'gnome-control-center'
	'nautilus'
	'gnome-themes-extra'
	'chrome-gnome-shell'
	'gnome-tweaks'
	'eog'
)

ADDITIONAL_PACKAGES=(
	'man'
	'vim'
	'xdg-user-dirs'
	'chromium'
	'code'
	'kitty'
	'inetutils'
	'p7zip'
	'python-pip'
	'qalculate-gtk'
	'telegram-desktop'
	'transmission-gtk'
	'vlc'
	'xcursor-openzone'
	'youtube-dl'
	'keepassxc'
	'libgnome-keyring'
	'fuse2'
)

# https://addons.mozilla.org/addon/${addon}/
FIREFOX_ADDONS=(
	'copy-selected-tabs-to-clipboar'
	'darkvk'
	'default-bookmark-folder'
	'gnome-shell-integration'
	'image-search-options'
	'keepassxc-browser'
	'tampermonkey'
	'wappalyzer'
	# Privacy add-ons
	'decentraleyes'
	'dont-touch-my-tabs'
	'dont-track-me-google1'
	'facebook-container'
	'google-container'
	'nano-defender-firefox'
	'nohttp'
	'noscript'
	'privacy-badger17'
	'privacy-possum'
	'smart-referer'
	'uaswitcher'
	'ublock-origin'
)

GNOME_EXTENSIONS=(
	'7/removable-drive-menu'
	'19/user-themes'
	'517/caffeine'
	'779/clipboard-indicator'
	'800/remove-dropdown-arrows'
	'1010/archlinux-updates-indicator'
	'1031/topicons'
	'1112/screenshot-tool'
	'1236/noannoyance'
	'1526/notification-centerselenium-h'
	'3396/color-picker'
)

# Applications not to move to folder 'Other' in GNOME applications' list
APPS_TO_SHOW=(
	'chromium'
	'code-oss'
	'kitty'
	'librewolf'
	'org.gnome.Nautilus'
	'qalculate-gtk'
	'telegramdesktop'
	'transmission-gtk'
	'virtualbox'
)
APPS_TO_SHOW=`printf '\|%s' "${APPS_TO_SHOW[@]}" | cut -c 3-`


function invalid_option () {
	cat <<-EOF >&2
		ALIS: invalid option -- '$1'
		Try run with '--help' option for more information.
	EOF
	exit 1
}


for option in "$@"; do
	shift
	case "$option" in
		'--help')
			set -- "$@" '-h' ;;
		'--update')
			set -- "$@" '-u' ;;
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
		*)  [ "$option" == --* ] && invalid_option "$option"
			set -- "$@" "$option"
	esac
done

LTS=false
MODE='base'
VBOX=false
XORG=false
DRIVE='/dev/sda'
UPDATE_CONFIGURATION=false

OPTIND=1
while getopts ':d:hlpuvx' option; do
	case "$option" in
		h) help ;;
		u) UPDATE_CONFIGURATION=true ;;
		d) DRIVE="$OPTARG" ;;
		l) LTS=true ;;
		p) MODE='post' ;;
		v) VBOX=true ;;
		x) XORG=true ;;
		?) invalid_option "$option"
	esac
done
shift $((OPTIND-1))
[ "${1:-}" = '--' ] && shift


[ "$EUID" == 0 ] || SUDO=sudo
[ "$MODE" == 'post' ] || CHROOT=arch-chroot /mnt


function setup_terminal_colors () {
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


function log () {
	# log function
	# -i <depth>  Add indent in message beggining
	# -s          Print "Started ..." message
	# -f          Print "Finished ..." message
	# -n          Prevent line break
	# -e          End message with provided string, '.' by default
	# -w          Wrap message with provided escape sequence

	local OPTIND=1
	local DEPTH=0
	local FORMAT="${ES_BOLD}"
	local PADDING=''
	local NEWLINE='\n'
	local END='.'
	local STATUS=''

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
		PADDING=$(printf "=%.0s" `seq $(($DEPTH * 2))`)
		PADDING="${ES_CYAN}${PADDING}>${ES_RESET} "
	fi

	printf "${ES_BOLD}${ES_CYAN}[ALIS]${ES_RESET} ${PADDING}${STATUS}${FORMAT}$@${ES_RESET}${END}${NEWLINE}" >&2
}


function setup_color_scheme () {
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
	COLORS_LIST='$BLACK,$RED,$GREEN,$YELLOW,$BLUE,$MAGENTA,$CYAN,$WHITE,$BLACK_BRIGHT,$RED_BRIGHT,$GREEN_BRIGHT,$YELLOW_BRIGHT,$BLUE_BRIGHT,$MAGENTA_BRIGHT,$CYAN_BRIGHT,$WHITE_BRIGHT,$FOREGROUND,$BACKGROUND,$BACKGROUND_HIGHLIGHT'
}


function check_system_errors () {
	log -e ':' 'System errors information'
	log -i 1 -e ':' 'systemctl --failed'
	PAGER= $SUDO systemctl --failed
	log -i 1 -e ':' 'journalctl -p 3 -xb'
	PAGER= $SUDO journalctl -p 3 -xb

	while true; do
		log -i 1 -n -e '? [Y/n] ' 'Clear these logs'
		read -e answer
		case $answer in
			[Nn]*) break ;;
			[Yy]*|'')
				$SUDO systemctl reset-failed
				$SUDO journalctl --vacuum-time=1s
				break
				;;
			*) log -i 1 'Try again'
		esac
	done
}


function revert_sudoers () {
	# revert original /etc/sudoers after preventing sudo timeout
	[ -f '/etc/sudoers.bak' ] && sudo mv /etc/sudoers.bak /etc/sudoers
}


function ask_to_reboot () {
	while true; do
		log -n -e '? [Y/n] ' 'Reboot now'
		read -e answer
		case $answer in
			[Nn]*) break ;;
			[Yy]*|'')
				revert_sudoers
				$SUDO reboot
				break
				;;
			*) log -i 1 'Try again'
		esac
	done
}


function install_packages () {
	pacman -Q paru &>/dev/null && command='paru' || command="$SUDO pacman"
	$command -S --noconfirm --needed "$@"
}


function install_vbox_guest_utils () {
	$CHROOT sh -c "pacman -Q linux 2>/dev/null || $SUDO pacman -S --noconfirm --needed virtualbox-guest-dkms"
	$CHROOT $SUDO pacman -S --noconfirm --needed virtualbox-guest-utils
	$CHROOT $SUDO systemctl enable vboxservice
	if [ "$MODE" == 'post' ]; then $SUDO systemctl start vboxservice; fi
}

function ask () {
	result=1
	while true; do
		log -n -e '? [Y/n] ' "$@"
		read -e answer
		case $answer in
			[Nn]*)
				break
				;;
			[Yy]*|'')
				result=0
				break
				;;
			*) log -i 1 'Try again'
		esac
	done
	return $result
}

function install_paru () {
	install_packages base-devel git
	local tempdir="$(mktemp -d)"
	git clone https://aur.archlinux.org/paru-bin.git "$tempdir"
	sh -c "cd '$tempdir' && makepkg -si --noconfirm --needed"
	rm -rf "$tempdir"
}

function update_configuration () {
	# XDG Base Directory specification
	# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
	export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME/.config"}
	export XDG_CACHE_HOME=${XDG_CACHE_HOME:-"$HOME/.cache"}
	export XDG_DATA_HOME=${XDG_DATA_HOME:-"$HOME/.local/share"}

	if command -v pacman &>/dev/null; then
		$SUDO pacman -Sy
		install_packages rsync
	elif command -v apt &>/dev/null; then
		$SUDO apt update
		$SUDO apt install rsync
	elif command -v yum &>/dev/null; then
		yum install rsync
	fi
	local tempdir="$(mktemp -d)"
	git clone https://gitlab.com/romanilin/alis.git "$tempdir"
	rm -rf "$tempdir/"{.git,install.sh,LICENSE,README.md}

	# GNU Privacy Guard directory
	export GNUPGHOME={GNUPGHOME:-"$XDG_CONFIG_HOME/gnupg"}
	mkdir -p "$GNUPGHOME"
	chmod 700 "$GNUPGHOME"
	if [ -d "$HOME/.gnupg" ]; then
		rsync -a "$HOME/.gnupg/" "$GNUPGHOME/"
		rm -rf "$HOME/.gnupg"
	fi
	rsync -a "$tempdir/.config/gnupg/" "$GNUPGHOME/"
	rm -rf "$tempdir/.config/gnupg"

	# Secure Shell directory
	mkdir -p "$XDG_CONFIG_HOME/ssh"
	if [ -d "$HOME/.ssh" ]; then
		rsync -a "$HOME/.ssh/" "$XDG_CONFIG_HOME/ssh/"
		rm -rf "$HOME/.ssh"
	fi
	rsync -a "$tempdir/.config/ssh/" "$XDG_CONFIG_HOME/ssh/"
	envsubst '$XDG_CONFIG_HOME' <"$tempdir/.config/ssh/config" >"$XDG_CONFIG_HOME/ssh/config"
	[ ! -f "$XDG_CONFIG_HOME/ssh/id_ed25519" ] && ssh-keygen -P '' -t ed25519        -f "$XDG_CONFIG_HOME/ssh/id_ed25519"
	[ ! -f "$XDG_CONFIG_HOME/ssh/id_rsa" ]     && ssh-keygen -P '' -t rsa -b 4096 -o -f "$XDG_CONFIG_HOME/ssh/id_rsa"
	chmod 600 "$XDG_CONFIG_HOME/ssh/id_"*
	eval "$(ssh-agent -s)"
	for file in "$XDG_CONFIG_HOME/ssh/id_"{rsa,dsa,ecdsa,ecdsa_sk,ed25519}; do
		[ -f $file ] && ssh-add $file
	done
	rm -rf "$tempdir/.config/ssh"

	# pacman and paru configuration
	if [ -f /etc/pacman.conf ]; then
		pacman -Q paru &>/dev/null || install_paru
		sudo mv "$tempdir/.config/paru/pacman.conf" /etc/pacman.conf
		rsync -a "$tempdir/.config/paru/" "$XDG_CONFIG_HOME/paru/"
		paru -Sy
	fi
	rm -rf "$tempdir/.config/paru/"
	
	envsubst "$COLORS_LIST" <"$tempdir/.config/kitty/kitty.conf" >"$XDG_CONFIG_HOME/kitty/kitty.conf"
	rm -rf "$tempdir/.config/kitty"

	if [ -d "$HOME/.vscode-oss" ]; then
		rsync -a "$HOME/.vscode-oss/" "$XDG_DATA_HOME/vscode-oss/"
		rm -rf "$HOME/.vscode-oss"
	fi
	if [ ! -f /usr/lib/electron/bin/code-oss ]; then
		sudo mkdir -p /usr/lib/electron/bin
		sudo ln /usr/bin/code-oss /usr/lib/electron/bin/code-oss
	fi
	rsync -a "$tempdir/.config/Code - OSS/" "$XDG_CONFIG_HOME/Code - OSS/"
	rm -rf "$tempdir/.config/Code - OSS"

	local librewolf_home="$XDG_DATA_HOME/librewolf/librewolf.AppImage.home"
	if [ -d "$HOME/.librewolf" ]; then
		rsync -a "$HOME/.librewolf/" "$librewolf_home/.librewolf/"
		rm -rf "$HOME/.librewolf"
		paru -Rcns librewolf
	fi
	if [ ! -f "$XDG_DATA_HOME/librewolf/librewolf.AppImage" ]; then
		local librewolf_gitlab_graphql='[{
			"operationName":"allReleases",
			"variables":{"fullPath":"librewolf-community/browser/linux","first":1},
			"query":"query allReleases($fullPath:ID!,$first:Int){project(fullPath:$fullPath){releases(first:$first){nodes{...Release}}}}fragment Release on Release{assets{links{nodes{name url}}}}"
		}]'
		local librewolf_appimage_url=`curl -s 'https://gitlab.com/api/graphql' -H 'content-type: application/json' --data-raw "$librewolf_gitlab_graphql"`
		librewolf_appimage_url=`echo "$librewolf_appimage_url" | grep -oP "https://[^\"]+?$(uname -m).AppImage(?=\")"`
		mkdir "$XDG_DATA_HOME/librewolf" && curl -o "$XDG_DATA_HOME/librewolf/librewolf.AppImage" "$librewolf_appimage_url"
		chmod +x "$XDG_DATA_HOME/librewolf/librewolf.AppImage"
		sudo ln -s "$XDG_DATA_HOME/librewolf/librewolf.AppImage" /usr/bin/librewolf
		librewolf --appimage-portable-home
	fi
	if [ ! -f "$librewolf_home/.librewolf/installs.ini" ]; then
		librewolf --headless </dev/null &>/dev/null &
		local librewolf_pid=$!
		while true; do
			[ -f "$librewolf_home/.librewolf/installs.ini" ] && break
			sleep 0.1
		done
		kill $librewolf_pid
		rm -rf "$librewolf_home/.librewolf/"*.default*
	fi
	export librefox_install_hash=`grep -oP '\[\K.+(?=])' "$librewolf_home/.librewolf/installs.ini"`
	local librewolf_home_temp="$tempdir/.local/share/librewolf/librewolf.AppImage.home"
	rsync -a "$librewolf_home_temp/.librewolf/" "$librewolf_home/.librewolf/"
	envsubst '$librefox_install_hash' <"$librewolf_home_temp/.librewolf/installs.ini" >"$librewolf_home/.librewolf/installs.ini"
	envsubst '$librefox_install_hash' <"$librewolf_home_temp/.librewolf/profiles.ini" >"$librewolf_home/.librewolf/profiles.ini"
	envsubst '$USER,$HOST' <"$librewolf_home_temp/.librewolf/default/user.js" >"$librewolf_home/.librewolf/default/user.js"
	rm -rf "$tempdir/.local/share/librewolf"

	mkdir -p "$librewolf_home/.librewolf/default/extensions"
	addons_root="https://addons.mozilla.org/firefox"
	log -s -i 1 'Firefox add-ons installation'
	for addon in "${FIREFOX_ADDONS[@]}"; do
		log -i 2 -w "${ES_RESET}" -e '...' "$addon"
		addon_page="$(curl -sL "$addons_root/addon/$addon")"
		addon_guid="$(echo $addon_page | grep -oP 'byGUID":{"\K.+?(?=":)')"
		if [ ! -f "$librewolf_home/.librewolf/default/extensions/$addon_guid.xpi" ]; do
			xpi_url="$addons_root/downloads/file/$(echo $addon_page | grep -oP 'file/\K.+\.xpi(?=">Download file)')"
			curl -fsSL "$xpi_url" -o "$librewolf_home/.librewolf/default/extensions/$addon_guid.xpi"
		fi
	done
	log -f -i 1 'Firefox add-ons installation'

	rsync -a "$tempdir/" "$HOME/"
	rm -rf "$tempdir"
}


function install_base () {
	log -s -w "${ES_CYAN}" 'Arch Linux base installation'

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
		if [ "$ROOT_PASSWORD" == "$ROOT_PASSWORD_CHECK" ]; then break; fi
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
		if [ "$USER_PASSWORD" == "$USER_PASSWORD_CHECK" ]; then break; fi
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
	if [ -d /sys/firmware/efi/efivars ]; then
		cat <<-EOF | sfdisk $DRIVE
			label: gpt
			sector-size: $SECTOR_SIZE
			${DRIVE}1: type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B, size=532480
			${DRIVE}2: type=0657FD6D-A4AB-43C4-84E5-0933C84B4F4F, size=$SWAP_SECTORS
			${DRIVE}3: type=0FC63DAF-8483-4772-8E79-3D69D8477DE4
		EOF
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
	else
		cat <<-EOF | sfdisk $DRIVE
			label: dos
			sector-size: $SECTOR_SIZE
			${DRIVE}1: type=82, size=$SWAP_SECTORS
			${DRIVE}2: type=83, bootable
		EOF
		log -f 'partitioning'

		log -s 'partitions formatting'
		mkswap /dev/sda1
		mkfs.ext4 /dev/sda2
		log -f 'partitions formatting'

		log -s 'file systems mounting'
		mount /dev/sda2 /mnt
		swapon /dev/sda1
		log -f 'file systems mounting'
	fi

	log -s 'mirrors list updating'
	reflector --fastest 5 --sort rate -c "$MIRRORS_COUNTRIES" --protocol https --save /etc/pacman.d/mirrorlist
	log -f 'mirrors list updating'

	log -s 'essential packages installation'
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
	cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
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

	log -f -w "${ES_CYAN}" 'Arch Linux base installation'

	check_system_errors

	ask_to_reboot
}


function install_post () {
	log -s -w "${ES_CYAN}" 'Arch Linux post-installation'

	# XDG Base Directory specification
	# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
	export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME/.config"}
	export XDG_CACHE_HOME=${XDG_CACHE_HOME:-"$HOME/.cache"}
	export XDG_DATA_HOME=${XDG_DATA_HOME:-"$HOME/.local/share"}

	export GNUPGHOME="$XDG_CONFIG_HOME/gnupg"
	mkdir -p "$GNUPGHOME"
	chmod 700 "$GNUPGHOME"

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
	sudo sh -c "cat <<-EOF >/etc/xdg/reflector/reflector.conf
		--save /etc/pacman.d/mirrorlist
		--protocol https
		--country $MIRRORS_COUNTRIES
		--sort rate
		--fastest 5
	EOF"
	sudo systemctl enable --now reflector.timer
	log -f 'pacman configuring'

	log -s 'paru installation'
	install_paru
	log -f 'paru installation'

	log -s 'fonts installation'
	install_packages "${FONTS_PACKAGES[@]}"
	log -f 'fonts installation'

	log -s 'GNOME installation'
	install_packages "${GNOME_PACKAGES[@]}"
	sudo systemctl enable gdm
	log -f 'GNOME installation'

	log -s 'zsh installation'
	install_packages zsh starship-bin
	sudo sh -c "echo 'export XDG_CONFIG_HOME=\"\$HOME/.config\"' >/etc/zsh/zshenv"
	sudo sh -c "echo 'export ZDOTDIR=\"\$XDG_CONFIG_HOME/zsh\"' >>/etc/zsh/zshenv"
	sudo chsh -s "$(which zsh)" "$(whoami)"
	export HISTFILE="$(mktemp)"
	export HISTSIZE=0
	history -c
	rm "$HOME/.bash"*
	log -f 'zsh installation'

	log -s 'OpenSSH installation'
	install_packages openssh
	sudo sh -c 'echo "DisableForwarding yes # disable all forwarding features (overrides all other forwarding-related options)" >>/etc/ssh/sshd_config'
	sudo sed -i 's/^#\(IgnoreRhosts\).*/\1 yes/' /etc/ssh/sshd_config
	sudo sed -i "s/^#\(AuthorizedKeysFile\).*/\1 .config\/ssh\/authorized_keys/" /etc/ssh/sshd_config
	# sudo sed -i 's/^#\(PasswordAuthentication\).*/\1 no/' /etc/ssh/sshd_config
	sudo sed -i 's/^#\(PermitRootLogin\).*/\1 no/' /etc/ssh/sshd_config
	sudo systemctl enable sshd
	log -f 'OpenSSH installation'

	log -s 'ufw installation'
	install_packages ufw
	sudo ufw limit ssh
	sudo ufw allow transmission
	sudo systemctl enable --now ufw
	log -f 'ufw installation'

	log -s 'additional packages installation'
	install_packages "${ADDITIONAL_PACKAGES[@]}"
	log -f 'additional packages installation'

	if [ "$VBOX" == true ]; then
		log -s 'VirtualBox guest utilities installation'
		install_vbox_guest_utils
		log -f 'VirtualBox guest utilities installation'
	fi

	log -s 'runtime configuration files cloning'
	update_configuration
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
	[ "$XORG" == true ] && sudo sed -i 's/^#\(WaylandEnable=false\)/\1/' /etc/gdm/custom.conf

	export apps_to_hide=$(ls -A1 /usr/share/applications | grep .desktop$)
	apps_to_hide=$(grep -v "\($APPS_TO_SHOW\).desktop" <<<$apps_to_hide)
	apps_to_hide=$(awk '{ print $0 }' RS='\n' ORS="', '" <<<$apps_to_hide)
	apps_to_hide=[\'${apps_to_hide::-4}\']

	tempdir=$(mktemp -d)
	extensions_root='https://extensions.gnome.org'
	gnome_shell_version="$(gnome-shell --version | awk '{print $NF}')"
	for extension in "${GNOME_EXTENSIONS[@]}"; do
		data_uuid="$(curl $extensions_root/extension/$extension/ -so - | awk -F\" '/data-uuid/ {print $2}')"
		extension_url="$extensions_root/download-extension/$data_uuid.shell-extension.zip?shell_version=$gnome_shell_version"
		extension_url="$(curl -sI $extension_url | awk '/Location:/ {print $2}' | tr -d '\r')"
		sh -c "cd '$tempdir' && curl -fsSLO '$extensions_root$extension_url'"
		gnome-extensions install -f $tempdir/*.zip
		gnome-extensions enable $data_uuid
		rm $tempdir/*
	done
	rm -rf "$tempdir"
	find "$HOME/.local/share/gnome-shell/extensions/arch-update@RaphaelRochet" \( -type d -name .git -prune \) -o -type f -print0 \
		| xargs -0 sed -i 's/\(Up to date\) :)/\1/g'

	export terminal_profile="$(uuidgen)"
	envsubst '$FOREGROUND,$BACKGROUND,$BACKGROUND_HIGHLIGHT,$PALETTE,$apps_to_hide,$terminal_profile' <"$HOME/.config/dconf/dump.ini" | dconf load /
	rm "$HOME/.config/dconf/dump.ini"
	log -f 'GNOME configuring'

	if [ "$VBOX" == true ]; then
		log -s 'VirtualBox guest utilities installation'
		install_vbox_guest_utils
		log -f 'VirtualBox guest utilities installation'
	fi

	log -s 'pacman clearing up'
	orphans="$(pacman -Qtdq | tee)"
	[[ -n "$orphans" ]] && sudo pacman -Rcns --noconfirm "$orphans"
	sudo pacman -Scc --noconfirm
	log -f 'pacman clearing up'

	log -f -w "${ES_CYAN}" 'Arch Linux post-installation'

	check_system_errors

	ask_to_reboot
}


setup_terminal_colors
setup_color_scheme

if [ "$UPDATE_CONFIGURATION" == true ]; then
	update_configuration
elif [ "$MODE" == 'post' ]; then
	install_post
else
	install_base
fi

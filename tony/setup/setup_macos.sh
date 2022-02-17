BREW_URL='https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh'
KEKA_URL='https://d.keka.io/'
KEKA_HELPER_URL='https://keka.io/'
ITERM_URL='https://iterm2.com/downloads/stable/latest'
CHROME_URL='https://dl.google.com/dl/chrome/mac/universal/stable/gcem/GoogleChrome.pkg'
FINICKY_URL='https://api.github.com/repos/johnste/finicky/releases/latest'
VSCODE_URL='https://code.visualstudio.com/sha/download?build=stable&os=darwin-universal'
FANTASTICAL_URL='https://flexibits.com/fantastical/download'
DOCKER_DESKTOP_URL='https://desktop.docker.com/mac/main/amd64/Docker.dmg'
RECTANGLE_URL='https://api.github.com/repos/rxhanson/Rectangle/releases/latest'
APPCLEANER_URL='https://freemacsoft.net/appcleaner'
FIREFOX_URL='https://download.mozilla.org/?product=firefox-latest-ssl&os=osx&lang=en-US'
HMA_VPN_URL='https://s-mac-sl.avcdn.net/macosx/privax/HMA-VPN.dmg'
TOR_BROWSER_URL='https://www.torproject.org/download/'

BREW_DEPENDENCIES=(
	cmake
	coreutils
	font-meslo-lg-nerd-font
	git
	go
	neovim
	nmap
	nvm
	python
	# qalculate-gtk
	starship
)

MACOS_DATA_HOME="$HOME/Library/Application Support"
MACOS_CONFIG_HOME="$HOME"/Library/Preferences
MACOS_CACHE_HOME="$HOME"/Library/Caches
MACOS_STATE_HOME="$HOME/Library/Saved Application State"


macos_install () {
	verify_app () {
		sudo xattr -rd com.apple.quarantine /Applications/"$1".app
	}
	brew_formula_installed () {
		brew --prefix "$1" >/dev/null 2>&1
	}
	mount_dmg () {
		sudo hdiutil attach -noverify "$DOWNLOADS"/"$1".dmg \
		| tail -1 \
		| awk -F\t '{ print $NF }'
	}

	# osascript -e 'tell app "Finder" to open location "smb://romanilin.me"'

	if ! xcode-select -v >/dev/null 2>&1 ; then
		echo 'Command Line Tools for Xcode...'
		sudo xcode-select --install 2>/dev/null
	fi

	if ! command_exists brew; then
		echo 'Brew...'
		/bin/bash -c "$(curl -fsSL \"$BREW_URL\")" </dev/null
	fi
	if [[ ! `brew tap` =~ 'homebrew/cask-fonts' ]]; then
		brew tap homebrew/cask-fonts
	fi
	# for formula in "${BREW_DEPENDENCIES[@]}"; do
	# 	if ! brew_formula_installed $formula; then
	# 		brew install $formula;
	# 	fi
	# done

	if [ ! -d /Applications/Keka.app ]; then
		echo 'Keka...'
		curl -sL "$KEKA_URL" -o "$DOWNLOADS"/Keka.dmg
		mountpoint=`mount_dmg Keka`
		sudo cp -R "$mountpoint"/Keka.app /Applications/Keka.app
		sudo hdiutil detach "$mountpoint" >/dev/null
		rm -rf "$DOWNLOADS"/Keka.dmg
		verify_app Keka
	fi
	if [ ! -d /Applications/KekaExternalHelper.app ]; then
		echo 'Keka helper...'
		curl -sL "$KEKA_HELPER_URL" \
		| awk -F\" '/helper_download/ {print $4}' \
		| xargs curl -sL -o "$DOWNLOADS"/KekaExternalHelper.zip
		unzip -q "$DOWNLOADS"/KekaExternalHelper.zip -d "$DOWNLOADS"
		rm -rf "$DOWNLOADS"/KekaExternalHelper.zip
		sudo mv "$DOWNLOADS"/KekaExternalHelper.app /Applications
		verify_app KekaExternalHelper
	fi

	if [ ! -d /Applications/iTerm.app ]; then
		echo 'iTerm2...'
		curl -sL "$ITERM_URL" -o "$DOWNLOADS"/iTerm.zip
		unzip -q "$DOWNLOADS"/iTerm.zip -d "$DOWNLOADS"
		rm -rf "$DOWNLOADS"/iTerm.zip
		sudo mv "$DOWNLOADS"/iTerm.app /Applications
		verify_app iTerm
	fi

	if [ ! -d '/Applications/Google Chrome.app' ]; then
		echo 'Google Chrome...'
		curl -sL "$CHROME_URL" -o "$DOWNLOADS"/GoogleChrome.pkg
		sudo installer -package "$DOWNLOADS"/GoogleChrome.pkg -target /
		rm -rf "$DOWNLOADS"/GoogleChrome.pkg
		verify_app 'Google Chrome'
	fi

	if [ ! -d /Applications/Finicky.app ]; then
		echo 'Finicky...'
		curl -s "$FINICKY_URL" \
		| awk -F\" '/browser_download_url/ {print $4}' \
		| xargs curl -sL -o "$DOWNLOADS"/Finicky.zip
		unzip -q "$DOWNLOADS"/Finicky.zip -d "$DOWNLOADS"
		rm -rf "$DOWNLOADS"/Finicky.zip
		sudo mv "$DOWNLOADS"/Finicky.app /Applications
		verify_app Finicky
	fi

	if [ ! -d /Applications/Fantastical.app ]; then
		echo 'Fantastical...'
		curl -sL "$FANTASTICAL_URL" -o "$DOWNLOADS"/Fantastical.zip
		unzip -q "$DOWNLOADS"/Fantastical.zip -d "$DOWNLOADS"
		rm -rf "$DOWNLOADS"/Fantastical.zip
		sudo mv "$DOWNLOADS"/Fantastical.app /Applications
		verify_app Fantastical
	fi

	if [ ! -d '/Applications/Visual Studio Code.app' ]; then
		echo 'VS Code...'
		curl -sL "$VSCODE_URL" -o "$DOWNLOADS"/VSCode.zip
		unzip -q "$DOWNLOADS"/VSCode.zip -d "$DOWNLOADS"
		rm -rf "$DOWNLOADS"/VSCode.zip
		sudo mv "$DOWNLOADS/Visual Studio Code.app" /Applications
		verify_app 'Visual Studio Code'
	fi

	if [ ! -d /Applications/Docker.app ]; then
		echo 'Docker Desktop...'
		curl -sL "$DOCKER_DESKTOP_URL" -o "$DOWNLOADS"/Docker.dmg
		mountpoint=`mount_dmg Docker`
		sudo cp -R "$mountpoint"/Docker.app /Applications/Docker.app
		sudo hdiutil detach "$mountpoint" >/dev/null
		rm -rf "$DOWNLOADS"/Docker.dmg
		verify_app Docker
	fi

	if [ ! -d /Applications/Rectangle.app ]; then
		echo 'Rectangle...'
		curl -s "$RECTANGLE_URL" \
		| awk -F\" '/download.+dmg/ {print $4}' \
		| xargs curl -sL -o "$DOWNLOADS"/Rectangle.dmg
		mountpoint=`mount_dmg Rectangle`
		sudo cp -R "$mountpoint"/Rectangle.app /Applications/Rectangle.app
		sudo hdiutil detach "$mountpoint" >/dev/null
		rm -rf "$DOWNLOADS"/Rectangle.dmg
		verify_app Rectangle
	fi

	if [ ! -d /Applications/AppCleaner.app ]; then
		echo 'AppCleaner...'
		curl -sL "$APPCLEANER_URL" \
		| awk 'match($0, /[^"]+downloads[^"]+/) {print substr($0, RSTART, RLENGTH); exit}' \
		| xargs curl -sL -o "$DOWNLOADS"/AppCleaner.zip
		unzip -q "$DOWNLOADS"/AppCleaner.zip -d "$DOWNLOADS"
		rm -rf "$DOWNLOADS"/AppCleaner.zip
		sudo mv "$DOWNLOADS"/AppCleaner.app /Applications
		verify_app AppCleaner
	fi

	if [ ! -d /Applications/KeePassXC.app ]; then
		echo 'KeePassXC...'
		brew install --cask keepassxc
	fi

	if [ ! -d /Applications/Firefox.app ]; then
		echo 'Firefox...'
		curl -sL "$FIREFOX_URL" -o "$DOWNLOADS"/Firefox.dmg
		mountpoint=`mount_dmg Firefox`
		sudo cp -R "$mountpoint"/Firefox.app /Applications/Firefox.app
		sudo hdiutil detach "$mountpoint" >/dev/null
		rm -rf "$DOWNLOADS"/Firefox.dmg
		verify_app Firefox
	fi

	if [ ! -d '/Applications/HMA VPN.app' ]; then
		echo 'HMA VPN...'
		curl -sL "$HMA_VPN_URL" -o "$DOWNLOADS"/HMA-VPN.dmg
		mountpoint=`mount_dmg HMA-VPN`
		sudo installer -package "$mountpoint/Install HMA VPN.pkg" -target /
		sudo hdiutil detach "$mountpoint" >/dev/null
		verify_app 'HMA VPN'
	fi

	if [ ! -d '/Applications/Tor Browser.app' ]; then
		curl -sL "$TOR_BROWSER_URL" \
		| awk -F\" '/"downloadLink.+dmg/ {print $4}' \
		| xargs -I% curl -sL 'https://www.torproject.org/%' -o "$DOWNLOADS/Tor Browser.dmg"
		mountpoint=`mount_dmg 'Tor Browser'`
		sudo cp -R "$mountpoint/Tor Browser.app" '/Applications/Tor Browser.app'
		sudo hdiutil detach "$mountpoint" >/dev/null
		rm -rf "$DOWNLOADS/Tor Browser.dmg"
		verify_app 'Tor Browser'
	fi
}

macos_install_post () {
	convert_xdg_to_macos () {
		if [ ! -L "$1" ]; then
			mkdir -p `dirname "$1"`
			mv "$1"/* "$2" >/dev/null 2>&1 || true
			rm -rf "$1"
			ln -s "$2" "$1"
		fi
	}
	convert_xdg_to_macos "$XDG_DATA_HOME" "$MACOS_DATA_HOME"
	convert_xdg_to_macos "$XDG_CONFIG_HOME" "$MACOS_CONFIG_HOME"
	convert_xdg_to_macos "$XDG_CACHE_HOME" "$MACOS_CACHE_HOME"
	convert_xdg_to_macos "$XDG_STATE_HOME" "$MACOS_STATE_HOME"

	echo "ZDOTDIR=${MACOS_CONFIG_HOME:-\"\$HOME\"/Library/Preferences}/zsh" | sudo tee -a /private/etc/zshenv >/dev/null

	# Hide terminal login message
	echo >"$HOME"/.hushlogin

	# Copying all rc files
	cp -R "$RCS_PATH"/configs/* "$MACOS_CONFIG_HOME"
	mv "$MACOS_CONFIG_HOME"/macos/* "$MACOS_CONFIG_HOME"
	rm -rf "$MACOS_CONFIG_HOME"/macos

	# Set Finicky config path to Home Library folder
	open -a Finicky
	FINICKY_PLIST="$MACOS_CONFIG_HOME"/net.kassett.finicky.plist
	plutil -convert xml1 "$FINICKY_PLIST"
	plutil -replace NSNavLastRootDirectory -string "$MACOS_CONFIG_HOME" "$FINICKY_PLIST"
	plutil -remove config_location_bookmark "$FINICKY_PLIST" >/dev/null || true
	plutil -convert binary1 "$FINICKY_PLIST"
	killall Finicky 2>/dev/null || true
	open -a Finicky

	rm -rf "$MACOS_CONFIG_HOME"/vscode
	cp "$RCS_PATH"/configs/vscode/* "$MACOS_DATA_HOME"/Code/User
	if [ ! -L "$HOME"/.vscode ]; then
		mv "$HOME"/.vscode "$MACOS_CONFIG_HOME"
		ln -s "$MACOS_CONFIG_HOME"/vscode "$HOME"/.vscode
	fi
	# open -a 'Visual Studio Code'

	if [ ! -L "$HOME"/.docker ]; then
		mv "$HOME"/.docker "$MACOS_CONFIG_HOME"
		ln -s "$MACOS_CONFIG_HOME"/docker "$HOME"/.docker
	fi
	# open -a Docker

	if [ ! -L "$HOME"/.ssh ]; then
		mv "$HOME"/.ssh "$MACOS_CONFIG_HOME"
		ln -s "$MACOS_CONFIG_HOME"/ssh "$HOME"/.ssh
	fi

	open -a Rectangle

	# Python
	pip3 install --upgrade pip setuptools poetry pynvim

	# Node.js
	source "$(brew --prefix nvm)"/nvm.sh
	if ! nvm ls node >/dev/null; then
		nvm install node
	fi
	nvm alias default node
	npm install --global bash-language-server

	# .jupyter
	# .kube
	# .matplotlib
	# .minikube
	# .npm
	# .node_path
	# .viminfo
}

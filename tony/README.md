# Configuration files

This is collection of configuration files: `.ini`, `(.)rc-suffix` (run-commands files), other configuration dotfiles, etc.

## macOS

### Main Homebrew formulas and casks

```sh
formulas=(
	awk
	neovim
	nmap
	nvm
	starship
	tony/gkc/gkc
	python
	coreutils
	rust

	findutils
	gnu-tar
	gnu-sed
	gawk
	gnutls
	gnu-indent
	gnu-getopt
	grep
)
brew install ${formulas[*]}

casks=(
	appcleaner
	charles
	docker
	hma-pro-vpn
	fantastical
	rectangle
	telegram
	tor-browser
	transmission
	virtualbox
	chromedriver
	docker
	font-meslo-lg-nerd-font

	datagrip
	finicky
	firefox
	google-chrome
	iterm2
	keepassxc
	keka
	kekaexternalhelper
	postman
	pycharm
	slack
	visual-studio-code
)
brew install --cask ${casks[*]}
```

<!--
### nvm

```sh
nvm_latest_version=`curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest | awk -F\" '/tag_name/ { print $(NF-1) }'`
curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
```
-->

### iTerm2

<!-- minimumContrast = (1 + sqrt(84 * wcagContrast - 83)) / 42 -->

Load preferences:
1. `iTerm` → `Preferences` → `General` → `Preferences` → `Load preferences from a custom folder or URL`;
2. Enter URL: [smb://romanilin.me](smb://romanilin.me) (or WebDAV).

### Keka

Set as the default uncompressor: `Keka` → `Preferences` → `General` → `Set Keka as the default uncompressor`.

## License

[CC0-1.0](./LICENSE).

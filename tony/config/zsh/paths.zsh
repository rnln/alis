command_exists() { if ! command -v "$1" >/dev/null; then return 1; fi }

typeset -U path
add_to_path() { path=("$1" $path[@]) }


# XDG Base Directory specification
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
XDG_DATA_HOME=${XDG_DATA_HOME:-"$HOME"/.local/share}
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME"/.config}
XDG_CACHE_HOME=${XDG_CACHE_HOME:-"$HOME"/.cache}
XDG_STATE_HOME=${XDG_STATE_HOME:-"$HOME"/.local/state}

if [[ "$OSTYPE" == 'darwin'* ]]; then
	MACOS_DATA_HOME=${MACOS_DATA_HOME:-"$HOME/Library/Application Support"}
	MACOS_CONFIG_HOME=${MACOS_CONFIG_HOME:-"$HOME/Library/Preferences"}
	MACOS_CACHE_HOME=${MACOS_CACHE_HOME:-"$HOME/Library/Caches"}
	MACOS_STATE_HOME=${MACOS_STATE_HOME:-"$HOME/Library/Saved Application State"}

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
fi


# Zsh
HISTFILE="$XDG_STATE_HOME"/zsh/history
ZCOMPDIR="$XDG_CACHE_HOME"/zsh

# Docker
DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker

# Kubernetes
# minikube
MINIKUBE_HOME="$XDG_DATA_HOME"/minikube

# Rust
RUSTUP_HOME="$XDG_DATA_HOME"/rustup
CARGO_HOME="$XDG_DATA_HOME"/cargo
add_to_path "$CARGO_HOME"/bin

# Go
GOPATH="$XDG_DATA_HOME"/go
add_to_path "$GOPATH"/bin

# Starship
STARSHIP_CACHE="$XDG_CACHE_HOME"/starship
[ ! -d "$STARSHIP_CACHE" ] && mkdir -p "$STARSHIP_CACHE"
STARSHIP_CONFIG="$XDG_CONFIG_HOME"/starship.toml

# Node.js
NODE_REPL_HISTORY="$XDG_DATA_HOME"/node_repl_history
# npm
NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME"/npm/npmrc
# nvm
NVM_DIR="$XDG_CONFIG_HOME"/nvm
NVM_LAZY_LOAD=true
source "$(brew --prefix nvm)"/nvm.sh
# ts-node
TS_NODE_HISTORY="$XDG_DATA_HOME"/ts_node_repl_history

# Ruby bundler
BUNDLE_USER_CONFIG="$XDG_CONFIG_HOME"/bundle
BUNDLE_USER_CACHE="$XDG_CACHE_HOME"/bundle
BUNDLE_USER_PLUGIN="$XDG_DATA_HOME"/bundle
# Ruby gems
GEM_HOME="$XDG_DATA_HOME"/gem
GEM_SPEC_CACHE="$XDG_CACHE_HOME"/gem

# Python
PYTHONSTARTUP="$XDG_CONFIG_HOME"/python/pythonrc.py
# Pylint
PYLINTHOME="$XDG_DATA_HOME"/pylint
PYLINTRC="$XDG_CONFIG_HOME"/pylint/pylintrc
# Poetry
POETRY_HOME="$XDG_CONFIG_HOME"/poetry
add_to_path "$POETRY_HOME"/bin
# IPython/Jupyter
IPYTHONDIR="$XDG_CONFIG_HOME"/jupyter
JUPYTER_CONFIG_DIR="$IPYTHONDIR"
# Matplotlib
MPLCONFIGDIR="$XDG_CONFIG_HOME"/matplotlib

GNUPGHOME="$XDG_CONFIG_HOME"/gnupg
LESSHISTFILE="$XDG_CACHE_HOME"/lesshist
VSCODE_PORTABLE="$XDG_DATA_HOME"/vscode
WINEPREFIX="$XDG_DATA_HOME"/wine

# Misc paths
add_to_path "$HOME"/.local/bin
add_to_path /usr/local/sbin

unset -f command_exists
unset -f add_to_path

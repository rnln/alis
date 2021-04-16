# XDG Base Directory specification
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME"/.config}
XDG_CACHE_HOME=${XDG_CACHE_HOME:-"$HOME"/.cache}
XDG_DATA_HOME=${XDG_DATA_HOME:-"$HOME"/.local/share}

CARGO_HOME="$XDG_DATA_HOME"/cargo
GNUPGHOME="$XDG_CONFIG_HOME"/gnupg
GOPATH="$XDG_DATA_HOME"/go
HISTFILE="$XDG_DATA_HOME"/zsh/history
LESSHISTFILE="$XDG_CACHE_HOME"/lesshist
PYLINTHOME="$XDG_CACHE_HOME"/pylint
STARSHIP_CACHE="$XDG_CACHE_HOME"/starship
VSCODE_PORTABLE="$XDG_DATA_HOME"/vscode
WINEPREFIX="$XDG_DATA_HOME"/wine

typeset -U path
path=("$HOME"/.local/bin $path[@])
path=("$CARGO_HOME"/bin $path[@])
path=("$GOPATH"/bin $path[@])

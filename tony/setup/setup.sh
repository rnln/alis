#!/usr/bin/env bash

set -e

# XDG Base Directory specification
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
XDG_DATA_HOME="$HOME"/.local/share
XDG_CONFIG_HOME="$HOME"/.config
XDG_CACHE_HOME="$HOME"/.cache
XDG_STATE_HOME="$HOME"/.local/state

DOWNLOADS="$HOME"/Downloads

RCS_PATH="`dirname \"$0\"`"
RCS_PATH="`( cd \"$RCS_PATH\"/.. && pwd )`"


command_exists () { command -v "$1" >/dev/null 2>&1; }


main () {
	sudo true # TODO: root required

	if [[ "$OSTYPE" == 'darwin'* ]]; then
		source "$RCS_PATH"/setup/setup_macos.sh
		macos_install
		macos_install_post
	elif [[ "$OSTYPE" == 'linux-gnu'* ]]; then
		linux_install
	fi
}


linux_install () {
	echo 'TODO: Linux installation.' >&2
	exit 1
}


main

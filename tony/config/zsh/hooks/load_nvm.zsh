__hook_load_nvmrc() {
	find_up() {
		local __path="`pwd`"
		while [[ "$__path" != / ]]; do
			find "$__path" -maxdepth 1 -mindepth 1 -name "$1" 2>/dev/null
			__path="`"${__MACOS_GNU_PREFIX}"readlink -f "$__path"/..`"
		done
	}
	local nvmrc_path="$(find_up .nvmrc)"

	if [ -n "$nvmrc_path" ]; then
		local node_version="$(nvm version)"
		local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

		if [ "$nvmrc_node_version" = "N/A" ]; then
			nvm install
		elif [ "$nvmrc_node_version" != "$node_version" ]; then
			nvm use
		fi
	elif command -v nvm 2>&1 1>/dev/null && [ "$(nvm version)" != "$(nvm version default)" ]; then
		echo "Reverting to nvm default version"
		nvm use default
	fi
}

add-zsh-hook chpwd __hook_load_nvmrc

__hook_load_nvmrc

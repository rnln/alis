# autoload -Uz colors zsh/terminfo
autoload -Uz colors
colors

eval "$(starship init zsh)"
export PS2=$'%F{8}%_ ❯%f ' # secondary prompt, printed when the shell needs more information to complete a command
export PS3=$'$F{8}select ❯%f ' # selection prompt used within a select loop
export PS4=$'%F{8}%N:%i:%_ ❯%f ' # the execution trace prompt (setopt xtrace)

# https://zsh.sourceforge.io/Doc/Release/Zsh-Line-Editor.html#Character-Highlighting
zle_highlight=(
	default:none
	isearch:bg=magenta
	region:bg=60
	special:fg=8
	suffix:fg=8
	paste:none
)

# zmodload zsh/complist
# ZLS_COLORS="$LS_COLORS"
autoload -Uz compinit
[ ! -d "$ZCOMPDIR" ] && mkdir -p "$ZCOMPDIR"
compinit -d "$ZCOMPDIR"/zcompdump # -$ZSH_VERSION
zstyle ':compinstall' filename "$ZDOTDIR"/prompt.zsh

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME"/zsh/zcompcache

zstyle ':completion:*' menu select
zstyle ':completion:*' verbose yes
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' group-name ''
zstyle ':completion:*' group-order files local-directories path-directories alias commands builtins functions
zstyle ':completion:*' list-dirs-first true
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' completer _complete _prefix _approximate # https://zsh.sourceforge.io/Doc/Release/Completion-System.html#Control-Functions
zstyle ':completion:*' matcher-list '+m:{a-zA-Z}={A-Za-z}' '+r:|[-_./]=* r:|=*'
zstyle ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/5))numeric)' # allow one error per 5 character typed
zstyle ':completion:*:corrections' format "%B%F{8} %d (errors: %e)%f%b"
zstyle ':completion:*:descriptions' format $'%F{8} %{%d%}%f'
zstyle ':completion:*:messages' format "%B%F{8}%d%f%b"
zstyle ':completion:*:warnings' format "%F{red}No matches for:%f %d"

zstyle ':completion:*:processes' menu interactive
zstyle ':completion:*:processes' command 'ps -axw'
zstyle ':completion:*:processes-names' menu interactive
zstyle ':completion:*:processes-names' command 'ps -awxho command'
zstyle ':completion:*:*:kill:*:processes' list-colors ' #([0-9]#)*=33'

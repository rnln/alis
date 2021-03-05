# Z shell options
# http://zsh.sourceforge.net/Doc/Release/Options.html
setopt   AUTO_CD
setopt   AUTO_PUSHD
unsetopt BEEP
setopt   COMPLETE_IN_WORD
setopt   EXTENDED_GLOB
unsetopt GLOB_DOTS
setopt   HIST_FIND_NO_DUPS
setopt   HIST_IGNORE_SPACE
setopt   LONG_LIST_JOBS
setopt   NOMATCH
unsetopt NOTIFY
setopt   PUSHD_IGNORE_DUPS
setopt   PUSHD_SILENT
setopt   RM_STAR_SILENT
unsetopt SH_WORD_SPLIT
setopt   UNSET
unsetopt CASE_GLOB

# XDG Base Directory specification
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME/.config"}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-"$HOME/.cache"}
export XDG_DATA_HOME=${XDG_DATA_HOME:-"$HOME/.local/share"}

export PATH="$PATH:$HOME/.local/bin"

export HISTFILE="$XDG_DATA_HOME/zsh/history"
export HISTSIZE=100000
export SAVEHIST=100000

export PAGER=less
export LESS='-ciJMR +Gg'
export LESSHISTFILE="$XDG_CACHE_HOME/lesshist"
# terminfo capabilities to stylize man pages
export LESS_TERMCAP_md=$(tput setaf 2; tput bold) # start bold (green)
export LESS_TERMCAP_me=$(tput sgr0)               # end all attributes
export LESS_TERMCAP_so=$(tput setaf 4; tput smso) # start standout-mode (blue background)
export LESS_TERMCAP_se=$(tput sgr0)               # end standout-mode
export LESS_TERMCAP_us=$(tput setaf 4; tput smul) # start underline (blue)
export LESS_TERMCAP_ue=$(tput sgr0)               # end underline

export EDITOR=vim
export VIMINIT='source "$XDG_CONFIG_HOME/vim/vimrc"'

export GNUPGHOME="$XDG_CONFIG_HOME/gnupg"

export VSCODE_PORTABLE="$XDG_DATA_HOME/vscode-oss"

source "$ZDOTDIR/keybindings.sh"
source "$ZDOTDIR/aliases.sh"

if [ -d "$HOME/filanco" ]; then
    export FILANCO_HOME="$HOME/filanco"
    source "$FILANCO_HOME/scripts/configs/.zshrc"
fi

export PS2='\`%_> '      # secondary prompt, printed when the shell needs more information to complete a command
export PS3='?# '         # selection prompt used within a select loop
export PS4='+%N:%i:%_> ' # the execution trace prompt (setopt xtrace), default is '+%N:%i>'
export STARSHIP_CACHE="$XDG_CACHE_HOME/starship"
eval "$(starship init zsh)"

zstyle :compinstall filename "$ZDOTDIR/.zshrc"
autoload -Uz compinit
[ ! -d "$XDG_CACHE_HOME/zsh" ] && mkdir -p "$XDG_CACHE_HOME/zsh"
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"

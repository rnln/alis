source "$ZDOTDIR"/options.zsh

if [[ "$OSTYPE" == 'darwin'* ]]; then export __MACOS_GNU_PREFIX=g; fi

set -a
source "$ZDOTDIR"/paths.zsh
set +a

[ ! -d "$HISTFILE" ] && mkdir -p "`dirname "$HISTFILE"`"
export HISTSIZE=100000
export SAVEHIST=100000

eval "$(${__MACOS_GNU_PREFIX}dircolors --sh "$ZDOTDIR"/.dircolors)"

export EDITOR=nvim
export PAGER=less
export LESS='-ciJMR +Gg'
# terminfo capabilities to stylize man pages
export LESS_TERMCAP_md=$(tput setaf 2; tput bold) # start bold (green)
export LESS_TERMCAP_so=$(tput setaf 4; tput smso) # start standout-mode (blue background)
export LESS_TERMCAP_us=$(tput setaf 4; tput bold) # start underline (blue w/o underline)
export LESS_TERMCAP_me=$(tput sgr0)               # end all attributes
export LESS_TERMCAP_se=$(tput sgr0)               # end standout-mode
export LESS_TERMCAP_ue=$(tput sgr0)               # end underline

source "$ZDOTDIR"/keybindings.zsh
source "$ZDOTDIR"/aliases.zsh

autoload -Uz add-zsh-hook
for hook in "$ZDOTDIR"/hooks/*; do source "$hook"; done

source "$ZDOTDIR"/prompt.zsh

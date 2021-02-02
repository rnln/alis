export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export GNUPGHOME="$XDG_CONFIG_HOME/gnupg"

PATH="$PATH:$HOME/.local/bin"
export PATH

export HISTFILE="$XDG_CACHE_HOME/.zsh_history"
export HISTSIZE=100000
export SAVEHIST=100000

export EDITOR=vim
export VIMINIT="source $XDG_CONFIG_HOME/vim/vimrc"

export PAGER=less
export LESS='-ciJMR +Gg'
export LESSHISTFILE="$XDG_CACHE_HOME/.lesshist"
# terminfo capabilities to stylize man pages
export LESS_TERMCAP_md=$(tput setaf 2) # start bold
export LESS_TERMCAP_me=$(tput sgr0) # end blink and bold
export LESS_TERMCAP_so=$(tput setaf 7; tput setab 4) # start standout-mode
export LESS_TERMCAP_se=$(tput sgr0) # end standout-mode
export LESS_TERMCAP_us=$(tput setaf 4) # start underline
export LESS_TERMCAP_ue=$(tput sgr0) # end underline

setopt autocd          # if a command is issued that can't be executed as a normal command, and the command is the name of a directory, perform the cd command to that directory
setopt autopushd       # make cd push the old directory onto the directory stack
setopt pushdignoredups # don't push the same dir twice
setopt pushdsilent     # do not print the directory stack after pushd or popd
setopt completeinword  # not just at the end
setopt extendedglob    # treat the "#", "~" and "^" characters as part of patterns (an initial unquoted "~" always produces named directory expansion)
setopt histfindnodups  # when searching for history entries in the line editor, do not display duplicates of a line previously found, even if the duplicates are not contiguous
setopt histignorespace # remove command lines from the history list when the first character on the line is a space
setopt longlistjobs    # display PID when suspending processes as well
setopt nobeep          # avoid "beep"ing
setopt noglobdots      # "*" shouldn't match dotfiles
setopt nomatch         # error out when no match
setopt nonotify        # don't report the status of backgrounds jobs immediately
setopt noshwordsplit   # use zsh style word splitting
setopt unset           # don't error out when unset parameters are used

source "$ZDOTDIR/keybindings.sh"

source "$ZDOTDIR/aliases.sh"

zstyle :compinstall filename "$ZDOTDIR/.zshrc"
autoload -Uz compinit
compinit

export PS2='\`%_> '      # secondary prompt, printed when the shell needs more information to complete a command
export PS3='?# '         # selection prompt used within a select loop
export PS4='+%N:%i:%_> ' # the execution trace prompt (setopt xtrace), default is '+%N:%i>'
export STARSHIP_CACHE="$XDG_CACHE_HOME/starship"
eval "$(starship init zsh)"

PATH="$PATH:$HOME/.local/bin"
export PATH

# XDG Base Directory specification
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME/.config"}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-"$HOME/.cache"}
export XDG_DATA_HOME=${XDG_DATA_HOME:-"$HOME/.local/share"}

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

setopt autocd          # if a command is issued that can't be executed as a normal command, and the command is the name of a directory, perform the cd command to that directory
setopt autopushd       # make cd push the old directory onto the directory stack
setopt completeinword  # not just at the end
setopt extendedglob    # treat the "#", "~" and "^" characters as part of patterns (an initial unquoted "~" always produces named directory expansion)
setopt histfindnodups  # when searching for history entries in the line editor, don't display duplicates of a line previously found, even if the duplicates aren't contiguous
setopt histignorespace # remove command lines from the history list when the first character on the line is a space
setopt longlistjobs    # display PID when suspending processes as well
setopt nobeep          # avoid "beep"ing
setopt noglobdots      # "*" shouldn't match dotfiles
setopt nomatch         # error out when no match
setopt nonotify        # don't report the status of backgrounds jobs immediately
setopt noshwordsplit   # use zsh style word splitting
setopt pushdignoredups # don't push the same dir twice
setopt pushdsilent     # don't print the directory stack after pushd or popd
setopt unset           # don't error out when unset parameters are used

export GNUPGHOME="$XDG_CONFIG_HOME/gnupg"

export VSCODE_PORTABLE="$XDG_DATA_HOME/vscode"

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

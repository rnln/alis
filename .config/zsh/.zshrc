# Z shell options
# http://zsh.sourceforge.net/Doc/Release/Options.html
# set +o alias_func_def # allow the definition of functions using the 'name ()' syntax if name was expanded as an alias
# set -o aliases # expand aliases
# set +o all_export # all parameters subsequently defined are automatically exported
# set -o always_last_prompt # key functions that list completions try to return to the last prompt if given no numeric argument
# set +o always_to_end
# set +o append_create
# set -o append_history
set -o auto_cd
# set +o auto_continue
# set -o auto_list
# set -o auto_menu
# set +o auto_name_dirs
# set -o auto_param_keys
# set -o auto_param_slash
set -o auto_pushd
# set -o auto_remove_slash
# set +o auto_resume
# set -o bad_pattern
# set -o bang_hist
# set -o bare_glob_qual
# set +o bash_auto_list
# set +o bash_rematch
set +o beep
# set -o bg_nice
# set +o brace_ccl
# set +o bsd_echo
# set +o c_bases
# set +o c_precedences
set +o case_glob
# set -o case_match
# set +o cd_silent
# set +o cdable_vars
# set +o chase_dots
# set +o chase_links
# set -o check_jobs
# set -o check_running_jobs
# set -o clobber
# set +o combining_chars
# set +o complete_aliases
set -o complete_in_word
# set +o continue_on_error
# set +o correct
# set +o correct_all
# set +o csh_junkie_history
# set +o csh_junkie_loops
# set +o csh_junkie_quotes
# set +o csh_null_glob
# set +o csh_nullcmd
# set -o debug_before_cmd

# set -o equals # Perform = filename expansion. http://zsh.sourceforge.net/Doc/Release/Expansion.html#Filename-Expansion
# set +o sh_file_expansion # Perform filename expansion (e.g., ~ expansion) before parameter expansion, command substitution, arithmetic expansion and brace expansion. If this option is unset, it is performed after brace expansion, so things like ‘~$USERNAME’ and ‘~{pfalstad,rc}’ will work.

# set -o glob # Perform filename generation (globbing). http://zsh.sourceforge.net/Doc/Release/Expansion.html#Filename-Generation
# set +o glob_assign # If this option is set, filename generation (globbing) is performed on the right hand side of scalar parameter assignments of the form ‘name=pattern (e.g. ‘foo=*’). If the result has more than one word the parameter will become an array with those words as arguments. This option is provided for backwards compatibility only: globbing is always performed on the right hand side of array assignments of the form ‘name=(value)’ (e.g. ‘foo=(*)’) and this form is recommended for clarity; with this option set, it is not possible to predict whether the result will be an array or a scalar.
# set +o glob_complete # When the current word has a glob pattern, do not insert all the words resulting from the expansion but generate matches as for completion and cycle through them like MENU_COMPLETE. The matches are generated as if a ‘*’ was added to the end of the word, or inserted at the cursor when COMPLETE_IN_WORD is set. This actually uses pattern matching, not globbing, so it works not only for files but for any completion, such as options, user names, etc. Note that when the pattern matcher is used, matching control (for example, case-insensitive or anchored matching) cannot be used. This limitation only applies when the current word contains a pattern; simply turning on the GLOB_COMPLETE option does not have this effect.
# set +o glob_dots # Do not require a leading ‘.’ in a filename to be matched explicitly.
# set +o glob_star_short # When this option is set and the default zsh-style globbing is in effect, the pattern ‘**/*’ can be abbreviated to ‘**’ and the pattern ‘***/*’ can be abbreviated to ***. Hence ‘**.c’ finds a file ending in .c in any subdirectory, and ‘***.c’ does the same while also following symbolic links. A / immediately after the ‘**’ or ‘***’ forces the pattern to be treated as the unabbreviated form. 
# set +o glob_subst # Treat any characters resulting from parameter expansion as being eligible for filename expansion and filename generation, and any characters resulting from command substitution as being eligible for filename generation. Braces (and commas in between) do not become eligible for expansion.

# set +o err_exit
# set +o err_return
# set -o eval_lineno
# set -o exec
set -o extended_glob
# set +o extended_history
# set -o flow_control
# set +o force_float
# set -o function_argzero
# set -o global_export
# set -o global_rcs
# set -o hash_cmds
# set -o hash_dirs
# set +o hash_executables_only
# set -o hash_list_all
# set +o hist_allow_clobber
# set -o hist_beep
# set +o hist_expire_dups_first
# set +o hist_fcntl_lock
set -o hist_find_no_dups
# set +o hist_ignore_all_dups
# set +o hist_ignore_dups
set -o hist_ignore_space
# set +o hist_lex_words
# set +o hist_no_functions
# set +o hist_no_store
# set +o hist_reduce_blanks
# set -o hist_save_by_copy
# set +o hist_save_no_dups
# set +o hist_subst_pattern
# set +o hist_verify
# set -o hup
# set +o ignore_braces
# set +o ignore_close_braces
# set +o ignore_eof
# set +o inc_append_history
# set +o inc_append_history_time
# set +o interactive_comments
# set +o ksh_arrays
# set +o ksh_autoload
# set +o ksh_glob
# set +o ksh_option_print
# set +o ksh_typeset
# set +o ksh_zero_subscript
# set -o list_ambiguous
# set -o list_beep
# set +o list_packed
# set +o list_rows_first
# set -o list_types
# set +o local_loops
# set -o local_options
# set -o local_patterns
# set -o local_traps
set -o long_list_jobs
# set +o magic_equal_subst
# set +o mail_warning
# set +o mark_dirs
# set +o menu_complete
# set -o multi_func_def
# set -o multibyte
# set -o multios
# set -o nomatch # =
set +o notify
# set +o null_glob
# set +o numeric_glob_sort
# set +o octal_zeroes
# set +o overstrike
# set +o path_dirs
# set +o path_script
# set +o pipe_fail
# set +o posix_aliases
# set +o posix_argzero
# set +o posix_builtins
# set +o posix_cd
# set +o posix_identifiers
# set +o posix_jobs
# set +o posix_strings
# set +o posix_traps
# set +o print_eight_bit
# set +o print_exit_value
# set +o prompt_bang
# set -o prompt_cr
# set -o prompt_percent
# set -o prompt_sp
# set +o prompt_subst
set -o pushd_ignore_dups
# set +o pushd_minus
set -o pushd_silent
# set +o pushd_to_home
# set +o rc_expand_param
# set +o rc_quotes
# set -o rcs
# set +o rec_exact
# set +o rematch_pcre
set -o rm_star_silent
# set +o rm_star_wait
# set +o sh_glob
# set +o sh_nullcmd
# set +o sh_option_letters
# set +o sh_word_split # =
# set +o share_history
# set -o short_loops
# set +o single_line_zle
# set +o source_trace
# set +o sun_keyboard_hack
# set +o transient_rprompt
# set +o traps_async
# set +o typeset_silent
# set -o unset # =
# set +o verbose
# set +o warn_create_global
# set +o warn_nested_var

# XDG Base Directory specification
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME"/.config}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-"$HOME"/.cache}
export XDG_DATA_HOME=${XDG_DATA_HOME:-"$HOME"/.local/share}

typeset -U path
path=("$HOME"/.local/bin $path[@])

export HISTFILE="$XDG_DATA_HOME"/zsh/history
export HISTSIZE=100000
export SAVEHIST=100000

eval "$(dircolors --sh "$ZDOTDIR"/.dircolors)"

export EDITOR=nvim
export PAGER=less
export LESS='-ciJMR +Gg'
export LESSHISTFILE="$XDG_CACHE_HOME"/lesshist
# terminfo capabilities to stylize man pages
export LESS_TERMCAP_md=$(tput setaf 2; tput bold) # start bold (green)
export LESS_TERMCAP_me=$(tput sgr0)               # end all attributes
export LESS_TERMCAP_so=$(tput setaf 4; tput smso) # start standout-mode (blue background)
export LESS_TERMCAP_se=$(tput sgr0)               # end standout-mode
export LESS_TERMCAP_us=$(tput setaf 4; tput smul) # start underline (blue)
export LESS_TERMCAP_ue=$(tput sgr0)               # end underline

export GNUPGHOME="$XDG_CONFIG_HOME"/gnupg

export VSCODE_PORTABLE="$XDG_DATA_HOME"/vscode-oss

export CARGO_HOME="$XDG_DATA_HOME"/cargo
# export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
path=("$CARGO_HOME"/bin $path[@])

export GOPATH="$XDG_DATA_HOME"/go
path=("$GOPATH"/bin $path[@])

export PYLINTHOME="$XDG_CACHE_HOME"/pylint

source "$ZDOTDIR"/keybindings.sh
source "$ZDOTDIR"/aliases.sh

if [ -d "$HOME"/filanco ]; then
    export FILANCO_HOME="$HOME"/filanco
    source "$FILANCO_HOME"/scripts/configs/.zshrc
fi

autoload -Uz colors zsh/terminfo
colors

export PS2=$'\e[2;34m%_\e[0;34m ❯ \e[0m' # secondary prompt, printed when the shell needs more information to complete a command
export PS3=$'\e[2;35mselect\e[0;35m ❯ \e[0m' # selection prompt used within a select loop
export PS4=$'\e[0;36m%N\e[2;36m:%i:%_\e[0;36m ❯ \e[0m' # the execution trace prompt (setopt xtrace)
export STARSHIP_CACHE="$XDG_CACHE_HOME"/starship
eval "$(starship init zsh)"

source /usr/share/doc/pkgfile/command-not-found.zsh

zle_highlight=(
    default:none
    isearch:standout,fg=3
    paste:standout,fg=3
    region:standout,fg=3
    special:standout,fg=3
    suffix:bold
)

# rustup completions zsh >"$XDG_CACHE_HOME"/zsh/rustup
# fpath+="$XDG_CACHE_HOME"/zsh

zmodload zsh/complist
autoload -Uz compinit
[ ! -d "$XDG_CACHE_HOME/zsh" ] && mkdir -p "$XDG_CACHE_HOME"/zsh
compinit -d "$XDG_CACHE_HOME"/zsh/zcompdump-$ZSH_VERSION

zstyle :compinstall filename "$ZDOTDIR"/.zshrc

zstyle ':completion:*' menu yes select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS} # http://linuxshellaccount.blogspot.com/2008/12/color-completion-using-zsh-modules-on.html
zstyle ':completion:*' verbose yes # http://www.masterzen.fr/2009/04/19/in-love-with-zsh-part-one/
zstyle ':completion:*' group-name ''
zstyle ':completion:*' completer _complete _approximate
zstyle ':completion:*:approximate:*' max-errors 'reply=( $(( ($#PREFIX+$#SUFFIX)/3 )) numeric )' # allow one error per 3 character typed
zstyle ':completion:*:corrections' format "%F{8}%d (errors: %e)$reset_color"
zstyle ':completion:*:descriptions' format "%F{8}%d$reset_color"
zstyle ':completion:*:messages' format "%F{8}%d$reset_color"
zstyle ':completion:*:warnings' format "%F{red}No matches for:$reset_color %d"

zstyle ':completion:*:pacman:*' force-list always
zstyle ':completion:*:*:pacman:*' menu yes select

zstyle ':completion:*:processes' command 'ps -ax'
zstyle ':completion:*:processes-names' command 'ps -e -o comm='

zstyle ':completion:*:kill:*' force-list always
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:kill:*:processes' list-colors ' #([0-9]#)*=31'

zstyle ':completion:*:killall:*' force-list always
zstyle ':completion:*:*:killall:*' menu yes select

autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git hg
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:git*' formats "%{${fg[cyan]}%}[%{${fg[green]}%}%s%{${fg[cyan]}%}][%{${fg[blue]}%}%r/%S%%{${fg[cyan]}%}][%{${fg[blue]}%}%b%{${fg[yellow]}%}%m%u%c%{${fg[cyan]}%}]%{$reset_color%}"

# autoload -Uz promptinit
# promptinit

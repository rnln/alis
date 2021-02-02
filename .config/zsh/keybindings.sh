bindkey -e

bindkey '^[d' copy-prev-shell-word # [Esc-m] copy previous shell word
bindkey -s '^[b' '.bak' # [Esc-b] insert '.bak'
bindkey ' ' magic-space # [Space] - don't do history expansion

# [Ctrl-x-v] Edit the current command line in $EDITOR
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

bindkey '^X^V' vi-cmd-mode # [Ctrl-x-v] Enter vi command mode
bindkey '^[[Z' reverse-menu-complete # [Shift-Tab] - move through the completion menu backwards
bindkey '^r' history-incremental-search-backward # [Ctrl-r] - Search backward incrementally for a specified string
bindkey '^[[5~' up-line-or-history # [PageUp] - Up a line of history
bindkey '^[[6~' down-line-or-history # [PageDown] - Down a line of history

# Start typing + [ArrowUp] - fuzzy find history forward
autoload -U up-line-or-beginning-search
zle -N up-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search

# Start typing + [ArrowDown] - fuzzy find history backward
autoload -U down-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search

bindkey '^[[H' beginning-of-line # [Home] - Go to beginning of line
bindkey '^[[F' end-of-line # [End] - Go to end of line
bindkey '^[[1;5C' forward-word # [Ctrl-ArrowRight] - move forward one word
bindkey '^[[1;5D' backward-word # [Ctrl-ArrowLeft] - move backward one word
bindkey '^?' backward-delete-char # [Backspace] - delete backward
bindkey '^[[3~' delete-char # [Delete] - delete forward
bindkey '^[[3;5~' kill-word # [Ctrl-Delete] - delete whole forward-word
bindkey '^H' backward-kill-word # [Ctrl-Backspace] - delete whole backward-word

export KEYTIMEOUT=1

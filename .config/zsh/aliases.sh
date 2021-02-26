alias please='sudo $(fc -ln -1)'
alias rmf='rm -rf'

# grep
grep_options='--color=auto --exclude-dir={.git,.idea,.vscode,.venv}'
alias grep="grep $grep_options"
alias egrep="egrep $grep_options"
alias fgrep="fgrep $grep_options"

# write a prompt before overwriting an existing file
alias cp='cp -i'
alias mv='mv -i'

alias ls='ls --hyperlink --color'
alias l='LC_COLLATE=C ls --almost-all --classify --group-directories-first --human-readable --time-style="+%F %T" -cl'
alias ...='cd ../../'
alias rmc='cd ..; rmdir $OLDPWD || cd $OLDPWD' # Remove current empty directory

# aliases for the stack of a visited directories
alias d='dirs -v'
for index ({1..9}) alias "$index"="cd +${index}"; unset index

# smart cd: cd to /etc when running 'cd /etc/fstab'
function cd () {
    if (( ${#argv} == 1 )) && [[ -f ${1} ]]; then
        [[ ! -e ${1:h} ]] && return 1
        echo "cd: ${1} was corrected to ${1:h}" >&2
        builtin cd ${1:h}
    else
        builtin cd "$@"
    fi
}

function cl () { cd "$@" && l } # cd to directory and list files

# create directory and cd to it
function mkcd () {
    if (( ARGC != 1 )); then
        echo 'Usage: mkcd <directory>' >&2
        echo 'Create directory and change the working directory to it.' >&2
        return 1;
    fi
    if [[ ! -d "$1" ]]; then
        command mkdir -p "$1"
    else
        echo "mkcd: '$1' already exists, changing the working directory to it" >&2
    fi
    builtin cd "$1"
}

# list files which have been accessed, changed and modified within the last {\it n} days, {\it n} defaults to 1
function accessed () { emulate -L zsh; print -l -- *(a-${1:-1}) }
function changed  () { emulate -L zsh; print -l -- *(c-${1:-1}) }
function modified () { emulate -L zsh; print -l -- *(m-${1:-1}) }

function pss () {
    emulate -L zsh
    unsetopt KSH_ARRAYS
    if [[ -z "$1" ]] ; then
        echo 'Usage: pss <keyword>' >&2
        echo 'Search for running processes by keyword.' >&2
        return 1
    else
        local ps_snapshot="$(ps xauwww)"
        echo $ps_snapshot | head -1
        echo $ps_snapshot | tail +2 | grep -i "[${1[1]}]${1[2,-1]}" --color=always | GREP_COLORS='mt=1;34' grep -P '^\S+\s+\K\S+'
    fi
}

# systemd journal logs
alias log='journalctl'
alias logf='journalctl -f'

# human-readable directories size
function ds () {
    if (( ARGC > 1 )); then
        du -sch "$@"
    else
        du -sch | head -1
    fi
}

ssh_options="-F $XDG_CONFIG_HOME/ssh/config"
alias ssh-sec="command ssh $ssh_options"
alias scp-sec="command scp $ssh_options"
ssh_options='-o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null"'
alias ssh="ssh-sec $ssh_options"
alias scp="scp-sec $ssh_options"

function ex () {
    local return_code=0
    if [[ -z "$1" ]] ; then
        echo 'Usage: ex <archive> ...' >&2
        echo 'Extract archives in these formats: tar, bz2, gz, xz, zst, 7z, deb, jar, lha, lzh, lzma, rar, Z and zip.' >&2
        return_code=1
    else
        for entry in "$@"; do
            if [ -f "$entry" ]; then
                case "$entry" in
                    *.(tar.bz2|tbz2|tbz))
                        tar --one-top-level xjf "$entry" ;;
                    *.(tar.gz|tgz))
                        tar --one-top-level xzf "$entry" ;;
                    *.(tar.xz|txz|tar.lzma))
                        tar --one-top-level xJf "$entry" ;;
                    *.tar.zst)
                        tar --one-top-level --zstd xvf "$entry" ;;
                    *.tar)
                        tar --one-top-level xvf "$entry" ;;
                    *.bz2)
                        bzip2 -d -k "$entry" ;;
                    *.(gz|Z))
                        gzip -d -k "$entry" ;;
                    *.(xz|lzma))
                        xz -d -k "$entry" ;;
                    *.zst)
                        zstd -d -k "$entry" ;;
                    *.(rar|lzh|lha|7z))
                        7z x -o "${entry%.*}" "$entry" ;;
                    *.(zip|jar))
                        unzip -d "${entry%.*}" "$entry" ;;
                    *.deb)
                        mkdir "${entry%.*}"
                        ar x --output "${entry%.*}" "$entry" ;;
                    *)
                        echo "$0: cannot extract '$entry': is not a supported file extension" >&2
                        return_code=1
                esac
            else
                echo "$0: cannot extract '$entry': is not a file" >&2
                return_code=1
            fi
        done
    fi
    return $return_code
}

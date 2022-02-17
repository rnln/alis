__HOOK_DONE_ALERT_TRASHOLD=300
__HOOK_DONE_ALERT_IGNORE_LIST=(
	vim
	nvim
	ssh
)
__hook_done_alert_timestamp=0

__hook_done_alert_notify() {
	format_time() {
		local T=$1
		local D=$((T/60/60/24))
		local H=$((T/60/60%24))
		local M=$((T/60%60))
		local S=$((T%60))
		(( $D > 0 )) && printf '%dd ' $D
		(( $H > 0 )) && printf '%dh ' $H
		(( $M > 0 )) && printf '%dm ' $M
		printf '%ds\n' $S
	}
	echo -ne "\033]9;done in $(format_time $1)\033\\"
}

__hook_done_alert_pre() {
	__hook_done_alert_last_cmd=$1
	__hook_done_alert_timestamp=$EPOCHSECONDS
}

__hook_done_alert_post() {
	local duration=$(($EPOCHSECONDS - $__hook_done_alert_timestamp))
	local overhead=$(($duration - $__HOOK_DONE_ALERT_TRASHOLD))
	local cmd_head=$(echo $__hook_done_alert_last_cmd | awk '{printf $1}')
	if [[ $overhead -gt 0 && ! -z $__hook_done_alert_last_cmd && ! ${__HOOK_DONE_ALERT_IGNORE_LIST[*]} =~ $(echo "\<$cmd_head\>") ]]; then
		__hook_done_alert_notify $duration
	fi
	__hook_done_alert_last_cmd=''
}

add-zsh-hook preexec __hook_done_alert_pre
add-zsh-hook precmd __hook_done_alert_post

#!/bin/bash

function main(){
    # Special actions
    case "$1" in
    -k)
        emacsclient -c -e '(save-buffers-kill-emacs)'
        exit 0
        ;;
    -kk)
        ssh -t apt-imac 'ec -t'
        ssh -t mini 'ec -t'
        exit 0
        ;;
    -K)
        kill_emacs_by_pid
        exit 0
        ;;
    -s)
        emacs --daemon
        exit 0
        ;;
    -r)
        emacsclient -e '(kill-emacs)'
        emacs --daemon
        exit 0
        ;;
    -rs)
        emacsclient -e '(kill-emacs)'
        emacs --daemon
        shift
        ;;
        -t)
            emacsclient -t $@
            exit $?
            ;;
    -K)
        kill_emacs_by_pid
        exit 0
        ;;
    esac

    if [[ "$SSH_CLIENT" != "" ]] ; then
        echo "SSH_CLIENT != '', executing ec -t \"\$@\""
        emacsclient -t "$@"
        return
    fi

    ensure-server-is-running
    ensure-frame-exists

    if [[ "$@" != "" ]] ; then
        emacsclient --no-wait $@
    fi

    focus-current-frame
}

# From https://superuser.com/a/862809
function frame-exists() {
    emacsclient -n -e "(if (> (length (frame-list)) 1) 't)" 2>/dev/null | grep -v nil >/dev/null 2>&1
}

function ensure-frame-exists() {
    if ! frame-exists ; then
	emacsclient -c --no-wait
	# emacsclient --no-wait -e '
	#     (when (window-system)
	# 	(set-frame-position (selected-frame) 150 30))'
    fi
}

# From https://emacs.stackexchange.com/a/54139/19972
function focus-current-frame() {
    emacsclient --eval "(progn (select-frame-set-input-focus (selected-frame)))"
}

# From https://emacs.stackexchange.com/a/12896/19972
function server-is-running() {
    emacsclient -e '(+ 1 0)' > /dev/null 2>&1
}

function ensure-server-is-running(){
    if ! server-is-running ; then
	echo "Need to start daemon, press enter to continue, C-c to abort"
	read
	emacs --daemon
    fi
}

function kill_emacs_by_pid(){
    if [[ $(uname) == Darwin ]] ; then
        emacs_process=$(ps -aupcarphin| grep Emacs.app | grep -v grep)
    else
        emacs_process=$(ps -aux | grep 'emacs --daemon' | grep -v grep)
    fi
    emacs_pid=$(awk '{print $2;}' <<< $emacs_process)

    if [[ -z $emacs_process ]] ; then
        echo "No emacs process found"
        return 1
    fi

    echo "emacs_process: $(awk '{print $2 " " $5;}' <<< $emacs_process)"
    echo -n "Kill this process? (y/n): "; read answer

    if [[ -z $answer ]] ; then
        return
    fi

    if [[ -z $answer ]] || ! ([[ $answer == y ]] || [[ $answer == Y ]]) ; then
        return
    fi

    echo kill $emacs_pid
    kill $emacs_pid
}

main $@

#!/bin/bash

function main(){
    # Special actions
    case "$1" in
	-k)
	    emacsclient -c -e '(save-buffers-kill-emacs)'
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
	-h) home=$2
            shift
	    shift
            HOME=$home emacs $@
            exit $?
    esac

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

main $@

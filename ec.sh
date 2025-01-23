#!/bin/bash
set -x

# Yet again, a per-process TMPDIR that contains the PID of the current shell
# causes a problem.  Lets define this then.
export TMPDIR=/tmp/$USER
unset XDG_RUNTIME_DIR
mkdir -p $TMPDIR
readlink -f $(which emacsclient)
function main(){

    # Special actions
    case "$1" in
	-k) emacsclient -t -c -e '(save-buffers-kill-emacs)' ;;
	-K) kill_emacs_by_pid ;;
	-s) emacs --daemon ;;
	-g)  gui_open "$@" ;;
	-t) : -t ; emacsclient "$@" ;;
	*)  : no -t ; emacsclient -t "$@" ;;
    esac
}

function gui_open(){
    ensure-server-is-running
    ensure-frame-exists
    if [[ "$@" != "" ]] ; then
	emacsclient --no-wait "$@"
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

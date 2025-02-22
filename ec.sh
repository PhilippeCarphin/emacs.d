#!/bin/bash
# set -x

# Yet again, a per-process TMPDIR that contains the PID of the current shell
# causes a problem.  Lets define this then.
if [[ $(uname) != Darwin ]] ; then
    export TMPDIR=/tmp/$USER
    unset XDG_RUNTIME_DIR
    mkdir -p $TMPDIR
fi
if [[ -n ${INSIDE_EMACS} ]] ; then
    exec emacsclient --no-wait "$@"
fi
function main(){

    # Special actions
    case "$1" in
	-k) emacsclient -t -c -e '(save-buffers-kill-emacs)' ;;
	-K) kill_emacs_by_pid ;;
	-s) emacs --daemon ;;
	-g) shift ; gui_open "$@" ;;
	-t) shift ; _emacsclient_t "$@" ;;
	-x) shift ; exec emacsclient "$@" ;;
	-y) shift ; _open_in_current_frame "$@" ;;
	-i) shift
	    readlink -f $(which emacsclient)
	    readlink -f $(which emacs)
	    ;;
    -f) shift ; _find_emacs_daemons ;;
	*)  : no -t ; _emacsclient_t "$@" ;;
    esac
    printf "\033]12;grey\a"
}

_find_emacs_daemons(){
    local j h cmd
    source ~/.philconfig/shell_lib/functions.sh
    python3 -c "
import yaml
import os
with(open(os.path.expanduser('~/.config/tmux-finder.yml'))) as f:
    y = yaml.safe_load(f)
print('\n'.join(y['hosts-to-check']))" \
    | while read jh ; do
        printf "\033[1;37m==> Doing host $jh\033[0m\n"
        local -a cmd=(ssh)
        if [[ $jh == *:* ]] ; then
            j=${jh%%:*}
            h=${jh##*:}
            cmd+=(-J $j)
        else
            h=$jh
        fi
        # pgrep -u $USER 'emacs' -P 1
        # would find only daemons (parent PID of 1) but I actually want to know
        # if I have any non-daemon processes running like clients and straight
        # non-server emacs command
        cmd+=($h "pgrep -u $USER emacs | xargs --no-run-if-empty ps -f")
        printf "\033[1;32m==>\033[0m ${cmd[*]}\n"
        # Make sure the SSH command does not consume STDIN which is supposed
        # to be consumed by the read.
        </dev/null "${cmd[@]}"
    done
}

_open_in_current_frame(){
    ensure-server-is-running
    ensure-frame-exists
    for f in "$@"; do
        emacsclient --eval "(find-file \"$f\")" >/dev/null
    done
}

_emacsclient_t(){
    if ! [[ -S "$TMPDIR/emacs$(id -u)/server" ]] ; then
        exec $HOME/fs1/bin/vim -p "$@"
    fi
    emacsclient -t "$@"
}


function open-in-any-frame(){
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
function gui_open(){
    # Requires user-defined Elisp function 'open-in-gui-frame'
    # see config.org
    local elisp_code="(let ((default-directory \"$PWD\"))
                         (open-in-gui-frame \"$1\"))"
    emacsclient --eval "${elisp_code}"
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

main "$@"

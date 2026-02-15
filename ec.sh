#!/usr/bin/env bash
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
debug=""
function main(){
    local status

    # Special actions
    while (($#)) ; do
        case "$1" in
        -d) debug="--debug-init" ;;
        -k) emacsclient -t -c -e '(save-buffers-kill-emacs)' ;;
        -p) emacsclient -e "(setenv \"PATH\" \"${PATH}\")" ; status=0 ; break ;;
        -l) : lisp mode ; shift ; emacsclient "$@" ; status=$? ; break ;;
        -K) kill_emacs_by_pid ; status=$? ; break ;;
        -s) emacs --daemon ${debug} ; status=$? ; break ;;
        -g) shift ; gui_open "$@" ; status=$? ; break ;;
        -t) shift ; _emacsclient_t "$@" ; status=$? ; break ;;
        -x) shift ; exec emacsclient "$@" ; status=$? ; break ;;
        -y) shift ; _open_in_current_frame "$@" ; status=$? ; break ;;
        -i) shift
            readlink -f $(which emacsclient)
            readlink -f $(which emacs)
            ;;
        -f) shift ; _find_emacs_daemons ; status=$? ; break ;;
        *)  : no -t ; _emacsclient_t "$@" ; status=$? ; break ;;
        esac
        shift
    done
    printf "\033]112\a"
    printf "\033[2 q"
    return ${status}
}

function kill_emacs_by_pid(){
    if [[ $(uname) == Darwin ]] ; then
        emacs_pid=$(ps -aupcarphin| grep Emacs.app | grep -v grep | awk '{print $2}')
    else
        emacs_pid=$(pgrep -u $USER -f 'emacs --daemon')
    fi

    if [[ -z $emacs_pid ]] ; then
        echo "No emacs process found"
        return 1
    fi

    echo "emacs_process:"
    ps -f ${emacs_pid} | sed 's/^/    /'
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


rearrange_vim_lineno_args_by_ref(){
    # Vim works with `vim FILENAME +LINENO` but emacs works with
    # `emacs +LINENO FILENAME` so a simple thing to do can be to say that if
    # the last argument starts with `+`, then it's a vim type call so we
    # just invert the two last arguments.
    local -n _args=$1
    if (( ${#_args[@]} < 2 )) ; then
        return
    fi

    if [[ ${_args[-1]} == +* ]] ; then
        _args=("${_args[@]:0:$((${#_args[@]}-2))}" "${_args[-1]}" "${_args[-2]}")
    fi
}

_find_emacs_daemons(){
    local j h jh cmd
    source ~/.philconfig/shell_lib/functions.sh
    python3 -c "
import yaml
import os
with(open(os.path.expanduser('~/.config/tmux-finder.yml'))) as f:
    y = yaml.safe_load(f)
print('\n'.join(y['hosts-to-check']))" \
    | while read jh ; do
        printf "\033[1;37m==> Doing host $jh\033[0m\n"
        cmd=(ssh)
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
    local args=("$@")
    rearrange_vim_lineno_args_by_ref args
    emacsclient -t "${args[@]}"
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
    for a in "$@" ; do
        if [[ $a == +* ]] ; then
            elisp_code+="(goto-line ${a#+})"
        fi
    done
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
	emacs --daemon ${debug}
    fi
}

main "$@"

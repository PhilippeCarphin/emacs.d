#!/bin/zsh
# TODO (uncomment if environment not configured in ~/.zshenv)
# source ~/.zshrc

function main(){
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
	emacsclient --no-wait -e '
	    (when (window-system)
		(set-frame-position (selected-frame) 150 30))'
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
         osascript -e '
             set theDialogText to "Emacs daemon was not running do you want to start it?"
             display dialog theDialogText' 2>/dev/null

         if [[ $? != 0 ]] ; then
              echo "Emacs daemon was not running" >&2
              exit 1
         fi

         emacs --daemon
    fi
}

main $@

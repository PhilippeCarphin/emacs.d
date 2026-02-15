#!/bin/zsh

# TODO (uncomment if environment not configured in ~/.zshenv)
# source ~/.zshrc

function main(){
    ensure-server-is-running
    emacsclient -e '
    (let ((frame (make-frame-on-display ":0")))
        (with-selected-frame frame
            (gtd-review-view)
            (select-frame-set-input-focus frame)
            (delete-other-windows)))
    '
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

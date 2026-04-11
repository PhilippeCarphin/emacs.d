#!/usr/bin/env bash

# TODO (uncomment if environment not configured in ~/.zshenv)
# source ~/.zshrc

function main(){
    if [[ $(uname) != Darwin ]] ; then
        export TMPDIR=/tmp/$USER
    else
        export TMPDIR=/tmp/$(id -u)
    fi
    export TERM=xterm-256color
    unset XDG_RUNTIME_DIR
    mkdir -p $TMPDIR
    # The following doesn't run (delete-other-windows) or (non-existing-func)
    #   emacsclient -t -e '(gtd-review-view)(delete-other-windows)'
    #   emacsclient -t -e '(gtd-review-view)(non-existing-func)'
    # which is weird because the the MacOS version does make my agenda
    # appear even though it is not using (progn ...) to make the whole thing
    # be a single sexp.
    #
    # The following is what I settled on initially
    #   emacsclient -t -e '(progn (gtd-review-view)(delete-other-windows))'
    # but I found something way better at
    # https://tomasfarias.dev/articles/org-capture-and-org-agenda-shell-commands/
    emacsclient -c -e '(tomas/org-agenda-frame "c")' -F '((name . "**tomas-agenda**"))'
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
    fi
}

main $@

#!/bin/bash

################################ NOTE #########################################
# This is meant to be the shell script of a mac automator app.
# The app ends up being 19 mb so I'm not checking it in with git.
# To make it, launch automator, select Application (self running workflow).
# In the bar with lots of options, chose shell script
# In paste this as the text of the shell script
# In the top right, select "Pass input as arguments"
# Save this.  Put it in your applications floder
# Right click the app, do show-pacakge-contents
# Make sure there is no icon or icon? file.
# Right click the app, do get info
# Right click the emacs app, do get info
# In the emacs info, click on the icon in the top left, do CMD-C
# In the automator app, click on the icon and do CMD-V
# Right click on an orgmode file, do get info
# In the open with, select your automator app (or click other and find it)
# Click on change all
#
# CONGRATULATIONS: You now have full fledged MacOS application that will start
# emacs daemon for you with a prompt and double clicking orgmode files will
# open them in the currently running emacs daemon using emacsclient.
###############################################################################

export PATH=$HOME/.local/bin:$PATH

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

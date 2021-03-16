#!/bin/zsh
###############################################################################
# CREATE A MACOS APP FROM THIS SCRIPT USING AUTOMATOR
###############################################################################
#
# This is meant to be the shell script of a mac automator app.
# The app ends up being 19 mb so I'm not checking it in with git and instead, I
# track this file.
#
# - Launch Automator
#   - File -> New : Application (self running workflow) : Choose
#   - Top left : Search bar : "Run Shell Script" : Double Click
#   - Paste this whole file in the text area.
#   - Pass Input : Select "As Arguments" (for MacOS to open files with this app)
#   - File -> Export : Save in /Applications or ~/Applications
#   - If environment not configured in ~/.zshenv see TODO below
#
# - In Finder where the exported App is (Change the icon of new app)
#   - Right click the app : Get info
#   - Right click the Emacs App : Get info
#   - Click on the emacs icon in the Emacs App Info window, do CMD-C
#   - Click on the icon in the exported app Info window, do CMD-V
#
# - In Finder where an orgmode file is
#   - Right click an orgmode file: Get Info
#   - In section "Open With" : Select other, find exported app and select it
#   - Click on change all to associate new app with all orgmode files
#
#
# CONGRATULATIONS: You now have full fledged MacOS application that will start
# emacs daemon for you with a prompt and double clicking orgmode files will
# open them in the currently running emacs daemon using emacsclient.
###############################################################################

# TODO (if environment not configured in ~/.zshenv)
# The file ~/.zshenv is sourced by zsh when the automator app runs this script.
# If your environment is configured in ~/.zshenv YOU HAVE NOTHING TO DO.
#
# However, if your PATH is set in ~/.zshrc, uncommenting the following line will
# make the app find emacs and make your daemon start in an environment that more
# closely resembles your shell (running shell SRC blocks with babel will look
# the same as in your shell)
#
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

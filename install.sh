#!/bin/bash

echo "$0 : Starting 'emacs --daemon=install'"
echo 'y' | emacs --daemon=install
echo "$0 : Killing install daemon \"emacsclient -s install -e '(kill-emacs)'\""
emacsclient -s install -e '(kill-emacs)'

echo "$0 : Linking ec command:"

if [ -e ~/.local/bin/ec ] ; then
    echo "$0 : ~/.local/bin/ec already exists, not doing anything"
else
    ln -v -s $PWD/ec.sh ~/.local/bin/ec
fi

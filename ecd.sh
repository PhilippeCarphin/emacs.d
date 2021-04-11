#!/bin/bash

emacs_user_directory=$(cd $1 && pwd)
shift

if ! [ -e $emacs_user_directory/init.el ] ; then
    echo "ERROR: No init.el in emacs_user_directory ($1 must be the path of an emacs config dir)"
    exit 1
fi

socket=$(basename $emacs_user_directory)
# Intercept for certain first arguments
case $1 in
    -s)
        emacs --daemon=$socket -q --eval "
          (setq user-emacs-directory
             \"$emacs_user_directory/\")
          " -l $emacs_user_directory/init.el
        exit 0
        ;;
esac

emacsclient -s $socket $@

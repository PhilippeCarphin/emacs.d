function main(){
    if [[ $(uname) != Darwin ]] ; then
        export TMPDIR=/tmp/$USER
        export TERM=xterm-256color
        unset XDG_RUNTIME_DIR
        mkdir -p $TMPDIR
    fi
    # https://tomasfarias.dev/articles/org-capture-and-org-agenda-shell-commands/
    emacsclient -c -e '(tomas/org-capture-frame "i")' -F '((name . "**tomas-capture**"))'
}

main "$@"

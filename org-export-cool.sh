#!/usr/bin/env -S bash -o errexit -o nounset -o errtrace -o pipefail -O inherit_errexit -O nullglob -O extglob

this_dir=$(cd -P $(dirname $0) && pwd)
file_to_export="$1"

if [[ $2 == "retro" ]] ; then
    # Produces a file that looks exactly like the emacs buffer
    lisp_export='
       (progn (outline-show-all)
              (font-lock-flush)
              (font-lock-fontify-buffer)
              (with-current-buffer
                (htmlize-buffer)
                (write-region (point-min)
                              (point-max)
                              "${file_to_export%.org}.html")))'
else
    # Produces something that looks a lot like an export done interactively.
    # org-export-simple.sh does pretty much the same thing though.
    lisp_export='
        (progn (outline-show-all)
               (font-lock-flush)
               (font-lock-fontify-buffer)
               (org-html-export-to-html))'
fi

emacs --batch \
      -l ${this_dir}/org-export-cool.el \
      "${file_to_export}" \
      --eval "${lisp_export}"

#!/usr/bin/env -S bash -o errexit -o nounset -o errtrace -o pipefail -O inherit_errexit -O nullglob -O extglob

# This is the script in my answer on
# https://emacs.stackexchange.com/a/83170/19972
# implementing what org-html-htmlize-output-type says to do as pointed out by
# dlukes
#
# Note that Tobias' answer is really cool too and the expansion by John32ma

file_to_export="$1"
css_file=org-adwaita.css
css_link="<link rel=\"stylesheet\" type=\"text/css\" href=\"${css_file}\"/>"
escaped_css_link="${css_link//\"/\\\"}"

lisp_setup="
(progn (require 'package)
       (package-initialize)
       (require 'htmlize)
       (setq org-html-htmlize-output-type 'css)
       (setq org-html-head-extra \"${escaped_css_link}\"))"

emacs --batch \
      --eval "${lisp_setup}" \
      "${file_to_export}" \
      -f org-html-export-to-html


#!/usr/bin/env bash

file_to_export="$1"
css_file=org-dwaita.css
css_link="<link rel=\"stylesheet\" type=\"text/css\" href=\"${css_file}\"/>"
escaped_css_link="${css_link//\"/\\\"}"

lisp_setup="
(progn (require 'package)
        (package-initialize)
        (require 'htmlize)
        (setq org-html-htmlize-output-type 'css)
        (setq org-html-head-extra \"${escaped_css_link}\"))"

# lisp_setup2=$(cat <<-EOF
# (progn (require 'package)
#         (package-initialize)
#         (require 'htmlize)
#         (setq org-html-htmlize-output-type 'css)
#         (setq org-html-head-extra
#               "<link rel=\"stylesheet\" type=\"text/css\" href=\"${css_file}\"/>"))
# EOF
# )

printf "lisp_setup = '%s'\n" "${lisp_setup2}"

# emacs --batch --eval "${lisp_setup2}" "${file_to_export}" -f org-html-export-to-html

file_to_export="$1"
css_file=org-adwaita.css

set -x
emacs --batch \
      --eval "(load-file \"prepare-export.el\")" \
      --eval "(prepare-export \"${css_file}\")" \
      "${file_to_export}" \
      -f org-html-export-to-html


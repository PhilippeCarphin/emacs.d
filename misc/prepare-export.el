(defun prepare-export (css-file)
  (require 'package)
  (package-initialize)
  (require 'htmlize)
  (setq org-html-htmlize-output-type 'css)
  (setq org-html-head-extra
        (format "<link rel=\"stylesheet\" type=\"text/css\" href=\"%s\"/>"
                css-file)))

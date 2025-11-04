(add-to-list 'load-path (car (file-expand-wildcards (concat (getenv "HOME") "/.emacs.d/elpa/evil-2*/"))))
(require 'evil)
(evil-mode)
(load-theme 'leuven)
(require 'ansi-color)
(defun my-ansi ()
  "Resolve all SGR type ANSI codes to color and face information and delete all
  other ANSI codes.  This modifies the buffer so closing it will prompt with 'Do
  you want to save?' to which 'No' is probably the answer"
  (interactive)
  (ansi-color-apply-on-region (point-min) (point-max)))

(defun apply-ansi-if-needed ()
  "Hook for the 'find-file-hook.  Calls 'my-ansi' for certain filenames
  - Files containing 'maestro_tid': Listings opend by Maestro in xflow
  - Files ending with .log: Listings from programs
  - Files ending with .out: my convention for output of programs that are not
    logs"
  (interactive)
  (when (and (stringp buffer-file-name)
             (or (string-match-p "maestro_tid" buffer-file-name)
                 (string-match-p ".out$" buffer-file-name)))
    (my-ansi)
    (set-buffer-modified-p nil)
    (read-only-mode)))

(add-hook 'find-file-hook #'apply-ansi-if-needed)

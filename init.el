;;; Custom stuff from Emacs this is there to make Emacs put stuff
;;; before loading config.org

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(custom-set-variables)
(custom-set-faces)


;;; Load the config
(org-babel-load-file (concat user-emacs-directory "config.org"))

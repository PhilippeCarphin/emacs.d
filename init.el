;;; Set up package
(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)
(package-initialize)

;;; Bootstrap use-package
;; Install use-package if it's not already installed.
;; use-package is used to configure the rest of the packages.
(unless (package-installed-p 'use-package)
    (package-refresh-contents)
    (package-install 'use-package))

;; From use-package README
(eval-when-compile (require 'use-package))

;;; Load the config
(org-babel-load-file (concat user-emacs-directory "config.org"))

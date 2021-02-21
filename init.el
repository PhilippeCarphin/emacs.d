;;; FROM https://github.com/danielmai/.emacs.d/blob/master/init.el
;;; Trimmed down to only the stuff that I use
;;; - requiring package
;;; - adding melpa and org
;;; - package initialize
;;; - ensure use-pacakge is installed
;;; - load orgmode true configuration

;;; Set up package
(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)
(package-initialize)

;; Install use-package if it's not already installed.
(unless (package-installed-p 'use-package)
    (package-refresh-contents)
    (package-install 'use-package))
;; From use-package README
(eval-when-compile (require 'use-package))

;;; Load the config
(org-babel-load-file (concat user-emacs-directory "config.org"))

;;; custom-set-variables part
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("bffa9739ce0752a37d9b1eee78fc00ba159748f50dc328af4be661484848e476" default))
 '(package-selected-packages
   '(spacemacs-theme magit htmlize ox-reveal ox-twbs ox-rst org-bullets which-key helm evil use-package)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:height 250)))))

;;; Custom stuff from Emacs this is there to make Emacs put stuff
;;; before loading config.org
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("c8b83e7692e77f3e2e46c08177b673da6e41b307805cd1982da9e2ea2e90e6d7" default))
 '(default-frame-alist '((height . 55) (width . 100) (vertical-scroll-bars)))
 '(indent-tabs-mode nil)
 '(magit-save-repository-buffers 'dontask)
 '(org-babel-python-command "python3")
 '(org-show-context-detail '((occur-tree . ancestors) (default . local)))
 '(org-startup-folded t)
 '(package-selected-packages
   '(doom-themes yasnippet-snippets yaml-mode which-key vterm vimrc-mode use-package undo-tree ssh-config-mode sage-shell-mode paredit ox-twbs ox-rst ox-reveal ox-gfm org-present org-bullets no-littering monokai-pro-theme modus-themes markdown-mode+ magit lorem-ipsum keyfreq htmlize highlight-defined helm go-mode go evil elfeed doom-modeline company command-log-mode cmake-mode aggressive-indent))
 '(safe-local-variable-values
   '((org-todo-keyword-faces
      ("GTD-IN" :foreground "#ff8800" :weight normal :underline t :size small)
      ("GTD-PROJECT" :foreground "#0088ff" :weight bold :underline t)
      ("GTD-ACTION" :foreground "#0088ff" :weight normal :underline nil)
      ("GTD-NEXT-ACTION" :foreground "#0088ff" :weight bold :underline nil)
      ("GTD-WAITING" :foreground "#aaaa00" :weight normal :underline nil)
      ("GTD-REFERENCE" :foreground "#00ff00" :weight normal :underline nil)
      ("GTD-SOMEDAY-MAYBE" :foreground "#7c7c74" :weight normal :underline nil)
      ("GTD-DONE" :foreground "#00ff00" :weight normal :underline nil))))
 '(vc-follow-symlinks nil)
 '(visual-line-fringe-indicators '(left-curly-arrow right-curly-arrow)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:height 200))))
 '(cursor ((t (:background "SlateGray3")))))



;;; Load the config
(org-babel-load-file (concat user-emacs-directory "config.org"))



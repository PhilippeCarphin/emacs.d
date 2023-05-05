;;; Load the config
(org-babel-load-file (concat user-emacs-directory "config.org"))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(magit-save-repository-buffers (quote dontask))
 '(org-show-context-detail (quote ((occur-tree . ancestors) (default . local))))
 '(org-startup-folded t)
 '(package-selected-packages
   (quote
    (command-log-mode keyfreq elfeed magit org-present htmlize ox-reveal ox-twbs ox-rst ox-gfm org-bullets company which-key helm undo-tree use-package)))
 '(vc-follow-symlinks nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(cursor ((t (:background "SlateGray3")))))

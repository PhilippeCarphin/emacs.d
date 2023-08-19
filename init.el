;;; Custom stuff from Emacs this is there to make Emacs put stuff
;;; before loading config.org

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(modus-vivendi))
 '(custom-safe-themes
   '("6dc02f2784b4a49dd5a0e0fd9910ffd28bb03cfebb127a64f9c575d8e3651440" "c7f364aeea0458b6368815558cbf1f54bbdcc1dde8a14b5260eb82b76c0ffc7b" default))
 '(default-frame-alist '((height . 55) (width . 100) (vertical-scroll-bars)))
 '(indent-tabs-mode nil)
 '(magit-save-repository-buffers 'dontask)
 '(org-babel-python-command "python3")
 '(org-show-context-detail '((occur-tree . ancestors) (default . local)))
 '(org-startup-folded t)
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

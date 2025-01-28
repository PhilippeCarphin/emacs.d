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
 '(custom-safe-themes
   '("fc1275617f9c8d1c8351df9667d750a8e3da2658077cfdda2ca281a2ebc914e0" "9b21c848d09ba7df8af217438797336ac99cbbbc87a08dc879e9291673a6a631" "95ee4d370f4b66ff2287d8075f8fe5f58c4a9b9c1e65d663b15174f1a8c57717" default))
 '(default-frame-alist '((height . 55) (width . 100) (vertical-scroll-bars)))
 '(magit-save-repository-buffers 'dontask)
 '(org-agenda-files '("/Users/pcarphin/Documents/gtd/GTD_Habits.org"))
 '(org-babel-python-command "python3")
 '(org-startup-folded t)
 '(visual-line-fringe-indicators '(left-curly-arrow right-curly-arrow)))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:height 150))))
 '(cursor ((t (:background "SlateGray3")))))

;;; Load the config
(org-babel-load-file (concat user-emacs-directory "config.org"))

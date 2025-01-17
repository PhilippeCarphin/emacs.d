(setq debug-on-error t)
;; Remember place like Vim
(save-place-mode)

;; Don't show startup screen when started without arguments
(setq inhibit-startup-screen t)

;; Remember place like Vim
(save-place-mode)

;; Load color theme
(load-theme 'misterioso)

;; Scroll one line at a time
(setq scroll-step 1)

;; Start scrolling 10 lines before the cursor reaches the edge
(setq-default scroll-margin 10)

;; Always open linked file when link points into a repo
(setq vc-follow-symlinks t)

(if (version< emacs-version "28.0")
    (progn (message "OLD EMACS")
	   ;; git@github.com:emacs-helm/helm (checkout v3.9.9)
	   (setq load-path (cons "/home/phc001/.emacs.d/old-packages/helm" load-path))
	   ;; git@github.com:jwiegley/emacs-async (any version)
	   (setq load-path (cons "/home/phc001/.emacs.d/old-packages/emacs-async" load-path))
	   (require 'helm)
	   (require 'helm-mode)
	   (helm-mode)
           (global-set-key (kbd "C-x C-f") 'helm-find-files)
	   )
  (message "RECENT EMACS"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Setup package installer.  This allows us to do `M-x package-install`
;; to install packages in Emacs but also installs the package `use-package`
;; which is handy for configurations.  What it does is that
;;
;;    (use-package <name> :ensure t)
;;
;; will download the package if it is not installed, then `(require _)` it.
;; It does a bit more stuff too.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq debug-on-error t)
(require 'package)
(setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
(add-to-list 'package-archives '("org"   . "http://orgmode.org/elpa/") t)
(add-to-list 'package-archives '("gnu"   . "http://elpa.gnu.org/packages/") t)
(package-initialize)
(unless (package-installed-p 'use-package)
    (setq package-check-signature nil)
    (package-refresh-contents)
    (package-install 'use-package))
    (setq package-check-signature t)
(eval-when-compile (require 'use-package))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Packages
;; Now, packages are signed with a key that is newer than the one that comes
;; with our old version of emacs so we should put use-package commands here
;; if when we try to install a package we get told there is some signature
;; stuff that went wrong.  I set it to nil then back to t for every package
;; just to be super explicit but it turns out that there aren't any packages
;; whose signature can be checked now :(
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq package-check-signature nil)
(use-package which-key :ensure t :delight
  :init
    (setq which-key-separator " ")
    (setq which-key-prefix-prefix "+")
    (setq which-key-idle-delay 0.5)
  :config
    (which-key-mode))

(use-package evil :ensure t
  :init
    (setq evil-want-C-i-jump nil)
    (setq evil-want-integration t)
    (setq evil-want-C-u-scroll t)
  :config
    (evil-mode 1)
    ;; j and k move by visual lines rather than logical lines
    (evil-global-set-key 'motion "j" 'evil-next-visual-line)
    (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

    ;; Since C-g is the universal "cancel" key in emacs, have it take me
    ;; out of insert mode
    (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)

    (setq evil-move-cursor-back nil)

    (setq evil-default-state 'emacs)
    (setq evil-insert-state-modes nil)
    (setq evil-motion-state-modes nil)
    (setq evil-normal-state-modes '(fundamental-mode
                                    conf-mode
                                    prog-mode
                                    text-mode
                                    dired-mode))
    (evil-set-undo-system 'undo-tree))

(use-package undo-tree :ensure t
  :config
    (global-undo-tree-mode))

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
  (progn (use-package helm :ensure t
	   :bind (("M-x" . helm-M-x)
		  ("C-x C-f" . helm-find-files)
		  ("C-x C-r" . helm-recentf)
		  ("C-h C-i" . helm-info)
		  ("C-x C-b" . helm-buffers-list)
		  ("C-c g" . helm-grep-do-git-grep)))
	 (helm-mode) ;; In my main config file, this is outside the 'use-package' but I
	             ;; don't remember why.  I wouldn't have done that without a reason
	 )
  )

(use-package powerline :ensure t
  :config
  (powerline-default-theme))

;; (use-package markdown-mode :ensure t)

;; This may be a waste of time because then we can't run a package-install
;; command without doing first setting this back to nil
(setq package-check-signature t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Basic configs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Remember place like Vim
(save-place-mode)

;; Don't show startup screen when started without arguments
(setq inhibit-startup-screen t)

;; Remember place like Vim
(save-place-mode)

;; Open config file `M-x open-emacs-config-file<ENTER>`
(defun open-emacs-config-file () (interactive) (find-file "~/.emacs.d/init.el"))

;; Load color theme
(load-theme 'misterioso)

;; Centrer le curseur dans l'écran après avoir fait shift-TAB
(advice-add 'org-global-cycle :after #'recenter)
;; Mettre le curseur au début de la ligne après avoir fait shift-TAB
(advice-add 'org-global-cycle :after #'org-beginning-of-line)

;; Scroll one line at a time
(setq scroll-step 1)

;; Start scrolling 10 lines before the cursor reaches the edge
(setq-default scroll-margin 10)

;; Always open linked file when link points into a repo
(setq vc-follow-symlinks t)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (markdown-mode which-key wfnames use-package undo-tree powerline ox-twbs ox-rst ox-reveal ox-gfm magit htmlize evil-escape company clojure-mode async almost-mono-themes))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

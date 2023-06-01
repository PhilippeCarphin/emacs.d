;; Package bootstrapping
(setq debug-on-error t)
(require 'package)
;; Run these three 4 sexpressions to update the gnu keyring
;; (setq package-check-signature nil)
;; (package-refresh-contents)
;; (package-install 'gnu-elpa-keyring-update)
;; (setq package-check-signature t)
(setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
(add-to-list 'package-archives '("org"   . "http://orgmode.org/elpa/") t)
(add-to-list 'package-archives '("gnu"   . "http://elpa.gnu.org/packages/") t)
(package-initialize)
(unless (package-installed-p 'use-package)
    (package-refresh-contents)
    (package-install 'use-package))
(eval-when-compile (require 'use-package))
(setq inhibit-startup-screen t)

;; Define 'leader-key': SPC in normal mode
(define-prefix-command 'leader-key)

;; Remember place like Vim
(save-place-mode)

;; Install and configure 'evil-mode'
;; There is an error Eager macro-expansion failure: (wrong-number-of-arguments (2 . 2) 4)
;; somewhere in here but I don't know where it comes from
(use-package evil :ensure t
  :init
    (setq evil-want-C-i-jump nil)
    (setq evil-want-integration t)
    (setq evil-want-C-u-scroll t)
  :config
    (evil-mode 1)
    (define-key evil-normal-state-map (kbd "SPC") 'leader-key)
    (evil-global-set-key 'motion "j" 'evil-next-visual-line)
    (evil-global-set-key 'motion "k" 'evil-previous-visual-line)
    ;; Because it is a prefix global map, when in normal mode,
    ;; it does all kinds of weird stuff.  I therefore us
    (global-unset-key (kbd "ESC"))
    ;; For some reason ESC seems like it isn't mapped to take me out
    ;; of insert-mode.
    (define-key evil-insert-state-map (kbd "ESC") 'evil-normal-state)
    (define-key evil-visual-state-map (kbd "ESC") 'evil-normal-state)
    (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
    (add-hook 'with-editor-mode-hook 'evil-insert-state)
    (setq evil-default-state 'emacs)
    (setq evil-insert-state-modes nil)
    (setq evil-motion-state-modes nil)
    (setq evil-move-cursor-back nil)
    (setq evil-normal-state-modes '(fundamental-mode
                                    conf-mode
                                    prog-mode
                                    text-mode
                                    dired-mode)))
(use-package evil-escape :ensure t
  :config
    (evil-escape-mode)
    (setq-default evil-escape-key-sequence "jk")
    (setq-default evil-escape-delay 0.3)
    (add-hook 'evil-visual-state-entry-hook (lambda () (evil-escape-mode -1)))
    (add-hook 'evil-visual-state-exit-hook (lambda () (evil-escape-mode t)))
    )

;; Install and configure various useful export backends
(use-package ox-gfm :ensure t)
(use-package ox-rst :ensure t)
(use-package ox-twbs :ensure t)
(use-package ox-reveal :ensure t
  :config (setq org-reveal-root "https://cdn/jsdelivr.net/npm/reveal.js"))
(use-package htmlize :ensure t)
(setq org-export-use-babel nil) ;; disable babel on export

;; Install and configure company autocomplete
(use-package company :ensure t
  :config (global-company-mode)
    (setq company-idle-delay 0))

;; Install and configure helm
(use-package helm :ensure t
  :bind (("M-x" . helm-M-x)
     ("C-x C-f" . helm-find-files)
     ("C-x C-r" . helm-recentf)
     ("C-h C-i" . helm-info)
     ("C-x C-b" . helm-buffers-list)
     ("C-c g" . helm-grep-do-git-grep)))
(helm-mode) ;; In my main config file, this is outside the 'use-package' but I
            ;; don't remember why.  I wouldn't have done that without a reason

;; Install and configure which-key.  This is the popup listing available keys
;; When the popup is up, use ?n ?p to cycle through the pages.
;; unless '?' is bound to something in which case you're out of luck
(use-package which-key :ensure t :delight
  :init
    (setq which-key-separator " ")
    (setq which-key-prefix-prefix "+")
    (setq which-key-idle-delay 0.5)
  :config
    (which-key-mode))

;; Define leader key mappings
(define-key leader-key (kbd "SPC") 'helm-M-x)
;; Files
(defun open-emacs-config-file () (interactive) (find-file "~/.emacs.d/init.el"))
(defun open-master-emacs-config-file () (interactive) (find-file "~/Repositories/github.com/philippecarphin/emacs.d/config.org"))
(define-prefix-command 'files)
(define-key leader-key (kbd "f") 'files)
(define-key files (kbd "c") 'open-emacs-config-file)
(define-key files (kbd "C") 'open-master-emacs-config-file)
(define-key files (kbd "f") 'helm-find-files)
(define-key files (kbd "r") 'helm-recentf)
(define-key files (kbd "s") 'save-buffer)
;; Buffers
(define-prefix-command 'buffers)
(define-key leader-key (kbd "b") 'buffers)
(define-key buffers (kbd "b") 'helm-buffers-list)
(define-key buffers (kbd "k") 'kill-buffer)
;; Others
(define-key leader-key (kbd "q") 'save-buffers-kill-emacs)

;; Scrolling behavior
(setq scroll-step 1) ;; Normal behavior is to jump by half a screen when the
                     ;; cursor reaches the edge which is annoying
(setq-default scroll-margin 10) ;; Same as vim scrolloff setting

;; Auto hard-wrap at 80 chars.  I only use emacs for orgmode and exporting
;; so I always want to have autofill on.
(setq-default auto-fill-function 'do-auto-fill)
(setq-default fill-column 80)

(global-visual-line-mode 1) ;; This should highlight the current line but
                            ;; it doesn't seem do do it.

;; Default theme
(use-package almost-mono-themes :ensure t)
(if (string= (getenv "__editor_grayscale") nil)
  (load-theme 'misterioso)
  (load-theme 'almost-mono-gray))

(setq vc-follow-symlinks t)

;; Center the screen on the cursor after doing shift-tab
(defun org-post-global-cycle () (interactive)
       (recenter)
       (org-beginning-of-line))
(advice-add 'org-global-cycle
	    :after #'org-post-global-cycle)


;; ;; Install and configure magit.  Seems can't install for the following reason:
;; ;; Error (use-package): Failed to install magit: Package 'compat-29.1.3.4' is
;; ;; unavailable
;; ;; Error (use-package): Cannot load magit
;;  (use-package magit
;;    :ensure t
;;    :custom
;;    (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))
   
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("d0fd069415ef23ccc21ccb0e54d93bdbb996a6cce48ffce7f810826bb243502c" default)))
 '(package-selected-packages
   (quote
    (vimrc-mode almost-mono-themes evil-escape evil use-package))))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

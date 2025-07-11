;; Add melpa package repository (mainly for evil)
(message "load-path: '%s'" load-path)
(if (version< emacs-version "28.0")
    (progn (message "OLD EMACS")
	   (setq load-path (cons "/home/phc001/.emacs.d/old-packages/helm" load-path))
	   (setq load-path (cons "/home/phc001/.emacs.d/old-packages/emacs-async" load-path))
	   (require 'helm)
	   (require 'helm-mode)
	   (require 'helm-command)
       (global-set-key (kbd "M-x") 'helm-M-x)
       (global-set-key (kbd "C-x C-f") 'helm-find-files)
       )
    (progn (use-package helm :ensure t
                        :bind (("M-x" . helm-M-x)
                               ("C-x C-f" . helm-find-files)
                               ("C-x C-r" . helm-recentf)
                               ("C-h C-i" . helm-info)
                               ("C-x C-b" . helm-buffers-list)))))

(message "load-path: '%s'" load-path)

(require 'package)
(setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/") t)
;; (setq package-archives '(("melpa" . "http://melpa.org/packages/") ("gnu" . "http://elpa.gnu.org/packages/")))
(message "package-archives: %s" package-archives)
;; Initialize package system
(package-initialize)

;; Install use-package if it is not installed, then load it
(unless (package-installed-p 'use-package)
    (package-refresh-contents)
    (package-install 'use-package))
(eval-when-compile (require 'use-package))

;; Ensure evil mode is installed, load it and configure it
(use-package evil :ensure t
  :init (setq evil-want-C-u-scroll t)
  :config (evil-mode)
          (evil-global-set-key 'motion "j" 'evil-next-visual-line)
	  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)
	  (evil-set-undo-system 'undo-redo))

;; Ensure which-key is installed, load it, and run which-key-mode
(use-package which-key :ensure t
  :config (which-key-mode))

;; Ensure helm is installed and bind some keys to the functions it provides
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (htmlize which-key wfnames use-package gnu-elpa-keyring-update evil))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

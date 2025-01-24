;; Add melpa package repository (mainly for evil)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)

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
(use-package helm :ensure t
  :bind (("M-x" . helm-M-x)
	 ("C-x C-f" . helm-find-files)
	 ("C-x C-r" . helm-recentf)
	 ("C-h C-i" . helm-info)
	 ("C-x C-b" . helm-buffers-list)))

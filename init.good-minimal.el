;; Package bootstrapping
(require 'package)
(package-initialize)
(setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
(add-to-list 'package-archives '("gnu"   . "http://elpa.gnu.org/packages/") t)
(unless (package-installed-p 'use-package)
    (setq package-check-signature nil)
    (package-refresh-contents)
    (package-install 'use-package))
    (setq package-check-signature t)
(eval-when-compile (require 'use-package))

(load-theme 'misterioso)     ;; Load a nicer theme
(save-place-mode)            ;; Remember place like Vim

;; Install and configure 'evil-mode'
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

;; Install and configure helm
(use-package helm :ensure t
  :bind (("M-x" . helm-M-x)
     ("C-x C-f" . helm-find-files)
     ("C-x C-r" . helm-recentf)
     ("C-h C-i" . helm-info)
     ("C-x C-b" . helm-buffers-list)
     ("C-c g" . helm-grep-do-git-grep))
  :config
     (setq helm-move-to-line-cycle-in-source nil))
(helm-mode) ;; In my main config file, this is outside the 'use-package' but I
            ;; don't remember why.  I wouldn't have done that without a reason


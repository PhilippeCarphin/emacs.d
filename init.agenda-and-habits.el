;; Package bootstrapping (not needed for any agenda stuff)
(package-initialize)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-refresh-contents)
(unless (package-installed-p 'use-package)
    (package-install 'use-package))
(eval-when-compile (require 'use-package))

;; Quality of life things not related to any agenda stuff
(load-theme 'misterioso)        ; Load a nicer theme
(save-place-mode)               ; Remember place like Vim
(setq scroll-step 1)            ; Scroll one line at a time (otherwise it centers
                                ; the line containing the cursor when the
                                ; cursor reaches the top which is unpleasant
(setq-default scroll-margin 10) ; Keep start scrolling the view when the cursor
                                ; gets to within 10 lines of the top or bottom.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The only thing required for the agenda: setting org-agenda-files to a list
;; containing either directories or org-mode files
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set the org agenda files list
(setq org-agenda-files '("~/Documents/gtd"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set a global key to bring up the agenda menu
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(global-set-key (kbd "C-c a") 'org-agenda)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Improving the agenda display
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; When inserting tags with =C-c C-q=, make them flush-right on at column 120
;; If you li
(setq org-tags-column -120)

;; Nicer agenda display.  Items with times align well with with the time markers
;; And items with a deadline or scheduled items are aligned vertically with
;; items that don't have a deadline or scheduled date.
(setq org-agenda-prefix-format  '((agenda . "    %-12t%-12s")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Setting up org-habits
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; After package 'org is loaded, run some code to activate org-habit
(use-package org
  :defer t
  :config (add-to-list 'org-modules 'org-habit)
          (org-load-modules-maybe t))

;; The org-agenda-prefix format moves things to the right for alignment
;; This moves the org-habit-graph to the right as well
(setq org-habit-graph-column 50)


(setq org-todo-keywords '((sequence "TODO(t)" "|" "DONE(d)")
			  (sequence "HABIT(h)" "|" "done-habit(x)")))
(setq org-todo-keyword-faces '(("HABIT" :foreground "#7c7c74" :weight bold :underline nil)))
(setq org-log-into-drawer t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Stuff that I need while working on this config
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Install and configure 'evil-mode'
(use-package evil :ensure t
  :init (setq evil-want-C-i-jump nil)
        (setq evil-want-integration t)
        (setq evil-want-C-u-scroll t)
  :config (evil-mode 1)
          (define-key evil-normal-state-map (kbd "SPC") 'leader-key)
          (evil-global-set-key 'motion "j" 'evil-next-visual-line)
          (evil-global-set-key 'motion "k" 'evil-previous-visual-line)
          (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
          (evil-global-set-key 'normal (kbd "M-u") 'universal-argument))

(use-package which-key :ensure t :delight
  :init (setq which-key-separator " ")
        (setq which-key-prefix-prefix "+")
	(setq which-key-idle-delay 0.5)
  :config (which-key-mode))

(use-package ivy :ensure t
  :config (ivy-mode))

;; Install and configure helm
;; (use-package helm :ensure t
;;  :bind (("M-x" . helm-M-x)
;;         ("C-x C-f" . helm-find-files)
;;         ("C-x C-r" . helm-recentf)
;;         ("C-h C-i" . helm-info)
;;         ("C-x C-b" . helm-buffers-list)
;;         ("C-c g" . helm-grep-do-git-grep))
;;  :config (setq helm-move-to-line-cycle-in-source t)
;;          (helm-mode 1))

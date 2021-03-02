(add-hook 'evil-insert-state-exit-hook (lambda () (blink-cursor-mode 0)))
(add-hook 'evil-insert-state-entry-hook (lambda () (blink-cursor-mode 1)))

(blink-cursor-mode 0)

(defun about-this-keymap () (interactive)
  (org-open-link-from-string "[[file:~/.emacs.d/config.org::Helper keymap]]"))

(define-prefix-command 'emacs-movement)
(global-set-key (kbd "C-| m") 'emacs-movement)
(global-set-key (kbd "C-| h") 'about-this-keymap)
(define-key emacs-movement (kbd "C-f") 'forward-char)
(define-key emacs-movement (kbd "C-b") 'backward-char)
(define-key emacs-movement (kbd "C-p") 'previous-line)
(define-key emacs-movement (kbd "C-v") 'scroll-up-command)
(define-key emacs-movement (kbd "M-v") 'scroll-down-command)
(define-key emacs-movement (kbd "C-s") 'isearch-forward)
(define-key emacs-movement (kbd "C-r") 'isearch-backward)
(define-prefix-command 'C-x)
(global-set-key (kbd "C-| C-x") 'C-x)
(define-key C-x (kbd "C-f") 'helm-find-files)
(define-key C-x (kbd "C-r") 'helm-recentf)
(define-key C-x (kbd "C-b") 'helm-buffers-list)
(define-key C-x (kbd "b") 'switch-to-buffer)
(define-key C-x (kbd "C-s") 'save-buffer)
(define-key C-x (kbd "C-c") 'save-buffers-kill-emacs)
(define-key emacs-movement (kbd "C-n") 'next-line)
(define-prefix-command 'C-h)
(global-set-key (kbd "C-| C-h") 'C-h)
(define-key C-h (kbd "C-i") 'helm-info)
(define-key C-h (kbd "o") 'describe-symbol)
(define-key C-h (kbd "f") 'describe-function)
(define-key C-h (kbd "k") 'describe-key)
(define-prefix-command 'orgmode)
(global-set-key (kbd "C-| o") 'orgmode)
(define-key orgmode (kbd "C-c C-,") 'org-insert-structure-template)
(define-key orgmode (kbd "C-c C-c") 'org-ctrl-c-ctrl-c)
(define-key orgmode (kbd "C-c '") 'org-edit-special)
(define-key orgmode (kbd "C-c .") 'org-time-stamp)
(define-key orgmode (kbd "C-c C-s") 'org-schedule)
(define-key orgmode (kbd "C-c C-d") 'org-deadline)
(define-key orgmode (kbd "a") 'org-agenda)
(define-key orgmode (kbd "v") 'org-tags-view)
(define-key orgmode (kbd "C-c /") 'org-match-sparse-tree)
(define-key orgmode (kbd "<M-S-left>") 'org-promote-subtree)
(define-key orgmode (kbd "<M-S-right>") 'org-demote-subtree)
(define-key orgmode (kbd "n") 'org-narrow-to-subtree)
(define-key orgmode (kbd "c") 'org-columns)

(defun org-agenda-help () (interactive)
   (org-open-link-from-string "[[file:~/.emacs.d/config.org::*Orgmode implementation of GTD]]"))
(define-prefix-command 'help-menu)
(global-set-key (kbd "C-~") 'help-menu)
(define-key 'help-menu (kbd "a") 'org-agenda-help)
 (easy-menu-define h-menu global-map
   "Menu for word navigation commands."
   '("PhilHelp"
     ["forward-char" forward-char]
     ["backward-char" forward-char]
     ["next-line" next-line]
     ["previous-line" previous-line]
     ["describe-key" describe-key]
     ["scroll-up-command" scroll-up-command]
     ["scroll-down-command" scroll-down-command]
     ["isearch-forward" isearch-forward]
     ["isearch-backward" isearch-backward]
     ["org-time-stamp" org-time-stamp]
     ["org-promote-subtree" org-promote-subtree]
     ["org-demote-subtree" org-demote-subtree]
     ["org-agenda-help" org-agenda-help]))

(use-package org-bullets
  :ensure t
  :hook (org-mode . org-bullets-mode))

(use-package ox-gfm :ensure t)
(use-package ox-rst :ensure t)
(use-package ox-twbs :ensure t)
(use-package ox-reveal :ensure t
  :config (setq org-reveal-root "https://cdn.jsdelivr.net/npm/reveal.js"))
(use-package htmlize :ensure t)

(org-babel-do-load-languages 'org-babel-load-languages
    '((shell . t)
      (python . t)))

(setq org-agenda-dir "~/Documents/gtd")
(setq org-agenda-files (list org-agenda-dir))

(setq org-refile-targets '((nil :maxlevel . 3) (org-agenda-files :maxlevel . 3)))
(setq org-outline-path-complete-in-steps nil)
(setq org-refile-use-outline-path 'file)

(setq org-capture-templates
  '(("i" "GTD Input" entry (file+headline gtd-in-tray-file "GTD Input Tray")
     "* GTD-IN %?\n %i\n %a" :kill-buffer t)))

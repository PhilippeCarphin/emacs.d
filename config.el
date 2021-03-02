(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
(add-to-list 'package-archives '("org"   . "http://orgmode.org/elpa/") t)
(add-to-list 'package-archives '("gnu"   . "http://elpa.gnu.org/packages/") t)
(package-initialize)

(unless (package-installed-p 'use-package)
    (package-refresh-contents)
    (package-install 'use-package))
(eval-when-compile (require 'use-package))

(setq scroll-step 1)
(setq-default scroll-margin 10)

(setq-default cursor-type '(bar . 3))
(set-cursor-color "light grey")
(custom-set-faces '(cursor ((t (:background "SlateGray3")))))

(load-theme 'misterioso)

(use-package undo-tree
  :ensure t
  :config (global-undo-tree-mode))

(use-package helm :ensure t
  :config
    (require 'helm-config)
  :bind (("M-x" . helm-M-x)
	 ("C-x C-f" . helm-find-files)
	 ("C-x C-r" . helm-recentf)
	 ("C-h C-i" . helm-info)
	 ("C-x C-b" . helm-buffers-list)
	 ("C-c g" . helm-grep-do-git-grep)))

(helm-mode)

(use-package which-key
  :ensure t
  :delight
  :init
  (setq which-key-separator " ")
  (setq which-key-prefix-prefix "+")
  (setq which-key-idle-delay 0.01)
  :config
  (which-key-mode))

(use-package company
  :ensure t
  :config (global-company-mode)
	  (setq company-idle-delay 0))

(use-package evil
  :ensure t
  :init (setq evil-want-C-i-jump nil)
	(setq evil-want-integration t)
	(setq evil-want-C-u-scroll t)
  :config (evil-mode 1)
	  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
	  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
	  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)
	  (setq evil-default-state 'emacs)
	  (setq evil-insert-state-modes nil)
	  (setq evil-motion-state-modes nil)
	  (setq evil-normal-state-modes '(fundamental-mode
					  conf-mode
					  prog-mode
					  text-mode
					  dired))
	  (setq evil-insert-state-cursor '((bar . 2) "lime green")
	      evil-normal-state-cursor '(box "yellow"))
	  (add-hook 'with-editor-mode-hook 'evil-insert-state))

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

(defun ox-reveal () (interactive) (org-reveal-export-to-html-and-browse nil t))
(defun ox-twbs () (interactive) (browse-url (org-twbs-export-to-html nil t)))
(defun ox-twbs-all () (interactive) (browse-url (org-twbs-export-to-html nil nil)))
(defun ox-html () (interactive) (browse-url (org-html-export-to-html nil t)))
(defun ox-html-all () (interactive) (browse-url (org-html-export-to-html nil nil)))
(defun ox-rst () (interactive) (org-open-file (org-rst-export-to-rst nil t)))
(defun ox-rst-all () (interactive) (org-open-file (org-rst-export-to-rst nil nil)))
(easy-menu-define present-menu org-mode-map
  "Menu for word navigation commands."
  '("Present"
    ["Present Right Now (C-c C-e R B)" org-reveal-export-to-html-and-browse]
    ["Present Subtree Right Now (C-c C-e C-s R B)" ox-reveal]
    ["View Twitter Bootstrap HTML Right now (C-c C-e C-s w o)" ox-twbs]
    ["View Twitter Bootstrap HTML all Right now (C-c C-e w o)" ox-twbs-all]
    ["View RST Right Now (C-c C-e C-s r R)" ox-rst]
    ["View RST All Right Now (C-c C-e r R)" ox-rst-all]
    ["View straight-pipe HTML Right Now (C-c C-e C-s h o)" ox-html]
    ["View straight-pipe HTML All Right Now (C-c C-e h o)" ox-html-all]))

(setq org-agenda-dir "~/Documents/gtd")
(setq org-agenda-files (list org-agenda-dir))

(setq org-refile-targets '((nil :maxlevel . 3) (org-agenda-files :maxlevel . 3)))
(setq org-outline-path-complete-in-steps nil)
(setq org-refile-use-outline-path 'file)

(setq org-capture-templates
  '(("i" "GTD Input" entry (file+headline gtd-in-tray-file "GTD Input Tray")
     "* GTD-IN %?\n %i\n %a" :kill-buffer t)))

(defun org-capture-input () (interactive) (org-capture nil "i"))
(global-set-key (kbd "C-c c") 'org-capture-input)

(global-set-key (kbd "C-c a a") 'gtd-agenda-view)
(global-set-key (kbd "C-c a c") 'gtd-review-view)
(global-set-key (kbd "C-c a n") 'gtd-next-action-sparse-tree)

(define-key evil-normal-state-map (kbd "SPC a g") 'gtd)

(add-hook 'org-agenda-mode-hook (lambda ()
(define-key org-agenda-mode-map (kbd "j") (lambda () (interactive)
  (message "- Lamont Cranston: Do you have any idea who you just kidnapped?
- Tulku: Cranston; Lamont Cranston.
- Lamont Cranston: You know my real name?
- Tulku: Yes. I also know that for as long as you can remember,
	 you struggled against your own black heart and always lost. You
	 watched your sprit, your very face change as the beast claws its
	 way out from within you.
j is deactivated
It normally does org-agenda-goto-date")))))
;; Originally org-agenda-capture : I use C-c c and I can't use k
(add-hook 'org-agenda-mode-hook (lambda ()
  (define-key org-agenda-mode-map (kbd "k") (lambda () (interactive)
    (message " The Shadow: I saved your life, Roy Tam. It now belongs to me.
- Dr. Tam: It does?
k is deactivated
It normally does org-agenda-capture (do C-h f to find out what key it is)")))))

(defun org-post-global-cycle () (interactive)
  (recenter)
  (org-beginning-of-line))
(advice-add 'org-global-cycle
  :after #'org-post-global-cycle)

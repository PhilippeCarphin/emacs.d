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

(setq-default auto-fill-function 'do-auto-fill)
(setq-default fill-column 80)

(load-theme 'misterioso)

(custom-set-faces '(default ((t (:height 200)))))

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

(define-key evil-insert-state-map (kbd "C-w") evil-window-map)
(define-key evil-insert-state-map (kbd "C-w /") 'split-window-right)
(define-key evil-insert-state-map (kbd "C-w -") 'split-window-below)

(define-key evil-normal-state-map (kbd "C-r") 'undo-tree-redo)
(define-key evil-normal-state-map (kbd "u") 'undo-tree-undo)

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

(setq org-confirm-babel-evaluate nil)

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

(setq org-startup-with-inline-images t)
(setq org-image-actual-width 100)

(define-prefix-command 'gtd)

;; (global-set-key (kbd "C-c a g") 'gtd)
(define-key gtd (kbd "a") 'org-agenda)
(define-key gtd (kbd "c") 'org-capture)

(cond
((string-equal system-type "windows-nt")
 (progn (setq org-agenda-dir "c:\\Users\\phil1\\Documents\\gtd")))
((string-equal system-type "darwin") ;  macOS
 (progn (setq org-agenda-dir "~/Documents/gtd/")))
((string-equal system-type "gnu/linux")
 (progn (setq org-agenda-dir "~/Documents/gtd/"))))
(setq org-agenda-files (list org-agenda-dir))
(setq gtd-in-tray-file (concat org-agenda-dir "GTD_InTray.org")
    gtd-next-actions-file (concat org-agenda-dir "GTD_NextActions.org")
    gtd-project-list-file (concat org-agenda-dir "GTD_ProjectList.org")
    gtd-reference-file (concat org-agenda-dir "GTD_Reference.org")
    gtd-someday-maybe-file (concat org-agenda-dir "GTD_SomedayMaybe.org")
    gtd-tickler-file (concat org-agenda-dir "GTD_Tickler.org")
    gtd-journal-file (concat org-agenda-dir "GTD_Journal.org"))

(defun gtd-open-in-tray      () (interactive) (find-file gtd-in-tray-file))
(defun gtd-open-project-list () (interactive) (find-file gtd-project-list-file))
(defun gtd-open-reference   () (interactive) (find-file gtd-reference-file))
(defun gtd-open-next-actions () (interactive) (find-file gtd-next-actions-file))
(define-key gtd (kbd "i") 'gtd-open-in-tray)
(define-key gtd (kbd "p") 'gtd-open-project-list)
(define-key gtd (kbd "r") 'gtd-open-reference)
(define-key gtd (kbd "n") 'gtd-open-next-actions)

(setq org-todo-keywords '((sequence "TODO" "WAITING" "VERIFY" "|" "DONE")
			  (sequence
			     "GTD-IN(i)"
			     "GTD-CLARIFY(c)"
			     "GTD-PROJECT(p)"
			     "GTD-SOMEDAY-MAYBE(s)"
			     "GTD-ACTION(a)"
			     "GTD-NEXT-ACTION(n)"
			     "GTD-WAITING(w)"
			     "|"
			     "GTD-REFERENCE(r)"
			     "GTD-DELEGATED(g)"
			     "GTD-DONE(d)")))

(setq org-todo-keyword-faces
   '(("GTD-IN" :foreground "#ff8800" :weight normal :underline t :size small)
     ("GTD-PROJECT" :foreground "#0088ff" :weight bold :underline t)
     ("GTD-ACTION" :foreground "#0088ff" :weight normal :underline nil)
     ("GTD-NEXT-ACTION" :foreground "#0088ff" :weight bold :underline nil)
     ("GTD-WAITING" :foreground "#aaaa00" :weight normal :underline nil)
     ("GTD-REFERENCE" :foreground "#00ff00" :weight normal :underline nil)
     ("GTD-SOMEDAY-MAYBE" :foreground "#7c7c74" :weight normal :underline nil)
     ("GTD-DONE" :foreground "#00ff00" :weight normal :underline nil)))

(setq org-stuck-projects
      '("TODO=\"GTD-PROJECT\"" ;; Search query
	("GTD-NEXT-ACTION")    ;; Not stuck if contains
	()                     ;; Stuck if contains
	""))                   ;; General regex

(setq org-agenda-span 7
      org-agenda-start-on-weekday 0
      org-agenda-start-day "-2d")

(setq org-agenda-custom-commands
      '(("c" "Simple agenda view"
	  ((tags "PRIORITY=\"A\"")
	   (stuck "" )
	   (agenda "")
	   (todo "GTD-ACTION")))
	("g" . "GTD keyword searches searches")
	("gi" todo "GTD-IN")
	("gc" todo "GTD-CLARIFY")
	("ga" todo "GTD-ACTION")
	("gn" todo-tree "GTD-NEXT-ACTION")
	("gp" todo "GTD-PROJECT")))

(defun gtd-agenda-view () (interactive)
  (org-agenda nil "a"))

(defun gtd-review-view () (interactive)
  (org-agenda nil "c"))

(defun gtd-next-action-sparse-tree () (interactive)
  (find-file gtd-project-list-file)
  (org-agenda nil "gn"))

(global-set-key (kbd "C-c a a") 'gtd-agenda-view)
(global-set-key (kbd "C-c a c") 'gtd-review-view)
(global-set-key (kbd "C-c a n") 'gtd-next-action-sparse-tree)

(setq org-log-done 'note)

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

(global-set-key (kbd "C-x C-c") 'save-buffers-kill-emacs)

(defun org-post-global-cycle () (interactive)
  (recenter)
  (org-beginning-of-line))
(advice-add 'org-global-cycle
  :after #'org-post-global-cycle)

(use-package org-roam
:ensure t
:hook (after-init . org-roam-mode)
:custom (org-roam-directory "~/Documents/org-roam/")
:bind (:map org-roam-mode-map
	(("C-c n l" . org-roam)
	 ("C-c n f" . org-roam-find-file)
	 ("C-c n g" . org-roam-graph))
       :map org-mode-map
	(("C-c n i" . org-roam-insert))
	(("C-c n I" . org-roam-insert-immediate))))

(use-package magit
  :ensure t
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(use-package yasnippet-snippets
  :ensure t
  :config (yas-global-mode 1))

;; data is stored in ~/.elfeed
(use-package elfeed :ensure t)
(setq elfeed-feeds
      '(
	;; programming
	("https://news.ycombinator.com/rss" hacker)
	("https://www.heise.de/developer/rss/news-atom.xml" heise)
	("https://www.reddit.com/r/programming.rss" programming)
	("https://www.reddit.com/r/emacs.rss" emacs)

	;; programming languages
	("https://www.reddit.com/r/golang.rss" golang)
	("https://www.reddit.com/r/java.rss" java)
	("https://www.reddit.com/r/javascript.rss" javascript)
	("https://www.reddit.com/r/typescript.rss" typescript)
	("https://www.reddit.com/r/clojure.rss" clojure)
	("https://www.reddit.com/r/python.rss" python)

	;; cloud
	("https://www.reddit.com/r/aws.rss" aws)
	("https://www.reddit.com/r/googlecloud.rss" googlecloud)
	("https://www.reddit.com/r/azure.rss" azure)
	("https://www.reddit.com/r/devops.rss" devops)
	("https://www.reddit.com/r/kubernetes.rss" kubernetes)
))

(setq-default elfeed-search-filter "@2-days-ago +unread")
(setq-default elfeed-search-title-max-width 100)
(setq-default elfeed-search-title-min-width 100)

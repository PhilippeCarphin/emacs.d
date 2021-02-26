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
  :preface (require 'helm-config)
  :config (helm-mode)
  :bind (("M-x" . helm-M-x)
	 ("C-x C-f" . helm-find-files)
	 ("C-x C-r" . helm-recentf)
	 ("C-x C-b" . helm-buffers-list)
	 ("C-c g" . helm-grep-do-git-grep)))

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

(use-package org-bullets
  :ensure t
  :hook (org-mode . org-bullets-mode))

(use-package ox-rst :ensure t)
(use-package ox-twbs :ensure t)
(use-package ox-reveal :ensure t
  :config (setq org-reveal-root "https://cdn.jsdelivr.net/npm/reveal.js"))
(use-package htmlize :ensure t)

(org-babel-do-load-languages 'org-babel-load-languages
    '((shell . t)
      (python . t)))

(setq org-confirm-babel-evaluate nil)

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
          (add-hook 'with-editor-mode-hook 'evil-insert-state))

(define-key evil-insert-state-map (kbd "C-w") evil-window-map)
(define-key evil-insert-state-map (kbd "C-w /") 'split-window-right)
(define-key evil-insert-state-map (kbd "C-w -") 'split-window-below)

(define-key evil-normal-state-map (kbd "C-r") 'undo-tree-redo)
(define-key evil-normal-state-map (kbd "u") 'undo-tree-undo)

(define-prefix-command 'gtd)
(define-key evil-normal-state-map (kbd "SPC a g") 'gtd)
(define-key gtd (kbd "a") 'org-agenda)

(setq org-agenda-dir "~/NDocuments/gtd/")
(setq org-agenda-files '("~/NDocuments/gtd"))
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

(setq org-capture-templates 
  '(("i" "GTD Input" entry (file+headline gtd-in-tray-file "GTD Input Tray")
     "* GTD-IN %?\n %i\n %a" :kill-buffer t)))

(global-set-key (kbd "C-c c") 'org-capture)

(setq org-agenda-span 10
      org-agenda-start-on-weekday nil
      org-agenda-start-day "-3d")

(global-set-key (kbd "C-c a") 'org-agenda)

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

(use-package magit
  :ensure t
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(use-package yasnippet
  :ensure t
  :config (yas-global-mode 1))

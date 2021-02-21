(setq scroll-step 1)
(setq-default scroll-margin 10)

(setq-default auto-fill-function 'do-auto-fill)
(setq-default fill-column 80)

(load-theme 'misterioso)

(use-package undo-tree
  :ensure t
  :config (global-undo-tree-mode))

(use-package helm :ensure t
  :preface (require 'helm-config)
  :config (helm-mode)
  :bind (("M-x" . helm-M-x)
	 ("C-x C-f" . helm-find-files)
	 ("C-x f" . helm-recentf)
	 ("C-c g" . helm-grep-do-git-grep)
	 ("C-x b" . helm-buffers-list)))

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

(custom-set-faces '(default ((t (:height 250)))))

(use-package evil
  :ensure t
  :config (evil-mode))

(define-key evil-insert-state-map (kbd "C-w") evil-window-map)
(define-key evil-insert-state-map (kbd "C-w /") 'split-window-right)
(define-key evil-insert-state-map (kbd "C-w -") 'split-window-below)

(define-key evil-normal-state-map (kbd "C-r") 'undo-tree-redo)
(define-key evil-normal-state-map (kbd "u") 'undo-tree-undo)

(setq org-agenda-dir "~/NDocuments/gtd")
(setq org-agenda-files '("~/NDocuments/gtd"))

(setq org-todo-keywords '((sequence "TODO" "WAITING" "VERIFY" "|" "DONE")
			  (sequence "GTD-IN(i)" "GTD-CLARIFY(c)"
			  "GTD-PROJECT(p)" "GTD-SOMEDAY-MAYBE(s)"
			  "GTD-ACTION(a)" "GTD-NEXT-ACTION(n)" "GTD-WAITING(w)"
			  "|" "GTD-REFERENCE(r)" "GTD-DELEGATED(g)"
			  "GTD-DONE(d)")))

(define-prefix-command 'gtd)
(define-key evil-normal-state-map (kbd "SPC a g") 'gtd)

(defun gtd-open-agenda-file (file)
  (interactive)
  (find-file (concat org-agenda-dir "/" file)))

(define-key gtd (kbd "i") (lambda () (interactive) (gtd-open-agenda-file "GTD_InTray.org")))
(define-key gtd (kbd "p") (lambda () (interactive) (gtd-open-agenda-file "GTD_ProjectList.org")))
(define-key gtd (kbd "r") (lambda () (interactive) (gtd-open-agenda-file "GTD_Reference.org")))
(define-key gtd (kbd "n") (lambda () (interactive) (gtd-open-agenda-file "GTD_NextActions.org")))

(setq org-stuck-projects
      '("TODO=\"GTD-PROJECT\"" ;; Search query
        ("GTD-NEXT-ACTION")    ;; Not stuck if contains
        ()                     ;; Stuck if contains
        ""))                   ;; General regex

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

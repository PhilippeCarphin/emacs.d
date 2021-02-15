(setq scroll-step 1)
(setq-default scroll-margin 10)

(setq-default auto-fill-function 'do-auto-fill)
(setq-default fill-column 80)

(load-theme 'misterioso)

(use-package evil
  :ensure t
  :config (evil-mode))

(define-key evil-insert-state-map (kbd "C-w") evil-window-map)
(define-key evil-insert-state-map (kbd "C-w /") 'split-window-right)
(define-key evil-insert-state-map (kbd "C-w -") 'split-window-below)

(use-package helm
  :ensure t
  :preface (require 'helm-config)
  :config (helm-mode)
  :bind (("M-x" . helm-M-x)
         ("C-x C-f" . helm-find-files)
         ("C-x f" . helm-recentf)
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

(setq org-todo-keywords '((sequence "TODO" "WAITING" "VERIFY" "|" "DONE")
			  (sequence "GTD-IN(i)" "GTD-CLARIFY(c)" "GTD-PROJECT(p)"
				    "GTD-SOMEDAY-MAYBE(s)" "GTD-ACTION(a)" "GTD-NEXT-ACTION(n)"
				    "GTD-WAITING(w)" "|" "GTD-REFERENCE(r)" "GTD-DELEGATED(g)" "GTD-DONE(d)")))

(setq org-agenda-files '("~/Dropbox/Notes/gtd/"))

(global-set-key (kbd "C-c a") 'org-agenda)

(setq org-agenda-span 10
      org-agenda-start-on-weekday nil
      org-agenda-start-day "-3d")

(org-babel-do-load-languages 'org-babel-load-languages
    '((shell . t)
      (python . t)))

(use-package magit
  :ensure t
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

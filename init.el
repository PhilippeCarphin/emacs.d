
;;; =========================== MELPA REGULAR SETUP =============================
;; This is exactly the snippet given at https://melpa.org/#/getting-started
(require 'package)
;; Do C-h o package-enable-at-startup to know what this does
;; the video https://youtu.be/49kBWM3RQQ8?t=354 added this line
(setq package-enable-at-startup nil)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
(package-refresh-contents)

;;; ============================ SCROLLING BEHAVIOR =============================
;; The first command makes the text scroll one line at a time when the cursor hits
;; the top or bottom of the window.  Otherwise the window will jump a whole page
;; when the cursor hits the top or bottom.  Setting this to one makes the second
;; command more relevant.
(setq scroll-step 1)             ;; instead of the default behavior of jumping
(setq-default scroll-margin 10)  ;; Prevent the cursor from getting too close to the edges

;;; ========================== USE PACKAGE ======================================
;; Make sure it is installed
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

;;; ========================== EVIL MODE ========================================
;; This gives emacs vim functionnality.
(unless (package-installed-p 'evil)
  (package-install 'evil))
(require 'evil)
(evil-mode 1)

;; ====================== SIMPLE CONFIGS FROM VANILLAMACS ========================
(setq inhibit-startup-message t) ;; Turn off the welcome screen
(unless (package-installed-p 'spacemacs-theme)
  (package-install 'spacemacs-theme))
(load-theme 'spacemacs-dark)        ;; Set startup theme
;; (electric-pair-mode 1)           ;; Automatic parens pairing
(delete-selection-mode 1)        ;; Typing when you have text selected deletes the selected text
(global-subword-mode 1)          ;; make cursor movement stop in between camelCase words.
(global-hl-line-mode 1)          ;; turn on highlighting current line
(show-paren-mode 1)              ;; Highlight matching parens
(save-place-mode 1)              ;; Remember position in files for when reopening
(display-line-numbers-mode)      ;; Activate display of line numbers
(column-number-mode 1)           ;; Column number in modeline


;;; ====================== WRAPPING BEHAVIOR ========================================
(setq-default auto-fill-function 'do-auto-fill) ;; Automatically hard-wrap everything
(setq-default fill-column 80) ;; Set text width


;;; ============================ HELM FRAMEWORK =====================================
;; Helm for the helm-config package and helm-mode:  This remaps common functionalities
;; lke find-files, buffers-list to other things.
;; The helm-config function remaps a bunch of them and I remap a couple of other ones.
;; Do M-x helm-... to see available helm functions
(unless (package-installed-p 'helm)
  (package-refresh-contents)
  (package-install 'helm))
(require 'helm-config)
(setq helm-completion-style 'fuzzy)
(helm-mode 1)
(global-set-key (kbd "C-x C-f") 'helm-find-files)
(global-set-key (kbd "C-x f") 'helm-recentf)
(global-set-key (kbd "C-x b") 'helm-buffers-list)
(global-set-key (kbd "M-x") 'helm-M-x)

(recentf-mode 1)
(setq-default recent-save-file "~/.emacs.d/recentf")  

;; Popup avec les keybindings disponibles
(use-package which-key
  :ensure t
  :delight
  :init
  (setq which-key-separator " ")
  (setq which-key-prefix-prefix "+")
  :config
  (which-key-mode))

;;; ============================= ORG MODE ==========================================
(unless (package-installed-p 'ox-rst)
  (package-install 'ox-rst))
(require 'ox-rst)

(unless (package-installed-p 'ox-twbs)
  (package-install 'ox-twbs))
(require 'ox-twbs)

(unless (package-installed-p 'ox-reveal)
  (package-install 'ox-reveal))
(use-package ox-reveal
  :ensure ox-reveal)

(unless (package-installed-p 'htmlize)
  (package-install 'htmlize))
(use-package htmlize)

(unless (package-installed-p 'org-bullets)
  (package-install 'org-bullets))
(use-package org-bullets)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

(setq org-todo-keywords '((sequence "TODO" "WAITING" "VERIFY" "|" "DONE")
			  (sequence "GTD-IN(i)" "GTD-CLARIFY(c)" "GTD-PROJECT(p)"
				    "GTD-SOMEDAY-MAYBE(s)" "GTD-ACTION(a)" "GTD-NEXT-ACTION(n)"
				    "GTD-WAITING(w)" "|" "GTD-REFERENCE(r)" "GTD-DELEGATED(g)" "GTD-DONE(d)")))

;; Set C-o in VISUAL MODE to ask for a language and insert #+BEGIN_SRC $lang\n
;; at the start and $+END_SRC at the end.
(defun surround-strings (start end start-string end-string)
  (save-excursion (goto-char end)
                  (insert end-string)
                  (goto-char start)
                  (insert start-string)))
(defun org-make-code-block (lang start end)
  (surround-strings start
                    end
                    (concat "#+BEGIN_SRC " lang "\n")
                    "#+END_SRC\n"))
(defun org-make-code-block-command (lang start end)
  (interactive (list (read-string "Enter a language (default C): " "" nil "c")
                     (region-beginning)
                     (region-end)))
  (org-make-code-block lang start end))
(defun org-set-make-code-block-key ()
  (define-key evil-visual-state-map (kbd "C-o") 'org-make-code-block-command))
;;; =============== ORG AGENDA STUFF ===========================================
;; This function will set C-o to do its thing when in org-mode buffers
(add-hook 'org-mode-hook 'org-set-make-code-block-key)
(setq gtd-directory "~/Dropbox/Notes/gtd/")
(setq gtd-in-tray-file (concat gtd-directory "GTD_InTray.org")
      gtd-next-actions-file (concat gtd-directory "GTD_NextActions.org")
      gtd-project-list-file (concat gtd-directory "GTD_ProjectList.org")
      gtd-reference-file (concat gtd-directory "GTD_Reference.org")
      gtd-someday-maybe-file (concat gtd-directory "GTD_SomedayMaybe.org")
      gtd-tickler-file (concat gtd-directory "GTD_Tickler.org")
      gtd-journal-file (concat gtd-directory "GTD_Journal.org"))
(setq org-agenda-files '("~/Dropbox/Notes/gtd/"))

(global-set-key (kbd "C-c a") 'org-agenda)

(setq org-agenda-span 10
      org-agenda-start-on-weekday nil
      org-agenda-start-day "-3d")

;;; ======================== BABEL ==============================================
;; https://orgmode.org/worg/org-contrib/babel/languages/index.html#configure
;; Activate the list of languages that you want
(unless (package-installed-p 'ob-go)
  (package-install 'ob-go))
(org-babel-do-load-languages 'org-babel-load-languages
    '((shell . t)
      (python . t)
      (go . t)))

;;; ============================= magit =========================================
(unless (package-installed-p 'magit)
  (package-install 'magit))
(use-package magit
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))
;;; ========================= For quick reloading ===============================
(defun reload-user-init-file()
  (interactive)
  (load-file user-init-file))

;;; ============================ WINDOW COMMANDS ================================
(define-key evil-insert-state-map (kbd "C-w") evil-window-map)
(define-key evil-insert-state-map (kbd "C-w /") 'split-window-right)
(define-key evil-insert-state-map (kbd "C-w -") 'split-window-below)

;;; ====== THE FOLLOWING IS GENERATED BY EMACS AND SHOULD NOT BE TOUCHED ========
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("bffa9739ce0752a37d9b1eee78fc00ba159748f50dc328af4be661484848e476" default))
 '(package-selected-packages
   '(magit ob-go org-bullets htmlize ox-reveal ox-twbs ox-rst which-key helm spacemacs-theme evil use-package)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; This file is a minimal reproducer for a problem getting
;; "wrong argument type listp, FUNC"
;; after I experimented with creaing menu bars.
;; Qestion asked on Emacs.StackExchange:
;; https://emacs.stackexchange.com/q/83081/19972

(define-prefix-command 'leader-key)
(define-key global-map (kbd "M-m") 'leader-key)
(define-key leader-key (kbd "f") 'find-file)

;; This line was entered in my config when following
;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Menu-Bar.html
(define-key global-map [menu-bar words] (cons "Words" leader-key))
;; It causes errors when doing '(describe-function FUNC)' with FUNC being
;; a function accessible through the keymap.


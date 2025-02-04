;;; This package is gives emacs functions for interacting with the repos
;;; command.

;;; It provides two sets of things.
;;; 1. Functions to find files from repos
;;; 2. A repos-overview: a buffer for the output.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 1. Generic commands and functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun repos-list-names ()
  (process-lines "repos" "-list-names"))

(defun repos-get-dir (repo-name)
  "Get the directory of a repo"
  (car (process-lines "repos" "-get-dir" repo-name)))

(defun repos-find-files ()
  "Find files from repos using helm."
  (interactive)
  (let ((repo-name (helm-comp-read
                    "Select a repos (fuzzy): "
                    (sort (repos-list-names) 'string<)
                    :fuzzy t)))
    (let ((repo-dir (repos-get-dir repo-name)))
      (helm-find-files-1 (concat repo-dir "/")))))

(defun repos--shell-in-directory (dir name)
  (let ((default-directory dir)
        (cmd (concat "cd " dir (kbd "RET")))
        )
    (message "default-directory: %s" default-directory)
    (with-current-buffer (vterm name)
      (vterm-send-string cmd))))

(defun repos-shell-in-repo (repo-name)
  "Open Vterm shell in repo named `repo-name'.

The Vterm buffer gets the name `Vterm:repo: NAME' where `NAME' is the name of
the repo.  If there is a buffer with this name, simply switch to it."
  (let ((buf (get-buffer (concat "Vterm:repo: " repo-name))))
    (if buf
        (switch-to-buffer buf)
      (let ((repo-dir (repos-get-dir repo-name)))
        ;; (message "repo-directory: %s" (repos-get-dir repo-name))
        (repos--shell-in-directory repo-dir (concat "Vterm:repo: " repo-name))))))

(defun repos-shell () 
  "Open a shell inside a repo selected with `helm-comp-read'."
  (interactive)
  (let ((repo-name (helm-comp-read
                    "Select a repos (fuzzy): "
                    (sort (repos-list-names) 'string<)
                    :fuzzy t)))
    (repos-shell-in-repo repo-name)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Repos Overview
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar repos-buffer nil "The buffer of the repos overview")
(defvar repos-errors nil "The buffer for the STDERR of the repos command")
(defvar repos-command "repos")
(defvar repos-remote-host nil "Host to run repos on")
(defvar repos-remote-command-fmt "/bin/bash -c '%s'" "The command to create a remote command.")
(defvar repos-overview-n-jobs 8 "Number of parallel jobs for the repos process.
Since most of the time is spent in git fetch commands, this number can be high
without taking much processing power.")
(defvar repos-overview-fetch t "Run git fetch for each repo.  If this is on, a
high value of `repos-over-view-n-jobs' like 8 or more is worth it.")
(defvar repos-overview-all t "Show all repos.  Normally repos filters out repos
that
- Are up-to-date with the remote (not ahead or behind)
- No unstaged changes
- No staged changes
- No untracked files
")
(defvar repos-overview-ignore t "Repos that are marked to be ignored are not
show if the only thing that is not 'clean' about them is that we are behind the
remote.

This is so that open-source repos that we don't work on don't needlessly show up
in the overview.

If we do want to see repos that are marked as ignored anyway we can set this to `nil'")

(defun repos--create-base-command ()
  ;; Add-to-list adds to the front
  ;; Also some guy who looks like he gets LISP says add-to-list isn't good
  ;; for building a list the way I want.
  (let ((l (list)))
    (when repos-overview-all (add-to-list 'l "-all"))
    (when repos-overview-n-jobs
      (add-to-list 'l (number-to-string repos-overview-n-jobs))
      (add-to-list 'l "-j"))
    (unless repos-overview-fetch
      (add-to-list 'l "-no-fetch"))
    (add-to-list 'l repos-command)
    l))

(defun repos--create-command ()
  (if repos-remote-host
      (repos--create-command-remote-command)
    (repos--create-base-command)))
(defun repos--create-command-remote-command ()
  (list "ssh"
        repos-remote-host
        (format repos-remote-command-fmt
                (mapconcat
                 'shell-quote-argument
                 (repos--create-base-command)
                 " "))))

(defun create-repos-buffer ()
  "Create the repos buffers and update them"
  (let ((repos-out-buf (generate-new-buffer "repos-out-buf"))
        (repos-err-buf (generate-new-buffer "repos-err-buf"))
        (cur (current-buffer)))
    (setq repos-buffer repos-out-buf)
    (setq repos-errors repos-err-buf)
    (repos--update-buffers repos-buffer repos-errors)))

;; TODO What if this function is called and the buffers
;; have not been created yet?
(defun repos-update ()
  "Update the repos buffer by re-running the repos command"
  (interactive)
  (repos--update-buffers repos-buffer repos-errors))

(defun repos--update-buffers (target-buffer errors-buffer)
  "Internal function to update the buffers"
  (with-current-buffer target-buffer
    (read-only-mode -1)
    (erase-buffer))
  (with-current-buffer errors-buffer
    (erase-buffer))
  (let ((proc (make-process
               :name "REPOS"
               :buffer target-buffer ;; Output goes in here
               :command (repos--create-command)
               :sentinel 'repos-process-sentinel
               :stderr errors-buffer)))
    (message "Constructing repos-buffer")))

  (defun repos-overview ()
    (interactive)
    (if (not (buffer-live-p repos-buffer))
        (create-repos-buffer)
      (view-buffer repos-buffer)
      (message "Repos buffer already exists (run repos-update to update it)")))

(defun repos-process-sentinel
    (x y) ;; Process sentinel requires two arguments
  (interactive) ;; Only interactive for testing
  (with-current-buffer repos-buffer
    (read-only-mode -1)
    (ansi-color-apply-on-region (point-min) (point-max))
    (read-only-mode)
    (beginning-of-buffer)
    (repos-mode))
  (message "Repos buffer ready!"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Repos overview major mode functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defmacro repos-make-buffer-function (n func &rest body)
  "Make a function that operates on the repo on the line containing the cursor"
  `(defun ,n ()
     (interactive)
     (unless (= (line-number-at-pos) 1)
       (save-excursion
         (beginning-of-line)
         (let ((repo-name (thing-at-point 'filename)))
           (message "You have clicked repo: '%s'" repo-name)
           (,func (repos-get-dir repo-name))))))
  )

(repos-make-buffer-function repos-magit-repo-at-point magit-status)
(repos-make-buffer-function repos-dired-repo-at-point dired)

;; (defun repos-magit-repo-at-point ()
;;   (interactive)
;;   (unless (= (line-number-at-pos) 1)
;;     (save-excursion
;;       (beginning-of-line)
;;       (let ((repo-name (thing-at-point 'filename)))
;;         (message "You have clicked repo: '%s'" repo-name)
;;         (magit-status (concat (repos-get-dir repo-name)))))))

;; (defun repos-open-at-point ()
;;   (interactive)
;;   (unless (= (line-number-at-pos) 1)
;;     (save-excursion
;;       (beginning-of-line)
;;       (let ((repo-name (thing-at-point 'filename)))
;;         (message "You have clicked repo: '%s'" repo-name)
;;         (dired (repos-get-dir repo-name))))))

(defun repos-find-files-at-point ()
  (interactive)
  (unless (= (line-number-at-pos) 1)
    (save-excursion
      (beginning-of-line)
      (let ((repo-name (thing-at-point 'filename)))
        (message "You have clicked repo: '%s'" repo-name)
        (helm-find-files-1 (concat (repos-get-dir repo-name) "/"))))))

(defun repos-shell-at-point ()
  "Open Vterm shell in the directory of the repo of the current line in the
repos-overview buffer"
  (interactive)
  (unless (= (line-number-at-pos) 1)
    (save-excursion
      (beginning-of-line)
      (let ((repo-name (thing-at-point 'filename)))
        (message "You have clicked repo: '%s'" repo-name)
        (repos-shell-in-repo repo-name)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Repos overview major mode and keymap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-derived-mode repos-mode special-mode "Repos"
  "This is my major mode"
  :interactive t
  :group 'repos)
(add-hook 'repos-mode-hook (lambda () (toggle-truncate-lines 1)))
(add-hook 'repos-mode-hook (lambda () (visual-line-mode -1)))
(add-hook 'repos-mode-hook (lambda () (hl-line-mode 1)))

(defvar-keymap repos-mode-map
  :doc "Keymap for `repos-mode'."
  :parent nil
  "RET" #'repos-magit-repo-at-point
  "g" #'repos-magit-repo-at-point
  "d" #'repos-dired-repo-at-point
  "f" #'repos-find-files-at-point
  "s" #'repos-shell-at-point
  "q" #'quit-window)

(evil-define-key 'motion repos-mode-map
  (kbd "RET") 'repos-magit-repo-at-point
  (kbd "f") 'repos-find-files-at-point)
(evil-define-key 'normal repos-mode-map
  (kbd "g") 'repos-magit-repo-at-point
  (kbd "d") 'repos-dired-repo-at-point
  (kbd "s") 'repos-shell-at-point
  (kbd "q") 'quit-window)
;; Magit does this, not sure what it does
(add-hook 'repos-mode-hook 'evil-normalize-keymaps)


(provide 'repos)

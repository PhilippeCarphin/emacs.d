;;; This package is gives emacs functions for interacting with the repos
;;; command.
;;; TODO I have a few (let ((rfc repos-config-file)) (erase-buffer) (setq repos-config-file))
;;;      to keep the local value of repos-config-file so I think I should
;;;      probably rethink how all that works so that I don't have to do that.

;;; It provides two sets of things.
;;; 1. Functions to find files from repos
;;; 2. A repos-overview: a buffer for the output.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Configuration variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar repos-buffer nil "The buffer of the repos overview")
(defvar repos-errors nil "The buffer for the STDERR of the repos command")
(defvar repos-buffer-other nil "The buffer of the repos overview other")
(defvar repos-errors-other nil "The buffer for the STDERR of the repos command other")
(defvar repos-command "repos")

(defvar repos-remote-host nil "Host to run repos on.  In contexts with a shared
filesystem where only some nodes have outside internet access, this should be
set to the hostname of such a node.

When this is non-nil, the repos command constructing the repos overview buffer
will be (list \"ssh\" repos-remote-host (format repos-remote-command-fmt ...))

See `repos-remote-command-fmt', `repos-shell-in-repo', and
`repos-local-shell-in-repo'")

(defvar repos-remote-command-fmt "/bin/bash -c '%s'" "When `repos-remote-host'
is not nil, this format string is used to create the command to run on the
remote host.  The value must constain exactly one format specifier which is
where the repos command will be put.")

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
- No untracked files ")

(defvar repos-overview-ignore t "Repos that are marked to be ignored are not
show if the only thing that is not 'clean' about them is that we are behind the
remote.

This is so that open-source repos that we don't work on don't needlessly show up
in the overview.

If we do want to see repos that are marked as ignored anyway we can set this to `nil'")

(defvar repos-shell-send-cd-command nil "Use `vterm-send-string' to send keys to
`cd' to the directory of the repo when creating shells.

The directory is normally set by locally setting `default-directory' before
launching `vterm' but depending on the value ov `vterm-shell' this may not go to
the no have any effect.  For example, if `vterm-shell' has the value `ssh localhost'

If `repos-remote-host' is set to `t', the commands `repos-shell-in-repo*' will
allways send the `cd' command to the shell regardless of the value
`repos-shell-send-cd-command' because doing so is necessary. ")

(defvar-local repos-config-file (expand-file-name "~/.config/repos.yml")
  "The location of the YAML config file for repos")

(defvar repos-bin-path nil
  "Path to the directory containing the repos command.  If non-nil, repos
  commands will be made with `repos-bin-path/repos' instead of simply 'repos'")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Base functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun repos-list-names ()
  "Return a list of repo names"
  (process-lines "repos" "-F" repos-config-file "-list-names"))

(defun repos-get-dir (repo-name)
  "Get the directory of a repo"
  (message "running 'repos -F %s -get-dir %s'" repos-config-file repo-name)
  (car (process-lines "repos" "-F" repos-config-file "-get-dir" repo-name)))

(defun repos-select-repo ()
  (helm-comp-read
   "Select a repos (fuzzy): "
   (sort (repos-list-names) 'string<)
   :fuzzy t))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Shells in repos
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun repos--shell-in-directory (dir name)
  (let ((buf (get-buffer vterm-buffer-name)))
    (if buf
        (switch-to-buffer buf)
      (let ((default-directory dir))
        (message "default-directory: %s" default-directory)
        (if (or repos-remote-host repos-shell-send-cd-command)
            (let ((vterm-shell (concat "ssh " repos-remote-host)))
              (with-current-buffer (vterm name)
                (vterm-send-string
                 (concat "cd " (shell-quote-argument dir) (kbd "RET")))))
          (vterm name))))))

(defun repos-find-files ()
  "Find files from repos using helm."
  (interactive)
  (let ((repo-name (repos-select-repo)))
    (let ((repo-dir (repos-get-dir repo-name)))
      (helm-find-files-1 (concat repo-dir "/")))))

(defun repos-shell-in-repo-select ()
  "Open a shell in a repo selected from the list of repos

See `repos-shell-in-repo'"
  (interactive)
  (repos-shell-in-repo (repos-select-repo)))

(defun repos-local-shell-in-repo-select ()
  "Open a local shell in a repo selected from the list of repos

See `repos-local-shell-in-repo'"
  (interactive)
  (repos-shell-in-repo (repos-select-repo)))

(defun repos-shell-in-repo (repo-name)
  "Open Vterm shell in repo named `repo-name'.

If `repos-remote-host' is a string, then this will be done `vterm-shell' locally
set to \"ssh <repos-remote-host>\" and in that case, `cd <repo-dir>' will be
sent to the shell via `vterm-send-string'."
  (let ((vterm-buffer-name (concat "Vterm:repo: " repo-name)))
    (repos--shell-in-directory (repos-get-dir repo-name) vterm-buffer-name)))

(defun repos-ignore-repo (repo-name)
  "Run the command `repos ignore --name REPO-NAME' for the given repo"
  (let ((exit-code (call-process "repos" nil nil nil "ignore" "--name" repo-name)))
    (if (equal 0 exit-code)
        (message "Set ignore flag to 'true' for repo '%s'" repo-name)
      (message "ERROR: `repos ignore --name %s` returned %d" repo-name exit-code))))

(defun repos-local-shell-in-repo (repo-name)
  "Open a local vterm shell in repo regardless of `repos-remote-host'

See `repos-shell-in-repo'"
  (let ((repos-remote-host nil)
        (vterm-buffer-name (concat "Vterm:repo: " repo-name "<local>")))
    (repos--shell-in-directory (repos-get-dir repo-name) vterm-buffer-name)))
(defun repos-update-repo (repo-name)
  (interactive)
  (message "Repo name: '%s'" repo-name)
  (let ((line (shell-command-to-string (format "repos --name %s" repo-name) )))
    (read-only-mode -1)
    (delete-line)
    (insert line)
    (ansi-color-apply-on-region (point-min) (point-max))
    (read-only-mode)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Creating the repos-overview buffer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Creating the command argument list
(defun repos--create-base-command ()
  ;; This method is suggested by https://stackoverflow.com/a/43211401/5795941
  ;; and shynur who answered my question ;; https://stackoverflow.com/a/43211401/5795941
  (let ((args (list)))
    (if repos-bin-path
        (push (concat repos-bin-path "/repos") args)
      (push repos-command args))
    (when repos-overview-n-jobs
      (push "-j" args)
      (push (number-to-string repos-overview-n-jobs) args))
    (when repos-overview-all
      (push "-all" args))
    (unless repos-overview-ignore
      (push "-noignore" args))
    (unless repos-overview-fetch
      (push "-no-fetch" args))
    (push "-F" args)
    (push (if (boundp 'other-config-file)
              other-config-file
            repos-config-file)
          args)
    (nreverse args)))

(defun repos--create-command ()
  "Create command "
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

;;; Creating and updating the buffer
(defun create-repos-buffer ()
  "Create the repos buffers and update them"
  (let ((repos-out-buf (generate-new-buffer "repos-out-buf"))
        (repos-err-buf (generate-new-buffer "repos-err-buf"))
        (cur (current-buffer)))
    (setq repos-buffer repos-out-buf)
    (setq repos-errors repos-err-buf)
    (repos--update-buffers repos-buffer repos-errors)))

(defun create-repos-buffer-other ()
  "Create the repos buffers and update them"
  (let ((repos-out-buf (generate-new-buffer "repos-out-buf-other"))
        (repos-err-buf (generate-new-buffer "repos-err-buf-other"))
        (cur (current-buffer)))
    (setq repos-buffer-other repos-out-buf)
    (setq repos-errors-other repos-err-buf)
    (repos--update-buffers repos-buffer-other repos-errors-other)))

;; TODO What if this function is called and the buffers
;; have not been created yet?
;; Maybe get rid of this function and just kill all the buffers and restart
(defun repos-update ()
  "Update the repos buffer by re-running the repos command"
  (interactive)
  (repos--update-buffers repos-buffer repos-errors))

(defun repos--update-buffers (target-buffer errors-buffer)
  "Internal function to update the buffers"
  (with-current-buffer target-buffer
    (read-only-mode -1)
    (let ((rfc repos-config-file))
      (erase-buffer)
      (setq repos-config-file rfc))
    (when (boundp 'other-config-file)
      (message "Setting repos-config-file to %s" other-config-file)
      (setq repos-config-file other-config-file)))
  (with-current-buffer errors-buffer
    (erase-buffer))
  (let ((proc (make-process
               :name "REPOS"
               :buffer target-buffer ;; Output goes in here
               :command (repos--create-command)
               :sentinel `(lambda (proc event) (repos-process-sentinel proc event ,target-buffer ,errors-buffer))
               :stderr errors-buffer)))
    (message "Constructing repos-buffer")))

(defun repos-overview ()
  (interactive)
  (if (not (buffer-live-p repos-buffer))
      (create-repos-buffer)
    (view-buffer repos-buffer)
    (message "Repos buffer already exists (run repos-update to update it)"))
  )

(defun repos-overview-other () (interactive)
       (let ((other-config-file (read-file-name
                                 "Select a repos config-file "
                                 (expand-file-name "~/.config/repos/")))
             (repos-overview-fetch nil))
         (if (not (buffer-live-p repos-buffer-other))
             (create-repos-buffer-other)
           (view-buffer repos-buffer-other))))

(defun repos-process-sentinel (proc event-string out err)
  ;; Function that gets run when the process ends
  (interactive) ;; Only interactive for testing
  (message "Repos process ended: %s" event-string)
  ;; I should also check (process-status proc) because this function
  ;; can get called for other things than process ending but in this
  ;; particular case it's the only event that can trigger this function.
  (let ((code (process-exit-status proc)))
    (when (equal code 0)
      (with-current-buffer out
        ;; Activating repos-mode seems to undo the local buffer value
        ;; so I do this let to store the value, then set it after
        ;; enabling repos-mode
        (let ((rcf repos-config-file))
          (read-only-mode -1)
          (ansi-color-apply-on-region (point-min) (point-max))
          (read-only-mode)
          (beginning-of-buffer)
          (repos-mode)
          (setq repos-config-file rcf))
        (message "Repos buffer ready!")))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Repos overview major mode functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defmacro repos-make-buffer-function (n func name-or-dir &rest body)
  "Create a function that operates on the repo on current line in the
`repos-overview' buffer.  Set `name-or-dir' to `:dir' if the function should
receive the repo's directory or `:name' if it should receive the repo name."
  `(defun ,n ()
     ,(format "Run `%s' in repo on the current line in the `repos-overview'
     buffer.

See `%s'" (symbol-name func) (symbol-name func))
     (interactive)
     (unless (= (line-number-at-pos) 1)
       (save-excursion
         (beginning-of-line)
         (let ((repo-name (thing-at-point 'filename)))
           (message "You have clicked repo: '%s'" repo-name)
           ,(if (equal name-or-dir :dir)
                ;; We ensure a '/' after the directory for helm-find-files-1
                ;; and it doesn't make a difference for other functions.
                `(,func (concat (repos-get-dir repo-name) "/"))
              `(,func repo-name))))))
  )

(repos-make-buffer-function repos-magit-in-repo-at-point magit-status :dir)
(repos-make-buffer-function repos-dired-in-repo-at-point dired :dir)
(repos-make-buffer-function repos-shell-in-repo-at-point repos-shell-in-repo :name)
(repos-make-buffer-function repos-ignore-repo-at-point repos-ignore-repo :name)
(repos-make-buffer-function repos-local-shell-in-repo-at-point repos-local-shell-in-repo :name)
(repos-make-buffer-function repos-find-files-in-repo-at-point helm-find-files-1 :dir)
(repos-make-buffer-function repos-update-repo-at-point repos-update-repo :name)

(defun repos-update-current-buffer ()
  ;; TODO Should definitely setup a buffer-local update function
  (interactive)
  (let ((buf-name (buffer-name (current-buffer))))
    (cond
     ((string-equal buf-name "repos-out-buf")
      (repos--update-buffers repos-buffer repos-errors))
     ((string-equal buf-name "repos-out-buf-other")
      (repos--update-buffers repos-buffer-other repos-errors-other)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions that exist just for the keymap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun repos-switch-to-buffer () (interactive)
       (switch-to-buffer repos-buffer))

(defun repos-switch-to-errors () (interactive)
       (switch-to-buffer repos-errors))

(defun repos-switch-to-buffer-other () (interactive)
       (switch-to-buffer repos-buffer-other))

(defun repos-switch-to-errors-other () (interactive)
       (view-buffer repos-errors-other))

(defun repos-kill-buffers () (interactive)
       (when repos-buffer
         (kill-buffer repos-buffer))
       (when repos-errors
         (kill-buffer repos-errors))
       (message "Killed other repos buffer and error buffer"))

(defun repos-kill-buffers-other () (interactive)
       (when repos-buffer-other
         (kill-buffer repos-buffer-other))
       (when repos-errors-other
         (kill-buffer repos-errors-other))
       (message "Killed repos buffer and error buffer"))

(defun repos-toggle-overview-all () (interactive)
       (setq repos-overview-all (not repos-overview-all)))

(defun repos-toggle-overview-ignore () (interactive)
       (setq repos-overview-ignore (not repos-overview-ignore)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Repos overview major mode and keymap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-derived-mode repos-mode special-mode "Repos"
  ;; TODO Setup buffer-local variables.  The documentation
  ;; [[info:elisp#Major Mode Conventions][elisp#Major Mode Conventions]]
  ;; says that major modes should clear buffer-local variables
  ;; and that define-derived-mode makes the created mode do this.
  ;; This is why I have to do my silly thing with the buffer local
  ;; variables.  For sure there is a better way.
  "This is my major mode"
  :interactive t
  :group 'repos)
(add-hook 'repos-mode-hook (lambda () (toggle-truncate-lines 1)))
(add-hook 'repos-mode-hook (lambda () (visual-line-mode -1)))
(add-hook 'repos-mode-hook (lambda () (hl-line-mode 1)))

(defvar-keymap repos-mode-map
  :doc "Keymap for `repos-mode'."
  :parent nil
  "RET" #'repos-magit-in-repo-at-point
  "g" #'repos-magit-in-repo-at-point
  "d" #'repos-dired-in-repo-at-point
  "f" #'repos-find-files-in-repo-at-point
  "s" #'repos-shell-in-repo-at-point
  "l" #'repos-local-shell-in-repo-at-point
  "u" #'repos-update-current-buffer
  "q" #'quit-window)

(evil-define-key 'motion repos-mode-map
  (kbd "RET") 'repos-magit-in-repo-at-point
  (kbd "f") 'repos-find-files-in-repo-at-point)
(evil-define-key 'normal repos-mode-map
  (kbd "U") 'repos-update-current-buffer
  (kbd "g") 'repos-magit-in-repo-at-point
  (kbd "d") 'repos-dired-in-repo-at-point
  (kbd "s") 'repos-shell-in-repo-at-point
  (kbd "l") 'repos-local-shell-in-repo-at-point
  (kbd "i") 'repos-ignore-repo-at-point
  (kbd "u") 'repos-update-repo-at-point
  (kbd "q") 'quit-window)
;; Magit does this, not sure what it does
(add-hook 'repos-mode-hook 'evil-normalize-keymaps)

;; Using 'repos-map' instead of 'repos' because I used I made a typo
;; "(substring repos a b)" where 'repo' was a local argument of my function.
;; The added 's' caused errors that were less than obvious.  With the debugger
;; it was easy but could have been even easier if it had just told me "repos"
;; was undefined.
(define-prefix-command 'repos-map)
(define-key repos-map (kbd "r") 'repos-overview)
(define-key repos-map (kbd "R") 'repos-overview-other)
(define-key repos-map (kbd "o") 'repos-switch-to-buffer)
(define-key repos-map (kbd "e") 'repos-switch-to-errors)
(define-key repos-map (kbd "O") 'repos-switch-to-buffer-other)
(define-key repos-map (kbd "E") 'repos-switch-to-errors-other)
(define-key repos-map (kbd "k") 'repos-kill-buffers)
(define-key repos-map (kbd "K") 'repos-kill-buffers-other)
(define-key repos-map (kbd "a") 'repos-toggle-overview-all)
(define-key repos-map (kbd "i") 'repos-toggle-overview-ignore)
(define-key repos-map (kbd "f") 'repos-find-files)
(define-key repos-map (kbd "s") 'repos-shell-in-repo-select)
(define-key repos-map (kbd "l") 'repos-local-shell-in-repo-select)

(provide 'repos)

